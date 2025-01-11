class MakananberatModel {
  final String id;
  final String nama;
  final String harga;
  final String deskripsi;
  final String image;
  final String kategori;

  MakananberatModel(
      {required this.id,
      required this.nama,
      required this.harga,
      required this.deskripsi,
      required this.image,
      required this.kategori});

  factory MakananberatModel.fromJson(Map data) {
    return MakananberatModel(
        id: data['_id'],
        nama: data['nama'],
        harga: data['harga'],
        deskripsi: data['deskripsi'],
        image: data['image'],
        kategori: data['kategori']);
  }
}

class PesananModel {
  final String id;
  final String pesanan_yang_di_pesan;
  final String alamat;
  final String pengiriman;
  final String pembayaran;
  final String subtotal;
  final String status_pesanan;
  final String userid;

  PesananModel(
      {required this.id,
      required this.pesanan_yang_di_pesan,
      required this.alamat,
      required this.pengiriman,
      required this.pembayaran,
      required this.subtotal,
      required this.status_pesanan,
      required this.userid});

  factory PesananModel.fromJson(Map data) {
    return PesananModel(
        id: data['_id'],
        pesanan_yang_di_pesan: data['pesanan_yang_di_pesan'],
        alamat: data['alamat'],
        pengiriman: data['pengiriman'],
        pembayaran: data['pembayaran'],
        subtotal: data['subtotal'],
        status_pesanan: data['status_pesanan'],
        userid: data['userid']);
  }
}
