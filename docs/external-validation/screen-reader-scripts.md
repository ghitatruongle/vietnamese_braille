# Kịch bản phiên kiểm thử trình đọc màn hình

Tài liệu này là kịch bản thao tác từng bước cho **bốn phiên bắt buộc** mà
`tools/release_evidence.py` cưỡng chế trước mọi release. Mã kịch bản
(`convert`, `copy`...) phải ghi **đúng nguyên văn** vào
`release_evidence/<tag>.json` — sai một mã là gate từ chối.

Nguyên tắc chung cho mọi phiên:

- Ghi lại: ngày giờ (kèm múi giờ), phiên bản HĐH, phiên bản trình đọc màn
  hình, mã người kiểm thử (bí danh, không tên thật), bản build app.
- Một kịch bản chỉ được đánh "đạt" khi hoàn thành **không cần nhìn màn hình**.
- Lỗi chặn tác vụ chính ⇒ `blocking_issues` ≥ 1 ⇒ gate fail. Sửa xong phải
  chạy lại phiên từ đầu.
- Biên bản lưu ở hệ thống có kiểm soát truy cập; repo chỉ giữ mã hồ sơ
  (`attestation_reference`).

---

## Phiên 1 — Windows + NVDA (app desktop)

Chuẩn bị: NVDA (bản mới nhất, miễn phí tại nvaccess.org), build
`flutter build windows --release`, tắt màn hình hoặc dùng tấm che.

### Kịch bản `convert`
1. Mở app, `Tab` đến ô nhập văn bản — NVDA phải đọc nhãn ô nhập.
2. Gõ: `Xin chào Việt Nam năm 2026`.
3. `Tab` đến nút chuyển đổi, `Enter` — NVDA phải thông báo trạng thái
   thành công (live-region), không im lặng.
4. `Tab` đến vùng kết quả Braille — NVDA đọc được nội dung ô kết quả.

- Đạt khi: mọi control có tên/role; trạng thái được đọc tự động.

### Kịch bản `copy`
1. Từ vùng kết quả, kích hoạt nút sao chép bằng `Enter`/`Space`.
2. NVDA phải xác nhận đã sao chép; dán vào Notepad kiểm tra nội dung.

### Kịch bản `learn`
1. Điều hướng đến màn hình Học bằng bàn phím.
2. `Tab` qua lưới 6 chấm — từng chấm phải đọc tên + trạng thái bật/tắt.
3. Bật/tắt chấm bằng `Enter`, nghe trạng thái đổi.

### Kịch bản `quiz`
1. Mở Quiz, trả lời 5 câu chỉ bằng `Tab`/`Enter` hoặc phím số 1–4, `N`
   sang câu mới.
2. Kết quả đúng/sai phải được đọc bằng chữ (không chỉ màu sắc).

### Kịch bản `export`
1. Sau một lần chuyển đổi, kích hoạt xuất BRF.
2. Hộp thoại Save As của Windows phải đọc được bằng NVDA; lưu và xác
   nhận file tồn tại.

---

## Phiên 2 — Web + NVDA (Chrome hoặc Edge)

Chuẩn bị: build `flutter build web --release`, serve cục bộ.

### Kịch bản `keyboard_navigation`
1. `Tab` xuyên suốt trang: không có bẫy focus, thứ tự hợp lý, focus
   nhìn thấy được.
2. `Shift+Tab` quay lui hoạt động đối xứng.

### Kịch bản `headings`
1. Dùng phím `H`/`Shift+H` của NVDA duyệt tiêu đề.
2. Cấu trúc tiêu đề phải phản ánh bố cục màn hình (không nhảy cấp vô lý).

### Kịch bản `error_announcements`
1. Kích hoạt chuyển đổi với ô nhập rỗng hoặc mở tệp không chứa văn bản.
2. Thông báo lỗi phải được NVDA đọc tự động (live-region), nêu rõ cách
   khắc phục.

---

## Phiên 3 — Android + TalkBack

Chuẩn bị: thiết bị Android thật (API 24+), TalkBack bật, AAB/APK release.

### Kịch bản `convert`
1. Vuốt phải tuần tự đến ô nhập, nhập câu tiếng Việt có dấu bằng bàn phím
   nói hoặc gõ.
2. Chạm đúp nút chuyển đổi — TalkBack thông báo kết quả.

### Kịch bản `ocr`
1. Chọn ảnh chứa văn bản tiếng Việt từ thư viện.
2. TalkBack đọc tiến trình và kết quả OCR; lỗi (ảnh không chữ) phải được
   thông báo rõ.

### Kịch bản `learn` / `quiz`
Như phiên 1 nhưng bằng cử chỉ TalkBack (vuốt phải/trái, chạm đúp); quiz
5 câu hoàn thành không nhìn màn hình.

### Kịch bản `share`
1. Kích hoạt chia sẻ BRF; sheet chia sẻ hệ thống đọc được bằng TalkBack.
2. Chia sẻ đến một ứng dụng bất kỳ và xác nhận thành công.

---

## Phiên 4 — iOS + VoiceOver

Chuẩn bị: iPhone/iPad thật (iOS 15.5+), VoiceOver bật, build release.

Kịch bản `convert`, `ocr`, `learn`, `quiz`, `share`: tương tự phiên 3
với cử chỉ VoiceOver (rotor, vuốt, chạm đúp). Lưu ý riêng: kiểm tra
rotor "Headings" hoạt động ở các màn hình chính.

---

## Biên bản mẫu (điền cho từng phiên)

```text
BIÊN BẢN PHIÊN KIỂM THỬ TRÌNH ĐỌC MÀN HÌNH
Mã hồ sơ (attestation_reference): ............
Nền tảng / Công nghệ hỗ trợ:      ............ / ............
Phiên bản HĐH / phiên bản AT:     ............ / ............
Mã người kiểm thử (tester_id):    ............
Thời điểm (ISO-8601 + múi giờ):   ............
Bản build (commit SHA):           ............

| Kịch bản | Đạt/Không | Lỗi chặn | Lỗi phụ | Ghi chú |
|---|---|---|---|---|
| ... | | | | |

Tổng lỗi chặn (blocking_issues): ....
Kết luận (result):               passed / failed
Chữ ký/xác nhận điện tử:         (lưu ngoài repo)
```

Sau khi cả bốn phiên đạt, chép số liệu vào `release_evidence/<tag>.json`
và chạy:

```bash
python tools/release_evidence.py --file release_evidence/<tag>.json \
  --tag <tag> --commit <FULL_SHA>
```
