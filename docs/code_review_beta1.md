# Biên bản review & debug code Beta 1 (Wave 1+2)

> Ngày: 2026-08-25 · Phạm vi: toàn bộ mã nguồn chưa-commit của Beta 1
> (packages/viet_braille_core, viet_braille_app, api_server) + tài liệu.
> Ràng buộc: chỉ review/sửa trên máy — **không commit/push**.

## Phương pháp

1. `dart analyze --fatal-infos` (core, api) và `flutter analyze --fatal-infos`
   (app) — kết quả: **0 vấn đề** ở cả 3 module.
2. Chạy đầy đủ 3 bộ test + corpus + coverage gates (số liệu cuối ở
   [docs/metrics.md](metrics.md)).
3. Soi thủ công các vùng đã sửa/thêm: preprocessor, converter/reverse,
   mapping, conversion/batch notifier, history service + backup, TTS,
   Perkins, DropZone, home/history/settings/braille-to-text/batch screens,
   main.dart, file_picker_service.
4. Quét dư lượng: **không còn** `print`/`debugPrint`/`TODO`/`FIXME` trong
   thư mục `lib/` của cả 3 module.

## Phát hiện & đã sửa (kèm test hồi quy)

| # | Vị trí | Vấn đề | Cách sửa |
|---|---|---|---|
| 1 | `history_screen.dart › _showSnack` | Gọi `ScaffoldMessenger.of(context)` sau async-gap mà không kiểm tra `mounted` → nguy cơ crash khi rời màn hình giữa lúc import/export chạy | Thêm `if (!mounted) return;` đầu hàm |
| 2 | `history_service.dart › mergeEntries` | Chèn bản ghi mới vào đầu theo thứ tự input → tệp backup sắp cũ→mới sẽ bị **đảo ngược trật tự thời gian** sau khi gộp | Sau khi gộp, sắp xếp lại theo timestamp giảm dần trước khi lưu; thêm test thứ tự |
| 3 | `braille_to_text_screen.dart › PerkinsKeyboard` | Ô gõ chỉ nối vào **cuối chuỗi**, không theo con trỏ → khó sửa giữa câu | Chèn tại vị trí con trỏ (thay vùng chọn), ⌫ xóa ký tự trước con trỏ hoặc cả vùng chọn; thêm test đặt con trỏ giữa "⠁⠎" chèn ra "⠁⠁⠎" |
| 4 | `batch_screen.dart › _exportBrf` | Không bắt lỗi I/O khi ghi BRF ra thư mục (thư mục sai/hết quyền) → ngoại lệ không xử lý | try/catch + snackbar lỗi; giữ snackbar thành công |

Lưu ý: phát hiện lớn trước đó của đợt này (vị trí dấu thanh vần âm đệm
"o+a" — *xoài→xòai*) và quy trình sửa chi tiết tại
[wave2_quality.md](wave2_quality.md).

## Các điểm đã xem xét và đánh giá là chấp nhận được

- Race giữa `_load()` bất đồng đồng bộ và setter trong các StateNotifier lưu
  prefs (theme/font/markdown/tts): cùng một pattern với phần code cũ, UI luôn
  pump xong load trước khi người dùng tương tác; unit test có chờ
  microtask. Theo dõi nếu sau này chuyển sang AsyncNotifier.
- Perkins hiện chèn ô Braille dạng text thường — giới hạn control-char
  markdown đã ghi nhận trong `symbol_extensions.md`.
- `TtsServiceImpl.speak` bắt mọi exception từ platform channel → trả false
  thay vì crash; có test trong môi trường VM.
- API server không đổi logic trong đợt này (chỉ version) — vẫn 31/31 test.

## Kết quả sau review

- core 286 ✓ · app ~756 ✓ · api 31 ✓ (chi tiết [docs/metrics.md](metrics.md))
- Coverage: core 95,59% · app 82,20% · api 90,94% — đủ gate 90/80/90
- `python tools/verify.py --all`: **PASS** (EXIT=0)
- Trạng thái git: **không commit/push** — toàn bộ nằm chưa-commit trên
  `main` @ `db1e7c2`, đúng yêu cầu.
