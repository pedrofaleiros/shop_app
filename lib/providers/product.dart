import 'dart:convert';

import 'package:flutter/foundation.dart ';

import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite = false;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  void handleFavoriteClick(String token, String userId) async {
    final url =
        'https://flutter-pedro-f1958-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';

    final oldStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();

    try {
      await http.put(Uri.parse(url),
          body: json.encode({
            'isFavorite': isFavorite,
          }));
    } catch (e) {
      _setFavValue(oldStatus);
    }
  }
}
