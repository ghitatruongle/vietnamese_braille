# Đóng góp cho Vietnamese Braille

Cảm ơn bạn quan tâm đến dự án! Hướng dẫn này giúp bạn bắt đầu đóng góp.

## Yêu cầu

- Flutter 3.29.x hoặc mới hơn
- Dart SDK ^3.11.5
- Python 3.11+ (cho verification tools)
- Git

## Bắt đầu

```bash
# Clone repository
git clone https://github.com/ghitatruongle/vietnamese-braille.git
cd vietnamese-braille

# Install Flutter dependencies
cd viet_braille_app
flutter pub get

# Chạy tests
flutter test

# Chạy Python verification tools
cd ..
pip install -r tools/requirements.txt
python tools/verify.py --all
```

## Quy trình đóng góp

1. **Fork** repository
2. Tạo **branch** mới: `git checkout -b feature/ten-tinh-nang`
3. **Implement** thay đổi (xem bên dưới)
4. **Chạy tests**: `flutter test` (phải PASS)
5. **Format code**: `dart format lib/ test/`
6. **Analyze**: `dart analyze` (không có warnings)
7. **Commit** với message rõ ràng
8. Tạo **Pull Request**

## Code Style

- Tuân thủ [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Sử dụng `dart format` trước khi commit
- Tên biến/method: `camelCase`
- Tên class: `PascalCase`
- Tên file: `snake_case.dart`
- Comment bằng tiếng Việt cho logic phức tạp

## Viết Tests

- **TDD** được khuyến khích: viết test trước, implement sau
- Mỗi feature mới cần có test tương ứng
- Đảm bảo tất cả tests pass trước khi PR

```bash
# Chạy tests
flutter test

# Chạy tests với coverage
flutter test --coverage

# Chạy tests cụ thể
flutter test test/domain/braille_converter_test.dart
```

## Kiến trúc dự án

```
viet_braille_app/
├── lib/
│   ├── core/           # Braille mapping, theme, error handling
│   ├── data/           # OCR, file picker, history, export
│   ├── domain/         # Business logic: converter, BRF formatter
│   └── presentation/   # UI: screens, widgets, providers
├── test/               # Unit, widget, integration tests
└── pubspec.yaml

tools/
├── verify/             # Mapping verification scripts
├── analysis/           # Deep analysis scripts
├── comparison/         # Comparison scripts
├── data/               # Parsed rules data
├── verify.py           # Unified CLI
└── requirements.txt
```

## Các loại đóng góp

### 🐛 Bug Report
- Mô tả rõ ràng vấn đề
- Steps to reproduce
- Expected vs actual behavior
- Screenshots nếu có

### ✨ Feature Request
- Mô tả tính năng mong muốn
- Use case cụ thể
- Proposed implementation (nếu có)

### 📝 Documentation
- Sửa lỗi chính tả
- Bổ sung hướng dẫn
- Cải thiện README

### 🔧 Code
- Fix bug
- Thêm tính năng
- Refactor code
- Cải thiện performance

## Quy tắc đặt tên Commit

```
<type>: <description>

Types:
- feat:     Tính năng mới
- fix:      Sửa bug
- docs:     Documentation
- style:    Format code
- refactor: Refactor code
- test:     Thêm/sửa tests
- chore:    Maintenance
```

Ví dụ:
```
feat: thêm nhận dạng giọng nói tiếng Việt
fix: sửa state leak trong reverse converter
docs: cập nhật hướng dẫn sử dụng
test: thêm integration tests cho full pipeline
```

## Liên kết

- [Design Spec](docs/superpowers/specs/2026-06-26-viet-braille-roadmap-design.md)
- [Implementation Plan](docs/superpowers/plans/2026-06-26-viet-braille-roadmap.md)
- [User Guide](docs/user-guide.md)

## License

Bằng cách đóng góp, bạn đồng ý rằng đóng góp của bạn sẽ được cấp phép theo MIT License.
