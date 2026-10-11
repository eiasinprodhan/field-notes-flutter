import 'customer.dart';
import 'site.dart';
import 'field_note.dart';

class SyncPushRequest {
  final List<Customer> customers;
  final List<Site> sites;
  final List<FieldNote> notes;

  SyncPushRequest({
    required this.customers,
    required this.sites,
    required this.notes,
  });

  bool get isEmpty => customers.isEmpty && sites.isEmpty && notes.isEmpty;

  Map<String, dynamic> toJson() => {
    'customers': customers.map((c) => c.toJson()).toList(),
    'sites': sites.map((s) => s.toJson()).toList(),
    'notes': notes.map((n) => n.toJson()).toList(),
  };
}

class SyncPullResponse {
  final String serverTime;
  final List<Customer> customers;
  final List<Site> sites;
  final List<FieldNote> notes;

  SyncPullResponse({
    required this.serverTime,
    required this.customers,
    required this.sites,
    required this.notes,
  });

  factory SyncPullResponse.fromJson(Map<String, dynamic> json) {
    final customersList = (json['customers'] as List<dynamic>? ?? [])
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
    final sitesList = (json['sites'] as List<dynamic>? ?? [])
        .map((e) => Site.fromJson(e as Map<String, dynamic>))
        .toList();
    final notesList = (json['notes'] as List<dynamic>? ?? [])
        .map((e) => FieldNote.fromJson(e as Map<String, dynamic>))
        .toList();

    return SyncPullResponse(
      serverTime: json['serverTime'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      customers: customersList,
      sites: sitesList,
      notes: notesList,
    );
  }
}
