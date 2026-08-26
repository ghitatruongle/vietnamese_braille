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

## Braille → Text

Drawer → **Braille→Text** để dịch ngược độc lập:

1. Dán hoặc nhập ô Braille Unicode vào ô trên — hoặc gõ trực tiếp bằng
   **bàn phím 6 chấm kiểu Perkins** ngay dưới ô nhập: `S D F` = chấm 1-2-3,
   `J K L` = chấm 4-5-6; bật các chấm rồi nhấn **Chốt ô (Space)**, nút ⌫ xóa
   ô cuối.
2. Chọn chế độ **Chuẩn** (đoán theo ngữ cảnh) hoặc **Lossless**
   (khôi phục tuyệt đối với chuỗi do ứng dụng tạo).
3. Nhấn **Chuyển đổi**, kết quả chữ tiếng Việt hiện ở ô dưới, có nút sao chép
   và nút 🔊 **đọc to** (nền tảng hỗ trợ TTS).

## Chuyển đổi batch

Drawer → **Batch** để xử lý nhiều tệp cùng lúc:

1. Chọn nhiều tệp TXT/DOCX trong một lần mở hộp thoại.
2. Mỗi tệp được chuyển đổi độc lập; tệp lỗi chỉ được đánh dấu, không làm
   hỏng các tệp còn lại.
3. Bảng kết quả hiển thị trạng thái, số ký tự và cảnh báo của từng tệp;
   có thể xuất toàn bộ thành các tệp `.brf`.

## Lịch sử và cài đặt

- Drawer → **Lịch sử** để xem, tìm hoặc xóa các lần chuyển đổi; trên thanh
  ứng dụng có thêm **xuất bản sao lưu JSON** và **nhập bản sao lưu** — khi
  nhập bạn chọn *Gộp* (bỏ qua bản ghi trùng) hoặc *Thay thế* toàn bộ.
- Kéo-thả tệp vào cửa sổ trên desktop: TXT/DOCX đi thẳng vào chuyển đổi,
  ảnh đi vào OCR nơi nền tảng hỗ trợ; khi kéo sẽ có lớp gợi ý "Thả tệp".
- **Cài đặt** cho phép đổi sáng/tối, cỡ chữ 80–200%, bật
  **"Hỗ trợ định dạng"** (markdown `**đậm**`, `*nghiêng*`, `_gạch chân_`)
  và chỉnh **Đọc to (TTS)**: tốc độ + cao độ giọng đọc.
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
