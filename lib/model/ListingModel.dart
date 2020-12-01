import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  String authorID = '';
  String authorName = '';
  String authorProfilePic = '';
  String categoryID = '';
  String categoryPhoto = '';
  String categoryTitle = '';
  Timestamp createdAt = Timestamp.now();
  String description = '';
  Map<String, dynamic> filters = Map();
  String id = '';
  bool isApproved = false;
  double latitude = 0.1;
  double longitude = 0.1;
  String photo = '';
  List<dynamic> photos = [];
  String place = '';
  String price = '';
  num reviewsCount = 0;
  num reviewsSum = 0;
  String title = '';
  String tourURL = 'https://asdelogy.com/palmacera';

  //internal use only, don't save to db
  bool isFav = false;

  ListingModel(
      {this.authorID,
      this.authorName,
      this.authorProfilePic,
      this.categoryID,
      this.categoryPhoto,
      this.categoryTitle,
      this.createdAt,
      this.description,
      this.filters,
      this.id,
      this.isApproved,
      this.latitude,
      this.longitude,
      this.photo,
      this.photos,
      this.place,
      this.price,
      this.reviewsCount,
      this.reviewsSum,
      this.tourURL,
      this.title});

  factory ListingModel.fromJson(Map<String, dynamic> parsedJson) {
    print('ListingModel.fromJson ${parsedJson.toString()}');
    return new ListingModel(
      tourURL: parsedJson['tourURL'] ?? '',
      authorID: parsedJson['authorID'] ?? '',
      authorName: parsedJson['authorName'] ?? '',
      authorProfilePic: parsedJson['authorProfilePic'] ?? '',
      categoryID: parsedJson['categoryID'] ?? '',
      categoryPhoto: parsedJson['categoryPhoto'] ?? '',
      categoryTitle: parsedJson['categoryTitle'] ?? '',
      createdAt: parsedJson['createdAt'] is Timestamp
          ? parsedJson['createdAt']
          : Timestamp(parsedJson['createdAt']['_seconds'] ?? 0,
              parsedJson['createdAt']['_nanoseconds'] ?? 0 ?? Timestamp.now()),
      description: parsedJson['description'] ?? '',
      filters: parsedJson['filters'] ?? Map(),
      id: parsedJson['id'] ?? '',
      isApproved: parsedJson['isApproved'] ?? false,
      latitude: parsedJson['latitude'] ?? 0.1,
      longitude: parsedJson['longitude'] ?? 0.1,
      photo: parsedJson['photo'] ?? '',
      photos: parsedJson['photos'] ?? [],
      place: parsedJson['place'] ?? '',
      price: parsedJson['price'] ?? '',
      reviewsCount: parsedJson['reviewsCount'] ?? 0,
      reviewsSum: parsedJson['reviewsSum'] ?? 0,
      title: parsedJson['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tourURL': this.tourURL,
      'authorID': this.authorID,
      'authorName': this.authorName,
      'authorProfilePic': this.authorProfilePic,
      'categoryID': this.categoryID,
      'categoryPhoto': this.categoryPhoto,
      'categoryTitle': this.categoryTitle,
      'createdAt': this.createdAt,
      'description': this.description,
      'filters': this.filters,
      'id': this.id,
      'isApproved': this.isApproved,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'photo': this.photo,
      'photos': this.photos,
      'place': this.place,
      'price': this.price,
      'reviewsCount': this.reviewsCount,
      'reviewsSum': this.reviewsSum,
      'title': this.title,
    };
  }
}
