# 🚀 Smart Production App - Startup Guide

## Prerequisites

Pastikan Anda sudah menginstall:
- **Flutter SDK** (versi 3.3.3 atau lebih baru)
- **Dart SDK** (included dengan Flutter)
- **Android Studio** atau **VS Code** dengan Flutter extension
- **Android SDK** (untuk Android development)
- **Xcode** (untuk iOS development - Mac only)

## Quick Start

### 1. Navigate ke Project Directory
```bash
cd smart-production-app-main/smart_production_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Backend API
Edit file `.env` dan sesuaikan dengan backend API Anda:

```env
# Ganti dengan URL backend API Anda
API_BASE_URL=https://your-backend-api.com/api

# Ganti dengan API key Anda (jika diperlukan)
API_KEY=your-api-key-here

# Set environment
ENVIRONMENT=development
```

### 4. Run Application

#### For Development (with hot reload):
```bash
flutter run
```

#### For specific device:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

#### For web:
```bash
flutter run -d chrome
```

#### For release build:
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (Mac only)
flutter build ios --release
```

## Environment Configuration

### Development Setup
```env
API_BASE_URL=http://localhost:3000/api
ENVIRONMENT=development
ENABLE_DEBUG_LOGS=true
```

### Production Setup
```env
API_BASE_URL=https://your-production-api.com/api
ENVIRONMENT=production
ENABLE_DEBUG_LOGS=false
API_KEY=your-production-api-key
```

## Backend API Requirements

Pastikan backend API Anda menyediakan endpoints berikut:

### Required Endpoints:
```
GET /api/buyers                    - List buyers
GET /api/customer-pos              - List customer POs
GET /api/customer-pos?buyer_id=X   - POs by buyer
GET /api/skus                      - List SKUs
GET /api/skus/{id}                 - SKU by ID
POST /api/webbing-entries          - Create webbing entry
GET /api/webbing-entries           - List webbing entries
POST /api/bonding-entries          - Create bonding entry
GET /api/bonding-entries           - List bonding entries
POST /api/bonding-summary          - Create bonding summary
GET /api/bonding-summary           - List bonding summary
```

### Expected Response Format:
```json
// GET /api/buyers
[
  {
    "id": "WMT",
    "name": "WMT.COM"
  }
]

// GET /api/customer-pos
[
  {
    "po_number": "PO001",
    "buyer_id": "WMT",
    "sku_id": "SKU001",
    "qty_order": 100
  }
]

// GET /api/skus/SKU001
{
  "id": "SKU001",
  "name": "Mattress King Size"
}
```

## Troubleshooting

### 1. Flutter not found
```bash
# Install Flutter
# Download from: https://flutter.dev/docs/get-started/install

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Dependencies error
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

### 3. API connection error
- Periksa `API_BASE_URL` di file `.env`
- Pastikan backend API running
- Check network connectivity
- Verify API endpoints

### 4. Build errors
```bash
# Clean build
flutter clean
flutter pub get
flutter build apk
```

### 5. Hot reload not working
```bash
# Restart with hot reload
flutter run --hot
```

## Development Tips

### 1. Enable Debug Logs
Set di `.env`:
```env
ENABLE_DEBUG_LOGS=true
```

Logs akan muncul di console:
```
🐛 [DEBUG] Environment: development
📡 [API] GET https://api.example.com/buyers
✅ [API] 200 https://api.example.com/buyers
```

### 2. Test API Endpoints
Gunakan tools seperti:
- **Postman** - GUI testing
- **curl** - Command line testing
- **Thunder Client** - VS Code extension

### 3. Backend Development
Untuk testing lokal, gunakan:
```env
API_BASE_URL=http://10.0.2.2:3000/api  # Android emulator
API_BASE_URL=http://localhost:3000/api  # iOS simulator/web
```

### 4. Database Inspection
Jika menggunakan SQLite lokal (offline mode):
```bash
# Install SQLite browser
# View database: data/databases/smart_production.db
```

## Project Structure

```
smart_production_app/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── models/                   # Data models
│   ├── screens/                  # UI screens
│   ├── services/                 # API & business logic
│   │   ├── api_service.dart      # Main API service
│   │   ├── environment_service.dart # Environment config
│   │   └── database_he.dart      # Database helper
│   └── data/                     # Static data
├── .env                          # Environment configuration
├── pubspec.yaml                  # Dependencies
└── ENV_SETUP.md                  # Environment setup guide
```

## Next Steps

1. **Configure Backend API** - Update `.env` dengan URL backend Anda
2. **Test API Connection** - Jalankan app dan periksa logs
3. **Customize Endpoints** - Sesuaikan endpoint di `.env` jika format berbeda
4. **Add Features** - Tambahkan department atau fitur baru
5. **Deploy** - Build untuk production

## Support

Jika mengalami masalah:
1. Check `flutter doctor` untuk environment issues
2. Periksa logs di console untuk API errors
3. Verify backend API dengan Postman/curl
4. Check `.env` configuration
5. Restart app setelah perubahan environment

---

**Happy Coding!** 🎉