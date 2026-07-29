# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- Job Semgrep SAST trong CI (rule `p/ci`, `p/python`, `p/github-actions`)
- Gate `check_release_workflow.py` từ chối mọi action không pin commit SHA
- `tools/refresh_metrics.py` sinh `docs/metrics.md` và badge coverage gộp
- API: interface `RateLimiter` cho phép inject backend chia sẻ khi scale ngang
- API: `BrailleHandlers` nhận converter qua constructor (bỏ singleton toàn cục)
- ADR-0003 về va chạm ô `?`/thanh hỏi và `-`/thanh ngã

### Changed
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
