import 'dart:io';

class Salle {
String name;
String price;
File image;

Salle({
required this.name,
required this.price,
required this.image,
});
}

class SalleData {
static List<Salle> salles = [];
}