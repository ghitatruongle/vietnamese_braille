# Changelog

All notable changes to the **Vietnamese Braille App** will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)

---

## [Unreleased]

### Changed
- UI và tài liệu dùng đúng thuật ngữ Braille tiếng Việt 6 chấm.
- BRF formatter mã hóa North American Braille ASCII thật.
- OCR chỉ được khởi tạo/hiển thị trên Android và iOS.
- App now consumes the shared `viet_braille_core` package as the single source of truth for conversion logic; removed duplicated copies in `lib/core` and `lib/domain` (mapping, dots, converter, reverse converter, BRF formatter).
- `conversion_provider` services are exposed as overridable Riverpod providers for easier testing/mock injection.
- `SpeechService` accepts an injectable `SpeechToText` dependency.

### Fixed
- Dấu `?`/`-` không còn bị đổi thành thanh hỏi/ngã trong các trường hợp như `a?a`, `a-a`, `Có?Ai`.
- Lưu lịch sử được chờ và tuần tự hóa; lỗi lưu không làm mất kết quả chuyển đổi.
- `lineLength <= 0` bị từ chối thay vì gây vòng lặp vô hạn.
- Init-caps phrase grouping consistency in `viet_braille_core` (aligned with the all-caps fix; Bug #3).
- Removed `print()` from the core library (`braille_converter.dart`).

### Added
- Tests: `SpeechService`, `LearningScreen`, `QuizScreen`; phrase-grouping regression tests in `viet_braille_core`.
- `analysis_options.yaml` and `README.md` for `viet_braille_core`.
- `LICENSE` (MIT) for the app.

---

## [1.0.0] - 2026-06-23

### Added
- Text → Unicode Braille 6 chấm cho chữ tiếng Việt
- Support for Vietnamese special vowels: ă, â, ê, ô, ơ, ư, đ
- Tone marks (sắc, huyền, hỏi, ngã, nặng) as standalone Braille cells before vowels
- Number indicator (⠼) prefix for digit sequences
- Capital indicator (⠨, chấm 4,6) trước chữ hoa
- Unicode NFC/NFD normalization with multi-level composition (a → â → ấ)
- Reverse converter: Braille → Text round-trip verification
- BRF file export bằng North American Braille ASCII
- File picker for TXT / DOCX / images
- OCR text recognition via Google ML Kit
- Conversion history (SharedPreferences, 50 items max)
- Dark/Light theme (Material Design 3)
- Accessibility: Semantics widgets for visually impaired users
- Qu/gi rule: tone placed after u/i per Vietnamese Braille standard
- Decimal number support within number mode
- Chuyển ngược theo ngữ cảnh và chế độ lossless riêng cho dấu câu va chạm
- 400+ test suite (unit + widget tests)
- Python verification scripts for comparison vs rules and UEB

### Technical
- Flutter + Material Design 3
- Riverpod (StateNotifier) for state management
- GoRouter for navigation
- Clean Architecture (core / data / domain / presentation)
- GitHub Actions CI workflow
