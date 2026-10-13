enum NoteStatus {
  pending,
  inProgress,
  completed;

  // Compatibility aliases
  static const NoteStatus open = NoteStatus.pending;
  static const NoteStatus resolved = NoteStatus.completed;
  static const NoteStatus closed = NoteStatus.completed;

  String toServer() {
    switch (this) {
      case NoteStatus.pending:
        return 'PENDING';
      case NoteStatus.inProgress:
        return 'IN_PROGRESS';
      case NoteStatus.completed:
        return 'COMPLETED';
    }
  }

  static NoteStatus fromServer(String? value) {
    switch (value?.toUpperCase()) {
      case 'IN_PROGRESS':
        return NoteStatus.inProgress;
      case 'COMPLETED':
      case 'RESOLVED':
      case 'CLOSED':
        return NoteStatus.completed;
      case 'PENDING':
      case 'OPEN':
      default:
        return NoteStatus.pending;
    }
  }

  static NoteStatus fromString(String? value) => fromServer(value);

  String get displayName {
    switch (this) {
      case NoteStatus.pending:
        return 'Pending';
      case NoteStatus.inProgress:
        return 'In Progress';
      case NoteStatus.completed:
        return 'Completed';
    }
  }
}
