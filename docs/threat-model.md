# Mô hình đe dọa

## Tài sản cần bảo vệ

- Nội dung văn bản/Braille, tệp, ảnh và âm thanh của người dùng.
- Tính đúng của mapping và artifact phát hành.
- Khóa ký, token CI và khả năng sẵn sàng của REST API.

## Biên tin cậy

Ứng dụng xử lý cục bộ nhưng đi qua trình chọn tệp, ML Kit, dịch vụ nhận dạng
giọng nói và bảng chia sẻ của hệ điều hành. API nhận dữ liệu không tin cậy từ
mạng. Workflow phát hành nhận dependency, action và bí mật ký.

## Mối đe dọa và kiểm soát

| Mối đe dọa | Kiểm soát hiện có | Rủi ro còn lại |
|---|---|---|
| Body/batch gây cạn RAM/CPU | Đọc stream có trần 1 MiB, trần từng chuỗi/tổng batch, rate limit | Rate limit trong bộ nhớ không dùng chung nhiều instance |
| Origin web ngoài dự kiến | CORS allowlist, mặc định rỗng | Client ngoài trình duyệt không bị CORS chặn |
| Truy cập API trái phép | API key tùy cấu hình, so sánh thời gian gần hằng, rate limit | Production phải cấp/xoay key qua secret manager; chế độ key rỗng là API công khai |
| Rò nội dung qua log | Structured log chỉ metadata, không body | Reverse proxy/hạ tầng có chính sách riêng |
| Giả mạo IP qua proxy | Chỉ tin `X-Forwarded-For` khi `TRUST_PROXY=true` | Cần cấu hình proxy đúng |
| Artifact bị thay thế | SHA-256, SBOM, GitHub provenance, ký Windows/Android | Web không có code-signing nền tảng |
| Khóa ký bị lộ | Chỉ đọc từ GitHub Secrets, gitignore khóa | Quản trị/vòng đời secret thuộc maintainer |
| Dependency có lỗ hổng đã biết | Dependabot, dependency review và OSV scan trên ba lockfile | Cơ sở dữ liệu lỗ hổng có thể chưa ghi nhận zero-day |
| Mapping sai làm hại người dùng | Fixture nguồn ghim hash, golden test, external review gate | Review bên ngoài hiện chưa hoàn tất |
| Dữ liệu giọng nói ra ngoài thiết bị | Công bố rõ, quyền micro có thể từ chối | Hành vi phụ thuộc OS/nhà cung cấp |

## Giả định triển khai

TLS, WAF, log retention, backup và rate limit phân tán thuộc đơn vị vận hành API.
`TRUST_PROXY=true` chỉ hợp lệ khi API không thể bị truy cập trực tiếp và proxy
ghi đè header chuyển tiếp từ client.
