# Hướng dẫn sử dụng Vietnamese Braille

## Mục lục

1. [Giới thiệu](#giới-thiệu)
2. [Cài đặt](#cài-đặt)
3. [Chuyển đổi Text → Braille](#chuyển-đổi-text--braille)
4. [Chuyển đổi Braille → Text](#chuyển-đổi-braille--text)
5. [OCR từ ảnh](#ocr-từ-ảnh)
6. [Xuất file BRF](#xuất-file-brf)
7. [Cài đặt](#cài-đặt-1)
8. [Phím tắt](#phím-tắt)
9. [Câu hỏi thường gặp](#câu-hỏi-thường-gặp)

---

## Giới thiệu

Vietnamese Braille là ứng dụng chuyển đổi văn bản tiếng Việt sang chữ Braille Unicode (8-dot, U+2800–U+28FF) và ngược lại.

### Tính năng chính

- ✅ Chuyển đổi text → Braille với đầy đủ dấu thanh
- ✅ Chuyển đổi Braille → text (reverse)
- ✅ OCR từ ảnh chụp văn bản
- ✅ Xuất file BRF (Braille Ready Format)
- ✅ Lịch sử chuyển đổi
- ✅ Chế độ tối (dark mode)
- ✅ Điều chỉnh kích thước chữ
- ✅ Nhập liệu bằng giọng nói
- ✅ Responsive trên mọi thiết bị

---

## Cài đặt

### Trên Android

1. Tải APK từ GitHub Releases
2. Mở file APK để cài đặt
3. Cho phép cài đặt từ nguồn không xác định (nếu được hỏi)

### Trên iOS

1. Tải từ App Store (khi có sẵn)
2. Hoặc build từ source (xem CONTRIBUTING.md)

### Trên Web

1. Mở URL: `https://<owner>.github.io/vietnamese-braille/`
2. Không cần cài đặt

### Từ Source

```bash
git clone https://github.com/<owner>/vietnamese-braille.git
cd vietnamese-braille/viet_braille_app
flutter pub get
flutter run
```

---

## Chuyển đổi Text → Braille

### Bước 1: Nhập văn bản

- Nhập văn bản tiếng Việt vào ô nhập liệu
- Hoặc nhấn nút **Dán** để dán từ clipboard
- Hoặc nhấn nút **Micro** để nhập bằng giọng nói

### Bước 2: Chuyển đổi

Nhấn nút **Chuyển đổi** (biểu tượng dịch thuật).

### Bước 3: Xem kết quả

Kết quả Braille Unicode sẽ hiển thị bên dưới. Nhấn **Sao chép** để copy vào clipboard.

### Ví dụ

| Input | Output (Braille Unicode) |
|-------|-------------------------|
| `Xin chào` | `⠭⠔⠝ ⠉⠓⠣⠕` |
| `Việt Nam` | `⠧⠊⠢⠞ ⠝⠁⠍` |
| `123` | `⠼⠁⠃⠉` |

---

## Chuyển đổi Braille → Text

### Bước 1: Nhập mã Braille

Nhập các ký tự Braille Unicode (U+2800–U+28FF) vào ô nhập liệu.

### Bước 2: Giải mã

Nhấn nút **Giải mã** (biểu tượng ngược).

### Bước 3: Xem kết quả

Văn bản tiếng Việt sẽ hiển thị bên dưới.

---

## OCR từ ảnh

### Bước 1: Chọn ảnh

Nhấn nút **Chọn file** và chọn ảnh chứa văn bản.

### Bước 2: Nhận dạng

Ứng dụng sẽ tự động nhận dạng văn bản từ ảnh bằng Google ML Kit.

### Bước 3: Chuyển đổi

Văn bản nhận dạng sẽ được tự động chuyển đổi sang Braille.

### Lưu ý

- Ảnh phải rõ nét, đủ ánh sáng
- Văn bản nên nằm ngang
- Hỗ trợ tiếng Việt và tiếng Anh

---

## Xuất file BRF

### Bước 1: Chuyển đổi văn bản

Thực hiện chuyển đổi text → Braille trước.

### Bước 2: Xuất file

Nhấn nút **Xuất BRF** để tạo file Braille Ready Format.

### Bước 3: Chia sẻ

File BRF có thể:
- In trên máy in Braille
- Mở trên thiết bị Braille display
- Chia sẻ qua email, USB, v.v.

---

## Cài đặt

### Chế độ tối

Vào **Cài đặt** → Bật/tắt **Chế độ tối**.

Chế độ tối giúp giảm mỏi mắt khi sử dụng trong bóng tối.

### Kích thước chữ

Vào **Cài đặt** → Điều chỉnh **Cỡ chữ** (80% - 200%).

Tính năng này hữu ích cho người khiếm thị cần chữ lớn.

---

## Câu hỏi thường gặp

### Q: Tại sao một số ký tự không chuyển đổi được?

A: Ứng dụng chỉ hỗ trợ chữ cái tiếng Việt, chữ số, dấu câu cơ bản. Các ký tự đặc biệt (emoji, ký hiệu toán học nâng cao) sẽ hiển thị cảnh báo.

### Q: File BRF mở bằng gì?

A: File BRF có thể mở bằng:
- Máy in Braille
- Thiết bị Braille display
- Text editor (hiển thị Unicode Braille)
- Phần mềm Braille chuyên dụng

### Q: Có hỗ trợ tiếng Anh không?

A: Có. Chữ cái tiếng Anh (a-z) được hỗ trợ đầy đủ. Tuy nhiên, quy tắc Braille tiếng Anh (UEB) khác với tiếng Việt.

### Q: Tại sao OCR không nhận dạng đúng?

A: OCR phụ thuộc vào chất lượng ảnh. Hãy đảm bảo:
- Ảnh rõ nét, không mờ
- Đủ ánh sáng
- Văn bản nằm ngang
- Không có nhiều font chữ khác nhau

### Q: Có thể dùng offline không?

A: Ứng dụng Flutter hoạt động offline. Chỉ có OCR (Google ML Kit) cần kết nối internet lần đầu để tải model.

---

## Liên kết

- [GitHub Repository](https://github.com/<owner>/vietnamese-braille)
- [Báo lỗi](https://github.com/<owner>/vietnamese-braille/issues)
- [Đóng góp](CONTRIBUTING.md)
