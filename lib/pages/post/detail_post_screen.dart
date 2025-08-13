import 'package:flutter/material.dart';
import 'package:perpustakaan/pages/post/edit_post_screen.dart';
import 'package:perpustakaan/services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  final String postTitle; // Optional, untuk judul di AppBar

  const PostDetailScreen({
    super.key,
    required this.postId,
    this.postTitle = 'Detail Post',
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map<String, dynamic>? postData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadPostDetail();
  }

  Future<void> loadPostDetail() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final result = await PostService.showPost(widget.postId);

    setState(() {
      isLoading = false;
      if (result != null) {
        postData = result;
      } else {
        hasError = true;
      }
    });
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Post'),
        content: const Text('Apakah Anda yakin ingin menghapus post ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await PostService.deletePost(widget.postId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post berhasil dihapus')),
        );
        Navigator.pop(context, true); // Kembali dengan result true
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus post')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postTitle),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          if (!isLoading && !hasError && postData != null) ...[
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostScreen(
                      postId: widget.postId,
                      postData: postData!,
                    ),
                  ),
                );
                if (result == true) {
                  loadPostDetail(); // Refresh data setelah edit
                }
              },
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Post',
            ),
            IconButton(
              onPressed: _deletePost,
              icon: const Icon(Icons.delete),
              tooltip: 'Hapus Post',
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal memuat detail post',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: loadPostDetail,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover Image
                      if (postData!['image'] != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                'http://127.0.0.1:8000/storage/${postData!['image']}',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Title
                      Text(
                        postData!['title'] ?? 'Tanpa Judul',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: postData!['status'] == 1
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          postData!['status'] == 1 ? 'Published' : 'Draft',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      Text(
                        postData!['content'] ?? 'Tidak ada konten',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Created Date (jika ada)
                      if (postData!['created_at'] != null)
                        Text(
                          'Dibuat: ${postData!['created_at']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
