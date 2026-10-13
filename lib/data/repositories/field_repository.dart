import 'dart:io';
import 'package:uuid/uuid.dart';

import '../../core/storage/settings_storage.dart';
import '../../models/customer.dart';
import '../../models/site.dart';
import '../../models/field_note.dart';
import '../../models/note_status.dart';
import '../../models/sync_dto.dart';
import '../local/app_database.dart';
import '../remote/api_client.dart';

class FieldRepository {
  final AppDatabase _db;
  final FieldNotesApi _api;
  final SettingsStorage _settings;
  final Uuid _uuidGen = const Uuid();

  FieldRepository(this._db, this._api, this._settings);

  AppDatabase get db => _db;
  FieldNotesApi get api => _api;
  SettingsStorage get settings => _settings;

  Future<List<Customer>> getCustomers({bool includeDeleted = false}) {
    return _db.getCustomers(includeDeleted: includeDeleted);
  }

  Future<Customer?> getCustomer(String uuid) {
    return _db.getCustomer(uuid);
  }

  Future<Customer> createCustomer({
    required String name,
    String? contactInfo,
  }) async {
    final customer = Customer(
      uuid: _uuidGen.v4(),
      name: name.trim(),
      contactInfo: contactInfo?.trim(),
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
      syncPending: true,
    );
    await _db.upsertCustomerLocally(customer);
    return customer;
  }

  Future<Customer> updateCustomer(Customer customer) async {
    final updated = customer.copyWith(
      updatedAt: DateTime.now().toUtc(),
      syncPending: true,
    );
    await _db.upsertCustomerLocally(updated);
    return updated;
  }

  Future<void> deleteCustomer(String uuid) async {
    await _db.softDeleteCustomerLocally(uuid);
  }

  Future<List<Site>> getSites({String? customerUuid, bool includeDeleted = false}) {
    return _db.getSites(customerUuid: customerUuid, includeDeleted: includeDeleted);
  }

  Future<Site?> getSite(String uuid) {
    return _db.getSite(uuid);
  }

  Future<Site> createSite({
    required String customerUuid,
    required String siteName,
    String? address,
  }) async {
    final site = Site(
      uuid: _uuidGen.v4(),
      customerUuid: customerUuid,
      siteName: siteName.trim(),
      address: address?.trim(),
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
      syncPending: true,
    );
    await _db.upsertSiteLocally(site);
    return site;
  }

  Future<Site> updateSite(Site site) async {
    final updated = site.copyWith(
      updatedAt: DateTime.now().toUtc(),
      syncPending: true,
    );
    await _db.upsertSiteLocally(updated);
    return updated;
  }

  Future<void> deleteSite(String uuid) async {
    await _db.softDeleteSiteLocally(uuid);
  }

  Future<List<FieldNote>> getNotes({
    String? search,
    NoteStatus? status,
    String? siteUuid,
    bool includeDeleted = false,
  }) {
    return _db.getNotes(
      searchQuery: search,
      statusFilter: status,
      siteUuid: siteUuid,
      includeDeleted: includeDeleted,
    );
  }

  Future<FieldNote?> getNote(String uuid) {
    return _db.getNote(uuid);
  }

  Future<FieldNote> createNote({
    required String siteUuid,
    required String title,
    String? description,
    String? location,
    DateTime? dateTime,
    NoteStatus? status,
    String? photoUrl,
  }) async {
    final defaultStatusStr = _settings.getDefaultNoteStatus();
    final effectiveStatus = status ?? NoteStatus.fromServer(defaultStatusStr);

    final note = FieldNote(
      uuid: _uuidGen.v4(),
      siteUuid: siteUuid,
      title: title.trim(),
      description: description?.trim(),
      location: location?.trim(),
      dateTime: dateTime ?? DateTime.now().toUtc(),
      status: effectiveStatus,
      photoUrl: photoUrl,
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
      syncPending: true,
    );
    await _db.upsertNoteLocally(note);
    return note;
  }

  Future<FieldNote> updateNote(FieldNote note) async {
    final updated = note.copyWith(
      updatedAt: DateTime.now().toUtc(),
      syncPending: true,
    );
    await _db.upsertNoteLocally(updated);
    return updated;
  }

  Future<void> deleteNote(String uuid) async {
    await _db.softDeleteNoteLocally(uuid);
  }

  Future<String> uploadPhoto(File file) {
    return _api.uploadPhoto(file);
  }

  Future<Map<String, int>> getPendingSyncCounts() {
    return _db.getPendingSyncCounts();
  }

  Future<void> sync() async {
    final dirtyCustomers = await _db.getDirtyCustomers();
    final dirtySites = await _db.getDirtySites();
    final dirtyNotes = await _db.getDirtyNotes();

    final hasChanges = dirtyCustomers.isNotEmpty || dirtySites.isNotEmpty || dirtyNotes.isNotEmpty;

    if (hasChanges) {
      final pushRequest = SyncPushRequest(
        customers: dirtyCustomers,
        sites: dirtySites,
        notes: dirtyNotes,
      );
      await _api.pushSync(pushRequest);

      await _db.markEntitiesClean(
        customerUuids: dirtyCustomers.map((e) => e.uuid).toList(),
        siteUuids: dirtySites.map((e) => e.uuid).toList(),
        noteUuids: dirtyNotes.map((e) => e.uuid).toList(),
      );
    }

    final lastSyncTime = _settings.getLastSyncTime();
    final pullResponse = await _api.pullSync(since: lastSyncTime);

    await _db.mergeServerData(
      customers: pullResponse.customers,
      sites: pullResponse.sites,
      notes: pullResponse.notes,
    );

    await _settings.setLastSyncTime(pullResponse.serverTime);
  }

  Future<void> clearLocalData() async {
    await _db.clearAll();
    await _settings.clearSyncTime();
  }
}
