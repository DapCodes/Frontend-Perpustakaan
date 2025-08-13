import 'package:flutter/material.dart';
import 'package:perpustakaan/models/kategori_model.dart';
import 'package:perpustakaan/services/kategori_service.dart';
import 'package:perpustakaan/pages/kategori/create_kategori_screen.dart';
import 'package:perpustakaan/pages/kategori/edit_kategori_screen.dart';

class ListKategori extends StatefulWidget {
  const ListKategori({super.key});

  @override
  State<ListKategori> createState() => _ListKategoriState();
}

class _ListKategoriState extends State<ListKategori> {
  late Future<Kategori> _futureKategori;

  @override
  void initState() {
    super.initState();
    _futureKategori = KategoriService.listKategoris();
  }

  void _refreshKategori() {
    setState(() {
      _futureKategori = KategoriService.listKategoris();
    });
  }

  Future<void> _deleteKategori(int id, String namaKategori) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content:
            Text('Apakah Anda yakin ingin menghapus kategori "$namaKategori"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await KategoriService.deleteKategori(id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kategori berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshKategori();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus kategori'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Kategori'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshKategori,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateKategoriScreen()),
              );
              if (result == true) _refreshKategori();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Kategori',
          ),
        ],
      ),
      body: FutureBuilder<Kategori>(
        future: _futureKategori,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshKategori,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final kategoriList = snapshot.data?.data ?? [];

          if (kategoriList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada kategori',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah kategori baru',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: kategoriList.length,
            itemBuilder: (context, index) {
              final kategori = kategoriList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    kategori.namaKategori ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'ID: ${kategori.id}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditKategoriScreen(kategori: kategori),
                            ),
                          );
                          if (result == true) _refreshKategori();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Hapus',
                        onPressed: () => _deleteKategori(
                          kategori.id ?? 0,
                          kategori.namaKategori ?? '',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
