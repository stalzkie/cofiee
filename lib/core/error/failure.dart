/// A simple error wrapper for repositories and services
/// so ViewModels can catch and display user-friendly messages.
class Failure implements Exception {
  final String message;
  final dynamic cause;
  final StackTrace? stackTrace;

  Failure(this.message, {this.cause, this.stackTrace});

  @override
  String toString() {
    return 'Failure: $message ${cause != null ? '→ $cause' : ''}';
  }

  /// Convert any exception into a Failure
  static Failure fromException(Object e, [StackTrace? st]) {
    if (e is Failure) return e;
    return Failure(e.toString(), cause: e, stackTrace: st);
  }
}
