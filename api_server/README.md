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

Mỗi chuỗi tối đa 100.000 ký tự và mỗi batch tối đa 100 phần tử. API trả JSON,
status `400` cho schema/JSON sai và `413` khi vượt giới hạn. CORS hiện mở (`*`);
triển khai công khai nên đặt reverse proxy, rate limit và chính sách origin phù
hợp với môi trường.

## Chất lượng

```bash
dart format --output=none --set-exit-if-changed bin lib test
dart analyze
dart test
```
