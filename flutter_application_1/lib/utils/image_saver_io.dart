import 'dart:typed_data';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> saveImageToDevice(Uint8List bytes, String fileName) async {
  Directory directory;
  if (Platform.isAndroid) {
    final directories = await getExternalStorageDirectories(
      type: StorageDirectory.downloads,
    );
    directory = directories?.first ?? await getApplicationDocumentsDirectory();
  } else {
    directory = await getApplicationDocumentsDirectory();
  }

  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final filePath = p.join(directory.path, fileName);
  await File(filePath).writeAsBytes(bytes);
  return filePath;
}
