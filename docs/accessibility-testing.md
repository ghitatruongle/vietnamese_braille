# Kiểm thử khả năng tiếp cận

## Phạm vi tự động

CI chạy widget test cho Home, kết quả chuyển đổi, History, Settings, luồng học
và quiz, bao gồm:

- mọi mục tiêu chạm có nhãn ngữ nghĩa;
- kích thước mục tiêu chạm tối thiểu theo guideline Android;
- tương phản chữ theo guideline Flutter;
- quiz không tràn bố cục ở cỡ chữ 200%;
- lưới 6 chấm dùng được bằng Tab/Enter;
- quiz dùng được bằng Tab/Enter hoặc phím số 1–4, phím `N` sang câu mới;
- kết quả đúng/sai có nội dung chữ và live-region, không chỉ dùng màu.
- nhãn mục tiêu chạm, kích thước mục tiêu Android và độ tương phản WCAG trên
  các màn hình chính.

Lệnh chạy:

```bash
cd viet_braille_app
flutter test test/accessibility --no-pub
```

## Ma trận kiểm thử thủ công

| Nền tảng | Công cụ | Kịch bản | Trạng thái |
|---|---|---|---|
| Windows | NVDA | Chuyển đổi, sao chép, học, quiz, xuất tệp | Chưa thực hiện |
| Web/Windows | NVDA + Chrome | Điều hướng bàn phím, tiêu đề, thông báo lỗi | Chưa thực hiện |
| Android | TalkBack | Chuyển đổi, OCR, học, quiz, chia sẻ | Chưa thực hiện |
| iOS | VoiceOver | Chuyển đổi, OCR, học, quiz, chia sẻ | Chưa thực hiện |
| Windows | Bàn phím | Tab/Shift+Tab, Enter/Space, phím tắt | Một phần tự động |

“Chưa thực hiện” là cổng phát hành, không được đổi thành “đạt” nếu thiếu ngày,
phiên bản hệ điều hành, phiên bản trình đọc màn hình, người kiểm thử và biên bản.
Kịch bản thao tác từng bước và biên bản mẫu cho cả bốn phiên:
[external-validation/screen-reader-scripts.md](external-validation/screen-reader-scripts.md).

Biên bản đã được ký xác nhận phải được tóm tắt theo mẫu
`release_evidence/release-evidence.json.example`. Workflow yêu cầu đủ bốn phiên
Windows/NVDA, Web/NVDA, Android/TalkBack và iOS/VoiceOver; chỉ ghi mã người kiểm
thử và tham chiếu hồ sơ, không ghi thông tin cá nhân nhạy cảm.

## Kịch bản nghiệm thu với người dùng

Mỗi phiên cần tối thiểu các tác vụ:

1. Nhập một câu tiếng Việt có dấu và đọc kết quả.
2. Mở tệp, nhận biết lỗi và xuất BRF.
3. Bật/tắt sáu chấm bằng trình đọc màn hình và bàn phím/cử chỉ.
4. Hoàn thành năm câu quiz mà không dựa vào màu sắc.
5. Thay cỡ chữ lên 200% và lặp lại tác vụ chính.

Ghi thời gian hoàn thành, lỗi nghiêm trọng, lỗi có thể phục hồi, phát biểu của
người tham gia và bản sửa tương ứng. Không lưu tên thật hoặc dữ liệu nhạy cảm
trong kho mã nguồn.

## Tiêu chí đóng cổng

- Không còn lỗi chặn tác vụ chính.
- Không còn mục tiêu tương tác thiếu tên/role/state.
- Điều hướng bàn phím không mắc kẹt và thứ tự hợp lý.
- Có ít nhất một vòng kiểm thử với người dùng khiếm thị hoặc chuyên gia sử dụng
  trình đọc màn hình; bằng chứng phải được người thực hiện ký xác nhận.
