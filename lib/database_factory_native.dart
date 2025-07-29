// Native platform implementation (Windows, Linux, macOS, iOS, Android)
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeDatabaseFactory() {
  // Initialize database factory for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    databaseFactory = databaseFactoryFfi;
  }
  // For mobile platforms (iOS, Android), sqflite uses the default database factory
}
