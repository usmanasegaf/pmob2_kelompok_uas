import 'package:flutter/material.dart';
import 'package:pmob2_kelompok_uas/history.dart';
import 'package:pmob2_kelompok_uas/make_report.dart';
import 'package:pmob2_kelompok_uas/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Container berwarna abu-abu
          Container(
            color: const Color.fromARGB(141, 66, 66, 66),
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
                            child: const Icon(Icons.flash_off,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      // Tombol Camera
                      InkWell(
                        onTap: () {
                          debugPrint('Camera button tapped');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      // Tombol Menu
                      InkWell(
                        onTap: () {
                          debugPrint('Menu button tapped');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Settings()),
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MakeReport()),
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const History()),
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
