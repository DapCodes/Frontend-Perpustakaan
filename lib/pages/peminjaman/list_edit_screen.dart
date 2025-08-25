import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/peminjaman_model.dart';
import '../../services/peminjaman_service.dart';

class ListEditScreen extends StatefulWidget {
  final PeminjamanModel? peminjaman;

  const ListEditScreen({
    Key? key,
    this.peminjaman,
  }) : super(key: key);

  @override
  State<ListEditScreen> createState() => _ListEditScreenState();
}

class _ListEditScreenState extends State<ListEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final PeminjamanService _peminjamanService = PeminjamanService();

  bool get _isEditMode => widget.peminjaman != null;
  bool _isLoading = false;

  // Color palette - consistent with other screens
  static const primaryGreen = Color(0xFF2E7D32);
  static const leafGreen = Color(0xFF66BB6A);
  static const creamWhite = Color(0xFFF9F9F6);
  static const warmGray = Color(0xFF9E9E9E);
  static const charcoalBlack = Color(0xFF212121);
  static const amber = Color(0xFFFFC107);

  // Controllers
  late TextEditingController _userIdController;
  late TextEditingController _bukuIdController;
  late TextEditingController _stokDipinjamController;
  late TextEditingController _tanggalPinjamController;
  late TextEditingController _tenggatController;

  // Data untuk menampilkan nama dan judul buku
  String _namaPeminjam = '';
  String _judulBuku = '';
  bool _isLoadingData = false;

  String _selectedStatus = 'dipinjam';
  final List<String> _statusOptions = ['dipinjam', 'dikembalikan'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (_isEditMode) {
      _loadPeminjamanData();
    }
  }

  void _initializeControllers() {
    final peminjaman = widget.peminjaman;

    _userIdController = TextEditingController(
      text: peminjaman?.userId.toString() ?? '',
    );
    _bukuIdController = TextEditingController(
      text: peminjaman?.bukuId.toString() ?? '',
    );
    _stokDipinjamController = TextEditingController(
      text: peminjaman?.stokDipinjam.toString() ?? '',
    );
    _tanggalPinjamController = TextEditingController(
      text: peminjaman?.tanggalPinjam ?? '',
    );
    _tenggatController = TextEditingController(
      text: peminjaman?.tenggat ?? '',
    );

    if (peminjaman != null) {
      _selectedStatus = peminjaman.status.toLowerCase();
    }
  }

  Future<void> _loadPeminjamanData() async {
    if (!_isEditMode) return;

    setState(() {
      _isLoadingData = true;
    });

    try {
      // Jika data user dan buku sudah ada di model, gunakan langsung
      if (widget.peminjaman!.user != null && widget.peminjaman!.buku != null) {
        setState(() {
          _namaPeminjam = widget.peminjaman!.user!.name;
          _judulBuku = widget.peminjaman!.buku!.judul;
          _isLoadingData = false;
        });
      } else {
        // Jika tidak ada, ambil data detail dari API
        final peminjamanDetail =
            await _peminjamanService.getPeminjamanById(widget.peminjaman!.id);

        if (mounted) {
          setState(() {
            _namaPeminjam = peminjamanDetail.user?.name ?? 'Tidak diketahui';
            _judulBuku = peminjamanDetail.buku?.judul ?? 'Tidak diketahui';
            _isLoadingData = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _namaPeminjam = 'Gagal memuat';
          _judulBuku = 'Gagal memuat';
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _bukuIdController.dispose();
    _stokDipinjamController.dispose();
    _tanggalPinjamController.dispose();
    _tenggatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller,
      {DateTime? firstDate}) async {
    DateTime initialDate = DateTime.now();

    // If controller has a date, use it as initial date
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        initialDate = DateTime.now();
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mohon lengkapi semua field yang wajib diisi"),
          backgroundColor: amber,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'user_id': int.parse(_userIdController.text),
        'buku_id': int.parse(_bukuIdController.text),
        'stok_dipinjam': int.parse(_stokDipinjamController.text),
        'tanggal_pinjam': _tanggalPinjamController.text,
        'tenggat': _tenggatController.text,
        'status': _selectedStatus,
      };

      if (_isEditMode) {
        await _peminjamanService.updatePeminjaman(widget.peminjaman!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman berhasil diperbarui'),
              backgroundColor: primaryGreen,
            ),
          );
        }
      } else {
        await _peminjamanService.createPeminjaman(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman berhasil dibuat'),
              backgroundColor: primaryGreen,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal ${_isEditMode ? 'memperbarui' : 'membuat'} peminjaman: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warmGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warmGray.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: warmGray, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: warmGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: charcoalBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: warmGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: warmGray.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Terkunci',
              style: TextStyle(
                color: warmGray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamWhite,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Peminjaman' : 'Buat Peminjaman',
          style: const TextStyle(
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
                  // Header Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: leafGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isEditMode ? Icons.edit : Icons.add,
                          color: primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isEditMode
                            ? 'Edit Peminjaman'
                            : 'Buat Peminjaman Baru',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: charcoalBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  if (_isEditMode)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: leafGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: leafGreen.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: primaryGreen),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mengedit peminjaman ID: ${widget.peminjaman!.id}',
                              style: TextStyle(
                                color: primaryGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // User ID Field (Read-only when editing)
                  if (_isEditMode)
                    _buildReadOnlyField(
                      label: 'ID & Nama Peminjam',
                      value: 'ID: ${_userIdController.text}',
                      subtitle: _isLoadingData ? 'Memuat...' : _namaPeminjam,
                      icon: Icons.person,
                    )
                  else
                    TextFormField(
                      controller: _userIdController,
                      decoration: InputDecoration(
                        labelText: 'ID Pengguna *',
                        labelStyle: const TextStyle(color: warmGray),
                        hintText: 'Masukkan ID pengguna',
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
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ID pengguna wajib diisi';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),

                  // Buku ID Field (Read-only when editing)
                  if (_isEditMode)
                    _buildReadOnlyField(
                      label: 'ID & Judul Buku',
                      value: 'ID: ${_bukuIdController.text}',
                      subtitle: _isLoadingData ? 'Memuat...' : _judulBuku,
                      icon: Icons.book,
                    )
                  else
                    TextFormField(
                      controller: _bukuIdController,
                      decoration: InputDecoration(
                        labelText: 'ID Buku *',
                        labelStyle: const TextStyle(color: warmGray),
                        hintText: 'Masukkan ID buku',
                        prefixIcon: Icon(Icons.book, color: leafGreen),
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
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ID buku wajib diisi';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),

                  // Stok Dipinjam Field
                  TextFormField(
                    controller: _stokDipinjamController,
                    decoration: InputDecoration(
                      labelText: 'Jumlah Dipinjam *',
                      labelStyle: const TextStyle(color: warmGray),
                      hintText: 'Masukkan jumlah buku yang dipinjam',
                      prefixIcon: Icon(Icons.numbers, color: leafGreen),
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah dipinjam wajib diisi';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Masukkan angka positif yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tanggal Pinjam Field
                  TextFormField(
                    controller: _tanggalPinjamController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Pinjam *',
                      labelStyle: const TextStyle(color: warmGray),
                      hintText: 'Pilih tanggal peminjaman',
                      prefixIcon: Icon(Icons.calendar_today, color: leafGreen),
                      suffixIcon: Icon(Icons.arrow_drop_down, color: leafGreen),
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
                    readOnly: true,
                    onTap: () => _selectDate(context, _tanggalPinjamController),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal pinjam harus dipilih';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tenggat Field
                  TextFormField(
                    controller: _tenggatController,
                    decoration: InputDecoration(
                      labelText: 'Tenggat Pengembalian *',
                      labelStyle: const TextStyle(color: warmGray),
                      hintText: 'Pilih batas waktu pengembalian',
                      prefixIcon: Icon(Icons.event, color: leafGreen),
                      suffixIcon: Icon(Icons.arrow_drop_down, color: leafGreen),
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
                    readOnly: true,
                    onTap: () {
                      DateTime? minDate;
                      if (_tanggalPinjamController.text.isNotEmpty) {
                        try {
                          minDate =
                              DateTime.parse(_tanggalPinjamController.text)
                                  .add(const Duration(days: 1));
                        } catch (e) {
                          minDate = DateTime.now().add(const Duration(days: 1));
                        }
                      }
                      _selectDate(context, _tenggatController,
                          firstDate: minDate);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tenggat pengembalian harus dipilih';
                      }
                      // Validate that tenggat is after tanggal_pinjam
                      if (_tanggalPinjamController.text.isNotEmpty) {
                        try {
                          final tanggalPinjam =
                              DateTime.parse(_tanggalPinjamController.text);
                          final tenggat = DateTime.parse(value);
                          if (tenggat.isBefore(tanggalPinjam) ||
                              tenggat.isAtSameMomentAs(tanggalPinjam)) {
                            return 'Tenggat harus setelah tanggal pinjam';
                          }
                        } catch (e) {
                          return 'Format tanggal tidak valid';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status Peminjaman *',
                      labelStyle: const TextStyle(color: warmGray),
                      prefixIcon: Icon(Icons.info, color: leafGreen),
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
                    items: _statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: status == 'dipinjam'
                                    ? Colors.orange
                                    : leafGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: charcoalBlack),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Status peminjaman harus dipilih';
                      }
                      return null;
                    },
                  ),
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
                            onPressed: _submitForm,
                            icon: Icon(
                              _isEditMode ? Icons.save : Icons.add,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isEditMode
                                  ? 'Perbarui Peminjaman'
                                  : 'Buat Peminjaman',
                              style: const TextStyle(
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
