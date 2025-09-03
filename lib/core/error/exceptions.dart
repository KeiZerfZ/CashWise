// lib/core/error/exceptions.dart

class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);
}