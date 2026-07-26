# Braille Tiếng Việt – Flutter app

Ứng dụng giao diện cho package `viet_braille_core`. Màn hình chính nhận văn
bản, tệp hoặc giọng nói, hiển thị Unicode Braille 6 chấm, kết quả đối chiếu và
cho phép chia sẻ tệp BRF/Braille ASCII.

## Luồng sử dụng

1. Nhập văn bản hoặc chọn **TXT/DOCX**.
2. Trên Android/iOS có thể chọn thêm ảnh để OCR.
3. Nhấn **Chuyển đổi**.
4. Sao chép Unicode Braille hoặc chọn **Xuất file BRF**.
5. Dùng drawer để mở lịch sử, học Braille, quiz và cài đặt.

Ứng dụng không có các tab Text → Braille, Braille → Text hoặc OCR riêng.
Kết quả chuyển ngược trên màn hình là đối chiếu lossless nội bộ, không phải
một editor Braille → Text độc lập.

## Hỗ trợ nền tảng

- Core, TXT/DOCX và UI: Android, iOS, Web và desktop.
- OCR Google ML Kit: chỉ Android/iOS.
- Speech: Android, iOS, macOS, web và Windows beta; phụ thuộc dịch vụ thiết bị.
- Linux không hiển thị nút microphone.
- Windows dùng hộp **Save As** gốc để lưu BRF/PDF; PDF có sẵn font Braille,
  không cần mạng ở lần xuất đầu tiên.

## Phát triển

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build windows --release
flutter build web --release
```

Flutter được pin trong CI ở 3.44.2. iOS đặt deployment target 15.5; Android
đặt minSdk theo Flutter 3.44 (API 24) và không dùng debug key cho release.

## Cấu trúc

```text
lib/
├── core/           # theme, error handler, platform capabilities
├── data/           # picker, extractor, OCR, speech, history, BRF export
├── presentation/   # Riverpod providers, screens, widgets
├── teaching/       # learning + quiz
└── main.dart
```

Xem [README ở gốc](../README.md) để biết giới hạn round-trip, định dạng BRF,
ma trận nền tảng và nguồn tiêu chuẩn.
