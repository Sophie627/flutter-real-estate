import 'package:cloud_firestore/cloud_firestore.dart';

class BlockUserModel {
  Timestamp createdAt = Timestamp.now();
  String dest = '';
  String source = '';
  String type = '';

  BlockUserModel({this.createdAt, this.dest, this.source, this.type});

  factory BlockUserModel.fromJson(Map<String, dynamic> parsedJson) {
    return new BlockUserModel(
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        dest: parsedJson['dest'] ?? '',
        source: parsedJson['source'] ?? '',
        type: parsedJson['type'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': this.createdAt,
      'dest': this.dest,
      'source': this.source,
      'type': this.type
    };
  }
}
