import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pmob2_kelompok_uas/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:typed_data'; // Import dart:typed_data for Uint8List

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
  Uint8List? qrCodeBytes; // Change qrCodeUrl to qrCodeBytes and use Uint8List
  bool isLoading = false;
  final String baseUrl = 'https://purring-scratch-plutonium.glitch.me';

  String getCurrentDateTime() {
    return DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
  }

  Future<void> _generateQRCode() async {
    setState(() {
      isLoading = true;
      debugPrint('GenerateQRCode: Set isLoading to true');
    });

    final String apiUrl = '$baseUrl/api/laporan_create';
    try {
      debugPrint('GenerateQRCode: Calling API - $apiUrl');
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
      debugPrint(
          'GenerateQRCode: API Response Status Code - ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('GenerateQRCode: API Response Body - $data');
        String base64String =
            data['qrCode'].split(',').last; // Extract base64 data
        debugPrint('GenerateQRCode: Base64 String extracted');

        Stopwatch stopwatch = Stopwatch()..start(); // Start stopwatch
        Uint8List decodedBytes = base64Decode(base64String); // Decode base64
        stopwatch.stop();
        debugPrint(
            'GenerateQRCode: Base64 Decoded in ${stopwatch.elapsedMilliseconds}ms');

        setState(() {
          qrCodeBytes = decodedBytes; // Store decoded bytes
        });
        debugPrint('GenerateQRCode: SetState called with decoded bytes');
      } else {
        debugPrint(
            'GenerateQRCode: API Failed - Status Code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate report')),
        );
      }
    } catch (e) {
      debugPrint('GenerateQRCode: Error during API call - $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
        debugPrint('GenerateQRCode: Set isLoading to false');
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
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                            (Route<dynamic> route) => false,
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
                        Icon(
                          Icons.calendar_today,
                          color: Colors.orange,
                          size: 48,
                        ),
                        SizedBox(height: 24),
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
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  WidgetsBinding
                                      .instance.focusManager.primaryFocus
                                      ?.unfocus();
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    _generateQRCode();
                                  });
                                },
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
                        if (qrCodeBytes != null) ...[
                          SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Image.memory(
                              // Use Image.memory with decoded bytes
                              qrCodeBytes!,
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
