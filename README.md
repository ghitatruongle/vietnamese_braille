# Vietnamese Braille Converter

[![Flutter CI](https://github.com/ghitatruongle/vietnamese_braille/actions/workflows/test.yml/badge.svg)](https://github.com/ghitatruongle/vietnamese_braille/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/ghitatruongle/vietnamese_braille/branch/main/graph/badge.svg)](https://codecov.io/gh/ghitatruongle/vietnamese_braille)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Ứng dụng chuyển đổi văn bản tiếng Việt sang chữ Braille Unicode (8-dot, U+2800–U+28FF)
>
> A Flutter app for converting Vietnamese text to Braille Unicode, with reverse conversion, OCR, and BRF export.

---

## Tính năng / Features

- **Text → Braille**: Chuyển đổi 293 ký tự tiếng Việt có dấu sang Braille Unicode (8-dot)
- **Braille → Text**: Reverse conversion để kiểm tra và đối chiếu
- **OCR từ ảnh**: Nhận dạng văn bản từ hình ảnh (Google ML Kit)
- **Xuất file BRF**: Export file BRF chuẩn quốc tế
- **Lịch sử**: Lưu và quản lý lịch sử chuyển đổi (tối đa 50 mục)
- **Chế độ tối/sáng**: Dark mode với Material Design 3
- **Responsive**: Hỗ trợ mobile, tablet và desktop
- **Accessibility**: Semantics widgets cho người khiếm thị

### Chi tiết kỹ thuật / Technical Details

- **Thanh điệu**: sắc, huyền, hỏi, ngã, nặng — mỗi thanh là ô Braille riêng đặt trước nguyên âm
- **Chữ số**: number indicator (⠼) + letter cells
- **Capital indicator** (⠠) cho chữ viết hoa
- **Unicode NFC/NFD**: xử lý multi-level (a → â → ấ) đúng chuẩn
- **Qu/gi rule**: tone placed after u/i per Vietnamese Braille standard
- **Collision resolution**: `?` → `⠈⠦`, `-` → `⠈⠤` (UEB-compliant)

---

## Quick Start

### Prerequisites

- Flutter 3.29.x (stable channel)
- Dart SDK ^3.11.5
- Android Studio / Xcode (cho mobile) hoặc Chrome (cho web)

### Cài đặt / Installation

```bash
# Clone repository
git clone https://github.com/ghitatruongle/vietnamese_braille.git
cd vietnamese_braille/viet_braille_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Chạy test / Run Tests

```bash
flutter test
```

Hiện tại có **408+ tests** bao gồm unit tests (domain, data, core) và widget tests (presentation).

---

## Cách sử dụng / Usage

### Text → Braille

1. Mở ứng dụng, chọn tab "Text → Braille"
2. Nhập văn bản tiếng Việt (hoặc chọn file TXT/DOCX)
3. Nhấn "Convert" để chuyển đổi
4. Xem kết quả Braille Unicode
5. Nhấn "Export" để lưu file BRF

### Braille → Text

1. Chọn tab "Braille → Text"
2. Nhập hoặc dán chuỗi Braille Unicode
3. Nhấn "Convert" để chuyển đổi ngược
4. Xem văn bản tiếng Việt

### OCR từ ảnh

1. Chọn tab "OCR"
2. Chụp ảnh hoặc chọn ảnh từ thiết bị
3. Ứng dụng sẽ tự động nhận dạng văn bản
4. Chuyển đổi sang Braille

### Xuất file BRF

1. Sau khi chuyển đổi, nhấn nút "Export"
2. Chọn vị trí lưu file
3. File BRF chuẩn quốc tế sẽ được tạo

---

## Kiến trúc / Architecture

Dự án sử dụng **Clean Architecture** với 4 lớp:

```
viet_braille_app/lib/
├── core/                    # Core utilities
│   ├── app_theme.dart       # Light/dark theme (Material 3)
│   ├── braille_mapping.dart # Unicode ↔ Braille cell mapping + NFD/NFC
│   ├── braille_dots.dart    # Shared dot bitmasks
│   └── error_handler.dart   # Centralized error handling
├── data/                    # Data layer
│   ├── file_exporter.dart   # BRF file export + sharing
│   ├── file_picker_service.dart # Device file picker (TXT, DOCX, images)
│   ├── history_service.dart # SharedPreferences history (50 items)
│   ├── ocr_processor.dart   # Google ML Kit text recognition
│   └── text_extractor.dart  # TXT / DOCX text extraction
├── domain/                  # Business logic
│   ├── braille_converter.dart         # Text → Braille (with qu/gi rules)
│   ├── braille_reverse_converter.dart # Braille → Text (with disambiguation)
│   └── brf_formatter.dart             # BRF line wrap + formatting
├── presentation/            # UI layer
│   ├── providers/           # Riverpod StateNotifiers
│   ├── screens/             # Home, History, Settings screens
│   └── widgets/             # Reusable UI components
└── main.dart                # Entry point + GoRouter + Theme
```

### Công nghệ / Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Material Design 3) |
| **State management** | Riverpod (StateNotifier) |
| **Routing** | GoRouter |
| **OCR** | Google ML Kit Text Recognition |
| **Storage** | SharedPreferences |
| **Architecture** | Clean Architecture |

---

## Chuẩn Braille / Braille Standard

- **8-dot Braille Unicode** (U+2800 – U+28FF)
- **Dấu thanh** là ô Braille riêng biệt đặt trước nguyên âm
- **Chữ số**: number indicator (dots 3,4,5,6 — ⠼)
- **Capital indicator**: dots 4,6 (⠠)
- **Dấu câu**: tuân thủ UEB (Unified English Braille)

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

## Contributing

Chúng tôi chào đón đóng góp! Vui lòng đọc [CONTRIBUTING.md](viet_braille_app/CONTRIBUTING.md) trước khi gửi Pull Request.

### Quy trình nhanh / Quick Workflow

1. Fork repository
2. Tạo branch: `git checkout -b feature/ten-tinh-nang`
3. Thực hiện thay đổi
4. Viết test cho code mới
5. Chạy `flutter test` — tất phải xanh
6. Chạy `dart analyze` — không warning
7. Commit: `git commit -m "feat: mo ta ngan gon"`
8. Push và tạo Pull Request

---

## License

Dự án được phát hành dưới giấy phép [MIT](LICENSE).

---

## Acknowledgments

- Vietnamese Braille standard: Quy tắc trình bày văn bản Braille tiếng Việt
- UEB (Unified English Braille) for punctuation rules
- Flutter community for excellent packages
