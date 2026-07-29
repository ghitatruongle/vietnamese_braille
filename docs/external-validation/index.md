# Xác thực bên ngoài (Giai đoạn 4)

Bốn cổng dưới đây cần con người thật và là điều kiện bắt buộc của
release (cưỡng chế bởi `tools/release_evidence.py` trong workflow
`Signed release`). Bộ tài liệu này chuẩn hóa cách thực hiện từng cổng:

| Cổng | Tài liệu hướng dẫn | Mục trong evidence JSON |
|---|---|---|
| 4 phiên trình đọc màn hình | [Kịch bản NVDA/TalkBack/VoiceOver](screen-reader-scripts.md) | `accessibility.sessions` |
| Nghiệm thu người dùng khiếm thị | [Phiếu nghiệm thu người dùng](user-validation-survey.md) | `user_validation` |
| Chuyên gia Braille review TT15 | [Gói đối chiếu chuyên gia](expert-review-packet.md) (sinh bằng `tools/expert_review_packet.py`) | `tt15_external_review` |
| Phê duyệt phát hành | Người phê duyệt ký sau khi 3 cổng trên đạt | `release_approval` |

## Quy trình chuẩn cho release v1.2.0

1. Hoàn thành các phiên theo tài liệu trên; lưu biên bản ở hệ thống có
   kiểm soát truy cập (repo chỉ giữ mã hồ sơ).
2. Điền `release_evidence/v1.2.0.json` (đã có sẵn template ở trạng thái
   `pending`): đổi `result` thành `passed` **chỉ khi** biên bản tương
   ứng đã ký và `blocking_issues = 0`.
3. Kiểm tra cục bộ:

   ```bash
   python tools/release_evidence.py \
     --file release_evidence/v1.2.0.json \
     --tag v1.2.0 \
     --commit <FULL_GIT_SHA>
   ```

4. Commit evidence, bump version 3 module lên `1.2.0`, tạo tag `v1.2.0`
   và push — workflow release sẽ chạy lại đúng phép kiểm trên và chặn
   nếu thiếu bất kỳ cổng nào.

## Nguyên tắc chung

- Không lưu tên thật, bản ghi âm/hình, chữ ký viết tay hay dữ liệu nhạy
  cảm trong repo — chỉ mã bí danh và mã hồ sơ.
- Mọi mã kịch bản (`convert`, `font_scale_200`...) phải khớp nguyên văn
  với hằng số trong `tools/release_evidence.py`.
- Người review TT15 phải độc lập với nhóm phát triển
  (`independent: true`).
