class Salle {
  final String name;
  final String city;
  final String description;
  final int capacity;
  final int price;
  final List<String> images;
  final List<String> equipements;

  Salle({
    required this.name,
    required this.city,
    required this.description,
    required this.capacity,
    required this.price,
    required this.images,
    required this.equipements,
  });
}