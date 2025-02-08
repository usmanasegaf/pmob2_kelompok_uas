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
      home: HistoryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Saat sudah ada database digantikan dengan yang berasa dari database:
    List<String> historyScanItems = [
      'Nama Laporan - lokasi - 15 Mei 2024, 09:30',
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
    //baiknya data sudah terurut dari database
    List<String> historyCreateItems = [
      'Nama Laporan - lokasi - 15 Mei 2025, 09:30',
      'Nama Laporan - lokasi - 16 Mei 2025, 10:30',
      'Nama Laporan - lokasi - 17 Mei 2025, 12:00',
      'Nama Laporan - lokasi - 18 Mei 2025, 14:30',
      'Nama Laporan - lokasi - 19 Mei 2025, 15:00',
      'Nama Laporan - lokasi - 20 Mei 2025, 16:30',
      'Nama Laporan - lokasi - 15 Mei 2025, 09:30',
      'Nama Laporan - lokasi - 16 Mei 2025, 10:30',
      'Nama Laporan - lokasi - 17 Mei 2025, 12:00',
      'Nama Laporan - lokasi - 18 Mei 2025, 14:30',
      'Nama Laporan - lokasi - 19 Mei 2025, 15:00',
      'Nama Laporan - lokasi - 20 Mei 2025, 16:30',
    ];

    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
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
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.orange),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
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
                  color: Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
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
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Create',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: historyScanItems.length,
                itemBuilder: (context, index) {
                  final parts = historyScanItems[index].split(' - ');

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2C2C2C),
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
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.qr_code_2,
                                      color: Colors.orange, size: 24),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          parts[0],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          parts[1],
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    parts[2],
                                    style: TextStyle(
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
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.delete_outline,
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
