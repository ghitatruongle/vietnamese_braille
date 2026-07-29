# Chính sách quyền riêng tư

Cập nhật: 27/07/2026.

## Ứng dụng

Ứng dụng Vietnamese Braille không yêu cầu tài khoản và không tự động tải văn
bản, nội dung Braille hoặc tệp của người dùng lên máy chủ của dự án.

- Chuyển đổi văn bản/Braille và tạo BRF/PDF chạy cục bộ.
- Lịch sử chuyển đổi và cài đặt giao diện được lưu trên thiết bị. Người dùng có
  thể xóa lịch sử trong màn hình **Lịch sử**.
- Ứng dụng chỉ đọc tệp mà người dùng chủ động chọn qua trình chọn tệp.
- OCR dùng Google ML Kit trên thiết bị Android/iOS. Nền tảng có thể tải thành
  phần mô hình cần thiết theo cơ chế của Google Play/App Store.
- Nhận dạng giọng nói dùng dịch vụ do hệ điều hành cung cấp. Tùy thiết bị, ngôn
  ngữ và cài đặt, âm thanh có thể được gửi đến Apple, Google, Microsoft hoặc nhà
  cung cấp nền tảng. Người dùng có thể không cấp hoặc thu hồi quyền micro.
- Chia sẻ tệp mở bảng chia sẻ của hệ điều hành; dữ liệu chỉ được chuyển cho ứng
  dụng đích do người dùng chọn.

Ứng dụng không tích hợp quảng cáo, phân tích hành vi hoặc SDK theo dõi riêng của
dự án.

## REST API

REST API là thành phần triển khai tùy chọn, tách khỏi ứng dụng. Mã nguồn máy chủ:

- xử lý nội dung yêu cầu trong bộ nhớ và không ghi nội dung vào log;
- không có cơ sở dữ liệu tài khoản hoặc lịch sử chuyển đổi;
- ghi metadata vận hành gồm thời gian, request ID, phương thức, đường dẫn, trạng
  thái và thời lượng;
- giữ bộ đếm rate-limit tạm thời trong bộ nhớ tiến trình.

Đơn vị tự triển khai API phải công bố địa chỉ vận hành, thời gian lưu log, nhà
cung cấp hạ tầng và chính sách pháp lý của riêng họ. Reverse proxy hoặc nền tảng
đám mây có thể tạo log bổ sung ngoài phạm vi mã nguồn này.

## Quyền và xóa dữ liệu

Người dùng có thể từ chối quyền micro, camera/ảnh hoặc tệp; các chức năng không
liên quan vẫn hoạt động. Xóa lịch sử trong ứng dụng để loại bỏ lịch sử cục bộ;
gỡ ứng dụng sẽ xóa dữ liệu trong vùng lưu trữ ứng dụng theo cơ chế của hệ điều
hành.

Vấn đề bảo mật hoặc quyền riêng tư được báo cáo theo hướng dẫn trong
[`SECURITY.md`](SECURITY.md) khi tệp này có trong bản phát hành.
