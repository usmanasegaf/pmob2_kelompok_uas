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

// Endpoint untuk menyimpan laporan dan generate QR Code
app.post('/api/laporan_create', async (req, res) => {
  try {
    const { nama_laporan, lokasi, tanggal, deskripsi } = req.body;
    if (!nama_laporan || !lokasi || !tanggal || !deskripsi) {
      return res.status(400).json({ error: 'Semua data harus diisi' });
    }

    const qrData = JSON.stringify({ nama_laporan, lokasi, tanggal, deskripsi });
    const qrCodeDataURL = await QRCode.toDataURL(qrData);

    db.query(
      'INSERT INTO laporan_create (nama_laporan, lokasi, tanggal, deskripsi, qr_code) VALUES (?, ?, ?, ?, ?)',
      [nama_laporan, lokasi, tanggal, deskripsi, qrCodeDataURL],
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

// Endpoint untuk menyimpan hasil scan QR Code
app.post('/scan', (req, res) => {
  const { qr_code } = req.body;

  if (!qr_code) {
    return res.status(400).json({ message: 'QR Code is required' });
  }

  // Format JSON QR harus sesuai dengan tabel
  let qrData;
  try {
    qrData = JSON.parse(qr_code);
  } catch (error) {
    qrData = null;
  }

  let query;
  let values;

  if (qrData && qrData.nama_laporan && qrData.lokasi && qrData.tanggal && qrData.deskripsi) {
    // Jika QR Code valid, masukkan data sesuai kolom
    query = `INSERT INTO laporan_scan (nama_laporan, lokasi, tanggal, deskripsi, qr_code) VALUES (?, ?, ?, ?, ?)`;
    values = [qrData.nama_laporan, qrData.lokasi, qrData.tanggal, qrData.deskripsi, qr_code];
  } else {
    // Jika QR tidak sesuai format, masukkan ke deskripsi dengan kategori 'Other QR'
    query = `INSERT INTO laporan_scan (nama_laporan, lokasi, tanggal, deskripsi, qr_code) VALUES (?, ?, ?, ?, ?)`;
    values = ['Other QR', 'Other QR', 'Other QR', qr_code, 'Other QR'];
  }

  db.query(query, values, (err, result) => {
    if (err) {
      console.error('Error memasukkan data:', err);
      return res.status(500).json({ message: 'Database insert error' });
    }
    res.json({ message: 'Scan data berhasil disimpan' });
  });
});


//Jalankan Server
app.listen(port, () => {
  console.log(`Server berjalan di http://localhost:${port}`);
});
