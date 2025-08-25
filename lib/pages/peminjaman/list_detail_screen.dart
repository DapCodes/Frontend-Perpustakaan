import 'package:flutter/material.dart';
import '../../models/peminjaman_model.dart';
import '../../services/peminjaman_service.dart';
import 'list_edit_screen.dart';

class ListDetailScreen extends StatefulWidget {
  final int peminjamanId;

  const ListDetailScreen({
    Key? key,
    required this.peminjamanId,
  }) : super(key: key);

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final PeminjamanService _peminjamanService = PeminjamanService();
  late Future<PeminjamanModel> _peminjamanFuture;
  bool _isDeleting = false;

  // Color palette (sama dengan DetailBukuScreen)
  static const primaryGreen = Color(0xFF2E7D32);
  static const leafGreen = Color(0xFF66BB6A);
  static const creamWhite = Color(0xFFF9F9F6);
  static const warmGray = Color(0xFF9E9E9E);
  static const charcoalBlack = Color(0xFF212121);
  static const amber = Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  void _loadPeminjaman() {
    _peminjamanFuture =
        _peminjamanService.getPeminjamanById(widget.peminjamanId);
  }

  Future<void> _deletePeminjaman() async {
    final shouldDelete = await showDialog<bool>(
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
              'Hapus Peminjaman',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: charcoalBlack,
              ),
            ),
          ],
        ),
        content: const Text(
          'Yakin ingin menghapus data peminjaman ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: warmGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: warmGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // Show loading dialog
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
                  "Menghapus peminjaman...",
                  style: TextStyle(color: charcoalBlack),
                ),
              ),
            ],
          ),
        ),
      );

      try {
        await _peminjamanService.deletePeminjaman(widget.peminjamanId);
        
        if (mounted) Navigator.pop(context); // Close loading dialog
        
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman berhasil dihapus'),
              backgroundColor: primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Close loading dialog
        
        if (mounted) {
          String errorMessage = "Terjadi kesalahan saat menghapus peminjaman";
          
          if (e.toString().contains('Token tidak valid')) {
            Navigator.of(context).pushReplacementNamed('/login');
            return;
          } else if (e.toString().contains('Network')) {
            errorMessage = "Koneksi internet bermasalah";
          } else if (e.toString().contains('404')) {
            errorMessage = "Peminjaman tidak ditemukan";
          } else if (e.toString().contains('403')) {
            errorMessage = "Anda tidak memiliki izin untuk menghapus peminjaman ini";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: () => _deletePeminjaman(),
              ),
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return amber;
      case 'dikembalikan':
        return primaryGreen;
      case 'terlambat':
        return Colors.red;
      default:
        return warmGray;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return Icons.schedule;
      case 'dikembalikan':
        return Icons.check_circle;
      case 'terlambat':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamWhite,
      appBar: AppBar(
        title: const Text(
          'Detail Peminjaman',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        actions: [
          FutureBuilder<PeminjamanModel>(
            future: _peminjamanFuture,
            builder: (context, snapshot) {
              return IconButton(
                onPressed: snapshot.hasData && !_isDeleting
                    ? () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListEditScreen(
                              peminjaman: snapshot.data!,
                            ),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            _loadPeminjaman();
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Peminjaman berhasil diperbarui"),
                                backgroundColor: primaryGreen,
                              ),
                            );
                          }
                        }
                      }
                    : null,
                icon: const Icon(Icons.edit, color: Colors.white),
              );
            },
          ),
          IconButton(
            onPressed: _isDeleting ? null : () => _deletePeminjaman(),
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<PeminjamanModel>(
        future: _peminjamanFuture,
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
                    const Text(
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
                      onPressed: () {
                        setState(() {
                          _loadPeminjaman();
                        });
                      },
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
                    const Text(
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

          final peminjaman = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
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
                      // Status Icon & Text
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _getStatusColor(peminjaman.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          _getStatusIcon(peminjaman.status),
                          size: 48,
                          color: _getStatusColor(peminjaman.status),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        peminjaman.status,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(peminjaman.status),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID Peminjaman: ${peminjaman.id}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: warmGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Informasi Peminjaman Card
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
                              "Informasi Peminjaman",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: charcoalBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow(
                          Icons.person_outline,
                          "Peminjam",
                          peminjaman.user?.name ?? 'User ID: ${peminjaman.userId}',
                        ),
                        _buildInfoRow(
                          Icons.book_outlined,
                          "Buku",
                          peminjaman.buku?.judul ?? 'Buku ID: ${peminjaman.bukuId}',
                        ),
                        _buildInfoRow(
                          Icons.format_list_numbered,
                          "Jumlah",
                          "${peminjaman.stokDipinjam} buku",
                          valueColor: primaryGreen,
                        ),
                        _buildInfoRow(
                          Icons.calendar_today,
                          "Tanggal Pinjam",
                          peminjaman.tanggalPinjam,
                        ),
                        _buildInfoRow(
                          Icons.event_available,
                          "Tenggat",
                          peminjaman.tenggat,
                          valueColor: Colors.orange,
                        ),
                        _buildInfoRow(
                          Icons.assignment_turned_in,
                          "Tanggal Kembali",
                          peminjaman.tanggalPengembalian ?? 'Belum dikembalikan',
                          valueColor: peminjaman.tanggalPengembalian != null 
                              ? primaryGreen 
                              : warmGray,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Informasi Tambahan Card
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
                              child: Icon(Icons.schedule,
                                  color: primaryGreen, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Informasi Sistem",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: charcoalBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow(
                          Icons.add_circle_outline,
                          "Dibuat",
                          peminjaman.createdAt,
                        ),
                        _buildInfoRow(
                          Icons.update,
                          "Diperbarui",
                          peminjaman.updatedAt,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons Card
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

                        // Edit Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _isDeleting
                                ? null
                                : () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListEditScreen(
                                          peminjaman: peminjaman,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      setState(() {
                                        _loadPeminjaman();
                                      });
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Peminjaman berhasil diperbarui"),
                                            backgroundColor: primaryGreen,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              "Edit Peminjaman",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Delete Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: _isDeleting ? null : _deletePeminjaman,
                            icon: _isDeleting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                    ),
                                  )
                                : const Icon(Icons.delete),
                            label: Text(
                              _isDeleting ? 'Menghapus...' : 'Hapus Peminjaman',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red, width: 2),
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
}