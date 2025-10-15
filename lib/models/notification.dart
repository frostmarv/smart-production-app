class NotificationModel {
  final String id;
  final String title;
  final String message;
  final List<String> recipientDepartments; // Ganti dari recipientRoles
  final String type;
  final String? link;
  final bool readStatus;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.recipientDepartments, // Ganti dari recipientRoles
    required this.type,
    this.link,
    required this.readStatus,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      recipientDepartments: List<String>.from(json['recipientDepartments']), // Ganti dari recipientRoles
      type: json['type'],
      link: json['link'],
      readStatus: json['readStatus'] ?? false,
      relatedEntityType: json['relatedEntityType'],
      relatedEntityId: json['relatedEntityId'],
      timestamp: DateTime.parse(json['timestamp']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'recipientDepartments': recipientDepartments, // Ganti dari recipientRoles
      'type': type,
      'link': link,
      'readStatus': readStatus,
      'relatedEntityType': relatedEntityType,
      'relatedEntityId': relatedEntityId,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    List<String>? recipientDepartments, // Ganti dari recipientRoles
    String? type,
    String? link,
    bool? readStatus,
    String? relatedEntityType,
    String? relatedEntityId,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      recipientDepartments: recipientDepartments ?? this.recipientDepartments, // Ganti dari recipientRoles
      type: type ?? this.type,
      link: link ?? this.link,
      readStatus: readStatus ?? this.readStatus,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}