# Agro-AHP Pro
**Microservices-Based Maintenance Decision System**

**Nama:** [Nama Mahasiswa]  
**NIM:** [NIM Mahasiswa]

## Deskripsi Kasus
Agro-AHP Pro adalah sistem pendukung keputusan (Decision Support System) untuk membantu manajer pemeliharaan di pabrik TIP Holding Company dalam memprioritaskan perbaikan mesin. Sistem ini menggunakan metode **Analytic Hierarchy Process (AHP)** untuk memastikan objektivitas dan konsistensi matematis.

Sistem terdiri dari:
1.  **Backend (Python/Flask):** Melakukan komputasi matriks AHP yang kompleks.
2.  **Frontend (Flutter):** Antarmuka mobile untuk input user.
3.  **Config Bridge (GitHub Gist):** Mengelola alamat server dinamis (Ngrok).

## Struktur Folder
- `/backend`: Berisi `ahp_engine.ipynb` untuk dijalankan di Google Colab.
- `/frontend`: Berisi source code aplikasi Flutter.

## Cara Menjalankan (Deployment Guide)

### 1. Setup Backend
1.  Buka [Google Colab](https://colab.research.google.com/).
2.  Upload file `backend/ahp_engine.ipynb`.
3.  Jalankan semua cell.
4.  Salin **Public URL Ngrok** yang muncul (contoh: `https://abcd.ngrok-free.app`).

### 2. Setup Config Bridge
1.  Buka [GitHub Gist](https://gist.github.com/).
2.  Buat Gist baru bernama `config.json`.
3.  Isi dengan format: `{"base_url": "https://abcd.ngrok-free.app"}` (Ganti URL dengan URL Ngrok Anda).
4.  Simpan sebagai Public/Secret Gist.
5.  Klik tombol **Raw** dan salin URL-nya.

### 3. Setup Frontend
1.  Buka `frontend/lib/services/gist_service.dart`.
2.  Ganti nilai variabel `_gistRawUrl` dengan URL Raw Gist Anda.
3.  Jalankan aplikasi Flutter:
    ```bash
    cd frontend
    flutter run
    ```

## Bukti Implementasi (Screenshots)

*(Silakan tambahkan screenshot Swagger UI dan Aplikasi Flutter di sini setelah dijalankan)*

## Link Terkait
- **Google Colab:** [Link Colab Anda]
- **GitHub Gist:** [Link Gist Anda]
- **Demo Aplikasi:** [Link Vercel/APK]
