class CourtModel {
  final String id;
  final String name;
  final String location;
  final double price;
  final String description;
  final String imageUrl;

  CourtModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory CourtModel.fromMap(Map<String, dynamic> map, String id) {
    return CourtModel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}
