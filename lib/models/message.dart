import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  String? senderID;
  String? content;
  MessageType? messageType;
  Timestamp? sentAt;

  Message({
    required this.senderID,
    required this.content,
    required this.messageType,
    required this.sentAt,
  });

  // Factory constructor for creating a Message instance from JSON
  Message.fromJson(Map<String, dynamic> json) {
    senderID = json['senderID'];
    content = json['content'];
    sentAt = json['sentAt'];

    // Safely parse messageType, handle possible null or unknown values
    final messageTypeString = json['messageType'];
    if (messageTypeString != null) {
      messageType = MessageType.values.firstWhere(
        (type) => type.name == messageTypeString,
        orElse: () => MessageType.Text, // Provide default if not found
      );
    }
  }

  // Converts the Message instance to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderID'] = senderID;
    data['content'] = content;
    data['sentAt'] = sentAt;
    data['messageType'] = messageType?.name; // Safely access name
    return data;
  }
}
