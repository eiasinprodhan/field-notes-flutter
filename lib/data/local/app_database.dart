import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../../models/customer.dart';
import '../../models/site.dart';
import '../../models/field_note.dart';
import '../../models/note_status.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    } else if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String path;
    if (kIsWeb) {
      path = 'field_notes.db';
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, 'field_notes.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers (
            uuid TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            contact_info TEXT,
            updated_at TEXT NOT NULL,
            deleted INTEGER NOT NULL DEFAULT 0,
            sync_pending INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE sites (
            uuid TEXT PRIMARY KEY,
            customer_uuid TEXT NOT NULL,
            site_name TEXT NOT NULL,
            address TEXT,
            updated_at TEXT NOT NULL,
            deleted INTEGER NOT NULL DEFAULT 0,
            sync_pending INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE field_notes (
            uuid TEXT PRIMARY KEY,
            site_uuid TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            location TEXT,
            date_time TEXT NOT NULL,
            status TEXT NOT NULL,
            photo_url TEXT,
            updated_at TEXT NOT NULL,
            deleted INTEGER NOT NULL DEFAULT 0,
            sync_pending INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

Future<List<Customer>> getCustomers({bool includeDeleted = false}) async {
    final db = await database;
    final where = includeDeleted ? null : 'deleted = 0';
    final rows = await db.query(
      'customers',
      where: where,
      orderBy: 'name ASC',
    );
    return rows.map((e) => Customer.fromMap(e)).toList();
  }

  Future<Customer?> getCustomer(String uuid) async {
    final db = await database;
    final rows = await db.query(
      'customers',
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Customer.fromMap(rows.first);
  }

  Future<void> upsertCustomerLocally(Customer customer) async {
    final db = await database;
    await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> softDeleteCustomerLocally(String uuid) async {
    final db = await database;
    await db.update(
      'customers',
      {
        'deleted': 1,
        'sync_pending': 1,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

Future<List<Site>> getSites({String? customerUuid, bool includeDeleted = false}) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (!includeDeleted) {
      conditions.add('deleted = 0');
    }
    if (customerUuid != null && customerUuid.isNotEmpty) {
      conditions.add('customer_uuid = ?');
      args.add(customerUuid);
    }

    final where = conditions.isEmpty ? null : conditions.join(' AND ');
    final rows = await db.query(
      'sites',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'site_name ASC',
    );
    return rows.map((e) => Site.fromMap(e)).toList();
  }

  Future<Site?> getSite(String uuid) async {
    final db = await database;
    final rows = await db.query(
      'sites',
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Site.fromMap(rows.first);
  }

  Future<void> upsertSiteLocally(Site site) async {
    final db = await database;
    await db.insert(
      'sites',
      site.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> softDeleteSiteLocally(String uuid) async {
    final db = await database;
    await db.update(
      'sites',
      {
        'deleted': 1,
        'sync_pending': 1,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

Future<List<FieldNote>> getNotes({
    String? searchQuery,
    NoteStatus? statusFilter,
    String? siteUuid,
    bool includeDeleted = false,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (!includeDeleted) {
      conditions.add('n.deleted = 0');
    }
    if (statusFilter != null) {
      conditions.add('n.status = ?');
      args.add(statusFilter.toServer());
    }
    if (siteUuid != null && siteUuid.isNotEmpty) {
      conditions.add('n.site_uuid = ?');
      args.add(siteUuid);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim()}%';
      conditions.add(
        '(n.title LIKE ? OR n.description LIKE ? OR s.site_name LIKE ? OR c.name LIKE ?)',
      );
      args.addAll([term, term, term, term]);
    }

    final whereClause = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';

    final query = '''
      SELECT n.*, s.site_name, s.customer_uuid, c.name AS customer_name
      FROM field_notes n
      LEFT JOIN sites s ON n.site_uuid = s.uuid
      LEFT JOIN customers c ON s.customer_uuid = c.uuid
      $whereClause
      ORDER BY n.date_time DESC
    ''';

    final rows = await db.rawQuery(query, args);
    return rows.map((e) => FieldNote.fromMap(e)).toList();
  }

  Future<FieldNote?> getNote(String uuid) async {
    final db = await database;
    const query = '''
      SELECT n.*, s.site_name, s.customer_uuid, c.name AS customer_name
      FROM field_notes n
      LEFT JOIN sites s ON n.site_uuid = s.uuid
      LEFT JOIN customers c ON s.customer_uuid = c.uuid
      WHERE n.uuid = ?
      LIMIT 1
    ''';
    final rows = await db.rawQuery(query, [uuid]);
    if (rows.isEmpty) return null;
    return FieldNote.fromMap(rows.first);
  }

  Future<void> upsertNoteLocally(FieldNote note) async {
    final db = await database;
    await db.insert(
      'field_notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> softDeleteNoteLocally(String uuid) async {
    final db = await database;
    await db.update(
      'field_notes',
      {
        'deleted': 1,
        'sync_pending': 1,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

Future<List<Customer>> getDirtyCustomers() async {
    final db = await database;
    final rows = await db.query('customers', where: 'sync_pending = 1');
    return rows.map((e) => Customer.fromMap(e)).toList();
  }

  Future<List<Site>> getDirtySites() async {
    final db = await database;
    final rows = await db.query('sites', where: 'sync_pending = 1');
    return rows.map((e) => Site.fromMap(e)).toList();
  }

  Future<List<FieldNote>> getDirtyNotes() async {
    final db = await database;
    final rows = await db.query('field_notes', where: 'sync_pending = 1');
    return rows.map((e) => FieldNote.fromMap(e)).toList();
  }
  Future<Map<String, int>> getPendingSyncCounts() async {
    final db = await database;
    final custRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM customers WHERE sync_pending = 1');
    final siteRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM sites WHERE sync_pending = 1');
    final noteRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM field_notes WHERE sync_pending = 1');

    final customers = (custRes.first['cnt'] as int?) ?? 0;
    final sites = (siteRes.first['cnt'] as int?) ?? 0;
    final notes = (noteRes.first['cnt'] as int?) ?? 0;

    return {
      'customers': customers,
      'sites': sites,
      'notes': notes,
      'total': customers + sites + notes,
    };
  }

  Future<void> markEntitiesClean({
    List<String>? customerUuids,
    List<String>? siteUuids,
    List<String>? noteUuids,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      if (customerUuids != null && customerUuids.isNotEmpty) {
        final placeholders = List.filled(customerUuids.length, '?').join(',');
        await txn.rawUpdate(
          'UPDATE customers SET sync_pending = 0 WHERE uuid IN ($placeholders)',
          customerUuids,
        );
      }
      if (siteUuids != null && siteUuids.isNotEmpty) {
        final placeholders = List.filled(siteUuids.length, '?').join(',');
        await txn.rawUpdate(
          'UPDATE sites SET sync_pending = 0 WHERE uuid IN ($placeholders)',
          siteUuids,
        );
      }
      if (noteUuids != null && noteUuids.isNotEmpty) {
        final placeholders = List.filled(noteUuids.length, '?').join(',');
        await txn.rawUpdate(
          'UPDATE field_notes SET sync_pending = 0 WHERE uuid IN ($placeholders)',
          noteUuids,
        );
      }
    });
  }

Future<void> mergeServerData({
    required List<Customer> customers,
    required List<Site> sites,
    required List<FieldNote> notes,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      
      for (final sCust in customers) {
        final local = await txn.query(
          'customers',
          where: 'uuid = ?',
          whereArgs: [sCust.uuid],
          limit: 1,
        );
        if (local.isEmpty) {
          await txn.insert('customers', sCust.toMap());
        } else {
          final isPending = (local.first['sync_pending'] as int) == 1;
          final localUpdated = DateTime.parse(local.first['updated_at'] as String).toUtc();
          
          if (!isPending || sCust.updatedAt.isAfter(localUpdated) || sCust.updatedAt.isAtSameMomentAs(localUpdated)) {
            await txn.insert('customers', sCust.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }

for (final sSite in sites) {
        final local = await txn.query(
          'sites',
          where: 'uuid = ?',
          whereArgs: [sSite.uuid],
          limit: 1,
        );
        if (local.isEmpty) {
          await txn.insert('sites', sSite.toMap());
        } else {
          final isPending = (local.first['sync_pending'] as int) == 1;
          final localUpdated = DateTime.parse(local.first['updated_at'] as String).toUtc();
          if (!isPending || sSite.updatedAt.isAfter(localUpdated) || sSite.updatedAt.isAtSameMomentAs(localUpdated)) {
            await txn.insert('sites', sSite.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }

for (final sNote in notes) {
        final local = await txn.query(
          'field_notes',
          where: 'uuid = ?',
          whereArgs: [sNote.uuid],
          limit: 1,
        );
        if (local.isEmpty) {
          await txn.insert('field_notes', sNote.toMap());
        } else {
          final isPending = (local.first['sync_pending'] as int) == 1;
          final localUpdated = DateTime.parse(local.first['updated_at'] as String).toUtc();
          if (!isPending || sNote.updatedAt.isAfter(localUpdated) || sNote.updatedAt.isAtSameMomentAs(localUpdated)) {
            await txn.insert('field_notes', sNote.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
    });
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('field_notes');
      await txn.delete('sites');
      await txn.delete('customers');
    });
  }
}
