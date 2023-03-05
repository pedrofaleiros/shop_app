import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> mItems = [];
  List<Product> get items {
    return [...mItems];
  }

  final String authToken;
  final String userId;

  Products({
    required this.authToken,
    required this.mItems,
    required this.userId,
  });

  Future<void> fetchAndSetProducts([bool filter = false]) async {
    
    final filterString = filter == true ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    
    var url =
        'https://flutter-pedro-f1958-default-rtdb.firebaseio.com/products.json?auth=${authToken}&$filterString';

    try {
      final response = await http.get(Uri.parse(url));

      final data = json.decode(response.body) as Map<String, dynamic>;

      url =
          'https://flutter-pedro-f1958-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));

      final List<Product> loadedProducts = [];

      final favoriteData = json.decode(favoriteResponse.body);
      // print(favoriteData);

      data.forEach((id, prodData) {
        loadedProducts.add(
          Product(
            id: id,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
            (favoriteData == null || favoriteData[id] == null)
                ? false
                : favoriteData[id]['isFavorite'] ?? false,
          ),
        );
      });

      mItems = loadedProducts;

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-pedro-f1958-default-rtdb.firebaseio.com/products.json?auth=${authToken}';

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            // 'isFavorite': product.isFavorite,
            'creatorId': userId,
          }));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        isFavorite: product.isFavorite,
      );

      mItems.add(newProduct);

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProd) async {
    final url =
        'https://flutter-pedro-f1958-default-rtdb.firebaseio.com/products/${id}.json?auth=${authToken}';

    final prodIndex = mItems.indexWhere((element) => element.id == id);

    if (prodIndex >= 0) {
      await http.patch(
        Uri.parse(url),
        body: json.encode({
          'title': newProd.title,
          'description': newProd.description,
          'imageUrl': newProd.imageUrl,
          'price': newProd.price,
          'isFavorite': newProd.isFavorite,
        }),
      );

      mItems[prodIndex] = newProd;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-pedro-f1958-default-rtdb.firebaseio.com/products/${id}.json?auth=${authToken}';

    final existingProductIndex =
        mItems.indexWhere((element) => element.id == id);
    Product? existingProduct = mItems[existingProductIndex];

    mItems.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      mItems.insert(existingProductIndex, existingProduct!);
      notifyListeners();
      throw HttpException('deu merda');
    }
    existingProduct = null;
  }

  Product findById(String id) {
    return mItems.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favoriteItems {
    return mItems.where((element) => element.isFavorite).toList();
  }
}
