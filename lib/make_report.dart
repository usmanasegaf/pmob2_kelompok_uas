import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pmob2_kelompok_uas/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MakeReport extends StatelessWidget {
  const MakeReport({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: ReportScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? qrCodeUrl;
  bool isLoading = false;

  String getCurrentDateTime() {
    return DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
  }

  Future<void> _generateQRCode() async {
    setState(() {
      isLoading = true;
    });

    final String apiUrl = 'http://localhost:3000/api/laporan_create';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_laporan': _nameController.text,
          'lokasi': _locationController.text,
          'tanggal': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          'deskripsi': _descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          qrCodeUrl = data['qrCode'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and title
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back, color: Colors.orange),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Main content card
                Container(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Colors.orange.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Calendar icon
                        Icon(
                          Icons.calendar_today,
                          color: Colors.orange,
                          size: 48,
                        ),
                        SizedBox(height: 24),

                        // Form fields
                        _buildTextField(
                            'Report name', 'Enter name', _nameController),
                        SizedBox(height: 16),
                        _buildTextField(
                            'Date and Time', getCurrentDateTime(), null,
                            enabled: false),
                        SizedBox(height: 16),
                        _buildTextField(
                            'Location', 'Enter location', _locationController),
                        SizedBox(height: 16),
                        _buildTextField(
                          'Report Description',
                          'Enter any details',
                          _descriptionController,
                          maxLines: 4,
                        ),
                        SizedBox(height: 32),

                        // Generate QR Code button
                        ElevatedButton(
                          onPressed: isLoading ? null : _generateQRCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: Size(200, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Generate QR Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),

                        if (qrCodeUrl != null) ...[
                          SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Image.network(
                              qrCodeUrl!,
                              height: 200,
                              width: 200,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController? controller,
      {bool enabled = true, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Color(0xFF2C2C2C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 12,
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
