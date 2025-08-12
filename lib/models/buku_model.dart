class Buku {
  final int id;
  final String kode_buku;
  final String judul;
  final String penulis;
  final String penerbit;
  final int tahun_terbit;
  final int stok;
  final int kategori_id;
  final String cover;

  Buku({
    required this.id,
    required this.kode_buku,
    required this.judul,
    required this.penulis,
    required this.penerbit,
    required this.tahun_terbit,
    required this.stok,
    required this.kategori_id,
    required this.cover,
  });

  factory Buku.fromJson(Map<String, dynamic> json) {
    return Buku(
      id: json['id'],
      kode_buku: json['kode_buku'],
      judul: json['judul'],
      penulis: json['penulis'],
      penerbit: json['penerbit'],
      tahun_terbit: json['tahun_terbit'],
      stok: json['stok'],
      // stok: int.parse(json['stok'].toString()),
      kategori_id: json['kategori_id'],
      cover: json['cover'],
    );
  }
}
