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

  // Color palette
  static const primaryGreen = Color(0xFF2E7D32);
  static const leafGreen = Color(0xFF66BB6A);
  static const creamWhite = Color(0xFFF9F9F6);
  static const warmGray = Color(0xFF9E9E9E);
  static const charcoalBlack = Color(0xFF212121);

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
      backgroundColor: creamWhite,
      appBar: AppBar(
        title: const Text(
          'Daftar Buku',
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
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BukuCreateScreen()),
          );
          _refreshBukus();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Buku>>(
        future: _futureBukus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );

          if (snapshot.hasError)
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: charcoalBlack),
              ),
            );

          final bukus = snapshot.data ?? [];

          if (bukus.isEmpty)
            return const Center(
              child: Text(
                "Tidak ada buku.",
                style: TextStyle(
                  color: charcoalBlack,
                  fontSize: 16,
                ),
              ),
            );

          return RefreshIndicator(
            color: primaryGreen,
            onRefresh: _refreshBukus,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bukus.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
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
                          // Book Cover
                          Container(
                            width: 70,
                            height: 95,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: creamWhite,
                              border: Border.all(
                                color: warmGray.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'http://127.0.0.1:8000/storage/${buku.cover}',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.auto_stories,
                                  color: leafGreen,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Book Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  buku.judul,
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
                                        buku.penulis,
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

                                const SizedBox(height: 12),

                                // Read More Button
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
