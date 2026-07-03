# Vietnamese Braille App

> Ứng dụng chuyển đổi văn bản tiếng Việt sang chữ Braille Unicode (8-dot, U+2800–U+28FF)
>
> A Flutter app for converting Vietnamese text to Braille Unicode.

---

## Tính năng / Features

### 🇻🇳 Tiếng Việt

- **Nhập văn bản**: trực tiếp, hoặc chọn file TXT, DOCX, ảnh (OCR)
- **Chuyển đổi đầy đủ** 293 ký tự tiếng Việt có dấu
- **Ký tự đặc biệt**: ă, â, ê, ô, ơ, ư, đ
- **Thanh điệu**: sắc, huyền, hỏi, ngã, nặng — mỗi thanh là ô Braille riêng đặt **trước** nguyên âm
- **Chữ số**: number indicator (⠼) + letter cells
- **Capital indicator** (⠠) cho chữ viết hoa
- **Unicode NFC/NFD**: xử lý multi-level (a → â → ấ) đúng chuẩn
- **Reverse converter**: Braille → Text để kiểm tra
- **Xuất file BRF** chuẩn quốc tế
- **OCR** từ ảnh (Google ML Kit)
- **Lịch sử** chuyển đổi (lưu local, tối đa 50 mục)
- **Chế độ tối/sáng**
- **Accessibility**: Semantics widgets cho người mù

### 🇬🇧 English

- **Text input**: type directly, or pick TXT / DOCX / image (OCR)
- **Full coverage** of 293 Vietnamese accented characters
- **Special vowels**: ă, â, ê, ô, ơ, ư, đ
- **Tone marks**: each tone is a standalone Braille cell placed **before** the vowel
- **Numbers**: number indicator (⠼) prefix
- **Capital indicator** (⠠) before uppercase letters
- **Unicode NFC/NFD**: multi-level normalization (a → â → ấ)
- **Reverse conversion**: Braille → Text round-trip verification
- **BRF export**: standard international format
- **OCR**: image text recognition via Google ML Kit
- **Conversion history** (local storage, 50 items max)
- **Dark/Light theme**
- **Accessibility**: Semantics widgets for visually impaired users

---

## Kiến trúc / Architecture

```
lib/
├── core/
│   ├── app_theme.dart           # Light/dark theme (Material 3)
│   ├── braille_mapping.dart     # Unicode ↔ Braille cell mapping + NFD/NFC
│   ├── braille_dots.dart        # Shared dot bitmasks
│   └── error_handler.dart       # Centralized error handling
├── data/
│   ├── file_exporter.dart       # BRF file export + sharing
│   ├── file_picker_service.dart # Device file picker (TXT, DOCX, images)
│   ├── history_service.dart     # SharedPreferences history (50 items)
│   ├── ocr_processor.dart       # Google ML Kit text recognition
│   └── text_extractor.dart      # TXT / DOCX text extraction
├── domain/
│   ├── braille_converter.dart         # Text → Braille (with qu/gi rules)
│   ├── braille_reverse_converter.dart # Braille → Text (with disambiguation)
│   └── brf_formatter.dart             # BRF line wrap + formatting
├── presentation/
│   ├── providers/
│   │   ├── conversion_provider.dart   # Riverpod StateNotifier
│   │   ├── history_provider.dart      # History state
│   │   └── theme_provider.dart        # Dark mode toggle
│   ├── screens/
│   │   ├── home_screen.dart           # Main conversion screen
│   │   ├── history_screen.dart        # Conversion history
│   │   └── settings_screen.dart       # App settings
│   └── widgets/
│       ├── app_drawer.dart
│       ├── braille_display_section.dart
│       ├── read_only_field.dart
│       ├── status_section.dart
│       └── text_input_section.dart
└── main.dart                    # Entry point + GoRouter + Theme
```

---

## Công nghệ / Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Material Design 3) |
| **State management** | Riverpod (StateNotifier) |
| **Routing** | GoRouter |
| **OCR** | Google ML Kit Text Recognition |
| **Storage** | SharedPreferences |
| **Architecture** | Clean Architecture (core / data / domain / presentation) |

---

## Cài đặt / Setup

```bash
cd viet_braille_app
flutter pub get
flutter run
```

### Chạy test / Running tests

```bash
flutter test
```

Hiện tại có **408+ tests** bao gồm unit tests (domain, data, core) và widget tests (presentation).

---

## Chuẩn Braille / Braille Standard

- **8-dot Braille Unicode** (U+2800 – U+28FF)
- **Dấu thanh** là ô Braille riêng biệt đặt **trước** nguyên âm
- **Chữ số**: number indicator (dots 3,4,5,6 — ⠼)
- **Capital indicator**: dots 4,6 (⠠)
- **Dấu câu**: tuân thủ UEB (Unified English Braille)

### Collision resolution

| Conflict | Resolution |
|----------|-----------|
| `?` vs tone hỏi (cùng ⠢) | `?` → `⠈⠦` (symbol prefix + UEB 2,3,6) |
| `-` vs tone ngã (cùng ⠤) | `-` → `⠈⠤` (symbol prefix + UEB 3,6) |

---

## Kiểm thử đối chiếu / Verification Scripts

Các Python scripts ở thư mục gốc dùng để đối chiếu mapping giữa quy tắc, app code, và chuẩn UEB:

| Script | Purpose |
|--------|---------|
| `compare_rules_vs_app.py` | So mapping quy tắc vs app code |
| `deep_analysis.py` | Phát hiện collision, so UEB |
| `ueb_comparison.py` | So sánh với Unified English Braille |
| `verify_braille.py` | Verify tính đúng đắn mapping |
| `extract_braille.py` | Trích xuất Braille data |

---

## Giấy phép / License

Dự án mã nguồn riêng tư — không phát hành công khai.
