# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- North American Braille ASCII codec và xuất BRF ASCII thật
- Chế độ đối chiếu lossless cho va chạm `?`/thanh hỏi và `-`/thanh ngã
- Fixture TT15 độc lập với 87 phép kiểm trực tiếp implementation
- CI Windows/Linux, coverage gates, Web/Android release builds
- Capability gating cho OCR và speech theo nền tảng
- Đọc TXT/DOCX từ bytes trên web
- Official README with badges, features, quick start
- CONTRIBUTING.md with detailed contribution guide
- MIT LICENSE file
- CHANGELOG.md (this file)
- Integration tests for full conversion pipeline (20 tests)
- Edge case tests for tone stacking, qu/gi rules, special chars (18 tests)
- CI pipeline with dart format, analyze, test, coverage
- Screen reader support (Semantics labels) for all widgets
- Font size adjustment (0.8x to 2.0x) with persistence
- Voice input with Vietnamese speech-to-text
- Flutter web build support
- Organized Python tools into `tools/` directory with unified CLI
- Performance benchmarks for text conversion
- State isolation tests for reverse converter

### Changed
- Toàn bộ tài liệu dùng đúng thuật ngữ Braille tiếng Việt 6 chấm
- Android/iOS/macOS permissions, bundle identifiers và release signing
- Lịch sử được tuần tự hóa để tránh ghi đè khi chuyển đổi đồng thời
- Reverse converter uses immutable `_CapState` (no more state leak)
- `composeNfc` logic extracted to shared `_composeNfcCore` implementation
- `AppTheme.light`/`AppTheme.dark` converted from static fields to methods with `fontScale` parameter

### Fixed
- Tệp `.brf` không còn chứa Unicode Braille UTF-8
- Reverse converter không còn biến `a-a`, `a?a`, `Á-Âu`, `Có?Ai` thành chữ có thanh
- `lineLength <= 0` không còn gây vòng lặp vô hạn
- Formatter giữ khoảng trắng lặp thay vì âm thầm làm mất bố cục
- State leak between consecutive `convert()` calls in reverse converter
- Font size scaling with null fontSize handling
