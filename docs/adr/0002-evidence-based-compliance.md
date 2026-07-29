# ADR-0002: Tuyên bố tuân thủ dựa trên bằng chứng

- Trạng thái: `accepted`
- Ngày: 27/07/2026

## Bối cảnh

Kiểm tra một ô có nằm trong dải Unicode Braille không chứng minh implementation
đúng chuẩn. Các tuyên bố tuyệt đối khi chưa có chuyên gia review tạo rủi ro cho
người dùng.

## Quyết định

Mỗi quy tắc phải có nguồn, số chấm, Unicode và ví dụ chính xác. CI kiểm tra hash
nguồn cùng output thật. Phạm vi chưa triển khai và thẩm định bên ngoài được báo
cáo riêng, không tính là đạt.

## Hệ quả

Release bị chặn nếu fixture sai hoặc nguồn đổi. Trạng thái
`pending_external` chỉ được đổi khi có biên bản của người review độc lập.
