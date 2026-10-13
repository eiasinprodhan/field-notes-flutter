import 'package:flutter_test/flutter_test.dart';
import 'package:field_notes_app/models/note_status.dart';
import 'package:field_notes_app/models/field_note.dart';
import 'package:field_notes_app/models/customer.dart';
import 'package:field_notes_app/models/site.dart';

void main() {
  group('NoteStatus Tests', () {
    test('serializes and deserializes PENDING, IN_PROGRESS, COMPLETED', () {
      expect(NoteStatus.pending.toServer(), equals('PENDING'));
      expect(NoteStatus.inProgress.toServer(), equals('IN_PROGRESS'));
      expect(NoteStatus.completed.toServer(), equals('COMPLETED'));

      expect(NoteStatus.fromServer('PENDING'), equals(NoteStatus.pending));
      expect(NoteStatus.fromServer('IN_PROGRESS'), equals(NoteStatus.inProgress));
      expect(NoteStatus.fromServer('COMPLETED'), equals(NoteStatus.completed));
    });

    test('backward compatibility aliases map correctly', () {
      expect(NoteStatus.fromServer('OPEN'), equals(NoteStatus.pending));
      expect(NoteStatus.fromServer('RESOLVED'), equals(NoteStatus.completed));
      expect(NoteStatus.fromServer('CLOSED'), equals(NoteStatus.completed));
      expect(NoteStatus.fromServer(null), equals(NoteStatus.pending));
      expect(NoteStatus.fromString('in_progress'), equals(NoteStatus.inProgress));
    });
  });

  group('Customer & Site Serialization', () {
    test('Customer toMap and fromMap roundtrip', () {
      final now = DateTime.now().toUtc();
      final customer = Customer(
        uuid: 'cust-123',
        name: 'Acme Corp',
        contactInfo: 'acme@example.com',
        updatedAt: now,
        deleted: false,
        syncPending: true,
      );

      final map = customer.toMap();
      final restored = Customer.fromMap(map);

      expect(restored.uuid, equals('cust-123'));
      expect(restored.name, equals('Acme Corp'));
      expect(restored.contactInfo, equals('acme@example.com'));
      expect(restored.deleted, isFalse);
      expect(restored.syncPending, isTrue);
    });

    test('Site toMap and fromMap roundtrip', () {
      final now = DateTime.now().toUtc();
      final site = Site(
        uuid: 'site-456',
        customerUuid: 'cust-123',
        siteName: 'Plant 1',
        address: '100 Industrial Pkwy',
        updatedAt: now,
        deleted: false,
        syncPending: false,
      );

      final map = site.toMap();
      final restored = Site.fromMap(map);

      expect(restored.uuid, equals('site-456'));
      expect(restored.customerUuid, equals('cust-123'));
      expect(restored.siteName, equals('Plant 1'));
      expect(restored.address, equals('100 Industrial Pkwy'));
      expect(restored.syncPending, isFalse);
    });
  });

  group('FieldNote Tests', () {
    test('Default status is pending', () {
      final note = FieldNote(
        uuid: 'note-789',
        siteUuid: 'site-456',
        title: 'Roof Inspection',
      );

      expect(note.status, equals(NoteStatus.pending));
      expect(note.deleted, isFalse);
      expect(note.syncPending, isFalse);
    });

    test('FieldNote toMap and fromMap preserves attributes', () {
      final now = DateTime.now().toUtc();
      final note = FieldNote(
        uuid: 'note-001',
        siteUuid: 'site-456',
        title: 'Generator Maintenance',
        description: 'Checked fuel levels and exhaust valve',
        location: '37.7749, -122.4194',
        dateTime: now,
        status: NoteStatus.inProgress,
        photoUrl: '/local/path/image.jpg',
        updatedAt: now,
        deleted: false,
        syncPending: true,
      );

      final map = note.toMap();
      expect(map['status'], equals('IN_PROGRESS'));
      expect(map['sync_pending'], equals(1));

      final restored = FieldNote.fromMap(map);
      expect(restored.uuid, equals('note-001'));
      expect(restored.title, equals('Generator Maintenance'));
      expect(restored.description, equals('Checked fuel levels and exhaust valve'));
      expect(restored.location, equals('37.7749, -122.4194'));
      expect(restored.status, equals(NoteStatus.inProgress));
      expect(restored.syncPending, isTrue);
    });
  });
}
