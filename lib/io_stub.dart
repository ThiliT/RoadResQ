// Stub file for web platform when dart:io is not available
// This prevents compilation errors on web builds.

class File {
  final String path;
  File(this.path);
  Future<bool> exists() async => false;
  Future<void> writeAsBytes(List<int> bytes) async {}
  Future<int> length() async => 0;
  Future<void> delete() async {}
}


