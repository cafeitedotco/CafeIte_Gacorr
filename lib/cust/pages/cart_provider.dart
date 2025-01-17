// cart_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String nama;
  final String harga;
  final String image;
  int quantity;
  bool isSelected;
  final String note;

  CartItem({
    required this.nama,
    required this.harga,
    required this.image,
    this.quantity = 1,
    this.isSelected = false,
    this.note = "",
  });

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'harga': harga,
      'image': image,
      'quantity': quantity,
      'isSelected': isSelected,
      'note': note,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      nama: json['nama'] ?? '',
      harga: json['harga'] ?? '',
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 1,
      isSelected: json['isSelected'] ?? false,
      note: json['note'] ?? '',
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  bool get isEmpty => _items.isEmpty;

  CartProvider() {
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final List<dynamic> decodedData = json.decode(cartData);
        _items = decodedData.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  Future<void> _saveCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(
        _items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('cart_items', encodedData);
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }

  void addItem(CartItem newItem) {
    // Check if item already exists
    final existingIndex = _items.indexWhere(
        (item) => item.nama == newItem.nama && item.harga == newItem.harga);

    if (existingIndex >= 0) {
      // If item exists, increment quantity
      _items[existingIndex].quantity += newItem.quantity;
    } else {
      // If item doesn't exist, add new item
      _items.add(newItem);
    }

    _saveCartItems();
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _saveCartItems();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCartItems();
    notifyListeners();
  }

  void updateQuantity(int index, int change) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity += change;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      _saveCartItems();
      notifyListeners();
    }
  }

  void toggleSelection(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].isSelected = !_items[index].isSelected;
      _saveCartItems();
      notifyListeners();
    }
  }

  void selectAll(bool select) {
    for (var item in _items) {
      item.isSelected = select;
    }
    _saveCartItems();
    notifyListeners();
  }

  double calculateTotal() {
    return _items.fold(0, (sum, item) {
      if (item.isSelected) {
        double price =
            double.parse(item.harga.replaceAll("Rp ", "").replaceAll(".", ""));
        return sum + (price * item.quantity);
      }
      return sum;
    });
  }

  List<Map<String, dynamic>> getSelectedItems() {
    return _items
        .where((item) => item.isSelected)
        .map((item) => {
              'name': item.nama,
              'note': item.note,
              'image': item.image,
              'quantity': item.quantity,
            })
        .toList();
  }
}
