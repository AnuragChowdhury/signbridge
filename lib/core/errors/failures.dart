// Core failure types for error handling.
// Failures represent domain-level errors that are returned instead of thrown.

abstract class Failure {
  final String message;
  final String? details;

  const Failure(this.message, {this.details});

  @override
  String toString() =>
      '$runtimeType: $message${details != null ? '\nDetails: $details' : ''}';
}

class ModelFailure extends Failure {
  const ModelFailure(super.message, {super.details});
}

class CameraFailure extends Failure {
  const CameraFailure(super.message, {super.details});
}

class RecognitionFailure extends Failure {
  const RecognitionFailure(super.message, {super.details});
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.details});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.details});
}
