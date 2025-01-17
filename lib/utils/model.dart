// lib/models/models.dart

class MakananModel {
  final String id;
  final String nama;
  final String harga;
  final String deskripsi;
  final String image;
  final String kategori;
  final String stock;

  MakananModel(
      {required this.id,
      required this.nama,
      required this.harga,
      required this.deskripsi,
      required this.image,
      required this.kategori,
      required this.stock});

  factory MakananModel.fromJson(Map<String, dynamic> json) {
    return MakananModel(
        id: json['_id'] ?? '',
        nama: json['nama'] ?? '',
        harga: json['harga'] ?? '',
        deskripsi: json['deskripsi'] ?? '',
        image: json['image'] ?? '',
        kategori: json['kategori'] ?? '',
        stock: json['stock'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nama': nama,
      'harga': harga,
      'deskripsi': deskripsi,
      'image': image,
      'kategori': kategori,
      'stock': stock,
    };
  }
}

class PesananModel {
  final String id;
  final String appid;
  final String order_id; // Tambahkan field ini
  final String pesanan_yang_di_pesan;
  final String alamat;
  final String pengiriman;
  final String pembayaran;
  final String subtotal;
  String status_pesanan;
  final String userid;
  final String username;
  final String email;
  final String tanggal;
  final String total;
  final String quantity;

  PesananModel({
    required this.id,
    required this.appid,
    required this.order_id, // Tambahkan ini
    required this.pesanan_yang_di_pesan,
    required this.alamat,
    required this.pengiriman,
    required this.pembayaran,
    required this.subtotal,
    required this.status_pesanan,
    required this.userid,
    required this.username,
    required this.email,
    required this.tanggal,
    required this.total,
    this.quantity = '1',
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    return PesananModel(
      id: json['_id'] ?? '',
      appid: json['appid'] ?? '',
      order_id: json['order_id'] ?? '', // Tambahkan ini
      pesanan_yang_di_pesan: json['pesanan_yang_di_pesan'] ?? '',
      alamat: json['alamat'] ?? '',
      pengiriman: json['pengiriman'] ?? '',
      pembayaran: json['pembayaran'] ?? '',
      subtotal: json['subtotal'] ?? '',
      status_pesanan: json['status_pesanan'] ?? '',
      userid: json['userid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      tanggal: json['tanggal'] ?? '',
      total: json['total'] ?? '',
      quantity: json['quantity'] ?? '1',
    );
  }
}
