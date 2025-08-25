import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:perpustakaan/models/buku_model.dart';
import 'package:perpustakaan/services/buku_service.dart';
import 'package:perpustakaan/services/kategori_service.dart';
import 'package:perpustakaan/models/kategori_model.dart';

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
  Uint8List? _coverBytes;
  String? _coverName;
  bool _isLoading = false;
  bool _isLoadingKategori = true;

  List<Datum> _kategoris = [];
  int? _selectedKategoriId;

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
    _loadKategoris();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _penulisController.dispose();
    _penerbitController.dispose();
    _tahunController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _loadKategoris() async {
    setState(() => _isLoadingKategori = true);
    try {
      final data = await KategoriService.fetchKategoris();
      if (mounted) {
        setState(() {
          _kategoris = data;
          _isLoadingKategori = false;
          _selectedKategoriId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingKategori = false);
        if (e.toString().contains('Token tidak valid')) {
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat kategori: $e"),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: _loadKategoris,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (mounted) {
          setState(() {
            _coverBytes = bytes;
            _coverName = picked.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengambil gambar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: primaryGreen),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (mounted) {
          setState(() {
            _coverBytes = bytes;
            _coverName = picked.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengambil gambar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    // Validasi form dan cover
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mohon lengkapi semua field yang wajib diisi"),
          backgroundColor: amber,
        ),
      );
      return;
    }

    if (_coverBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mohon pilih cover buku terlebih dahulu"),
          backgroundColor: amber,
        ),
      );
      return;
    }

    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mohon pilih kategori buku"),
          backgroundColor: amber,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await BukuService.createBuku(
        judul: _judulController.text.trim(),
        penulis: _penulisController.text.trim(),
        penerbit: _penerbitController.text.trim(),
        tahunTerbit: int.tryParse(_tahunController.text) ?? DateTime.now().year,
        stok: int.tryParse(_stokController.text) ?? 0,
        kategoriId: _selectedKategoriId!,
        coverBytes: _coverBytes!,
        coverName: _coverName ?? 'cover.jpg',
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Buku berhasil ditambahkan"),
              backgroundColor: primaryGreen,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gagal menambahkan buku. Silakan coba lagi."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        if (e.toString().contains('Token tidak valid')) {
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cover Buku *",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: charcoalBlack,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: _coverBytes == null
                    ? Colors.red.shade300
                    : warmGray.withOpacity(0.3),
                width: _coverBytes == null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color: _coverBytes == null ? creamWhite : Colors.white,
            ),
            child: _coverBytes != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          _coverBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 20),
                            onPressed: () {
                              setState(() {
                                _coverBytes = null;
                                _coverName = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 50, color: leafGreen),
                        const SizedBox(height: 12),
                        const Text(
                          "Pilih Cover Buku",
                          style: TextStyle(
                            color: charcoalBlack,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Tap untuk memilih dari galeri",
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
        if (_coverBytes == null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Cover buku wajib dipilih",
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamWhite,
      appBar: AppBar(
        title: const Text(
          "Tambah Buku",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
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
            child: Form(
              key: _formKey,
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
                        child: Icon(Icons.auto_stories,
                            color: primaryGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Informasi Buku",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: charcoalBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Field Judul
                  TextFormField(
                    controller: _judulController,
                    decoration: InputDecoration(
                      labelText: "Judul Buku *",
                      labelStyle: const TextStyle(color: warmGray),
                      prefixIcon: Icon(Icons.title, color: leafGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: warmGray.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: primaryGreen, width: 2),
                      ),
                      filled: true,
                      fillColor: creamWhite,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul buku wajib diisi';
                      }
                      if (value.trim().length < 3) {
                        return 'Judul buku minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Kategori
                  _isLoadingKategori
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child:
                                CircularProgressIndicator(color: primaryGreen),
                          ),
                        )
                      : DropdownButtonFormField<int>(
                          value: _selectedKategoriId,
                          decoration: InputDecoration(
                            labelText: "Kategori *",
                            labelStyle: const TextStyle(color: warmGray),
                            prefixIcon: Icon(Icons.category, color: leafGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: warmGray.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: primaryGreen, width: 2),
                            ),
                            filled: true,
                            fillColor: creamWhite,
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text(
                                "Pilih kategori",
                                style: TextStyle(color: warmGray),
                              ),
                            ),
                            ..._kategoris.map((kategori) {
                              return DropdownMenuItem<int>(
                                value: kategori.id!,
                                child: Text(
                                  kategori.namaKategori ??
                                      'Nama tidak tersedia',
                                  style: const TextStyle(color: charcoalBlack),
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedKategoriId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? "Kategori wajib dipilih" : null,
                        ),

                  const SizedBox(height: 20),

                  // Field Penulis
                  TextFormField(
                    controller: _penulisController,
                    decoration: InputDecoration(
                      labelText: "Penulis *",
                      labelStyle: const TextStyle(color: warmGray),
                      prefixIcon: Icon(Icons.person, color: leafGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: warmGray.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: primaryGreen, width: 2),
                      ),
                      filled: true,
                      fillColor: creamWhite,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama penulis wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Field Penerbit
                  TextFormField(
                    controller: _penerbitController,
                    decoration: InputDecoration(
                      labelText: "Penerbit *",
                      labelStyle: const TextStyle(color: warmGray),
                      prefixIcon: Icon(Icons.business, color: leafGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: warmGray.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: primaryGreen, width: 2),
                      ),
                      filled: true,
                      fillColor: creamWhite,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama penerbit wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Row untuk Tahun dan Stok
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tahunController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Tahun Terbit *",
                            labelStyle: const TextStyle(color: warmGray),
                            prefixIcon:
                                Icon(Icons.calendar_today, color: leafGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: warmGray.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: primaryGreen, width: 2),
                            ),
                            filled: true,
                            fillColor: creamWhite,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Tahun wajib diisi';
                            }
                            final tahun = int.tryParse(value.trim());
                            if (tahun == null) {
                              return 'Tahun harus angka';
                            }
                            if (tahun < 1900 ||
                                tahun > DateTime.now().year + 1) {
                              return 'Tahun tidak valid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stokController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Stok *",
                            labelStyle: const TextStyle(color: warmGray),
                            prefixIcon: Icon(Icons.inventory, color: leafGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: warmGray.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: primaryGreen, width: 2),
                            ),
                            filled: true,
                            fillColor: creamWhite,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Stok wajib diisi';
                            }
                            final stok = int.tryParse(value.trim());
                            if (stok == null) {
                              return 'Stok harus angka';
                            }
                            if (stok < 0) {
                              return 'Stok tidak boleh negatif';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section Cover
                  _buildCoverSection(),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: _isLoading
                        ? Container(
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              "Simpan Buku",
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
                              elevation: 3,
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
