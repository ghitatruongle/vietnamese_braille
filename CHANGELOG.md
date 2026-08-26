# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

## [1.5.0-beta1] - 2026-08-25

### Added
- Màn hình **Braille→Text** (`/braille-to-text`): dán/nhập ô Braille Unicode,
  dịch ngược thành chữ tiếng Việt (standard/lossless), copy kết quả
- Màn hình **chuyển đổi batch** (`/batch`): chọn nhiều tệp TXT/DOCX, chuyển đổi
  từng tệp độc lập, xuất BRF hàng loạt, lỗi một tệp không làm hỏng cả lô
- Toggle **"Hỗ trợ định dạng"** trong Settings: nhận diện markdown
  `**đậm**` / `*nghiêng*` / `_gạch chân_`; cờ `enableMarkdown` được đưa qua
  API `convert`/`convertWithDetails` của lõi và nối vào cả pipeline chính
  lẫn pipeline batch
- Bảng ký hiệu mở rộng của ứng dụng (tài liệu hóa trong
  `docs/symbol_extensions.md`): nhóm toán học prefix dot 5
  (`≈ ≤ ≥ ≠ ± × ÷ √`) và nhóm ký tự đặc biệt prefix dot 4
  (`« » – — ₫ ‰ © ® ™ ° ² ³ ← → ↑ ↓`), đồng bộ forward/reverse/preprocessor
- Marker định dạng B5: bold `⠈⠘`, italic `⠈⠊`, underline `⠈⠞`;
  reverse converter nhận diện đủ 3 marker ngược về control char
- Test phủ mapping toàn diện `mapping_completeness_test.dart`: mọi ký tự
  Latin/tiếng Việt, tone cell, capitalization, marker B5 và regression
  markdown trên tiếng Việt có dấu

### Added (Wave 2 — cùng bản Beta 1)
- **Nhập Braille 6 phím kiểu Perkins** (`S D F` = chấm 1-2-3, `J K L` =
  chấm 4-5-6): bật/tắt chấm, nút Chốt ô, xem trước ô; tích hợp màn
  Braille→Text
- **Đọc to (TTS)** bằng `flutter_tts`: nút loa trên văn bản gốc/đối chiếu ở
  màn chính và kết quả Braille→Text; tốc độ + cao độ chỉnh trong Settings;
  capability gating theo nền tảng (Android/iOS/Windows/macOS)
- **Sao lưu / khôi phục lịch sử** JSON: xuất toàn bộ lịch sử ra tệp có schema,
  nhập lại với lựa chọn Gộp (bỏ trùng lặp theo bản sắc) hoặc Thay thế;
  validate schema chặt, báo lỗi tiếng Việt
- **Drag & drop hoàn thiện trên desktop**: vùng phủ gợi ý khi kéo tệp vào cửa
  sổ; định tuyến tự động TXT/DOCX → chuyển đổi, ảnh → OCR nơi nền tảng hỗ trợ
- **Corpus độ chính xác reverse chuẩn**: 67 câu thực tế đạt **100%**
  round-trip (tiêu chí ≥99%), chạy tự động trong suite; sửa lỗi vị trí dấu
  thanh vần âm đệm "o+a" (*xoài/ngoái/hòa/toàn*) kèm regression test;
  baseline hiệu năng ghi tại `docs/wave2_quality.md`

### Fixed
- Markdown bold `**text**` bị xử lý như ký tự literal vì cờ markdown chưa
  được truyền qua API chuyển đổi — đã nối trọn đường từ Settings tới lõi
- **Batch crash khi có ≥ 2 tệp:** `convertAll` đọc `state.items.sublist(i + 1)`
  sau khi state đã bị thay bằng danh sách kết quả → `RangeError` ở tệp thứ hai;
  vòng lặp được tái cấu trúc (snapshot phần đuôi, cập nhật state sau mọi nhánh,
  item cuối không còn kẹt trạng thái "converting")
- Ký hiệu `≈ ≤ ≥` không còn bị drop khỏi văn bản (preprocessor nhận diện
  nhưng bảng mã thiếu entry)
- Phụ âm đầu `w` được xử lý đúng như các phụ âm mở rộng khác (Wifi, Zoom…)
- Reverse standard đoán va chạm `?`/thanh hỏi và `-`/thanh ngã theo ngữ cảnh
  chính xác hơn; giữ lossless làm lớp an toàn
- Version hiển thị trong Settings đọc từ `kAppVersion`, không còn hardcode

### Changed
- Dọn các script probe kiểm chứng một-lần trong
  `packages/viet_braille_core/tool/`, giữ lại `verify_b5`, `verify_b5_cells`,
  `verify_symbols`, `verify_tt15`
- Phiên bản đồng bộ: app `1.5.0-beta1+4`, core/api `1.5.0-beta1`

## [1.2.0] - 2026-07-30

### Added
- Bộ tài liệu xác thực bên ngoài `docs/external-validation/`: kịch bản 4 phiên
  NVDA/TalkBack/VoiceOver kèm biên bản mẫu, phiếu nghiệm thu người dùng
  khiếm thị (5 kịch bản bắt buộc), quy trình tổng quan cho release v1.2.0
