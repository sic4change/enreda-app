
import 'dart:io';
import 'dart:typed_data';

class FileData {
  final String name;
  final Uint8List? bytes;
  final File? file;

  FileData(this.name, this.bytes, this.file);
}
