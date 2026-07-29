# Phiếu nghiệm thu với người dùng khiếm thị

Gate `user_validation` trong `tools/release_evidence.py` yêu cầu:
ít nhất **1 người tham gia**, trong đó có người **mù hoặc thị lực kém**
(`includes_blind_or_low_vision_participant: true`), hoàn thành đủ **5 kịch
bản** dưới đây với `blocking_issues = 0`.

## Nguyên tắc đạo đức & riêng tư

- Người tham gia được giải thích mục đích và đồng ý trước khi bắt đầu;
  có quyền dừng bất cứ lúc nào.
- **Không** lưu tên thật, giọng nói, ảnh, video vào repo — chỉ mã bí danh
  (ví dụ `P01`) và mã hồ sơ.
- Người điều phối (coordinator) ghi biên bản; người tham gia xác nhận
  bằng hình thức phù hợp (đọc lại biên bản, xác nhận miệng có ghi nhận,
  hoặc chữ ký điện tử lưu ngoài repo).
- Bồi dưỡng thời gian cho người tham gia nếu điều kiện cho phép.

## Gợi ý tuyển người tham gia

- Hội Người mù Việt Nam (cấp tỉnh/thành) — hoivnm.vn
- Trường PTCS Nguyễn Đình Chiểu (Hà Nội / TP.HCM)
- Trung tâm Sao Mai, trung tâm hỗ trợ người khiếm thị địa phương
- Cộng đồng người dùng NVDA/TalkBack tiếng Việt trên các diễn đàn

## 5 kịch bản bắt buộc (mã phải khớp nguyên văn khi ghi evidence)

### 1. `convert_and_read`
Nhập (gõ hoặc đọc giọng nói) một câu tiếng Việt có dấu tự chọn, thực hiện
chuyển đổi và đọc lại kết quả bằng trình đọc màn hình của mình.

- Ghi: thời gian hoàn thành, số lần cần trợ giúp, cảm nhận.

### 2. `file_and_brf`
Mở một tệp TXT/DOCX có sẵn, nhận biết thông báo (thành công hoặc lỗi),
xuất tệp BRF và xác nhận tệp đã lưu/chia sẻ được.

### 3. `learn_with_screen_reader`
Vào màn hình Học, bật/tắt các chấm trong lưới 6 chấm chỉ bằng trình đọc
màn hình + bàn phím hoặc cử chỉ.

### 4. `five_question_quiz`
Hoàn thành 5 câu quiz liên tiếp; xác nhận người tham gia biết mình đúng
hay sai ở từng câu **mà không cần nhìn màu sắc**.

### 5. `font_scale_200`
Tăng cỡ chữ lên 200% trong Cài đặt rồi lặp lại kịch bản 1. Bố cục không
được vỡ/che khuất nội dung.

## Phiếu ghi nhận (một bản cho mỗi người tham gia)

```text
PHIẾU NGHIỆM THU NGƯỜI DÙNG — Vietnamese Braille
Mã người tham gia:        P.....   (bí danh, không tên thật)
Mù / thị lực kém:         có / không
Công nghệ hỗ trợ quen dùng: ............ (NVDA/TalkBack/VoiceOver/khác)
Nền tảng thử nghiệm:      ............
Mã điều phối viên (coordinator_id): ............
Thời điểm (ISO-8601 + múi giờ):     ............

| # | Kịch bản | Hoàn thành? | Thời gian | Lỗi chặn | Lỗi phụ | Trích phát biểu |
|---|---|---|---|---|---|---|
| 1 | convert_and_read | | | | | |
| 2 | file_and_brf | | | | | |
| 3 | learn_with_screen_reader | | | | | |
| 4 | five_question_quiz | | | | | |
| 5 | font_scale_200 | | | | | |

Ba điều người tham gia thích nhất:      1) ... 2) ... 3) ...
Ba điều gây khó khăn nhất:              1) ... 2) ... 3) ...
Người tham gia có sẵn lòng dùng tiếp?   có / không / có nếu sửa ...
Tổng lỗi chặn (blocking_issues):        ....
Mã hồ sơ (attestation_reference):       ............
```

## Sau phiên nghiệm thu

1. Mỗi lỗi chặn mở một issue, sửa xong phải chạy lại kịch bản liên quan
   với chính người tham gia (hoặc người tương đương).
2. Khi tất cả kịch bản đạt và `blocking_issues = 0`, điền mục
   `user_validation` trong `release_evidence/<tag>.json`:
   `participant_count`, `includes_blind_or_low_vision_participant: true`,
   `coordinator_id`, `tested_at`, `attestation_reference`,
   `scenarios` (đủ 5 mã trên), `result: "passed"`.
