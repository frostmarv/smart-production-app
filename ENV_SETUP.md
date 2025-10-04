# Panduan Konfigurasi Environment

## Konfigurasi Backend API

Aplikasi Flutter ini dirancang untuk berkomunikasi dengan backend melalui permintaan HTTP. Untuk menentukan alamat backend Anda, aplikasi ini menggunakan file `.env` di direktori utama proyek.

## Pengaturan

### 1. Buat atau Edit File `.env`

Pastikan Anda memiliki file bernama `.env` di root direktori proyek Anda.

### 2. Tentukan URL Backend Anda

Di dalam file `.env`, tambahkan variabel `API_BASE_URL` dan atur nilainya ke alamat dasar (base URL) dari backend API Anda.

**Contoh untuk Development (Lokal):**

```env
# Ganti dengan alamat backend lokal Anda
API_BASE_URL=http://localhost:3000/api
```

**Contoh untuk Production:**

```env
# Ganti dengan alamat backend production Anda
API_BASE_URL=https://api.domainanda.com/v1
```

## Cara Kerja

- Layanan `EnvironmentService` di dalam aplikasi akan secara otomatis memuat variabel `API_BASE_URL` dari file `.env` saat aplikasi dimulai.
- Layanan lain (seperti `ApiService` atau `http_client`) kemudian akan menggunakan URL ini untuk semua permintaan ke backend.

## Troubleshooting

- **Error: "Unable to load asset: .env"**: Pastikan file `.env` ada di root folder dan sudah ditambahkan ke `assets` di dalam file `pubspec.yaml`.
- **Error Koneksi (Connection Timeout, Refused, dll.)**: Periksa kembali nilai `API_BASE_URL` di file `.env` dan pastikan backend Anda sedang berjalan dan dapat diakses dari tempat Anda menjalankan aplikasi Flutter.
