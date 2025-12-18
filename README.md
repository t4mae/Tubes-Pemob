# SiGizi - KELOMPOK 3

SiGizi adalah aplikasi pemantauan tumbuh kembang bayi yang dirancang untuk membantu orang tua dalam mencatat dan memantau perkembangan fisik anak secara optimal. Aplikasi ini menggunakan standar WHO sebagai referensi untuk memastikan anak tumbuh dengan sehat.

## Anggota Kelompok:
<ul>
  <li>Ahmad Rozan Raufansyah Nasution (231402002)</li>
  <li>Rangga Alif Fahreza (231402017)</li>
  <li>Prayer Ezekiel Levy Sitepu (231402053)</li>
  <li>Tama Hagana Perangin-Angin (231402059)</li>
  <li>Fajar Prawira Pasaribu (231402126)</li>
</ul>

## Fitur Utama SiGizi:

1. **Dashboard Tumbuh Kembang**
   - Ringkasan data gizi terbaru (Berat, Tinggi, Lingkar Kepala).
   - Tampilan profil anak yang sesuai gender

2. **Grafik Pertumbuhan Standar WHO**
   - Visualisasi tren pertumbuhan menggunakan standar  WHO.
   - **Analisis Otomatis**: Menampilkan status pertumbuhan (Normal, Di Atas Normal, Di Bawah Normal) berdasarkan perbandingan data anak dengan median WHO.
   - Legend grafik yang informatif dan mudah dibaca.

3. **Kalender Pengukuran Interaktif**
   - Riwayat pengukuran bulanan yang terorganisir dalam grid.
   - **Tap-to-Edit**: Kemudahan mengubah data pengukuran lama secara langsung melalui kalender.

4. **Edukasi & Berita Kesehatan Terkini**
   - **Integrasi News API**: Menyajikan berita kesehatan terupdate tentang nutrisi anak, MPASI, dan parenting secara dinamis.
   - Fitur baca selengkapnya yang terhubung langsung ke browser eksternal.

5. **Manajemen Profil Lengkap**
   - Tambah dan kelola banyak profil anak.
   - Edit profil pengguna dengan dukungan unggah foto profil ke **Firebase Storage**.

## Deskripsi Proyek:
Proyek ini bertujuan untuk membuat aplikasi mobile yang membantu orang tua dalam memantau pertubuhan bayi secara digital.
Pengguna dapat menambahkan data pertumbuhan, melihat grafik perkembangan bayi, serta mendapat informasi kesehatan anak terbarukan.

## Teknologi & Tools:
- **Framework**: Flutter (Cross-platform Android & iOS)
- **Backend**: Firebase (Firestore Database, Firebase Authentication, Firebase Storage)
- **Data Source**: News API (Real-time Health News)
- **Library Utama**:
  - `fl_chart`: Visualisasi data pertumbuhan.
  - `http`: Fetching data dari News API.
  - `url_launcher`: Integrasi dengan browser eksternal.
  - `intl`: Format tanggal dan angka.
  - `image_picker`: Pengambilan foto profil.



