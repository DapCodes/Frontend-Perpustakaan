import 'package:flutter/material.dart';
import 'package:perpustakaan/models/buku_model.dart';
import 'package:perpustakaan/pages/buku/buku_edit_screen.dart';
import 'package:perpustakaan/pages/peminjaman/peminjaman_create_screen.dart';
import 'package:perpustakaan/services/buku_service.dart';

class DetailBukuScreen extends StatefulWidget {
  final int bukuId;
  const DetailBukuScreen({Key? key, required this.bukuId}) : super(key: key);

  @override
  State<DetailBukuScreen> createState() => _DetailBukuScreenState();
}

class _DetailBukuScreenState extends State<DetailBukuScreen> {
  late Future<Buku> _futureBuku;

  // Color palette
  static const primaryGreen = Color(0xFF2E7D32);
  static const leafGreen = Color(0xFF66BB6A);
  static const creamWhite = Color(0xFFF9F9F6);
  static const warmGray = Color(0xFF9E9E9E);
  static const charcoalBlack = Color(0xFF212121);
  static const amber = Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    _futureBuku = BukuService.showBuku(widget.bukuId);
  }

  void _refreshBuku() {
    setState(() {
      _futureBuku = BukuService.showBuku(widget.bukuId);
    });
  }

  void _navigateToEdit(Buku buku) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BukuEditScreen(buku: buku),
      ),
    );

    if (result == true) {
      _refreshBuku();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Buku berhasil diperbarui"),
            backgroundColor: primaryGreen,
          ),
        );
      }
    }
  }

  void _navigateToPinjamBuku(Buku buku) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PeminjamanCreateScreen(
          selectedBuku: buku,
        ),
      ),
    );

    if (result == true) {
      _refreshBuku();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Peminjaman berhasil dibuat"),
            backgroundColor: primaryGreen,
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
          "Detail Buku",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        actions: [
          FutureBuilder<Buku>(
            future: _futureBuku,
            builder: (context, snapshot) {
              return IconButton(
                onPressed: snapshot.hasData
                    ? () => _navigateToEdit(snapshot.data!)
                    : null,
                icon: const Icon(Icons.edit, color: Colors.white),
              );
            },
          ),
          IconButton(
            onPressed: () {
              _showDeleteDialog();
            },
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<Buku>(
        future: _futureBuku,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      "Terjadi Kesalahan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: warmGray),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshBuku,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 64, color: warmGray),
                    const SizedBox(height: 16),
                    Text(
                      "Data Tidak Ditemukan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: charcoalBlack,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final buku = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Cover Image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            'http://127.0.0.1:8000/storage/${buku.cover}',
                            height: 280,
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 280,
                              width: 200,
                              decoration: BoxDecoration(
                                color: creamWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: warmGray.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_stories,
                                    size: 64,
                                    color: leafGreen,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Cover tidak tersedia",
                                    style: TextStyle(
                                      color: warmGray,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        buku.judul ?? 'Judul tidak tersedia',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: charcoalBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Info Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: leafGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.info_outline,
                                  color: primaryGreen, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Informasi Buku",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: charcoalBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow(Icons.person_outline, "Penulis",
                            buku.penulis ?? 'Tidak tersedia'),
                        _buildInfoRow(Icons.business, "Penerbit",
                            buku.penerbit ?? 'Tidak tersedia'),
                        _buildInfoRow(Icons.calendar_today, "Tahun Terbit",
                            buku.tahunTerbit?.toString() ?? 'Tidak tersedia'),
                        _buildInfoRow(Icons.category, "Kategori",
                            buku.kategori?.namaKategori ?? 'Tidak tersedia'),
                        _buildInfoRow(
                          Icons.inventory_2,
                          "Stok",
                          "${buku.stok ?? 0} buku",
                          valueColor:
                              (buku.stok ?? 0) > 0 ? primaryGreen : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: leafGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.touch_app,
                                  color: primaryGreen, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Aksi",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: charcoalBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Pinjam Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: (buku.stok ?? 0) > 0
                                ? () => _navigateToPinjamBuku(buku)
                                : null,
                            icon: Icon(
                              (buku.stok ?? 0) > 0
                                  ? Icons.book_online
                                  : Icons.block,
                              color: Colors.white,
                            ),
                            label: Text(
                              (buku.stok ?? 0) > 0
                                  ? "Pinjam Buku"
                                  : "Stok Habis",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (buku.stok ?? 0) > 0
                                  ? primaryGreen
                                  : warmGray,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Edit Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToEdit(buku),
                            icon: Icon(Icons.edit, color: leafGreen),
                            label: const Text(
                              "Edit Buku",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: leafGreen,
                              side: BorderSide(color: leafGreen, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: leafGreen),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: warmGray,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? charcoalBlack,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red[400], size: 24),
            const SizedBox(width: 12),
            const Text(
              "Hapus Buku",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: charcoalBlack,
              ),
            ),
          ],
        ),
        content: const Text(
          "Yakin ingin menghapus buku ini? Tindakan ini tidak dapat dibatalkan.",
          style: TextStyle(color: warmGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: warmGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => _deleteBuku(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Hapus",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBuku() async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: const Row(
          children: [
            CircularProgressIndicator(color: primaryGreen),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                "Menghapus buku...",
                style: TextStyle(color: charcoalBlack),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final success = await BukuService.deleteBuku(widget.bukuId);

      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Buku berhasil dihapus"),
              backgroundColor: primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  "Buku tidak bisa dihapus karena masih ada yang meminjam."),
              backgroundColor: amber,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        String errorMessage = "Terjadi kesalahan saat menghapus buku";

        if (e.toString().contains('Token tidak valid')) {
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        } else if (e.toString().contains('Network')) {
          errorMessage = "Koneksi internet bermasalah";
        } else if (e.toString().contains('404')) {
          errorMessage = "Buku tidak ditemukan";
        } else if (e.toString().contains('403')) {
          errorMessage = "Anda tidak memiliki izin untuk menghapus buku ini";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: () => _showDeleteDialog(),
            ),
          ),
        );
      }
    }
  }
}
