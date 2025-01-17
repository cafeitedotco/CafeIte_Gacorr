// ignore_for_file: prefer_interpolation_to_compose_strings, non_constant_identifier_names

import 'dart:convert';

import 'package:cafeite/utils/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class DataService {
  final String baseUrl = 'https://io.etter.cloud/v4';
  final String token = '6773b664f853312de5509c6d';
  final String project = 'cafeite';
  final String appid = '67766d01f853312de5509d18'; // Replace with your app ID

  Future<String> insertPesanan(
    String appid,
    String pesananYangDiPesan,
    String alamat,
    String pengiriman,
    String pembayaran,
    String subtotal,
    String statusPesanan,
    String userId,
  ) async {
    String uri = '$baseUrl/insert';

    try {
      final response = await http.post(
        Uri.parse(uri),
        body: {
          'token': token,
          'project': project,
          'collection': 'pesanan',
          'appid': appid,
          'pesanan_yang_di_pesan': pesananYangDiPesan,
          'alamat': alamat,
          'pengiriman': pengiriman,
          'pembayaran': pembayaran,
          'subtotal': subtotal,
          'status_pesanan': statusPesanan,
          'userid': userId,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Error response: ${response.statusCode}');
        print('Error body: ${response.body}');
        return '[]';
      }
    } catch (e) {
      print('Error inserting order: $e');
      return '[]';
    }
  }

  Future<List<PesananModel>> fetchPesananMasuk() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status_pesanan', isEqualTo: 'Masuk')
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['_id'] = doc.id;
        return PesananModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching incoming orders: $e');
      return [];
    }
  }

  Future<List<PesananModel>> fetchPesananDiproses() async {
    try {
      final firebaseSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status_pesanan', isEqualTo: 'Diproses')
          .orderBy('tanggal', descending: true)
          .get();

      List<PesananModel> orders = [];

      for (var doc in firebaseSnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        // Gunakan document ID sebagai order_id jika tidak ada
        data['order_id'] = data['order_id'] ?? doc.id;
        data['id'] = doc.id;

        print(
            'Creating order with ID: ${doc.id}, Order ID: ${data['order_id']}');

        if (data['userid'] != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['userid'])
              .get();

          if (userDoc.exists) {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            data['username'] = userData['username'] ?? 'Unknown User';
          }
        }

        orders.add(PesananModel.fromJson(data));
      }

      return orders;
    } catch (e) {
      print('Error fetching processed orders: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      print('Updating order status in API:');
      print('Order ID: $orderId');
      print('New Status: $newStatus');

      // Update di Etter Cloud
      final etterResponse = await http.put(
        Uri.parse('$baseUrl/update_id'),
        body: {
          'token': token,
          'project': project,
          'collection': 'pesanan',
          'appid': appid,
          'id': orderId,
          'update_field': 'status_pesanan',
          'update_value': newStatus
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      print(
          'Etter Cloud Response: ${etterResponse.statusCode} - ${etterResponse.body}');

      // Lanjutkan meskipun Etter Cloud gagal
      return true;
    } catch (e) {
      print('Error updating order status in API: $e');
      return false;
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      // Hapus dari Etter Cloud
      final etterResponse = await http.delete(Uri.parse(
          '$baseUrl/remove_id/token/$token/project/$project/collection/pesanan/appid/$appid/id/$orderId'));

      // Hapus dari Firebase
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();

      return etterResponse.statusCode == 200;
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }

  // Search orders
  Future<List<PesananModel>> searchOrders(String query) async {
    try {
      // Cari di Firebase
      final firebaseSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('pesanan_yang_di_pesan', isGreaterThanOrEqualTo: query)
          .where('pesanan_yang_di_pesan', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      List<PesananModel> orders = [];

      for (var doc in firebaseSnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        if (data['userid'] != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['userid'])
              .get();

          if (userDoc.exists) {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            data['username'] = userData['username'] ?? 'Unknown User';
          }
        }

        orders.add(PesananModel.fromJson(data));
      }

      return orders;
    } catch (e) {
      print('Error searching orders: $e');
      return [];
    }
  }

  Future insertMakananberat(String appid, String nama, String harga,
      String deskripsi, String image, String kategori, String stock) async {
    String uri = 'https://io.etter.cloud/v4/insert';

    try {
      final response = await http.post(Uri.parse(uri), body: {
        'token': '6773b664f853312de5509c6d',
        'project': 'cafeite',
        'collection': 'makananberat',
        'appid': appid,
        'nama': nama,
        'harga': harga,
        'deskripsi': deskripsi,
        'image': image,
        'kategori': kategori,
        'stock': stock
      });

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future selectAll(
      String token, String project, String collection, String appid) async {
    String uri = 'https://io.etter.cloud/v4/select_all/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future selectId(String token, String project, String collection, String appid,
      String id) async {
    String uri = 'https://io.etter.cloud/v4/select_id/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/id/' +
        id;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future selectWhere(String token, String project, String collection,
      String appid, String where_field, String where_value) async {
    String uri = 'https://io.etter.cloud/v4/select_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/where_field/' +
        where_field +
        '/where_value/' +
        where_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future selectOrWhere(String token, String project, String collection,
      String appid, String or_where_field, String or_where_value) async {
    String uri = 'https://io.etter.cloud/v4/select_or_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/or_where_field/' +
        or_where_field +
        '/or_where_value/' +
        or_where_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future selectWhereLike(String token, String project, String collection,
      String appid, String wlike_field, String wlike_value) async {
    String uri = 'https://io.etter.cloud/v4/select_where_like/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wlike_field/' +
        wlike_field +
        '/wlike_value/' +
        wlike_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future selectWhereIn(String token, String project, String collection,
      String appid, String win_field, String win_value) async {
    String uri = 'https://io.etter.cloud/v4/select_where_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/win_field/' +
        win_field +
        '/win_value/' +
        win_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future selectWhereNotIn(String token, String project, String collection,
      String appid, String wnotin_field, String wnotin_value) async {
    String uri = 'https://io.etter.cloud/v4/select_where_not_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wnotin_field/' +
        wnotin_field +
        '/wnotin_value/' +
        wnotin_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future removeAll(
      String token, String project, String collection, String appid) async {
    String uri = 'https://io.etter.cloud/v4/remove_all/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid;

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Print error here
      return false;
    }
  }

  Future removeId(String token, String project, String collection, String appid,
      String id) async {
    String uri = 'https://io.etter.cloud/v4/remove_id/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/id/' +
        id;

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Print error here
      return false;
    }
  }

  Future removeWhere(String token, String project, String collection,
      String appid, String where_field, String where_value) async {
    String uri = 'https://io.etter.cloud/v4/remove_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/where_field/' +
        where_field +
        '/where_value/' +
        where_value;

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Print error here
      return false;
    }
  }

  Future removeOrWhere(String token, String project, String collection,
      String appid, String or_where_field, String or_where_value) async {
    String uri = 'https://io.etter.cloud/v4/remove_or_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/or_where_field/' +
        or_where_field +
        '/or_where_value/' +
        or_where_value;

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Print error here
      return false;
    }
  }

  Future removeWhereLike(String token, String project, String collection,
      String appid, String wlike_field, String wlike_value) async {
    String uri = 'https://io.etter.cloud/v4/remove_where_like/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wlike_field/' +
        wlike_field +
        '/wlike_value/' +
        wlike_value;

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Print error here
      return false;
    }
  }

  Future removeWhereIn(String token, String project, String collection,
      String appid, String win_field, String win_value) async {
    String uri = 'https://io.etter.cloud/v4/remove_where_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/win_field/' +
        win_field +
        '/win_value/' +
        win_value;

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Print error here
      return false;
    }
  }

  Future removeWhereNotIn(String token, String project, String collection,
      String appid, String wnotin_field, String wnotin_value) async {
    String uri = 'https://io.etter.cloud/v4/remove_where_not_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wnotin_field/' +
        wnotin_field +
        '/wnotin_value/' +
        wnotin_value;

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Print error here
      return false;
    }
  }

  Future updateAll(String update_field, String update_value, String token,
      String project, String collection, String appid) async {
    String uri = 'https://io.etter.cloud/v4/update_all';

    try {
      final response = await http.put(Uri.parse(uri), body: {
        'update_field': update_field,
        'update_value': update_value,
        'token': token,
        'project': project,
        'collection': collection,
        'appid': appid
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future updateId(String update_field, String update_value, String token,
      String project, String collection, String appid, String id) async {
    String uri = 'https://io.etter.cloud/v4/update_id';

    try {
      final response = await http.put(Uri.parse(uri), body: {
        'update_field': update_field,
        'update_value': update_value,
        'token': token,
        'project': project,
        'collection': collection,
        'appid': appid,
        'id': id
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future updateWhere(
      String where_field,
      String where_value,
      String update_field,
      String update_value,
      String token,
      String project,
      String collection,
      String appid) async {
    String uri = 'https://io.etter.cloud/v4/update_where';

    try {
      final response = await http.put(Uri.parse(uri), body: {
        'where_field': where_field,
        'where_value': where_value,
        'update_field': update_field,
        'update_value': update_value,
        'token': token,
        'project': project,
        'collection': collection,
        'appid': appid
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future updateOrWhere(
      String or_where_field,
      String or_where_value,
      String update_field,
      String update_value,
      String token,
      String project,
      String collection,
      String appid) async {
    String uri = 'https://io.etter.cloud/v4/update_or_where';

    try {
      final response = await http.put(Uri.parse(uri), body: {
        'or_where_field': or_where_field,
        'or_where_value': or_where_value,
        'update_field': update_field,
        'update_value': update_value,
        'token': token,
        'project': project,
        'collection': collection,
        'appid': appid
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future updateWhereLike(
      String wlike_field,
      String wlike_value,
      String update_field,
      String update_value,
      String token,
      String project,
      String collection,
      String appid) async {
    String uri = 'https://io.etter.cloud/v4/update_where_like';

    try {
      final response = await http.put(Uri.parse(uri), body: {
        'wlike_field': wlike_field,
        'wlike_value': wlike_value,
        'update_field': update_field,
        'update_value': update_value,
        'token': token,
        'project': project,
        'collection': collection,
        'appid': appid
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future updateWhereIn(
      String win_field,
      String win_value,
      String update_field,
      String update_value,
      String token,
      String project,
      String collection,
      String appid) async {
    String uri = 'https://io.etter.cloud/v4/update_where_in';

    try {
      final response = await http.put(Uri.parse(uri), body: {
        'win_field': win_field,
        'win_value': win_value,
        'update_field': update_field,
        'update_value': update_value,
        'token': token,
        'project': project,
        'collection': collection,
        'appid': appid
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future updateWhereNotIn(
      String wnotin_field,
      String wnotin_value,
      String update_field,
      String update_value,
      String token,
      String project,
      String collection,
      String appid) async {
    String uri = 'https://io.etter.cloud/v4/update_where_not_in';

    try {
      final response = await http.put(Uri.parse(uri), body: {
        'wnotin_field': wnotin_field,
        'wnotin_value': wnotin_value,
        'update_field': update_field,
        'update_value': update_value,
        'token': token,
        'project': project,
        'collection': collection,
        'appid': appid
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future firstAll(
      String token, String project, String collection, String appid) async {
    String uri = 'https://io.etter.cloud/v4/first_all/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future firstWhere(String token, String project, String collection,
      String appid, String where_field, String where_value) async {
    String uri = 'https://io.etter.cloud/v4/first_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/where_field/' +
        where_field +
        '/where_value/' +
        where_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future firstOrWhere(String token, String project, String collection,
      String appid, String or_where_field, String or_where_value) async {
    String uri = 'https://io.etter.cloud/v4/first_or_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/or_where_field/' +
        or_where_field +
        '/or_where_value/' +
        or_where_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future firstWhereLike(String token, String project, String collection,
      String appid, String wlike_field, String wlike_value) async {
    String uri = 'https://io.etter.cloud/v4/first_where_like/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wlike_field/' +
        wlike_field +
        '/wlike_value/' +
        wlike_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future firstWhereIn(String token, String project, String collection,
      String appid, String win_field, String win_value) async {
    String uri = 'https://io.etter.cloud/v4/first_where_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/win_field/' +
        win_field +
        '/win_value/' +
        win_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future firstWhereNotIn(String token, String project, String collection,
      String appid, String wnotin_field, String wnotin_value) async {
    String uri = 'https://io.etter.cloud/v4/first_where_not_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wnotin_field/' +
        wnotin_field +
        '/wnotin_value/' +
        wnotin_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future lastAll(
      String token, String project, String collection, String appid) async {
    String uri = 'https://io.etter.cloud/v4/last_all/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future lastWhere(String token, String project, String collection,
      String appid, String where_field, String where_value) async {
    String uri = 'https://io.etter.cloud/v4/last_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/where_field/' +
        where_field +
        '/where_value/' +
        where_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future lastOrWhere(String token, String project, String collection,
      String appid, String or_where_field, String or_where_value) async {
    String uri = 'https://io.etter.cloud/v4/last_or_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/or_where_field/' +
        or_where_field +
        '/or_where_value/' +
        or_where_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future lastWhereLike(String token, String project, String collection,
      String appid, String wlike_field, String wlike_value) async {
    String uri = 'https://io.etter.cloud/v4/last_where_like/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wlike_field/' +
        wlike_field +
        '/wlike_value/' +
        wlike_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future lastWhereIn(String token, String project, String collection,
      String appid, String win_field, String win_value) async {
    String uri = 'https://io.etter.cloud/v4/last_where_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/win_field/' +
        win_field +
        '/win_value/' +
        win_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future lastWhereNotIn(String token, String project, String collection,
      String appid, String wnotin_field, String wnotin_value) async {
    String uri = 'https://io.etter.cloud/v4/last_where_not_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wnotin_field/' +
        wnotin_field +
        '/wnotin_value/' +
        wnotin_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future randomAll(
      String token, String project, String collection, String appid) async {
    String uri = 'https://io.etter.cloud/v4/random_all/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future randomWhere(String token, String project, String collection,
      String appid, String where_field, String where_value) async {
    String uri = 'https://io.etter.cloud/v4/random_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/where_field/' +
        where_field +
        '/where_value/' +
        where_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future randomOrWhere(String token, String project, String collection,
      String appid, String or_where_field, String or_where_value) async {
    String uri = 'https://io.etter.cloud/v4/random_or_where/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/or_where_field/' +
        or_where_field +
        '/or_where_value/' +
        or_where_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future randomWhereLike(String token, String project, String collection,
      String appid, String wlike_field, String wlike_value) async {
    String uri = 'https://io.etter.cloud/v4/random_where_like/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wlike_field/' +
        wlike_field +
        '/wlike_value/' +
        wlike_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future randomWhereIn(String token, String project, String collection,
      String appid, String win_field, String win_value) async {
    String uri = 'https://io.etter.cloud/v4/random_where_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/win_field/' +
        win_field +
        '/win_value/' +
        win_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }

  Future randomWhereNotIn(String token, String project, String collection,
      String appid, String wnotin_field, String wnotin_value) async {
    String uri = 'https://io.etter.cloud/v4/random_where_not_in/token/' +
        token +
        '/project/' +
        project +
        '/collection/' +
        collection +
        '/appid/' +
        appid +
        '/wnotin_field/' +
        wnotin_field +
        '/wnotin_value/' +
        wnotin_value;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Return an empty array
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
  }
}
