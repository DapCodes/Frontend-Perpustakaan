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

  // Color palette matching BukuListScreen
  static const primaryGreen = Color(0xFF2E7D32);
  static const leafGreen = Color(0xFF66BB6A);
  static const creamWhite = Color(0xFFF9F9F6);
  static const warmGray = Color(0xFF9E9E9E);
  static const charcoalBlack = Color(0xFF212121);

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Konfirmasi Hapus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: charcoalBlack,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus kategori "$namaKategori"?',
          style: TextStyle(color: charcoalBlack),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: warmGray,
            ),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await KategoriService.deleteKategori(id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Kategori berhasil dihapus'),
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _refreshKategori();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gagal menghapus kategori'),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamWhite,
      appBar: AppBar(
          title: const Text(
            'Daftar Kategori',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: primaryGreen,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.white)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateKategoriScreen()),
          );
          if (result == true) _refreshKategori();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<Kategori>(
        future: _futureKategori,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: charcoalBlack),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshKategori,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final kategoriList = snapshot.data?.data ?? [];

          if (kategoriList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: warmGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada kategori',
                    style: TextStyle(
                      fontSize: 18,
                      color: charcoalBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah kategori baru',
                    style: TextStyle(color: warmGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: primaryGreen,
            onRefresh: () async => _refreshKategori(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: kategoriList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final kategori = kategoriList[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Category Icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: leafGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.category_rounded,
                            color: primaryGreen,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Category Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kategori.namaKategori ?? 'Tanpa Nama',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: charcoalBlack,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.tag,
                                    size: 14,
                                    color: warmGray,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ID: ${kategori.id}',
                                    style: TextStyle(
                                      color: warmGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                color: Colors.blue,
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditKategoriScreen(
                                          kategori: kategori),
                                    ),
                                  );
                                  if (result == true) _refreshKategori();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                color: Colors.red,
                                tooltip: 'Hapus',
                                onPressed: () => _deleteKategori(
                                  kategori.id ?? 0,
                                  kategori.namaKategori ?? '',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
