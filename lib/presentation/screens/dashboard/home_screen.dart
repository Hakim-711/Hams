import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:hams/core/network/api_service.dart';
import 'package:hams/data/local/models/room_model.dart';
import 'package:hams/domain/entities/room_entity.dart';
import 'package:hams/presentation/blocs/auth/auth_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_event.dart';
import 'package:hams/presentation/blocs/auth/auth_state.dart';
import 'package:hams/presentation/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _timeFormat = DateFormat('hh:mm a');
  final DateFormat _dateFormat = DateFormat('d MMM');

  List<RoomEntity> _conversations = const [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _logout() {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  Future<void> _loadConversations({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() => _isRefreshing = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final rooms = await _fetchDirectRooms();
      if (!mounted) return;
      setState(() {
        _conversations = rooms;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'تعذر تحميل المحادثات: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<List<RoomEntity>> _fetchDirectRooms() async {
    Future<List<Map<String, dynamic>>> load(String endpoint) =>
        ApiService.getList(endpoint);

    List<Map<String, dynamic>> raw;
    try {
      raw = await load('rooms/direct');
    } catch (_) {
      raw = await load('rooms');
    }

    final entities = raw
        .map(RoomModel.fromJson)
        .map((model) => model.toEntity())
        .where((room) => room.participants.length <= 2)
        .toList(growable: false);

    entities.sort((a, b) {
      final aTime = a.lastMessageAt ?? a.createdAt;
      final bTime = b.lastMessageAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return entities;
  }

  List<RoomEntity> get _filteredConversations {
    final query = _searchController.text.trim();
    if (query.isEmpty) return _conversations;
    final normalized = query.toLowerCase();
    return _conversations.where((room) {
      final peerName = (room.peerUsername ?? room.title).toLowerCase();
      final peerId = (room.peerId ?? '').toLowerCase();
      return peerName.contains(normalized) || peerId.contains(normalized);
    }).toList(growable: false);
  }

  String _formatTimestamp(RoomEntity room) {
    final time = room.lastMessageAt ?? room.createdAt;
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return _timeFormat.format(time);
    }
    return _dateFormat.format(time);
  }

  ImageProvider _resolveUserAvatar(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/user_placeholder.png');
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/user_placeholder.png');
  }

  ImageProvider _resolvePeerAvatar(RoomEntity room) {
    final avatar = room.peerAvatarUrl;
    if (avatar == null || avatar.isEmpty) {
      return const AssetImage('assets/user_placeholder.png');
    }
    if (avatar.startsWith('http')) {
      return NetworkImage(avatar);
    }
    final file = File(avatar);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/user_placeholder.png');
  }

  void _openChat(RoomEntity room) {
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: room,
    ).then((_) => _loadConversations(isRefresh: true));
  }

  Future<void> _onRefresh() => _loadConversations(isRefresh: true);

  void _openFriends() {
    Navigator.pushNamed(context, AppRoutes.friends).then(
      (_) => _loadConversations(isRefresh: true),
    );
  }

  void _openSettings() {
    Navigator.pushNamed(context, AppRoutes.generalSettings);
  }

  void _openProfile() {
    Navigator.pushNamed(context, AppRoutes.userProfile);
  }

  CupertinoSliverNavigationBar _buildNavigationBar(AuthAuthenticated state) {
    final user = state.user;
    final displayName = user.username.isNotEmpty ? user.username : 'صديق جديد';
    final tag = user.userId.isNotEmpty ? '#${user.userId}' : '';

    return CupertinoSliverNavigationBar(
      largeTitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(displayName),
          if (tag.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ),
        ],
      ),
      middle: const Text('الهمسات'),
      leading: GestureDetector(
        onTap: _openProfile,
        child: CircleAvatar(
          radius: 22,
          backgroundImage: _resolveUserAvatar(user.profileImagePath),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavIconButton(
            icon: CupertinoIcons.person_add,
            onPressed: _openFriends,
          ),
          const SizedBox(width: 6),
          _NavIconButton(
            icon: CupertinoIcons.settings,
            onPressed: _openSettings,
          ),
          const SizedBox(width: 6),
          _NavIconButton(
            icon: CupertinoIcons.square_arrow_right,
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      stretch: true,
      border:
          const Border(bottom: BorderSide(color: CupertinoColors.separator)),
    );
  }

  Widget _buildSearchAndActions() {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoSearchTextField(
            controller: _searchController,
            placeholder: 'ابحث عن صديق أو همسة',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickActionChip(
                icon: CupertinoIcons.chat_bubble_text,
                label: 'همسة جديدة',
                onTap: _openFriends,
              ),
              _QuickActionChip(
                icon: CupertinoIcons.star,
                label: 'الأصدقاء المفضلون',
                onTap: _openFriends,
              ),
              _QuickActionChip(
                icon: CupertinoIcons.bell,
                label: 'تنبيهات',
                onTap: _openSettings,
              ),
            ],
          ),
          if (_conversations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 6),
              child: Text(
                'المحادثات الأخيرة',
                style: textTheme.textStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 14,
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _loadConversations,
              child: const Icon(
                CupertinoIcons.refresh,
                color: CupertinoColors.systemRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.bubble_left_bubble_right_fill,
              size: 64,
              color: CupertinoColors.inactiveGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد محادثات بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ همسة جديدة مع أصدقائك الآن.',
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: _openFriends,
              child: const Text('بدء محادثة'),
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildConversationsList() {
    final items = _filteredConversations;
    final textTheme = CupertinoTheme.of(context).textTheme;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final room = items[index];
          final timestamp = _formatTimestamp(room);
          final unread = room.unreadCount;
          final subtitle = room.lastMessage?.isNotEmpty == true
              ? room.lastMessage!
              : 'ابدأوا المحادثة الآن';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: GestureDetector(
              onTap: () => _openChat(room),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: _resolvePeerAvatar(room),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  room.peerUsername?.isNotEmpty == true
                                      ? room.peerUsername!
                                      : room.title,
                                  style: textTheme.textStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                timestamp,
                                style: textTheme.textStyle.copyWith(
                                  fontSize: 12,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subtitle,
                                  style: textTheme.textStyle.copyWith(
                                    fontSize: 14,
                                    color: CupertinoColors.tertiaryLabel,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (unread > 0)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.activeBlue,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    unread.toString(),
                                    style: textTheme.textStyle.copyWith(
                                      color: CupertinoColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.chevron_back,
                      size: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.LoginRegisterScreens,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const CupertinoPageScaffold(
              backgroundColor: CupertinoColors.systemGroupedBackground,
              child: Center(child: CupertinoActivityIndicator()),
            );
          }

          if (state is! AuthAuthenticated) {
            return const CupertinoPageScaffold(
              backgroundColor: CupertinoColors.systemGroupedBackground,
              child: Center(
                child: Text('لا توجد جلسة مستخدم نشطة'),
              ),
            );
          }

          final media = MediaQuery.of(context);
          final bottomInset = media.padding.bottom;

          final List<Widget> slivers = [
            _buildNavigationBar(state),
            CupertinoSliverRefreshControl(onRefresh: _onRefresh),
            SliverToBoxAdapter(child: _buildSearchAndActions()),
            if (_errorMessage != null)
              SliverToBoxAdapter(child: _buildErrorBanner()),
          ];

          if (_isLoading && !_isRefreshing) {
            slivers.add(
              const SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator()),
              ),
            );
          } else if (_filteredConversations.isEmpty) {
            slivers.add(_buildEmptyState());
          } else {
            slivers
              ..add(_buildConversationsList())
              ..add(
                SliverToBoxAdapter(
                  child: SizedBox(height: bottomInset + 32),
                ),
              );
          }

          return CupertinoPageScaffold(
            backgroundColor: CupertinoColors.systemGroupedBackground,
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: slivers,
                ),
                Positioned(
                  right: 20,
                  bottom: bottomInset > 0 ? bottomInset : 20,
                  child: _FloatingNewMessageButton(onPressed: _openFriends),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 32,
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 20,
        color: CupertinoColors.activeBlue,
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CupertinoColors.separator),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: CupertinoColors.activeBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.textStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNewMessageButton extends StatelessWidget {
  const _FloatingNewMessageButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              CupertinoIcons.plus_bubble,
              color: CupertinoColors.white,
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              'همسة جديدة',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
