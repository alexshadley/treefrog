import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Returns
class FileFactory {
  /// Gets the file corresponding to [relativePath], where the base directory is
  /// the application documents directory.
  Future<File> getFile(String relativePath) async {
    return new File('${(await getApplicationDocumentsDirectory())}/$relativePath');
  }
}