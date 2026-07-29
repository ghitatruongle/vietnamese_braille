# Chính sách bảo mật

## Phiên bản được hỗ trợ

| Dòng phiên bản | Trạng thái |
|---|---|
| `1.0.x` | Đang nhận bản vá bảo mật |
| `< 1.0` | Không còn hỗ trợ |

Trạng thái này được cập nhật khi một dòng phát hành mới thay thế dòng hiện tại.

## Báo cáo lỗ hổng

Không đăng công khai nội dung khai thác, dữ liệu nhạy cảm, khóa hoặc token trong
issue. Hãy dùng **Security → Report a vulnerability** của repository để mở
GitHub Private Vulnerability Report:

<https://github.com/ghitatruongle/vietnamese-braille/security/advisories/new>

Báo cáo nên có phiên bản/commit, nền tảng, tác động, bước tái hiện tối thiểu và
biện pháp giảm thiểu nếu biết. Dự án đặt mục tiêu xác nhận đã nhận trong 7 ngày;
thời gian sửa phụ thuộc mức độ, khả năng tái hiện và phối hợp phát hành.

## Phạm vi

Bao gồm ứng dụng Flutter, package `viet_braille_core`, REST API, workflow phát
hành và nguy cơ rò rỉ dữ liệu người dùng. Sai khác quy tắc Braille không có yếu
tố bảo mật nên dùng issue “Sai khác chuẩn Braille”; nếu sai khác có thể gây nguy
hiểm cho người dùng, có thể báo cáo riêng tư theo kênh trên.

## Công bố phối hợp

Không phát hành bản sửa hoặc công bố chi tiết trước khi artifact đã được kiểm
thử và người báo cáo có cơ hội xác nhận. Credit chỉ được ghi khi người báo cáo
đồng ý.
