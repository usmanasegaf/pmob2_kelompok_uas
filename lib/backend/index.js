const express = require('express');
const mysql = require('mysql2');
const app = express();
const port = 3000;

// Konfigurasi koneksi ke database MySQL
const db = mysql.createConnection({
  host: 'localhost', 
  user: 'root',
  password: '', 
  database: 'uas_pmobile2_database_us' 
});

db.connect((err) => {
  if (err) {
    console.error('Koneksi database gagal:', err);
    return;
  }
  console.log('Terhubung ke database!');
});

app.get('/', (req, res) => {
  res.send('Halo dari backend!');
});

// Contoh endpoint untuk mengambil data dari database
app.get('/api/data', (req, res) => {
    db.query(
      'SELECT nama_laporan, lokasi, DATE_FORMAT(tanggal, "%d %M %Y, %H:%i") AS tanggal FROM laporan_create ORDER BY tanggal DESC',
      (err, results) => {
        if (err) {
          console.error('Error saat mengambil data:', err);
          res.status(500).json({ error: 'Gagal mengambil data' });
          return;
        }
        res.json(results);
      }
    );
  });
  

app.listen(port, () => {
  console.log(`Server berjalan di http://localhost:${port}`);
});