import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final String id;
  final String nama;
  final String harga;
  final String image;
  final String note;
  int quantity;
  bool isSelected;

  CartItem({
    String? id,
    required this.nama,
    required this.harga,
    required this.image,
    this.note = '',
    this.quantity = 1,
    this.isSelected = true,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'image': image,
      'note': note,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      image: json['image'],
      note: json['note'] ?? '',
      quantity: json['quantity'] ?? 1,
      isSelected: json['isSelected'] ?? true,
    );
  }
}

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  // Mendapatkan referensi collection cart untuk user tertentu
  CollectionReference _getCartRef() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User tidak terautentikasi');
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  // Load cart items dari Firebase
  Future<void> loadCartItems() async {
    try {
      final snapshot = await _getCartRef().get();
      _items = snapshot.docs
          .map((doc) => CartItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading cart items: $e');
      rethrow;
    }
  }

  // Menambah item ke cart dengan pengecekan item yang sama
  Future<void> addItem(CartItem newItem) async {
    try {
      // Cari item yang sama berdasarkan nama
      final existingItemIndex =
          _items.indexWhere((item) => item.nama == newItem.nama);

      if (existingItemIndex >= 0) {
        // Update quantity jika item sudah ada
        final existingItem = _items[existingItemIndex];
        final updatedQuantity = existingItem.quantity + 1;

        // Update di Firebase
        await _getCartRef().doc(existingItem.id).update({
          'quantity': updatedQuantity,
        });

        // Update di local state
        existingItem.quantity = updatedQuantity;
      } else {
        // Tambah item baru jika belum ada
        await _getCartRef().doc(newItem.id).set(newItem.toJson());
        _items.add(newItem);
      }

      notifyListeners();
    } catch (e) {
      print('Error adding item to cart: $e');
      rethrow;
    }
  }

  // Update quantity item
  Future<void> updateQuantity(int index, int change) async {
    try {
      final item = _items[index];
      final newQuantity = item.quantity + change;

      if (newQuantity <= 0) {
        // Hapus item jika quantity 0
        await _getCartRef().doc(item.id).delete();
        _items.removeAt(index);
      } else {
        // Update quantity
        await _getCartRef().doc(item.id).update({
          'quantity': newQuantity,
        });
        item.quantity = newQuantity;
      }

      notifyListeners();
    } catch (e) {
      print('Error updating quantity: $e');
      rethrow;
    }
  }

  // Toggle selection item
  Future<void> toggleSelection(int index) async {
    try {
      final item = _items[index];
      await _getCartRef().doc(item.id).update({
        'isSelected': !item.isSelected,
      });
      item.isSelected = !item.isSelected;
      notifyListeners();
    } catch (e) {
      print('Error toggling selection: $e');
      rethrow;
    }
  }

  // Hitung total harga
  double calculateTotal() {
    return _items.fold(0, (sum, item) {
      if (item.isSelected) {
        return sum +
            (double.parse(
                    item.harga.replaceAll("Rp ", "").replaceAll(".", "")) *
                item.quantity);
      }
      return sum;
    });
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _getCartRef().get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _items.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }
}
