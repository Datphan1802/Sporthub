class CourtModel {
  final String id;
  final String name;
  final String location;
  final double price;
  final String description;
  final String imageUrl;
  final double? latitude;
  final double? longitude;
  final String? sportType;

  CourtModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.sportType,
  });

  factory CourtModel.fromMap(Map<String, dynamic> map, String id) {
    return CourtModel(
      id: id,
      name: map['name'] is String ? map['name'] : '',
      location: map['location'] is String ? map['location'] : '',
      price: (map['price'] is num ? map['price'] : 0).toDouble(),
      description: map['description'] is String ? map['description'] : '',
      imageUrl: map['imageUrl'] is String ? map['imageUrl'] : '',
      latitude: map['latitude'] is num ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] is num ? (map['longitude'] as num).toDouble() : null,
      sportType: map['sportType'] is String ? map['sportType'] : null,
    );
  }

  bool get hasLocation => latitude != null && longitude != null;
}
