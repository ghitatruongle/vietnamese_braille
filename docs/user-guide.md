# Hướng dẫn sử dụng

## Chuyển đổi văn bản

1. Nhập tiếng Việt vào ô văn bản, dán từ clipboard hoặc dùng microphone.
2. Nhấn **Chuyển đổi**.
3. Kết quả **Braille Unicode** có thể được chọn hoặc sao chép.
4. **Văn bản đối chiếu lossless** giúp phát hiện lỗi pipeline; đây không phải
   ô nhập Braille → Text độc lập.

## Chọn tệp và OCR

- TXT và DOCX hoạt động trên mobile, web và desktop.
- Ảnh JPG/PNG chỉ xuất hiện trong bộ chọn trên Android/iOS.
- OCR dùng Google ML Kit, vì vậy web và desktop không quảng bá tính năng này.
- Ảnh cần rõ, đủ sáng và văn bản nên nằm ngang.

## Xuất BRF

Sau khi chuyển đổi, nhấn **Xuất file BRF**. Ứng dụng:

1. Chuyển các ô Unicode Braille 6 chấm sang NABCC/Braille ASCII.
2. Ngắt dòng tối đa theo cấu hình và giữ các dòng logic.
3. Chia sẻ hoặc tải tệp `.brf`.

Tệp mở bằng editor sẽ thấy các chữ ASCII như `A`, `B`, `#`; đó là biểu diễn
ô Braille của BRF, không phải nội dung print text.

## Lịch sử và cài đặt

- Drawer → **Lịch sử** để xem, tìm hoặc xóa các lần chuyển đổi.
- **Cài đặt** cho phép đổi sáng/tối và cỡ chữ 80–200%.
- **Học Braille** và **Quiz** sử dụng lưới 6 chấm.

## Giới hạn chuyển ngược

Trong bảng chuẩn, `⠢` có thể là dấu hỏi hoặc thanh hỏi; `⠤` có thể là gạch
ngang hoặc thanh ngã. Chuyển ngược chuẩn phải dựa vào ngữ cảnh. Chế độ
lossless thêm escape marker riêng để kiểm tra máy, nhưng chuỗi này không hợp
lệ để xuất BRF.

## Xử lý sự cố

- Nếu speech không khởi động, kiểm tra quyền microphone và dịch vụ nhận dạng
  của hệ điều hành/trình duyệt.
- Nếu OCR không xuất hiện, nền tảng hiện tại không phải Android/iOS.
- Nếu tệp không đọc được, thử TXT UTF-8 hoặc DOCX hợp lệ.
- Ký tự chưa có trong bảng sẽ tạo cảnh báo thay vì bị bỏ qua im lặng.
