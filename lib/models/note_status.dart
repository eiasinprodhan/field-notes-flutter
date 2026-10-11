enum NoteStatus {
  open,
  inProgress,
  resolved,
  closed;

  String toServer() {
    switch (this) {
      case NoteStatus.open:
        return 'OPEN';
      case NoteStatus.inProgress:
        return 'IN_PROGRESS';
      case NoteStatus.resolved:
        return 'RESOLVED';
      case NoteStatus.closed:
        return 'CLOSED';
    }
  }

  static NoteStatus fromServer(String? value) {
    switch (value?.toUpperCase()) {
      case 'IN_PROGRESS':
        return NoteStatus.inProgress;
      case 'RESOLVED':
        return NoteStatus.resolved;
      case 'CLOSED':
        return NoteStatus.closed;
      case 'OPEN':
      default:
        return NoteStatus.open;
    }
  }

  String get displayName {
    switch (this) {
      case NoteStatus.open:
        return 'Open';
      case NoteStatus.inProgress:
        return 'In Progress';
      case NoteStatus.resolved:
        return 'Resolved';
      case NoteStatus.closed:
        return 'Closed';
    }
  }
}
