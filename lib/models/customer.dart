class Customer {
  final String uuid;
  final String name;
  final String? contactInfo;
  final DateTime updatedAt;
  final bool deleted;
  final bool syncPending;

  Customer({
    required this.uuid,
    required this.name,
    this.contactInfo,
    DateTime? updatedAt,
    this.deleted = false,
    this.syncPending = false,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc();

  Customer copyWith({
    String? uuid,
    String? name,
    String? contactInfo,
    DateTime? updatedAt,
    bool? deleted,
    bool? syncPending,
  }) {
    return Customer(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      contactInfo: contactInfo ?? this.contactInfo,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncPending: syncPending ?? this.syncPending,
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      contactInfo: json['contactInfo'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String).toUtc()
          : DateTime.now().toUtc(),
      deleted: json['deleted'] as bool? ?? false,
      syncPending: false,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'contactInfo': contactInfo,
    'updatedAt': updatedAt.toIso8601String(),
    'deleted': deleted,
  };

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      contactInfo: map['contact_info'] as String?,
      updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
      deleted: (map['deleted'] as int) == 1,
      syncPending: (map['sync_pending'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'name': name,
    'contact_info': contactInfo,
    'updated_at': updatedAt.toIso8601String(),
    'deleted': deleted ? 1 : 0,
    'sync_pending': syncPending ? 1 : 0,
  };
}
