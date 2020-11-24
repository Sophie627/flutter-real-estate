class FilterModel {
  String id = '';
  String name = '';
  List options = [];

  FilterModel({this.id, this.name, this.options});

  factory FilterModel.fromJson(Map<String, dynamic> parsedJson) {
    return new FilterModel(
      id: parsedJson['id'] ?? '',
      name: parsedJson['name'] ?? '',
      options: parsedJson['options'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'options': this.options,
    };
  }
}
