import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:perpustakaan/services/buku_service.dart';

class BukuCreateScreen extends StatefulWidget {
  const BukuCreateScreen({super.key});

  @override
  State<BukuCreateScreen> createState() => _BukuCreateScreenState();
}

class _BukuCreateScreenState extends State<BukuCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _penulisController = TextEditingController();
  final _penerbitController = TextEditingController();
  final _tahunController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final _stokController = TextEditingController();
  final _kategoriIdController = TextEditingController(text: "1");

  Uint8List? _coverBytes;
  String? _coverName;
  bool _isLoading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _coverBytes = bytes;
        _coverName = picked.name;
      });
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() || _coverBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua field dan pilih cover")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await BukuService.createBuku(
      judul: _judulController.text,
      penulis: _penulisController.text,
      penerbit: _penerbitController.text,
      tahunTerbit: int.tryParse(_tahunController.text) ?? DateTime.now().year,
      stok: int.tryParse(_stokController.text) ?? 0,
      kategoriId: int.tryParse(_kategoriIdController.text) ?? 1,
      coverBytes: _coverBytes!,
      coverName: _coverName!,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Buku berhasil ditambahkan")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menambahkan buku")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Buku"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Buku",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _judulController,
                    decoration: const InputDecoration(
                      labelText: "Judul",
                      prefixIcon: Icon(Icons.book),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _penulisController,
                    decoration: const InputDecoration(
                      labelText: "Penulis",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _penerbitController,
                    decoration: const InputDecoration(
                      labelText: "Penerbit",
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tahunController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Tahun Terbit",
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stokController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Stok",
                      prefixIcon: Icon(Icons.inventory),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _kategoriIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Kategori ID",
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Cover Buku",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: _coverBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _coverBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.add_a_photo, size: 50),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: submit,
                            icon: const Icon(Icons.save),
                            label: const Text("Simpan Buku"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
