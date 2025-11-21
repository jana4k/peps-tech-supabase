class AccessLog {
  final int id;
  final String? tagId;
  final String? name;
  final String? company;
  final String? floor;
  final DateTime createdAt;

  AccessLog({
    required this.id,
    this.tagId,
    this.name,
    this.company,
    this.floor,
    required this.createdAt,
  });

  factory AccessLog.fromJson(Map<String, dynamic> json) {
    return AccessLog(
      id: json['id'] as int,
      tagId: json['tag_id'] as String?,
      name: json['name'] as String?,
      company: json['company'] as String?,
      floor: json['floor'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag_id': tagId,
      'name': name,
      'company': company,
      'floor': floor,
      'created_at': createdAt.toIso8601String(),
    };
  }
}