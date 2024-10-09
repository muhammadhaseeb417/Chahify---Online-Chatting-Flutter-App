import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recipe_flutter_app/servics/auth_service.dart';
import 'package:recipe_flutter_app/servics/database_service.dart';
import 'package:recipe_flutter_app/servics/media_service.dart';
import 'package:recipe_flutter_app/servics/navigation_service.dart';
import 'package:recipe_flutter_app/servics/show_toast_service.dart';
import 'package:recipe_flutter_app/servics/storage_servive.dart';

Future<void> RegisterServics() async {
  final GetIt getIt = GetIt.instance;

  getIt.registerSingleton<AuthService>(
    AuthService(),
  );
  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );
  getIt.registerSingleton<ShowToastService>(
    ShowToastService(),
  );
  getIt.registerSingleton<MediaService>(
    MediaService(),
  );
  getIt.registerSingleton<StorageServive>(
    StorageServive(),
  );
  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
}

String createChatId({required String uid1, required String uid2}) {
  var bothIDs = [uid1, uid2];
  bothIDs.sort();
  String chatId = bothIDs.fold(
    "",
    (preID, uid) => "$preID$uid",
  );
  return chatId;
}
