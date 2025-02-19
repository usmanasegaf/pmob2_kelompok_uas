import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pmob2_kelompok_uas/history.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart'; // Import qr_flutter package

class OpenFileScreen extends StatelessWidget {
  final bool isScan;
  final String itemId;

  const OpenFileScreen({Key? key, required this.isScan, required this.itemId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OpenFileUI(isScan: isScan, itemId: itemId),
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OpenFileUI extends StatefulWidget {
  final bool isScan;
  final String itemId;

  const OpenFileUI({Key? key, required this.isScan, required this.itemId})
      : super(key: key);

  @override
  State<OpenFileUI> createState() => _OpenFileUIState();
}

class _OpenFileUIState extends State<OpenFileUI> {
  Map<String, dynamic> reportData = {};
  bool isLoading = true;
  String errorMessage = '';

  final String baseUrl =
      'https://purring-scratch-plutonium.glitch.me'; // Tambahkan baseUrl

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    final jenisLaporan = widget.isScan ? 'scan' : 'create';
    final url = Uri.parse(
        '$baseUrl/api/laporan/$jenisLaporan/${widget.itemId}'); // Gunakan baseUrl

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          reportData = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'Data tidak ditemukan';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Gagal memuat data. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan koneksi: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildQrCode(String qrCodeData) {
    if (qrCodeData.startsWith("data:image/png;base64,")) {
      String base64Image = qrCodeData.split(',')[1];
      Uint8List bytes = base64Decode(base64Image);
      return Image.memory(bytes, width: 200, height: 200);
    } else {
      return QrImageView(
        data: qrCodeData,
        version: QrVersions.auto,
        size: 200.0,
        foregroundColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Text(errorMessage,
                          style: TextStyle(color: Colors.orange)))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  debugPrint("Tombol Back");
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => const History()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.arrow_back,
                                      color: Colors.orange),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Detail Laporan',
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Card Data
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        color: Colors.orange),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reportData['nama_laporan'] ??
                                              'Tidak ada Nama Laporan',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          reportData['tanggal'] != null
                                              ? "${reportData['tanggal']}"
                                                  .split('T')[0]
                                              : 'Tidak ada Tanggal',
                                          style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildDetailRow('Lokasi', reportData['lokasi']),
                                _buildDetailRow(
                                    'Deskripsi', reportData['deskripsi']),
                                const SizedBox(height: 10),
                                Center(
                                  child:
                                      _buildQrCode(reportData['qr_code'] ?? ''),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value ?? 'Tidak ada data',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
