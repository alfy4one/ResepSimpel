<div align="center">

# 🍲 ResepSimpel

**Aplikasi resep masakan Indonesia untuk Android**

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-13+-3DDC84?logo=android)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[Download APK](../../releases/latest) • [Report Bug](../../issues)

</div>

---

## ✨ Fitur

- **Pencarian Langsung** — temukan resep dengan mengetik nama masakan
- **Filter Bahan** — jelajahi resep berdasarkan bahan utama
- **In-App Update** — periksa dan install pembaruan langsung dari aplikasi
- **Material Design** — antarmuka bersih, responsif, dan aksesibel

## 📱 Screenshot

<div align="center">
  <em>Coming soon</em>
</div>

## 📦 Download

Unduh APK terbaru dari halaman [**Releases**](../../releases/latest).

**Minimum Requirements:**
- Android 13+ (API Level 33) 
- ~50MB storage

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.47+ |
| Platform | Android (iOS coming soon) |
| State | StatefulWidget + setState |
| Update | GitHub Releases API |
| Design | Material 3, 8pt grid, WCAG AA |

## 🚀 Build dari Source

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.47+
- Android SDK (API 33+)
- Git

### Clone & Build

```bash
# Clone repository
git clone https://github.com/alfy4one/ResepSimpel.git
cd ResepSimpel

# Install dependencies
flutter pub get

# Run di emulator/device
flutter run

# Build APK release
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build Web (Experimental)

```bash
flutter build web --release
# Output: build/web/
```

## 📂 Struktur Project

```
ResepSimpel/
├── lib/
│   └── main.dart              # Entry point + all pages
├── test/
│   ├── widget_test.dart       # Unit tests
│   └── screenshots_test.dart  # Golden tests
├── pubspec.yaml
└── README.md
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# With coverage
flutter test --coverage

# Update golden screenshots
flutter test --update-goldens
```

## 🎨 Design System

**Spacing:** 8pt grid (8, 16, 24, 32, 48)

**Colors:** Material Blue 60-30-10 rule
- Background: `#E3F2FD` (60%)
- Accent: `#90CAF9` (30%)
- Primary: `#2196F3`, `#0D47A1` (10%)

**Typography:** Material Design guidelines

## 🗺️ Roadmap

- [ ] Konten resep lengkap dengan foto
- [ ] Detail resep (bahan, langkah, waktu)
- [ ] Bookmark & favorit
- [ ] Mode offline
- [ ] iOS support
- [ ] Backend API

## 🤝 Contributing

Pull requests welcome. Untuk perubahan besar, buka issue terlebih dahulu.

## 📄 Lisensi

[MIT License](LICENSE) © 2026 Alfiansyah

---

<div align="center">
  <sub>Built with Flutter • v1.0.0</sub>
</div>
