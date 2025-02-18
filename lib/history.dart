import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pmob2_kelompok_uas/home.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: const HistoryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isScanActive = true;
  List<Map<String, dynamic>> historyScanItems = [];
  List<Map<String, dynamic>> historyCreateItems = [];

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    try {
      final scanResponse =
          await http.get(Uri.parse('http://localhost:3000/api/laporan_scan'));
      final createResponse =
          await http.get(Uri.parse('http://localhost:3000/api/laporan_create'));

      if (scanResponse.statusCode == 200) {
        List<dynamic> scanData = json.decode(scanResponse.body);
        debugPrint('Received scan data: $scanData');
        setState(() {
          historyScanItems = List<Map<String, dynamic>>.from(scanData);
        });
      }

      if (createResponse.statusCode == 200) {
        List<dynamic> createData = json.decode(createResponse.body);
        debugPrint('Received create data: $createData');
        setState(() {
          historyCreateItems = List<Map<String, dynamic>>.from(createData);
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  String? _getIdFromItem(Map<String, dynamic> item, bool isScan) {
    final idKey = isScan ? 'id_scan' : 'id_create';
    final dynamic id = item[idKey];

    // Handle different possible types
    if (id == null) return null;
    if (id is int) return id.toString();
    if (id is String) return id;

    return id.toString();
  }

  Future<void> _deleteHistoryItem(String itemId, bool isScan) async {
    final endpoint = isScan ? 'laporan_scan' : 'laporan_create';
    final url = Uri.parse('http://localhost:3000/api/$endpoint/$itemId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        fetchHistoryData(); // Refresh data setelah hapus berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus item')),
        );
        debugPrint(
            'Failed to delete item. Status code: ${response.statusCode}, response: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menghapus item')),
      );
      debugPrint('Error deleting item: $e');
    }
  }

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
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Home()),
                        (Route<dynamic> route) => false,
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
                  if (index >= items.length) {
                    return null;
                  }

                  final item = items[index];
                  final id = _getIdFromItem(item, isScanActive);

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
                              debugPrint(
                                  'Item ${item['nama_laporan']} (ID: $id) diklik');
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
                                          item['nama_laporan'] ?? 'Untitled',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          item['lokasi'] ?? 'Unknown location',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          id != null ? 'ID: $id' : '',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        item['tanggal'] ?? 'No date',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (id == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('ID item tidak valid')),
                              );
                              return;
                            }
                            _deleteHistoryItem(id, isScanActive);
                          },
                          child: const Padding(
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
