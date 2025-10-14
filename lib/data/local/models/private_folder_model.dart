class PrivateFolderModel {
  final int? id;
  final String title;
  final List<String> userIds;
  final DateTime createdAt;

  PrivateFolderModel({
    this.id,
    required this.title,
    required this.userIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'userIds': userIds.join(','),
        'createdAt': createdAt.toIso8601String(),
      };

  factory PrivateFolderModel.fromMap(Map<String, dynamic> map) =>
      PrivateFolderModel(
        id: map['id'],
        title: map['title'],
        userIds: (map['userIds'] as String).split(','),
        createdAt: DateTime.parse(map['createdAt']),
      );
}
