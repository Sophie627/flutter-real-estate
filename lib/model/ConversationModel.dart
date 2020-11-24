import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  String id = '';
  String creatorId = '';
  String lastMessage = '';
  String name = '';
  Timestamp lastMessageDate = Timestamp.now();

  ConversationModel(
      {this.id,
      this.creatorId,
      this.lastMessage,
      this.name,
      this.lastMessageDate});

  factory ConversationModel.fromJson(Map<String, dynamic> parsedJson) {
    return new ConversationModel(
        id: parsedJson['id'] ?? '',
        creatorId: parsedJson['creatorID'] ?? parsedJson['creator_id'] ?? '',
        lastMessage: parsedJson['lastMessage'] ?? '',
        name: parsedJson['name'] ?? '',
        lastMessageDate: parsedJson['lastMessageDate'] ?? Timestamp.now());
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "creatorID": this.creatorId,
      "lastMessage": this.lastMessage,
      "name": this.name,
      "lastMessageDate": this.lastMessageDate
    };
  }
}
