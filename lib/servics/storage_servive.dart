import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageServive {
  StorageServive();

  final FirebaseStorage _firebasestorage = FirebaseStorage.instance;

  Future<String?> uploadUserpfp({
    required File file,
    required String uid,
  }) async {
    try {
      Reference pfpRef = _firebasestorage
          .ref("/users/pfp")
          .child("$uid${p.extension(file.path)}");

      UploadTask TASK = pfpRef.putFile(File(file.path));

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await TASK.whenComplete(() => null);
      String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> uploadChatIdImage({
    required File file,
    required String chatId,
  }) async {
    try {
      Reference ImageRef = _firebasestorage.ref("/chatImages/$chatId").child(
          "${DateTime.now().toIso8601String()}${p.extension(file.path)}");
      UploadTask TASK = ImageRef.putFile(File(file.path));

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await TASK.whenComplete(() => null);
      String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
