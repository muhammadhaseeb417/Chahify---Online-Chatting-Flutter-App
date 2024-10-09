import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:recipe_flutter_app/models/message.dart';
import 'package:recipe_flutter_app/servics/auth_service.dart';

import '../models/chat.dart';
import '../models/user_profile.dart';
import '../utils.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;

  CollectionReference<UserProfile>? _userReference;
  CollectionReference? _chatReference;

  DatabaseService() {
    _setupFirebaseUserReference();
    _authService = _getIt.get<AuthService>();
    _chatReference = _firebaseFirestore.collection("chats");
  }

  void _setupFirebaseUserReference() {
    _userReference =
        _firebaseFirestore.collection("users").withConverter<UserProfile>(
              fromFirestore: (snapshot, _) =>
                  UserProfile.fromJson(snapshot.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );

    _chatReference = _firebaseFirestore.collection("chats").withConverter<Chat>(
          fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        );
  }

  Future<void> createUserInFirebase({required UserProfile userProfile}) async {
    await _userReference!.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _userReference!
        .where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots();
  }

  Future<bool> chatExistBetweenUser({
    required String uid1,
    required String uid2,
  }) async {
    String chatId = createChatId(uid1: uid1, uid2: uid2);
    var result = await _chatReference?.doc(chatId).get();

    // Check if the chat document exists
    return result != null && result.exists;
  }

  Future<void> createChatInFirebase(
      {required String uid1, required String uid2}) async {
    String chatId = createChatId(uid1: uid1, uid2: uid2);

    final chatRef = _chatReference?.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);

    // Set the new chat document in Firestore
    await chatRef?.set(chat.toJson());
  }

  Future<void> sendChatMessageToFirebase(
      {required String uid1,
      required String uid2,
      required Message message}) async {
    String chatId = createChatId(uid1: uid1, uid2: uid2);

    final chatRef = _chatReference?.doc(chatId);

    await chatRef?.update(
      {
        "messages": FieldValue.arrayUnion(
          [
            message.toJson(),
          ],
        ),
      },
    );
  }

  Stream<DocumentSnapshot<Chat>> getChatData({
    required String uid1,
    required String uid2,
  }) {
    String chatId = createChatId(uid1: uid1, uid2: uid2);

    // Cast to Stream<DocumentSnapshot<Chat>> to ensure correct typing.
    return _chatReference!
        .doc(chatId)
        .withConverter<Chat>(
          fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        )
        .snapshots();
  }
}