- `tools/expert_review_packet.py` sinh gói đối chiếu TT15 cho chuyên gia
  Braille từ fixture đã ghim SHA-256 (bảng chữ cái, thanh điệu, ký hiệu,
  15 ví dụ chính xác kèm cột xác nhận)
- Template `release_evidence/v1.2.0.json` (trạng thái pending, gate từ chối
  đúng thiết kế cho đến khi có bằng chứng thật)
- Job Semgrep SAST trong CI (rule `p/ci`, `p/python`, `p/github-actions`)
- Gate `check_release_workflow.py` từ chối mọi action không pin commit SHA
- `tools/refresh_metrics.py` sinh `docs/metrics.md` và badge coverage gộp
- API: interface `RateLimiter` cho phép inject backend chia sẻ khi scale ngang
- API: `BrailleHandlers` nhận converter qua constructor (bỏ singleton toàn cục)
- ADR-0003 về va chạm ô `?`/thanh hỏi và `-`/thanh ngã

### Changed
- Refactor core: tách `braille_reverse_converter.dart` (768 dòng) thành
  `lib/src/reverse/` (types, cell handlers, tone decoder) qua `part`; thay
  sentinel string `_ENTER_NUMBER_`/`_EXIT_NUMBER_` bằng enum `_NumberAction`
- Thêm `lib/src/vietnamese_letters.dart`: hằng số nguyên âm/thanh dùng chung,
  thay regex liệt kê tay trong preprocessor và predicate reverse
- Refactor app: tách `conversion_provider.dart` (400 dòng) thành state /
  notifier / providers; gộp pipeline chuyển đổi trùng lặp 3 method thành một
  `_applyConversion` dùng chung (coverage app 82,89% → 84,33%)
- **BREAKING (lịch sử git):** thư mục `quytac/` (tài liệu nội bộ) bị xóa
  vĩnh viễn khỏi toàn bộ lịch sử bằng `git filter-branch`; commit hash đổi
  toàn bộ, cần force-push và các clone cũ phải clone lại
- Gate TT15: PDF nguồn không còn vendored — thiếu file báo cáo trung thực
  `not_vendored` (gate dựa trên 141 phép kiểm fixture), hash sai vẫn fail;
  `verify_tt15.dart` kiểm tham chiếu nguồn thay vì sự tồn tại của file
- **BREAKING (API server):** xác thực là mặc định khi cấu hình từ biến môi
  trường; biến `API_AUTH_REQUIRED` bị thay bằng `ALLOW_ANONYMOUS` — server
  từ chối khởi động nếu `API_KEYS` rỗng mà không đặt `ALLOW_ANONYMOUS=true`
- Toàn bộ GitHub Actions pin bằng commit SHA kèm comment version
- CI nâng mức analyze lên `--fatal-infos` cho cả 3 module
- Tài liệu lịch sử 2026-06-30 (BUG_REPORT, FIXES_COMPLETED, TEST_SUMMARY)
  chuyển vào `docs/archive/` kèm banner snapshot

## [1.1.0] - 2026-07-28

### Added
- North American Braille ASCII codec và xuất BRF ASCII thật
- Chế độ đối chiếu lossless cho va chạm `?`/thanh hỏi và `-`/thanh ngã
- Fixture TT15 có nguồn/SHA-256 và 141 phép kiểm chính xác với implementation
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
- API hardening: streaming body limit, batch aggregate limit, CORS allowlist,
  request ID, structured metadata logging, security headers và rate limit
- Accessibility tests cho semantics, touch target, contrast, cỡ chữ 200% và
  keyboard shortcuts của lưới/quiz
- Privacy policy trong app và repository; threat model, SECURITY, CODEOWNERS,
  issue forms, ADR và release checklist
- Signed release workflow với SHA-256, SPDX SBOM và GitHub provenance

### Changed
- Toàn bộ tài liệu dùng đúng thuật ngữ Braille tiếng Việt 6 chấm
- Android/iOS/macOS permissions, bundle identifiers và release signing
- Lịch sử được tuần tự hóa để tránh ghi đè khi chuyển đổi đồng thời
- Reverse converter uses immutable `_CapState` (no more state leak)
- `composeNfc` logic extracted to shared `_composeNfcCore` implementation
- `AppTheme.light`/`AppTheme.dark` converted from static fields to methods with `fontScale` parameter
- Converter đặt dấu thanh trước toàn bộ phần vần theo ví dụ TT15 như `Việt`,
  `oán`, đồng thời reverse converter khôi phục đúng vị trí dấu tiếng Việt
- Quiz có phản hồi chữ/live-region thay vì chỉ dựa vào màu; lưới 6 chấm dùng
  được bằng Tab/Enter

### Fixed
- Tệp `.brf` không còn chứa Unicode Braille UTF-8
- Reverse converter không còn biến `a-a`, `a?a`, `Á-Âu`, `Có?Ai` thành chữ có thanh
- `lineLength <= 0` không còn gây vòng lặp vô hạn
- Formatter giữ khoảng trắng lặp thay vì âm thầm làm mất bố cục
- State leak between consecutive `convert()` calls in reverse converter
- Font size scaling with null fontSize handling
- Mất ký hiệu kết thúc định dạng khi cụm viết hoa kết thúc bằng nguyên âm có dấu
- Tiền xử lý chuỗi phép toán có thể bỏ sót khoảng trắng ở chuỗi toán tử
