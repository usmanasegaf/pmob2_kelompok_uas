import 'package:flutter/material.dart';
import 'package:pmob2_kelompok_uas/history.dart';
import 'package:pmob2_kelompok_uas/make_report.dart';
import 'package:pmob2_kelompok_uas/settings.dart';
import 'package:camera/camera.dart';
import 'package:pmob2_kelompok_uas/show_qr.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // Tambahkan import http package

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  CameraController? _cameraController;
  bool _isCameraAvailable = true;
  String? scannedData;
  bool _isFlashOn = false;
  bool _isRearCameraSelected = true;

  final String baseUrl =
      'https://purring-scratch-plutonium.glitch.me'; // Tambahkan baseUrl

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 13, end: 255).animate(_animationController)
          ..addListener(() {
            setState(() {});
          });

    _fetchDataFromBackend(); // Panggil fungsi untuk fetch data saat initState
    _initializeCamera();
  }

  void _scanQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.orange,
        title:
            const Text("Scan QR Code", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          height: 250,
          width: 250,
          child: MobileScanner(
            onDetect: (capture) async {
              final List<Barcode>? barcodes = capture.barcodes;
              if (barcodes != null && barcodes.isNotEmpty) {
                final Barcode barcode = barcodes.first;
                final rawValue = barcode.rawValue;
                if (rawValue != null) {
                  // Validasi format JSON
                  try {
                    // Mencoba parse JSON
                    final jsonData = json.decode(rawValue);

                    // Validasi field yang diperlukan
                    if (jsonData is Map<String, dynamic> &&
                        jsonData['nama_laporan'] != null &&
                        jsonData['lokasi'] != null &&
                        jsonData['tanggal'] != null &&
                        jsonData['deskripsi'] != null) {
                      setState(() {
                        scannedData = rawValue;
                      });

                      if (mounted) {
                        Navigator.pop(context); // Tutup dialog scanner
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowQr(scannedData: rawValue),
                          ),
                        );
                      }
                    } else {
                      // JSON valid tapi tidak memiliki field yang diperlukan
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'QR Code tidak sesuai format yang diperlukan'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // Bukan format JSON yang valid
                    setState(() {
                      scannedData = rawValue;
                    });

                    if (mounted) {
                      Navigator.pop(context); // Tutup dialog scanner
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowQr(scannedData: rawValue),
                        ),
                      );
                    }
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        CameraDescription selectedCamera;

        if (_isRearCameraSelected) {
          selectedCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () =>
                cameras.first, // Default to first camera if rear not found
          );
        } else {
          selectedCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () =>
                cameras.first, // Default to first camera if front not found
          );
        }

        _cameraController =
            CameraController(selectedCamera, ResolutionPreset.medium);
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
        }
      } else {
        setState(() {
          _isCameraAvailable = false;
        });
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
      setState(() {
        _isCameraAvailable = false;
      });
    }
  }

  Future<void> _scanQRCodeFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      // User cancelled image picking
      return;
    }

    final filePath = pickedFile.path;
    final mobileScanner = MobileScannerController();

    try {
      final BarcodeCapture? capture =
          await mobileScanner.analyzeImage(filePath); // Get BarcodeCapture?
      if (capture != null && capture.barcodes.isNotEmpty) {
        // Check if capture is not null and barcodes is not empty
        final Barcode barcode = capture.barcodes.first;
        final rawValue = barcode.rawValue;
        if (rawValue != null) {
          // Validasi format JSON
          try {
            final jsonData = json.decode(rawValue);

            // Validasi field yang diperlukan
            if (jsonData is Map<String, dynamic> &&
                jsonData['nama_laporan'] != null &&
                jsonData['lokasi'] != null &&
                jsonData['tanggal'] != null &&
                jsonData['deskripsi'] != null) {
              setState(() {
                scannedData = rawValue;
              });

              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowQr(scannedData: rawValue),
                  ),
                );
              }
            } else {
              // JSON valid tapi tidak memiliki field yang diperlukan
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('QR Code tidak sesuai format yang diperlukan'),
                  ),
                );
              }
            }
          } catch (e) {
            // Bukan format JSON yang valid
            setState(() {
              scannedData = rawValue;
            });

            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowQr(scannedData: rawValue),
                ),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code tidak terdeteksi'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning QR Code: ${e.toString()}'),
          ),
        );
      }
    } finally {
      mobileScanner.dispose();
    }
  }

  // Fungsi untuk mengontrol flash
  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint("Error toggling flash: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling flash: ${e.toString()}'),
        ),
      );
    }
  }

  // Fungsi untuk memutar kamera
  void _rotateCamera() async {
    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
    });
    await _initializeCamera();
  }

  // Fungsi contoh untuk mengambil data dari backend
  Future<void> _fetchDataFromBackend() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/laporan_scan')); // Contoh endpoint
      if (response.statusCode == 200) {
        debugPrint('Data dari backend berhasil diambil: ${response.body}');
        // Anda bisa melakukan sesuatu dengan data ini, misalnya menyimpannya di state
      } else {
        debugPrint(
            'Gagal mengambil data dari backend. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data from backend: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Kamera
          Center(
            child: _isCameraAvailable &&
                    _cameraController?.value.isInitialized == true
                ? AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: const Text(
                      'Device has no camera',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Bagian atas - Ikon-ikon (Gallery, Flash, Camera, Menu)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 48.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Gallery
                      InkWell(
                        onTap: () {
                          _scanQRCodeFromGallery();
                          debugPrint('Gallery button tapped');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.photo_library,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      // Tombol Flash
                      InkWell(
                        onTap: () {
                          _toggleFlash();
                          debugPrint('Flash button tapped');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      // Tombol Rotate Camera
                      InkWell(
                        onTap: () {
                          _rotateCamera();
                          debugPrint('Rotate camera button tapped');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.flip_camera_ios,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      // Tombol Menu
                      InkWell(
                        onTap: () {
                          debugPrint('Menu button tapped');
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const Settings()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.menu, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tengah - Area Frame QR Code dan Garis Scan
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Frame QR Code (Kotak Putih dengan Opacity)
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),

                        // Stack untuk Sudut-sudut Orange dan Garis Scan
                        SizedBox(
                          width: 270,
                          height: 270,
                          child: Stack(
                            children: [
                              // Sudut Kiri Atas (Orange)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(9),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4)),
                                  ),
                                ),
                              ),
                              // Sudut Kanan Atas (Orange)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(9),
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4)),
                                  ),
                                ),
                              ),
                              // Sudut Kiri Bawah (Orange)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(9),
                                        topRight: Radius.circular(4),
                                        topLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4)),
                                  ),
                                ),
                              ),
                              // Sudut Kanan Bawah (Orange)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(9),
                                      topRight: Radius.circular(4),
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),

                              // Garis Scan Animasi
                              Positioned(
                                top: _animation.value,
                                left: 20,
                                right: 20,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange.withOpacity(0),
                                            Colors.orange,
                                            Colors.orange.withOpacity(0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 15,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.orange.withOpacity(0.2),
                                            Colors.orange.withOpacity(0),
                                          ],
                                        ),
                                      ),
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

                // Bawah - Tombol Generate, Scan, History
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol Generate
                      InkWell(
                        onTap: () {
                          debugPrint('Generate button tapped');
                          //setelah generate:
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const MakeReport()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.qr_code,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Generate',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tombol Scan (Orange)
                      InkWell(
                        onTap: () {
                          _scanQRCode();
                          debugPrint('Scan button tapped');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(Icons.qr_code_scanner,
                                color: Colors.white, size: 32),
                          ),
                        ),
                      ),

                      // Tombol History
                      InkWell(
                        onTap: () {
                          debugPrint('History button tapped');
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const History()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.history,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'History',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
