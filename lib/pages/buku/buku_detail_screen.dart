import 'package:flutter/material.dart';
import 'package:perpustakaan/models/buku_model.dart';
import 'package:perpustakaan/services/buku_service.dart';

class DetailBukuScreen extends StatefulWidget {
  final int bukuId;

  const DetailBukuScreen({Key? key, required this.bukuId}) : super(key: key);

  @override
  State<DetailBukuScreen> createState() => _DetailBukuScreenState();
}

class _DetailBukuScreenState extends State<DetailBukuScreen> {
  late Future<Buku> _futureBuku;

  @override
  void initState() {
    super.initState();
    _futureBuku = BukuService.showBuku(widget.bukuId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Buku"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Buku>(
        future: _futureBuku,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Data buku tidak ditemukan"));
          }

          final buku = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Buku
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://127.0.0.1:8000/storage/${buku.cover}',
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 80),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  buku.judul,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Penulis: ${buku.penulis}"),
                Text("Penerbit: ${buku.penerbit}"),
                Text("Tahun Terbit: ${buku.tahun_terbit}"),
                Text("Stok: ${buku.stok}"),
                Text("Kategori: ${buku.kategori_id}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
