# Kiến trúc

## Monorepo

```text
packages/viet_braille_core/   pure Dart, nguồn sự thật duy nhất
viet_braille_app/             Flutter UI và tích hợp nền tảng
api_server/                   REST API Dart/Shelf dùng chung core
tools/data/                   fixture TT15 độc lập
tools/verify.py               CLI kiểm chứng đa nền tảng
```

## Core pipeline

```text
print text
  → normalize NFC + theo dõi chữ hoa
  → phân tích từ/cụm, số, qu/gi
  → ánh xạ Unicode Braille 6 chấm
  ├─→ reverse parser theo ngữ cảnh
  └─→ NABCC codec → BRF formatter
```

`BrailleConversionMode.standard` luôn tạo 6 chấm. Mode `lossless` dùng escape
8 chấm dành riêng cho kiểm thử va chạm, và bị BRF codec từ chối.

## App layers

```text
presentation/
  screens + widgets
  Riverpod ConversionNotifier
          ↓
data/
  file picker/extractor
  OCR + speech
  history + BRF sharing
          ↓
viet_braille_core
```

`PlatformCapabilities` là cổng duy nhất quyết định tính năng nào được hiển
thị. OCR không được khởi tạo ngoài Android/iOS. File web truyền bytes tới
extractor thay vì sử dụng `dart:io` path.

## API layer

`api_server` chỉ làm nhiệm vụ HTTP, validation và giới hạn payload; mọi chuyển
đổi tiếp tục đi qua `viet_braille_core`. Handler từ chối JSON sai schema bằng
400, từ chối chuỗi/batch quá giới hạn bằng 413 và không trả chi tiết exception
nội bộ cho client.

## Tính nhất quán dữ liệu

- `ConversionNotifier` chờ lưu lịch sử và biến lỗi persistence thành warning.
- `HistoryServiceImpl` tuần tự hóa mutation để tránh hai lần ghi dùng chung
  snapshot rồi ghi đè nhau.
- BRF exporter kiểm tra Braille ASCII trước khi ghi hoặc chia sẻ.
- Release Android không dùng debug signing key.

## Kiểm thử và CI

- Unit/property/regression test cho mapping, converter, reverse và BRF.
- Fixture TT15 không được sinh từ implementation.
- Flutter unit/widget/integration tests cho data và presentation.
- Handler tests cho ba endpoint API và các nhánh validation.
- CI chạy Windows/Linux; coverage gate hiện là core 90%, app 80%, API 90%, kèm
  Web/Android release builds.
