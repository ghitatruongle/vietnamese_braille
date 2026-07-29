# ADR-0001: Core thuần Dart là nguồn chuyển đổi duy nhất

- Trạng thái: `accepted`
- Ngày: 27/07/2026

## Bối cảnh

Ứng dụng Flutter và REST API phải cho cùng kết quả. Sao chép mapping/converter
sang nhiều package làm bản sửa quy tắc dễ lệch nhau.

## Quyết định

`packages/viet_braille_core` là nguồn duy nhất cho mapping, chuyển xuôi, chuyển
ngược, Braille ASCII và BRF. App/API chỉ điều phối I/O và giao diện.

## Hệ quả

CI kiểm thử core độc lập và mọi consumer dùng dependency path đến core. Thay đổi
mapping cần fixture TT15, golden test và kiểm tra ngược tương ứng.
