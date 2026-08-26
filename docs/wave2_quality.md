# Chất lượng Wave 2 — Corpus & hiệu năng

> Số liệu đo trên máy phát triển Windows (2026-08-25), kèm theo Phase 2A của
> [kế hoạch v1.5.0](upgrade_plan_v150.md). Cập nhật lại mỗi khi thay đổi lõi.

## 1. Corpus round-trip chuẩn (Phase 2A.1)

- Bộ corpus: **67 câu** tiếng Việt thực tế (`test/corpus_accuracy_test.dart`
  trong package core): tin bài, văn bản hành chính, hội thoại, số/ngày/tiền,
  dấu câu ngoặc kép, toán & đơn vị, ký hiệu mở rộng ứng dụng (₫ ° →), câu dài
  phức hợp; phủ đủ 6 thanh điệu, quy tắc qu/gi, hoa/VIẾT TẮT.
- **Kết quả: 67/67 câu khớp nguyên văn = 100%** (tiêu chí ≥ 99%).
- Test tự động chạy trong suite core — tụt dưới ngưỡng sẽ làm fail CI.

### Quy tắc vị trí dấu thanh đã siết lại (sửa lỗi thật)

Trước Phase này, mọi vần âm đệm **o + a** có đuôi bán nguyên âm bị đặt dấu
nhầm vào chữ đầu: *xoài → "xòai"*, *ngoái → "ngóai"*. Đã sửa
`_toneTargetIndex`:

| Vần | Ví dụ | Vị trí dấu |
|---|---|---|
| âm đệm o + **a** (+ coda / i, y) | hòa, toàn, xoài, ngoài, ngoáy | chữ **a** (thứ hai) |
| oe (ô nguyên âm chính) | khỏe, khoén | chữ **ô** |
| oi/ui hai chữ | mòi, mùi, đói | chữ **o/u** đầu |
| uy mở / uy + coda | thủy, suýt | u / y |
| âm đệm ư mã hóa bằng ô u | của, mùa, cửa | chữ **ư** (đầu) |

Ghi chú: các biến thể chính tả kiểu "hóa/văn hóa" (dấu trên o) khi dịch ngược
chuẩn sẽ về dạng chủ từ điển Hoàng Phê "hoá/văn hoá"; cần phân biệt tuyệt đối
hãy dùng chế độ lossless.

## 2. Baseline hiệu năng (Phase 2A.2)

Văn bản ~140.000 ký tự (câu mẫu × 2.000), chạy 2 lượt sau warm-up:

| Hướng | Dữ liệu | Thời gian | Thông lượng |
|---|---|---|---|
| Forward (text → Braille) | 140.000 ký tự | ~430–450 ms | ~320.000 ký tự/s |
| Reverse (Braille → text) | 164.000 ô | ~675–815 ms | ~220.000 ô/s |

Test hiệu năng sẵn có yêu cầu 100.000 ký tự hoàn thành < 2 giây — biên an toàn
rộng. Đây là mốc đối chiếu khi thêm tính năng mới (2B–2F).
