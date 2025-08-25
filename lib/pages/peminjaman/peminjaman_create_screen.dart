import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/peminjaman_service.dart';
import '../../services/auth_service.dart';
import '../../services/buku_service.dart';
import '../../models/buku_model.dart';

class PeminjamanCreateScreen extends StatefulWidget {
  final Buku? selectedBuku; // Add parameter to pre-select a book
  const PeminjamanCreateScreen({Key? key, this.selectedBuku}) : super(key: key);

  @override
  State<PeminjamanCreateScreen> createState() => _PeminjamanCreateScreenState();
}

class _PeminjamanCreateScreenState extends State<PeminjamanCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final PeminjamanService _peminjamanService = PeminjamanService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoadingBuku = true;

  // Color palette - same as BukuCreateScreen
  static const primaryGreen = Color(0xFF2E7D32);
  static const leafGreen = Color(0xFF66BB6A);
  static const creamWhite = Color(0xFFF9F9F6);
  static const warmGray = Color(0xFF9E9E9E);
  static const charcoalBlack = Color(0xFF212121);
  static const amber = Color(0xFFFFC107);

  // User data
  Map<String, dynamic>? _currentUser;
  int? _userId;

  // Buku data
  List<Buku> _bukuList = [];
  Buku? _selectedBuku;

  // Controllers
  final TextEditingController _stokDipinjamController =
      TextEditingController(text: '1');
  final TextEditingController _tanggalPinjamController =
      TextEditingController();
  final TextEditingController _tenggatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setDefaultDates();
  }

  Future<void> _initializeData() async {
    await _loadCurrentUser();
    await _loadBukuList();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getProfile();
      setState(() {
        _currentUser = user;
        _userId = user!['id']; // Assuming the user ID field is 'id'
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadBukuList() async {
    try {
      setState(() {
        _isLoadingBuku = true;
      });

      final bukus = await BukuService.fetchBukus();
      setState(() {
        _bukuList = bukus;

        // If there's a pre-selected book, set it as selected
        if (widget.selectedBuku != null) {
          _selectedBuku = _bukuList.firstWhere(
            (buku) => buku.id == widget.selectedBuku!.id,
            orElse: () => widget.selectedBuku!,
          );
        }

        _isLoadingBuku = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBuku = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data buku: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setDefaultDates() {
    // Set default tanggal_pinjam to today
    final today = DateTime.now();
    _tanggalPinjamController.text =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Set default tenggat to 7 days from today
    final defaultTenggat = today.add(const Duration(days: 7));
    _tenggatController.text =
        '${defaultTenggat.year}-${defaultTenggat.month.toString().padLeft(2, '0')}-${defaultTenggat.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
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
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data user tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedBuku == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih buku terlebih dahulu'),
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
        'user_id': _userId!,
        'buku_id': _selectedBuku!.id,
        'stok_dipinjam': int.parse(_stokDipinjamController.text),
        'tanggal_pinjam': _tanggalPinjamController.text,
        'tenggat': _tenggatController.text,
        'status': 'dipinjam',
      };

      await _peminjamanService.createPeminjaman(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil dibuat'),
            backgroundColor: primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
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
            content: Text('Gagal membuat peminjaman: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  void _resetForm() {
    _selectedBuku = null;
    _stokDipinjamController.text = '1';
    _setDefaultDates();
    _formKey.currentState?.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamWhite,
      appBar: AppBar(
        title: const Text(
          'Tambah Peminjaman',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
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
                        child: Icon(Icons.library_books,
                            color: primaryGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Informasi Peminjaman",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: charcoalBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
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
                            widget.selectedBuku != null
                                ? 'Peminjaman untuk buku "${widget.selectedBuku!.judul}" atas nama ${_currentUser?['name'] ?? 'Loading...'}'
                                : 'Peminjaman akan dibuat atas nama ${_currentUser?['name'] ?? 'Loading...'}',
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
                  const SizedBox(height: 24),

                  // User Info Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: creamWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: warmGray.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: leafGreen, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Peminjam',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: warmGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _currentUser?['name'] ?? 'Loading...',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: charcoalBlack,
                                ),
                              ),
                              Text(
                                _currentUser?['email'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: warmGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buku Dropdown
                  DropdownButtonFormField<Buku>(
                    value: _selectedBuku,
                    decoration: InputDecoration(
                      labelText: 'Pilih Buku *',
                      labelStyle: const TextStyle(color: warmGray),
                      hintText: _isLoadingBuku
                          ? 'Memuat data buku...'
                          : 'Pilih buku yang akan dipinjam',
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
                    items: _isLoadingBuku
                        ? []
                        : _bukuList.map((Buku buku) {
                            return DropdownMenuItem<Buku>(
                              value: buku,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${buku.judul} | Stok: ${buku.stok}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: charcoalBlack,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    onChanged: _isLoadingBuku
                        ? null
                        : (Buku? newValue) {
                            setState(() {
                              _selectedBuku = newValue;
                            });
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih buku yang akan dipinjam';
                      }
                      return null;
                    },
                    isExpanded: true,
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
                        return 'Jumlah dipinjam harus diisi';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'Jumlah dipinjam harus berupa angka positif';
                      }
                      if (_selectedBuku != null && qty > _selectedBuku!.stok) {
                        return 'Jumlah melebihi stok tersedia (${_selectedBuku!.stok})';
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

                  // Status Display (Read-only)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Peminjaman',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: warmGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'DIPINJAM',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                            onPressed: (_isLoading || _isLoadingBuku)
                                ? null
                                : _submitForm,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              'Buat Peminjaman',
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
