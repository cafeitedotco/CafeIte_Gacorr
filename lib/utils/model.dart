class MakananberatModel {
   final String id;
   final String nama;
   final String harga;
   final String deskripsi;
   final String image;

   MakananberatModel({
      required this.id,
      required this.nama,
      required this.harga,
      required this.deskripsi,
      required this.image
   });

   factory MakananberatModel.fromJson(Map data) {
      return MakananberatModel(
         id: data['_id'],
         nama: data['nama'],
         harga: data['harga'],
         deskripsi: data['deskripsi'],
         image: data['image']
      );
   }
}