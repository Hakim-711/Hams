// 📁 lib/presentation/screens/splash/splash_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hams/presentation/blocs/auth/auth_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  final List<Star> _stars = List.generate(
    100,
    (i) {
      final rand = math.Random();
      return Star(
        offset: Offset(rand.nextDouble() * 400, rand.nextDouble() * 800),
        size: rand.nextDouble() * 1.8 + 0.8,
        speed: rand.nextDouble() * 0.6 + 0.2,
      );
    },
  );

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckSession());

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmer(Widget child) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Colors.white38, Colors.white, Colors.white38],
          stops: [0.2, 0.5, 0.8],
          begin: Alignment(-1, -0.3),
          end: Alignment(1, 0.3),
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }

  Widget _glassEffect({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: Colors.white.withOpacity(0.05),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 183, 183),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF0f0f1a),
                      Color.fromARGB(255, 4, 1, 0),
                      Color.fromARGB(255, 0, 4, 10),
                    ],
                    stops: [
                      0,
                      0.5 + 0.2 * math.sin(_controller.value * 2 * math.pi),
                      0.8,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(
                painter: StarPainter(_stars, _controller.value),
              );
            },
          ),
          Positioned.fill(
            child: _glassEffect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return CustomPaint(
                    painter: WavePainter(_stars, _controller.value),
                  );
                },
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.12),
                            blurRadius: 50,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/logo3.svg',
                        height: 120,
                        width: 120,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _shimmer(
                      const Text(
                        'همس',
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 12,
                              color: Colors.white30,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'تواصل بلا ضجيج... فقط همس',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'SFPro',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Star {
  final Offset offset;
  final double size;
  final double speed;

  Star({required this.offset, required this.size, required this.speed});
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final paint = Paint()..color = Colors.white10;
    for (final star in stars) {
      final dx = star.offset.dx +
          20 * math.sin(animationValue * 2 * math.pi * star.speed);
      final dy = star.offset.dy +
          10 * math.cos(animationValue * 2 * math.pi * star.speed);
      final x = dx % size.width;
      final y = dy % size.height;
      canvas.drawCircle(Offset(x, y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  WavePainter(this.stars, this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final paint = Paint()..color = Colors.white10;
    for (final star in stars) {
      final dx = star.offset.dx +
          20 * math.sin(animationValue * 2 * math.pi * star.speed);
      final dy = star.offset.dy +
          10 * math.cos(animationValue * 2 * math.pi * star.speed);
      final x = dx % size.width;
      final y = dy % size.height;
      canvas.drawCircle(Offset(x, y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
