import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recipe_flutter_app/models/chat.dart';
import 'package:recipe_flutter_app/models/message.dart';
import 'package:recipe_flutter_app/models/user_profile.dart';
import 'package:recipe_flutter_app/servics/auth_service.dart';
import 'package:recipe_flutter_app/servics/database_service.dart';
import 'package:recipe_flutter_app/servics/media_service.dart';
import 'package:recipe_flutter_app/servics/storage_servive.dart';

import '../utils.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;

  late AuthService _authService;
  late MediaService _mediaService;
  late StorageServive _storageServive;

  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageServive = _getIt.get<StorageServive>();

    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name!),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(
        uid1: currentUser!.id,
        uid2: otherUser!.id,
      ),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = [];

        if (chat != null && chat.messages != null) {
          messages = _generateChatMessages(chat.messages!);
        }

        return DashChat(
          messageOptions: MessageOptions(
            showOtherUsersAvatar: true,
            showTime: true,
          ),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            trailing: [_sendImageButton()],
          ),
          currentUser: currentUser!,
          onSend: _sendMessageFunction,
          messages: messages,
        );
      },
    );
  }

  Future<void> _sendMessageFunction(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: currentUser!.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendChatMessageToFirebase(
          uid1: currentUser!.id,
          uid2: otherUser!.id,
          message: message,
        );
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessageToFirebase(
        uid1: currentUser!.id,
        uid2: otherUser!.id,
        message: message,
      );
    }
  }

  List<ChatMessage> _generateChatMessages(List<Message> messages) {
    List<ChatMessage> chatMessage = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            createdAt: m.sentAt!.toDate(),
            medias: [
              ChatMedia(
                url: m.content!,
                fileName: "",
                type: MediaType.image,
              )
            ]);
      } else {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          text: m.content!,
        );
      }
    }).toList();
    chatMessage.sort(
      (a, b) {
        return b.createdAt.compareTo(a.createdAt);
      },
    );

    return chatMessage;
  }

  Widget _sendImageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getMediaImageFromUserGallery();
        String chatId =
            createChatId(uid1: currentUser!.id, uid2: otherUser!.id);
        if (file != null) {
          String? downloadURL = await _storageServive.uploadChatIdImage(
            file: file!,
            chatId: chatId,
          );
          if (downloadURL != null) {
            ChatMessage chatMessage = ChatMessage(
              user: currentUser!,
              createdAt: DateTime.now(),
              medias: [
                ChatMedia(
                  url: downloadURL,
                  fileName: "",
                  type: MediaType.image,
                ),
              ],
            );
            _sendMessageFunction(chatMessage);
          }
        }
      },
      icon: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
