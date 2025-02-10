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

// Endpoint untuk mendapatkan data laporan_create dengan QR Code
app.get('/api/laporan_create', (req, res) => {
  db.query('SELECT id, nama_laporan, lokasi, tanggal FROM laporan_create ORDER BY tanggal DESC', async (err, results) => {
    if (err) {
      console.error('Error saat mengambil data:', err);
      return res.status(500).json({ error: 'Gagal mengambil data' });
    }

    // Generate QR Code untuk setiap laporan
    const laporanWithQR = await Promise.all(results.map(async (laporan) => {
      const qrCode = await QRCode.toDataURL(JSON.stringify(laporan));
      return { ...laporan, qrCode };
    }));

    res.json(laporanWithQR);
  });
});

// Endpoint untuk mendapatkan data laporan_scan dengan QR Code
app.get('/api/laporan_scan', (req, res) => {
  db.query('SELECT id, nama_laporan, lokasi, tanggal FROM laporan_scan ORDER BY tanggal DESC', async (err, results) => {
    if (err) {
      console.error('Error saat mengambil data:', err);
      return res.status(500).json({ error: 'Gagal mengambil data' });
    }

    // Generate QR Code untuk setiap laporan
    const laporanWithQR = await Promise.all(results.map(async (laporan) => {
      const qrCode = await QRCode.toDataURL(JSON.stringify(laporan));
      return { ...laporan, qrCode };
    }));

    res.json(laporanWithQR);
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

// Endpoint untuk menyimpan laporan dan QR Code ke database
app.post('/api/laporan_create', async (req, res) => {
  try {
    const { nama_laporan, lokasi, tanggal } = req.body;
    if (!nama_laporan || !lokasi || !tanggal) {
      return res.status(400).json({ error: 'Semua data harus diisi' });
    }

    const qrCodeDataURL = await QRCode.toDataURL(JSON.stringify({ nama_laporan, lokasi, tanggal }));

    db.query(
      'INSERT INTO laporan_create (nama_laporan, lokasi, tanggal, qr_code) VALUES (?, ?, ?, ?)',
      [nama_laporan, lokasi, tanggal, qrCodeDataURL],
      (err, result) => {
        if (err) {
          console.error('Gagal menyimpan laporan:', err);
          return res.status(500).json({ error: 'Gagal menyimpan laporan' });
        }
        res.json({ message: 'Laporan berhasil disimpan', qrCode: qrCodeDataURL });
      }
    );
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Terjadi kesalahan' });
  }
});

app.listen(port, () => {
  console.log(`Server berjalan di http://localhost:${port}`);
});
