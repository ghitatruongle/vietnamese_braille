# Spike OCR trên Windows — báo cáo kỹ thuật (Phase 2F.1)

> Trạng thái: **chờ người dùng chốt phương án** trước khi triển khai 2F.2.
> Bối cảnh: OCR đang chỉ chạy trên Android/iOS bằng Google ML Kit; Windows
> là nền tảng chính của dự án nên đây là khoảng trống lớn nhất của ma trận
> nền tảng.

## Mục tiêu

Cho phép kéo-thả/chọn ảnh JPG/PNG trên Windows và nhận văn bản tiếng Việt
bằng OCR chạy cục bộ, tích hợp vào pipeline `ConversionNotifier` đã có sẵn
định tuyến (`convertDroppedFile`, Phase 2E).

## Khảo sát các phương án

| # | Phương án | Kết quả khảo sát | Đánh giá |
|---|---|---|---|
| A | Package [`winrt_ocr_flutter`](https://pub.dev/packages/winrt_ocr_flutter) 0.1.0 | Wrap đúng Windows.Media.Ocr qua C++/WinRT; API `recognizeText(path)` khớp nhu cầu; mới đăng ~2 tuần | ⚠️ Giấy phép độc quyền "All rights reserved", repo riêng tư, uploader chưa verify, mới thử trên 1 máy — **không an toàn về giấy phép/cung ứng cho dự án MIT** |
| B | Package `windows_ocr` 0.0.1 | Engine Nicomsoft thương mại bên thứ ba; phát hành 5 năm trước; **Dart 3 incompatible** | ❌ Loại |
| C | **Tự viết plugin C++/WinRT + MethodChannel** | Gọi thẳng `StorageFile → BitmapDecoder → OcrEngine.RecognizeAsync`; ~100–200 dòng C++, phụ thuộc C++/WinRT header; ngôn ngữ theo profile người dùng (cần cài gói ngôn ngữ OCR tiếng Việt trong Settings > Time & language) | ✅ Sạch giấy phép, kiểm soát trọn vẹn, khớp cơ chế capability gating hiện có; công sức ước tính 1–2 buổi + kiểm thử tay trên Windows thật |
| D | Tesseract (`tesseract_flutter` + traineddata vi) | Đa nền tảng, MIT; chất lượng tiếng Việt thấp hơn engine hệ điều hành; bundle tăng ~10–15 MB; thêm native build deps vào CI | ⚠️ Dự phòng nếu C gặp trở lực |

## Điều kiện vận hành (áp dụng cho C và A)

- Người dùng cần cài **gói ngôn ngữ tiếng Việt kèm OCR** trong
  *Settings › Time & language › Language & region* của Windows; khi thiếu,
  `OcrEngine::TryCreateFromUserProfileLanguages()` trả null → app phải hiển thị
  hướng dẫn thay vì lỗi trần.
- Đầu vào là **đường dẫn tệp** (không bytes) — khớp luồng drag & drop hiện có;
  web/mobile không bị ảnh hưởng.

## Đề xuất

**Chọn phương án C** (tự viết plugin WinRT). Lý do: dự án MIT cần chuỗi cung
ứng giấy phép sạch; lượng code native nhỏ và đóng gói trong một plugin nội bộ
(`viet_braille_ocr_windows`) không phát hành pub.dev; giao diện Dart giữ nguyên
`OcrProcessor` hiện hành để UI không đổi.

Nếu bạn muốn giảm rủi ro tiến độ, có thể chấp nhận A như bản thử nghiệm nội bộ
(không đưa vào release) song song với C.

## Phân nhánh sau quyết định

- **Duyệt C:** triển khai 2F.2 (plugin + gating + UI hiển thị ngôn ngữ OCR)
  và 2F.3 (test + cập nhật ma trận nền tảng README/docs) — bổ sung vào Beta 1
  hoặc tách thành bản 1.5.0-beta1+k tuỳ quyết định của bạn.
- **Chuyển backlog:** đánh dấu 2F chuyển sang 1.6.x; ma trận nền tảng giữ
  nguyên trạng thái trung thực hiện tại (OCR: Android/iOS ✓, Windows —).
