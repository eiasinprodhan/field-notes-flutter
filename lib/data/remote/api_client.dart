import 'dart:io';
import 'package:dio/dio.dart';

import '../../models/auth_response.dart';
import '../../models/customer.dart';
import '../../models/site.dart';
import '../../models/field_note.dart';
import '../../models/note_status.dart';
import '../../models/sync_dto.dart';

class FieldNotesApi {
  final Dio _dio;

  FieldNotesApi(this._dio);

  Dio get dio => _dio;

Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> register(String email, String password, String name) async {
    final response = await _dio.post(
      '/api/auth/register',
      data: {'email': email, 'password': password, 'name': name},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

Future<List<Customer>> getCustomers() async {
    final response = await _dio.get('/api/customers');
    final list = response.data as List<dynamic>;
    return list.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Customer> createCustomer(String name, String? contactInfo) async {
    final response = await _dio.post(
      '/api/customers',
      data: {'name': name, 'contactInfo': contactInfo},
    );
    return Customer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Customer> updateCustomer(String uuid, String name, String? contactInfo) async {
    final response = await _dio.put(
      '/api/customers/$uuid',
      data: {'name': name, 'contactInfo': contactInfo},
    );
    return Customer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCustomer(String uuid) async {
    await _dio.delete('/api/customers/$uuid');
  }

Future<List<Site>> getSites({String? customerUuid}) async {
    final path = (customerUuid != null && customerUuid.isNotEmpty)
        ? '/api/customers/$customerUuid/sites'
        : '/api/sites';
    final response = await _dio.get(path);
    final list = response.data as List<dynamic>;
    return list.map((e) => Site.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Site> createSite(String customerUuid, String siteName, String? address) async {
    final response = await _dio.post(
      '/api/sites',
      data: {'customerUuid': customerUuid, 'siteName': siteName, 'address': address},
    );
    return Site.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Site> updateSite(String uuid, String customerUuid, String siteName, String? address) async {
    final response = await _dio.put(
      '/api/sites/$uuid',
      data: {'customerUuid': customerUuid, 'siteName': siteName, 'address': address},
    );
    return Site.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteSite(String uuid) async {
    await _dio.delete('/api/sites/$uuid');
  }

Future<List<FieldNote>> getNotes({
    String? search,
    NoteStatus? status,
    String? siteUuid,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null) queryParams['status'] = status.toServer();
    if (siteUuid != null && siteUuid.isNotEmpty) queryParams['siteUuid'] = siteUuid;

    final response = await _dio.get('/api/notes', queryParameters: queryParams);
    final list = response.data as List<dynamic>;
    return list.map((e) => FieldNote.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FieldNote> createNote(FieldNote note) async {
    final response = await _dio.post(
      '/api/notes',
      data: {
        'siteUuid': note.siteUuid,
        'title': note.title,
        'description': note.description,
        'location': note.location,
        'dateTime': note.dateTime.toIso8601String(),
        'status': note.status.toServer(),
        'photoUrl': note.photoUrl,
      },
    );
    return FieldNote.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FieldNote> updateNote(FieldNote note) async {
    final response = await _dio.put(
      '/api/notes/${note.uuid}',
      data: {
        'siteUuid': note.siteUuid,
        'title': note.title,
        'description': note.description,
        'location': note.location,
        'dateTime': note.dateTime.toIso8601String(),
        'status': note.status.toServer(),
        'photoUrl': note.photoUrl,
      },
    );
    return FieldNote.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteNote(String uuid) async {
    await _dio.delete('/api/notes/$uuid');
  }

Future<String> uploadPhoto(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    final response = await _dio.post('/api/photos', data: formData);
    final data = response.data as Map<String, dynamic>;
    return data['url'] as String;
  }

Future<String> pushSync(SyncPushRequest request) async {
    final response = await _dio.post(
      '/api/sync/push',
      data: request.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    return data['serverTime'] as String? ?? DateTime.now().toUtc().toIso8601String();
  }

  Future<SyncPullResponse> pullSync({String? since}) async {
    final queryParams = <String, dynamic>{};
    if (since != null && since.isNotEmpty) {
      queryParams['since'] = since;
    }
    final response = await _dio.get('/api/sync/pull', queryParameters: queryParams);
    return SyncPullResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
