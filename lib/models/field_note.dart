import 'note_status.dart';

class FieldNote {
  final String uuid;
  final String siteUuid;
  final String title;
  final String? description;
  final String? location;
  final DateTime dateTime;
  final NoteStatus status;
  final String? photoUrl;
  final DateTime updatedAt;
  final bool deleted;
  final bool syncPending;

final String? siteName;
  final String? customerName;
  final String? customerUuid;

  FieldNote({
    required this.uuid,
    required this.siteUuid,
    required this.title,
    this.description,
    this.location,
    DateTime? dateTime,
    this.status = NoteStatus.open,
    this.photoUrl,
    DateTime? updatedAt,
    this.deleted = false,
    this.syncPending = false,
    this.siteName,
    this.customerName,
    this.customerUuid,
  })  : dateTime = dateTime ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  FieldNote copyWith({
    String? uuid,
    String? siteUuid,
    String? title,
    String? description,
    String? location,
    DateTime? dateTime,
    NoteStatus? status,
    String? photoUrl,
    DateTime? updatedAt,
    bool? deleted,
    bool? syncPending,
    String? siteName,
    String? customerName,
    String? customerUuid,
  }) {
    return FieldNote(
      uuid: uuid ?? this.uuid,
      siteUuid: siteUuid ?? this.siteUuid,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncPending: syncPending ?? this.syncPending,
      siteName: siteName ?? this.siteName,
      customerName: customerName ?? this.customerName,
      customerUuid: customerUuid ?? this.customerUuid,
    );
  }

  factory FieldNote.fromJson(Map<String, dynamic> json) {
    return FieldNote(
      uuid: json['uuid'] as String,
      siteUuid: json['siteUuid'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String).toUtc()
          : DateTime.now().toUtc(),
      status: NoteStatus.fromServer(json['status'] as String?),
      photoUrl: json['photoUrl'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String).toUtc()
          : DateTime.now().toUtc(),
      deleted: json['deleted'] as bool? ?? false,
      syncPending: false,
      siteName: json['siteName'] as String?,
      customerName: json['customerName'] as String?,
      customerUuid: json['customerUuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'siteUuid': siteUuid,
    'title': title,
    'description': description,
    'location': location,
    'dateTime': dateTime.toIso8601String(),
    'status': status.toServer(),
    'photoUrl': photoUrl,
    'updatedAt': updatedAt.toIso8601String(),
    'deleted': deleted,
  };

  factory FieldNote.fromMap(Map<String, dynamic> map) {
    return FieldNote(
      uuid: map['uuid'] as String,
      siteUuid: map['site_uuid'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      location: map['location'] as String?,
      dateTime: DateTime.parse(map['date_time'] as String).toUtc(),
      status: NoteStatus.fromServer(map['status'] as String?),
      photoUrl: map['photo_url'] as String?,
      updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
      deleted: (map['deleted'] as int) == 1,
      syncPending: (map['sync_pending'] as int) == 1,
      siteName: map['site_name'] as String?,
      customerName: map['customer_name'] as String?,
      customerUuid: map['customer_uuid'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'site_uuid': siteUuid,
    'title': title,
    'description': description,
    'location': location,
    'date_time': dateTime.toIso8601String(),
    'status': status.toServer(),
    'photo_url': photoUrl,
    'updated_at': updatedAt.toIso8601String(),
    'deleted': deleted ? 1 : 0,
    'sync_pending': syncPending ? 1 : 0,
  };
}
