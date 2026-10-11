class Site {
  final String uuid;
  final String customerUuid;
  final String siteName;
  final String? address;
  final DateTime updatedAt;
  final bool deleted;
  final bool syncPending;

  Site({
    required this.uuid,
    required this.customerUuid,
    required this.siteName,
    this.address,
    DateTime? updatedAt,
    this.deleted = false,
    this.syncPending = false,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc();

  Site copyWith({
    String? uuid,
    String? customerUuid,
    String? siteName,
    String? address,
    DateTime? updatedAt,
    bool? deleted,
    bool? syncPending,
  }) {
    return Site(
      uuid: uuid ?? this.uuid,
      customerUuid: customerUuid ?? this.customerUuid,
      siteName: siteName ?? this.siteName,
      address: address ?? this.address,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncPending: syncPending ?? this.syncPending,
    );
  }

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      uuid: json['uuid'] as String,
      customerUuid: json['customerUuid'] as String,
      siteName: json['siteName'] as String,
      address: json['address'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String).toUtc()
          : DateTime.now().toUtc(),
      deleted: json['deleted'] as bool? ?? false,
      syncPending: false,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'customerUuid': customerUuid,
    'siteName': siteName,
    'address': address,
    'updatedAt': updatedAt.toIso8601String(),
    'deleted': deleted,
  };

  factory Site.fromMap(Map<String, dynamic> map) {
    return Site(
      uuid: map['uuid'] as String,
      customerUuid: map['customer_uuid'] as String,
      siteName: map['site_name'] as String,
      address: map['address'] as String?,
      updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
      deleted: (map['deleted'] as int) == 1,
      syncPending: (map['sync_pending'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'customer_uuid': customerUuid,
    'site_name': siteName,
    'address': address,
    'updated_at': updatedAt.toIso8601String(),
    'deleted': deleted ? 1 : 0,
    'sync_pending': syncPending ? 1 : 0,
  };
}
