import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class Storage with ChangeNotifier {
  FirebaseStorage storage;

  Storage(this.storage);

  Future<void> deleteFromStorage(
      final String path, final String fileName) async {
      await this.storage.ref().child(path).child(fileName).delete();
  }

  Future<File> downloadFromStorage(
      final String path, final String fileName) async {
    if (fileName.isEmpty)
      throw PathException(
          'File name not found in http path:\n$path\\$fileName');
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$fileName');
    final StorageReference ref = this.storage.ref().child(path).child(fileName);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);
    await downloadTask.future;
    return file;
  }

  Future<String> uploadToStorage(
      File file, String path, String fileName) async {
    List<StorageUploadTask> _tasks = <StorageUploadTask>[];
    final StorageReference ref = this.storage.ref().child(path).child(fileName);

    final StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );
    final downloadUrl =
        await (await uploadTask.onComplete).ref.getDownloadURL();
    _tasks.add(uploadTask);
    this.notifyListeners();
    return downloadUrl;
  }
}
