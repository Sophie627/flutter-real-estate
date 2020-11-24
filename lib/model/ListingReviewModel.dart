import 'package:cloud_firestore/cloud_firestore.dart';

class ListingReviewModel {
  String authorID = '';
  String content = '';
  Timestamp createdAt = Timestamp.now();
  String firstName = '';
  String lastName = '';
  String listingID = '';
  String profilePictureURL = '';
  num starCount = 0;

  ListingReviewModel(
      {this.authorID,
      this.content,
      this.createdAt,
      this.firstName,
      this.lastName,
      this.listingID,
      this.profilePictureURL,
      this.starCount});

  String fullName() => '$firstName $lastName';

  factory ListingReviewModel.fromJson(Map<String, dynamic> parsedJson) {
    return new ListingReviewModel(
        authorID: parsedJson['authorID'] ?? '',
        content: parsedJson['content'] ?? '',
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        listingID: parsedJson['listingID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '',
        starCount: parsedJson['starCount'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'authorID': this.authorID,
      'content': this.content,
      'createdAt': this.createdAt,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'listingID': this.listingID,
      'profilePictureURL': this.profilePictureURL,
      'starCount': this.starCount
    };
  }
}
