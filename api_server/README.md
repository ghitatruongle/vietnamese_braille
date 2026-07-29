# Vietnamese Braille REST API

REST API Dart/Shelf dùng chung `viet_braille_core`.

## Chạy cục bộ

```bash
dart pub get
dart run bin/server.dart
```

Mặc định server lắng nghe `0.0.0.0:8080`; có thể đổi cổng bằng biến môi trường
`PORT`.

## Endpoint

- `GET /health`
- `POST /convert` với `{"text":"Xin chào"}`
- `POST /reverse` với `{"braille":"..."}`
- `POST /batch` với `{"texts":["xin","chào"]}`

Hợp đồng đầy đủ, schema và mọi mã phản hồi được công bố trong
[`openapi.json`](openapi.json). Cổng `python tools/check_openapi.py` ngăn endpoint,
auth hoặc giới hạn kích thước trong đặc tả lệch khỏi yêu cầu bắt buộc.

Mỗi chuỗi tối đa 100.000 ký tự, tổng nội dung một batch tối đa 500.000 ký tự,
mỗi batch tối đa 100 phần tử và body tối đa 1 MiB. API yêu cầu
`Content-Type: application/json`.

API trả JSON với status `400` cho schema/JSON sai, `401` khi API key không hợp
lệ, `413` khi vượt giới hạn, `415` cho media type sai và `429` khi vượt rate
limit.

## Cấu hình bảo mật

| Biến môi trường | Mặc định | Ý nghĩa |
|---|---:|---|
| `PORT` | `8080` | Cổng lắng nghe |
| `ALLOWED_ORIGINS` | rỗng | Danh sách origin CORS, phân cách bằng dấu phẩy |
| `API_KEYS` | rỗng | Danh sách API key, phân cách bằng dấu phẩy; bắt buộc trừ khi bật `ALLOW_ANONYMOUS` |
| `ALLOW_ANONYMOUS` | `false` | Secure-by-default: server từ chối khởi động nếu `API_KEYS` rỗng, trừ khi đặt tường minh `true` (chỉ phù hợp phát triển/API công khai có chủ đích) |
| `RATE_LIMIT_REQUESTS` | `120` | Số yêu cầu tối đa trong một cửa sổ |
| `RATE_LIMIT_WINDOW_SECONDS` | `60` | Độ dài cửa sổ rate limit |
| `TRUST_PROXY` | `false` | Chỉ bật khi reverse proxy đáng tin đã chuẩn hóa `X-Forwarded-For` |

CORS mặc định không cấp quyền cho origin bên ngoài. Chỉ dùng `*` khi chủ động
chấp nhận API công khai. Rate limit nằm trong bộ nhớ từng tiến trình; triển khai
nhiều instance cần thêm rate limit dùng chung tại gateway/reverse proxy.

Khi `API_KEYS` có giá trị, mọi endpoint trừ `GET /health` và preflight
`OPTIONS` yêu cầu một trong hai header:

```text
X-API-Key: <secret>
Authorization: Bearer <secret>
```

Không ghi API key vào mã nguồn, log hoặc image. Xác thực là mặc định;
muốn chạy không xác thực phải đặt `ALLOW_ANONYMOUS=true` tường minh.
Dùng secret có entropy cao và xoay vòng tại secret manager/gateway.

Rate limiter mặc định là in-memory theo từng tiến trình; khi chạy nhiều
instance sau load balancer, inject implementation `RateLimiter` dùng backend
chung (ví dụ Redis) qua `createApiHandler(rateLimiter: ...)`.

Mỗi phản hồi có `X-Request-ID`, security headers và metadata rate-limit. Log có
request ID, method, path, status, thời lượng; không ghi body chuyển đổi.

## Chất lượng

```bash
dart format --output=none --set-exit-if-changed bin lib test
dart analyze
dart test
```
