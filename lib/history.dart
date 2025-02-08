import 'package:flutter/material.dart';
import 'package:pmob2_kelompok_uas/home.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const HistoryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isScanActive = true;
// formatnya saat dimasukkan seperti dicontoh bawah dengan "-" sebagai sekatnya
// diganti dengan yang ada di database
  List<String> historyScanItems = [
    'Nama Laporan Scan - lokasi - 15 Mei 2024, 09:30',
    'Nama Laporan - lokasi - 16 Mei 2024, 10:30',
    'Nama Laporan - lokasi - 17 Mei 2024, 12:00',
    'Nama Laporan - lokasi - 18 Mei 2024, 14:30',
    'Nama Laporan - lokasi - 19 Mei 2024, 15:00',
    'Nama Laporan - lokasi - 20 Mei 2024, 16:30',
    'Nama Laporan - lokasi - 15 Mei 2025, 09:30',
    'Nama Laporan - lokasi - 16 Mei 2025, 00:30',
    'Nama Laporan - lokasi - 17 Mei 2025, 02:00',
    'Nama Laporan - lokasi - 18 Mei 2025, 04:30',
    'Nama Laporan - lokasi - 19 Mei 2025, 05:00',
    'Nama Laporan - lokasi - 20 Mei 2025, 06:30',
  ];
// bagusnya sudah terurut dari database
  List<String> historyCreateItems = [
    'Nama Laporan Create - lokasi - 15 Mei 2025, 09:30',
    'Nama Laporan - lokasi - 16 Mei 2025, 00:30',
    'Nama Laporan - lokasi - 17 Mei 2025, 02:00',
    'Nama Laporan - lokasi - 18 Mei 2025, 04:30',
    'Nama Laporan - lokasi - 19 Mei 2025, 05:00',
    'Nama Laporan - lokasi - 20 Mei 2025, 06:30',
    'Nama Laporan - lokasi - 15 Mei 2025, 09:30',
    'Nama Laporan - lokasi - 16 Mei 2025, 00:30',
    'Nama Laporan - lokasi - 17 Mei 2025, 02:00',
    'Nama Laporan - lokasi - 18 Mei 2025, 04:30',
    'Nama Laporan - lokasi - 19 Mei 2025, 05:00',
    'Nama Laporan - lokasi - 20 Mei 2025, 06:30',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'History',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isScanActive = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isScanActive
                                ? Colors.orange
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Center(
                            child: Text(
                              'Scan',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isScanActive = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isScanActive
                                ? Colors.orange
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Center(
                            child: Text(
                              'Create',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: isScanActive
                    ? historyScanItems.length
                    : historyCreateItems.length,
                itemBuilder: (context, index) {
                  final items =
                      isScanActive ? historyScanItems : historyCreateItems;
                  final parts = items[index].split(' - ');
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              debugPrint('Item ${parts[0]} diklik');
                              debugPrint("Tombol buka history");
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.qr_code_2,
                                      color: Colors.orange, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          parts[0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          parts[1],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    parts[2],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            debugPrint('Hapus item ${parts[0]}');
                            debugPrint("Tombol Hapus");
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.orange, size: 20),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
