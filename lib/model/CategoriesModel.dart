class CategoriesModel {
  String id = '';
  String name = '';
  String order = '';
  String photo = '';
  String title = '';

  CategoriesModel({this.id, this.name, this.order, this.photo, this.title});

  factory CategoriesModel.fromJson(Map<String, dynamic> parsedJson) {
    return new CategoriesModel(
        id: parsedJson['id'] ?? '',
        name: parsedJson['name'] ?? '',
        order: parsedJson['order'] ?? '',
        photo: parsedJson['photo'] ?? '',
        title: parsedJson['title'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'order': this.order,
      'photo': this.photo,
      'title': this.title
    };
  }
}
