const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const QRCode = require('qrcode');

const app = express();
const port = 3000;

// Konfigurasi CORS
app.use(cors());

// Middleware untuk parsing JSON
app.use(express.json());

// Konfigurasi koneksi ke database MySQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'uas_pmobile2_database_us',
});

db.connect((err) => {
  if (err) {
    console.error('Koneksi database gagal:', err);
    return;
  }
  console.log('Terhubung ke database!');
});

// Endpoint untuk mendapatkan data laporan_create
app.get('/api/laporan_create', (req, res) => {
  db.query('SELECT nama_laporan, lokasi, tanggal FROM laporan_create ORDER BY tanggal DESC', async (err, results) => {
    if (err) {
      console.error('Error saat mengambil data:', err);
      return res.status(500).json({ error: 'Gagal mengambil data' });
    }
    res.json(results);
  });
});

// Endpoint untuk mendapatkan data laporan_scan
app.get('/api/laporan_scan', (req, res) => {
  db.query('SELECT nama_laporan, lokasi, tanggal FROM laporan_scan ORDER BY tanggal DESC', async (err, results) => {
    if (err) {
      console.error('Error saat mengambil data:', err);
      return res.status(500).json({ error: 'Gagal mengambil data' });
    }
    res.json(results);
  });
});

// Endpoint untuk generate QR Code dari teks
app.post('/api/generate_qr', async (req, res) => {
  try {
    const { text } = req.body;
    if (!text) {
      return res.status(400).json({ error: 'Teks tidak boleh kosong' });
    }

    const qrCodeDataURL = await QRCode.toDataURL(text);
    res.json({ qrCode: qrCodeDataURL });
  } catch (error) {
    console.error('Gagal membuat QR Code:', error);
    res.status(500).json({ error: 'Gagal membuat QR Code' });
  }
});

app.listen(port, () => {
  console.log(`Server berjalan di http://localhost:${port}`);
});
