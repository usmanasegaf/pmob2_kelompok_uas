import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowQr extends StatelessWidget {
  final String scannedData;

  const ShowQr({super.key, required this.scannedData});

  @override
  Widget build(BuildContext context) {
    return ShowQrScreen(scannedData: scannedData);
  }
}

class ShowQrScreen extends StatefulWidget {
  final String scannedData;
  const ShowQrScreen({super.key, required this.scannedData});

  @override
  State<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends State<ShowQrScreen> {
  bool _isSaving = false;
  String? _errorMessage;
  final String baseUrl =
      'https://purring-scratch-plutonium.glitch.me'; // Tambahkan baseUrl

  Future<void> _saveQrToBackend() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    // Mencoba parse JSON dari scannedData
    Map<String, dynamic>? qrData;
    bool isValidFormat = false; // Inisialisasi isValidFormat di luar try-catch
    try {
      qrData = json.decode(widget.scannedData);
      isValidFormat = qrData != null &&
          qrData['nama_laporan'] != null &&
          qrData['lokasi'] != null &&
          qrData['tanggal'] != null &&
          qrData['deskripsi'] != null;
    } catch (e) {
      qrData = null;
      isValidFormat = false; // Format tetap tidak valid jika gagal parse JSON
    }

    Map<String, dynamic> dataToSave;
    if (isValidFormat) {
      // Jika format valid, kirim data dari QR Code
      dataToSave = json.decode(widget.scannedData);
    } else {
      // Jika format tidak valid, kirim data default dengan tanggal saat ini
      dataToSave = {
        'nama_laporan': 'Other QR', // Atau nilai default lain yang sesuai
        'lokasi': 'Other QR', // Atau nilai default lain yang sesuai
        'tanggal': DateTime.now()
            .toIso8601String(), // Gunakan tanggal saat ini dengan format ISO 8601
        'deskripsi':
            widget.scannedData, // Tetap kirim raw data sebagai deskripsi
        'qr_code': widget.scannedData, // Tetap kirim raw data untuk qr_code
      };
      setState(() {
        _errorMessage =
            'Format QR tidak sesuai, data yang disimpan adalah data default dengan tanggal saat ini.'; // Pesan error format tidak valid
      });
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scan'), // Gunakan baseUrl di sini
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode(dataToSave), // Kirim dataToSave (bisa dari QR atau default)
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code berhasil disimpan')),
          );
        }
      } else {
        throw Exception('Failed to save QR Code');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menyimpan QR Code: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mencoba parse JSON dari scannedData
    Map<String, dynamic>? qrData;
    try {
      qrData = json.decode(widget.scannedData);
    } catch (e) {
      qrData = null;
    }

    // Menentukan apakah QR valid sesuai format yang diinginkan
    bool isValidFormat = qrData != null &&
        qrData['nama_laporan'] != null &&
        qrData['lokasi'] != null &&
        qrData['tanggal'] != null &&
        qrData['deskripsi'] != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      debugPrint("Tombol Back");
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'QR Code',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                        Icon(
                          isValidFormat ? Icons.check_circle : Icons.warning,
                          color: isValidFormat ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isValidFormat
                                ? 'Format QR Valid'
                                : 'Format QR Tidak Sesuai',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (isValidFormat) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Nama Laporan: ${qrData['nama_laporan']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Lokasi: ${qrData['lokasi']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Tanggal: ${qrData['tanggal']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Deskripsi: ${qrData['deskripsi']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Text(
                        'Raw Data: ${widget.scannedData}',
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: widget.scannedData,
                    version: QrVersions.auto,
                    size: 150.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // Implementasi share
                          debugPrint("Tombol Share");
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.share, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Share',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      InkWell(
                        onTap: _isSaving ? null : _saveQrToBackend,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isSaving ? Colors.grey : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                )
                              : const Icon(Icons.save, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
