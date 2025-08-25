import 'package:flutter/material.dart';
import '../../models/peminjaman_model.dart';
import '../../services/peminjaman_service.dart';
import 'list_detail_screen.dart';
import 'peminjaman_create_screen.dart';

class ListPeminjamanScreen extends StatefulWidget {
  const ListPeminjamanScreen({Key? key}) : super(key: key);

  @override
  State<ListPeminjamanScreen> createState() => _ListPeminjamanScreenState();
}

class _ListPeminjamanScreenState extends State<ListPeminjamanScreen> {
  final PeminjamanService _peminjamanService = PeminjamanService();
  late Future<List<PeminjamanModel>> _peminjamanFuture;

  // Color palette - same as BukuListScreen
  static const primaryGreen = Color(0xFF2E7D32);
  static const leafGreen = Color(0xFF66BB6A);
  static const creamWhite = Color(0xFFF9F9F6);
  static const warmGray = Color(0xFF9E9E9E);
  static const charcoalBlack = Color(0xFF212121);

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  void _loadPeminjaman() {
    _peminjamanFuture = _peminjamanService.getAllPeminjaman();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadPeminjaman();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamWhite,
      appBar: AppBar(
        title: const Text(
          'Daftar Peminjaman',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryGreen,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PeminjamanCreateScreen(),
            ),
          );
          if (result == true) {
            _refreshData();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<PeminjamanModel>>(
        future: _peminjamanFuture,
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
                  const Icon(
                    Icons.error_outline,
                    color: primaryGreen,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: charcoalBlack),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    color: warmGray,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada peminjaman.',
                    style: TextStyle(
                      color: charcoalBlack,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final peminjamanList = snapshot.data!;

          return RefreshIndicator(
            color: primaryGreen,
            onRefresh: _refreshData,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: peminjamanList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final peminjaman = peminjamanList[index];
                final isActive = peminjaman.status.toLowerCase() == 'dipinjam';

                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListDetailScreen(
                          peminjamanId: peminjaman.id,
                        ),
                      ),
                    );
                    if (result == true) {
                      _refreshData();
                    }
                  },
                  child: Container(
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
                          // Status Icon
                          Container(
                            width: 70,
                            height: 95,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isActive
                                  ? Colors.orange.withOpacity(0.1)
                                  : leafGreen.withOpacity(0.1),
                              border: Border.all(
                                color: isActive
                                    ? Colors.orange.withOpacity(0.3)
                                    : leafGreen.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              isActive ? Icons.book : Icons.check_circle,
                              color: isActive ? Colors.orange : leafGreen,
                              size: 32,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Peminjaman Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  peminjaman.buku?.judul ??
                                      'Buku ID: ${peminjaman.bukuId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: charcoalBlack,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: warmGray,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        peminjaman.user?.name ??
                                            'User ID: ${peminjaman.userId}',
                                        style: const TextStyle(
                                          color: warmGray,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.orange.withOpacity(0.1)
                                        : leafGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    peminjaman.status,
                                    style: TextStyle(
                                      color:
                                          isActive ? Colors.orange : leafGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Detail Button
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: leafGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Lihat Detail',
                                        style: TextStyle(
                                          color: primaryGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: primaryGreen,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
