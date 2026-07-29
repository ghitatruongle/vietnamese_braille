# Bằng chứng phát hành

Mỗi tag phát hành phải có một tệp JSON cùng tên trong thư mục này, ví dụ
`release_evidence/v1.1.0.json`. Tệp phải được commit trước khi tạo tag và phải
trỏ tới đúng commit được phát hành.

Quy trình:

1. Sao chép `release-evidence.json.example` thành `<tag>.json`.
2. Điền mã định danh không chứa thông tin cá nhân nhạy cảm và liên kết hoặc mã
   hồ sơ xác nhận độc lập.
3. Chỉ đổi `result` thành `passed` khi biên bản tương ứng đã được ký xác nhận và
   không còn lỗi chặn.
4. Chạy:

   ```bash
   python tools/release_evidence.py \
     --file release_evidence/v1.1.0.json \
     --tag v1.1.0 \
     --commit <FULL_GIT_SHA>
   ```

Workflow phát hành chạy lại cùng lệnh với `GITHUB_REF_NAME` và `GITHUB_SHA`.
Không thể phát hành nếu thiếu review TT15 độc lập, một trong bốn phiên
NVDA/TalkBack/VoiceOver, nghiệm thu người dùng khiếm thị hoặc phê duyệt phát
hành.

Không commit tên thật, bản ghi âm, nội dung người dùng, chữ ký viết tay hoặc dữ
liệu nhạy cảm. Chỉ lưu mã hồ sơ và tham chiếu tới hệ thống quản lý bằng chứng có
kiểm soát truy cập.
