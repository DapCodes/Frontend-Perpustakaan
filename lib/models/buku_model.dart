import 'dart:convert';

List<Buku> bukuListFromJson(String str) =>
    List<Buku>.from(json.decode(str)["data"].map((x) => Buku.fromJson(x)));

class Buku {
  final int id;
  final String kodeBuku;
  final String judul;
  final String penulis;
  final String penerbit;
  final int tahunTerbit;
  final int stok;
  final String? cover;
  final Kategori? kategori;

  Buku({
    required this.id,
    required this.kodeBuku,
    required this.judul,
    required this.penulis,
    required this.penerbit,
    required this.tahunTerbit,
    required this.stok,
    this.cover,
    this.kategori,
  });

  factory Buku.fromJson(Map<String, dynamic> json) => Buku(
        id: json["id"],
        kodeBuku: json["kode_buku"],
        judul: json["judul"],
        penulis: json["penulis"],
        penerbit: json["penerbit"],
        tahunTerbit: json["tahun_terbit"],
        stok: json["stok"],
        cover: json["cover"],
        kategori: json["kategori"] == null
            ? null
            : Kategori.fromJson(json["kategori"]),
      );
}

class Kategori {
  final int id;
  final String namaKategori;

  Kategori({
    required this.id,
    required this.namaKategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
        id: json["id"],
        namaKategori: json["nama_kategori"],
      );
}
