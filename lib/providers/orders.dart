import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';

import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> mOrders = [];

  List<OrderItem> get orders {
    return [...mOrders];
  }

  final String authToken;
  final String userId;

  Orders({
    required this.authToken,
    required this.mOrders,
    required this.userId,
  });

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-pedro-f1958-default-rtdb.firebaseio.com/orders/${userId}.json?auth=${authToken}';

    final response = await http.get(Uri.parse(url));

    final List<OrderItem> loadedOrders = [];

    final data = json.decode(response.body) as Map<String, dynamic>;

    if (data == null) {
      return;
    }

    data.forEach((id, order) {
      loadedOrders.add(
        OrderItem(
          id: id,
          amount: order['amount'],
          dateTime: DateTime.parse(order['dateTime']),
          products: (order['products'] as List<dynamic>)
              .map(
                (e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price'],
                ),
              )
              .toList(),
        ),
      );
    });

    mOrders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://flutter-pedro-f1958-default-rtdb.firebaseio.com/orders/$userId.json?auth=${authToken}';

    final timestamp = DateTime.now();

    final response = await http.post(Uri.parse(url),
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map(
                (item) => {
                  'id': item.id,
                  'title': item.title,
                  'quantity': item.quantity,
                  'price': item.price,
                },
              )
              .toList(),
        }));

    mOrders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timestamp,
      ),
    );
    notifyListeners();
  }
}
