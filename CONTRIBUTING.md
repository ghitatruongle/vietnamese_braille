# Đóng góp cho Vietnamese Braille

Cảm ơn bạn quan tâm đến dự án! Hướng dẫn này giúp bạn bắt đầu đóng góp.

## Yêu cầu

- Flutter 3.44.2 stable
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
5. **Format code**: `dart format --output=none --set-exit-if-changed lib test`
6. **Analyze**: `flutter analyze` (không có warnings)
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

Thay đổi mapping hoặc quy tắc phải kèm ví dụ chính xác trong
`tools/data/tt15_rules.json`, vị trí nguồn và golden test. Không đổi
`review_status` thành `externally_reviewed` nếu chưa có biên bản của người review
độc lập.

Thay đổi UI phải kiểm tra bàn phím, semantics, tương phản và cỡ chữ 200%. Không
đưa dữ liệu cá nhân từ phiên kiểm thử người dùng vào issue, fixture hoặc log.

## Kiến trúc dự án

```
packages/viet_braille_core/
├── lib/                # mapping, converter, reverse, BRF codec
├── test/
└── tool/

viet_braille_app/
├── lib/
│   ├── core/           # theme, error handling, platform capabilities
│   ├── data/           # OCR, file picker, history, export
│   ├── presentation/   # UI: screens, widgets, providers
│   └── teaching/       # learning and quiz
├── test/               # Unit, widget, integration tests
└── pubspec.yaml

api_server/
├── bin/                 # Shelf server
├── lib/handlers/        # REST handlers và validation
└── test/                # Handler tests

tools/
├── data/               # Fixture TT15 độc lập
├── verify.py           # Unified CLI
├── check_lcov.py       # Coverage gate
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
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)
- [Privacy Policy](PRIVACY.md)
- [Release Checklist](docs/release-checklist.md)

## License

Bằng cách đóng góp, bạn đồng ý rằng đóng góp của bạn sẽ được cấp phép theo MIT License.
