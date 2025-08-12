import 'package:flutter/material.dart';
import 'package:perpustakaan/models/buku_model.dart';
import 'package:perpustakaan/pages/buku/buku_create_screen.dart';
import 'package:perpustakaan/pages/buku/buku_detail_screen.dart';
import 'package:perpustakaan/services/buku_service.dart';

class BukuListScreen extends StatefulWidget {
  const BukuListScreen({super.key});

  @override
  State<BukuListScreen> createState() => _BukuListScreenState();
}

class _BukuListScreenState extends State<BukuListScreen> {
  late Future<List<Buku>> _futureBukus;

  @override
  void initState() {
    super.initState();
    _loadBukus();
  }

  void _loadBukus() {
    _futureBukus = BukuService.fetchBukus();
  }

  Future<void> _refreshBukus() async {
    setState(() => _loadBukus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BukuCreateScreen()),
          );
          _refreshBukus();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Buku>>(
        future: _futureBukus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final bukus = snapshot.data ?? [];

          if (bukus.isEmpty)
            return const Center(child: Text("Tidak ada buku."));

          return RefreshIndicator(
            onRefresh: _refreshBukus,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bukus.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final buku = bukus[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailBukuScreen(bukuId: buku.id),
                      ),
                    );
                    _refreshBukus();
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'http://127.0.0.1:8000/storage/${buku.cover}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(
                        buku.judul,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        buku.penulis,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
