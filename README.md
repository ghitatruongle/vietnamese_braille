# Vietnamese Braille

[![CI](https://github.com/ghitatruongle/vietnamese_braille/actions/workflows/ci.yml/badge.svg)](https://github.com/ghitatruongle/vietnamese_braille/actions/workflows/ci.yml)
[![Coverage](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fghitatruongle%2Fvietnamese_braille%2Fmain%2Fdocs%2Fcoverage-badge.json)](docs/metrics.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Ứng dụng Flutter chuyển đổi văn bản tiếng Việt sang **Unicode Braille 6
chấm**, có bộ chuyển ngược để đối chiếu và xuất tệp **BRF/Braille ASCII**.
Logic chuyển đổi nằm trong package pure Dart độc lập.

## Chức năng hiện có

- Nhập văn bản trực tiếp hoặc bằng giọng nói.
- Đọc tệp TXT và DOCX; trên web tệp được xử lý từ bytes, không phụ thuộc
  đường dẫn cục bộ.
- Chuyển tiếng Việt sang Unicode Braille 6 chấm, gồm thanh điệu, chữ hoa,
  chữ số và quy tắc `qu`/`gi`.
- OCR ảnh bằng Google ML Kit trên Android và iOS.
- Xuất `.brf` bằng North American Braille ASCII, không ghi giả Unicode UTF-8
  với phần mở rộng BRF.
- Xuất PDF bằng font Noto Sans Symbols 2 có glyph Braille Unicode.
- Đối chiếu round-trip lossless cho hai va chạm không thể phân biệt chỉ bằng
  một ô: dấu hỏi/thanh hỏi và gạch ngang/thanh ngã.
- Lịch sử cục bộ, giao diện sáng/tối, cỡ chữ 80–200%, màn hình học và quiz.
- Semantics, tooltip và điều hướng responsive cho mobile/desktop.
- REST API Dart/Shelf có `/convert`, `/reverse`, `/batch`, validation và giới hạn
  payload.

## Giới hạn cần biết

- Unicode chứa 256 mẫu Braille 8 chấm, nhưng bảng tiếng Việt mà dự án triển
  khai chỉ dùng các mẫu **chấm 1–6**.
- Dấu `?` dùng cùng ô với thanh hỏi; `-` dùng cùng ô với thanh ngã. Bộ chuyển
  ngược chuẩn phải suy luận theo ngữ cảnh và không thể đảm bảo song ánh cho
  mọi chuỗi. Chế độ lossless dùng một escape marker 8 chấm riêng, chỉ phục vụ
  kiểm tra nội bộ và **không được xuất BRF**.
- OCR chỉ hỗ trợ Android/iOS do giới hạn của Google ML Kit. Web và desktop chỉ
  cho chọn TXT/DOCX.
- Speech phụ thuộc dịch vụ nhận dạng có sẵn trên thiết bị/trình duyệt; Linux
  hiện không được plugin hỗ trợ.
- PDF đóng gói sẵn Noto Sans Symbols 2 theo giấy phép OFL nên có thể xuất
  ngoại tuyến. Trên Windows, BRF và PDF dùng hộp **Save As** gốc.
- Đây là phần mềm hỗ trợ chuyển đổi, chưa thay thế việc hiệu đính của chuyên
  gia Braille cho tài liệu xuất bản.

## Ma trận nền tảng

| Tính năng | Android | iOS | Web | Windows | macOS | Linux |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Chuyển đổi lõi | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| TXT/DOCX | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| OCR ảnh | ✓ | ✓ | — | — | — | — |
| Nhập giọng nói | ✓ | ✓ | tùy trình duyệt | beta | ✓ | — |
| Chia sẻ/xuất BRF | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

## Cài đặt

Yêu cầu khuyến nghị:

- Flutter **3.44.2** stable, kèm Dart 3.12.x.
- Android SDK 35+; Android tối thiểu API 24 theo Flutter 3.44.
- Với iOS: Xcode 15.3+, deployment target 15.5.
- Python 3.11+ chỉ cần khi chạy CLI kiểm chứng.

```bash
git clone https://github.com/ghitatruongle/vietnamese_braille.git
cd vietnamese_braille/viet_braille_app
flutter pub get
flutter run
```

## Kiểm tra chất lượng

```bash
# Toàn bộ monorepo: đối chiếu TT15, analyze và test
python tools/verify.py --all

# Chỉ package lõi
cd packages/viet_braille_core
dart analyze
dart run tool/verify_tt15.dart
dart test

# Chỉ ứng dụng
cd ../../viet_braille_app
flutter analyze
flutter test --coverage
flutter build windows --release
flutter build web --release

# Chỉ REST API
cd ../api_server
dart analyze
dart test
dart run bin/server.dart
```

`tools/compliance_report.py` kiểm tra SHA-256 của PDF nguồn, fixture tại
`tools/data/tt15_rules.json` và 141 phép so sánh trực tiếp với package hiện hành.
Ba ký hiệu định dạng chưa có trong API văn bản thuần được báo cáo rõ là chưa
triển khai; review chuyên gia bên ngoài vẫn là cổng phát hành. CI chạy
trên Ubuntu và Windows, áp ngưỡng coverage, ưu tiên tạo bundle Windows x64,
sau đó tạo thêm Web/Android release build.

Số liệu test/coverage hiện hành xem [docs/metrics.md](docs/metrics.md)
(sinh tự động bằng `python tools/refresh_metrics.py --write`).

## Trạng thái xác thực bên ngoài

Các cổng dưới đây cần con người thật và **chưa hoàn tất** — dự án không
tuyên bố "production-ready" khi chưa có đủ bằng chứng (cập nhật 2026-07-30):

| Cổng | Trạng thái | Bằng chứng khi hoàn tất |
|---|---|---|
| Chuyên gia Braille thẩm định đầu ra theo TT15 | ⏳ Chưa có | `release_evidence/` + `docs/tt15-compliance.md` |
| Phiên kiểm thử NVDA/TalkBack/VoiceOver có biên bản | ⏳ Chưa có | `docs/accessibility-testing.md` |
| Nghiệm thu bởi người dùng khiếm thị | ⏳ Chưa có | Phiếu khảo sát trong `release_evidence/` |
| Khóa ký chính thức (Android keystore, Authenticode) | ⏳ Chưa có | Artifact ký trong GitHub Release |
| Release có tag chạy qua `release.yml` (SBOM, provenance) | ⏳ Chưa chạy lần nào | GitHub Release kèm attestation |

Chi tiết từng phase: [docs/phase-0-5-audit.md](docs/phase-0-5-audit.md).
Bộ kịch bản/biên bản để thực hiện các cổng này:
[docs/external-validation/index.md](docs/external-validation/index.md).

## BRF được tạo như thế nào?

Luồng xuất tệp:

```text
Văn bản tiếng Việt
  → Unicode Braille 6 chấm
  → NABCC/Braille ASCII
  → ngắt dòng, giữ bố cục
  → tệp .brf chỉ chứa ASCII + CR/LF/FF
```

Ví dụ, các ô `⠁⠃⠉` được ghi thành bytes ASCII `ABC`. Formatter từ chối
print text, Unicode Braille 7/8 chấm và độ dài dòng không hợp lệ.

## Kiến trúc

```text
packages/viet_braille_core/
├── lib/
│   ├── braille_mapping.dart
│   ├── braille_converter.dart
│   ├── braille_reverse_converter.dart
│   ├── braille_ascii_codec.dart
│   └── brf_formatter.dart
├── test/
└── tool/verify_tt15.dart

viet_braille_app/
├── lib/core/            # theme, lỗi, capability theo nền tảng
├── lib/data/            # file, OCR, speech, history, export
├── lib/presentation/    # Riverpod UI
├── lib/teaching/        # học và quiz Braille
└── test/

api_server/
├── bin/server.dart
├── lib/handlers/
└── test/
```

## Android release signing

Không có fallback sang debug key. Sao chép
`viet_braille_app/android/key.properties.example` thành `key.properties`,
điền đường dẫn keystore và giữ cả hai ngoài Git. CI tạo artifact unsigned;
workflow `Signed release` bắt buộc khóa release cho Android và Authenticode cho
Windows, đồng thời tạo checksum, SBOM và provenance.

## Nguồn quy chiếu

- [Thông tư 15/2019/TT-BGDĐT – chuẩn quốc gia về chữ nổi Braille](https://moet.gov.vn/content/vanban/Lists/VBDT/Attachments/1421/17.06.19-Quy%20%C4%91%E1%BB%8Bnh%20chu%E1%BA%A9n%20qu%E1%BB%91c%20gia%20v%E1%BB%81%20ch%E1%BB%AF%20n%E1%BB%95i%20Braille%20cho%20NKT%20%28b%E1%BA%A3n%20PDF%29.pdf)
- [Library of Congress – Braille Ready Format](https://www.loc.gov/preservation/digital/formats/fdd/fdd000551.shtml)
- [NLS – North American ASCII Braille trong BRF](https://www.loc.gov/nls/who-we-are/guidelines-and-specifications/contract-specifications/delivery-of-braille-book-and-magazine-files-via-the-internet/)

## Đóng góp và giấy phép

Xem [CONTRIBUTING.md](CONTRIBUTING.md), [CHANGELOG.md](CHANGELOG.md),
[PRIVACY.md](PRIVACY.md), [SECURITY.md](SECURITY.md),
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) và [LICENSE](LICENSE). Dự án phát hành
theo giấy phép MIT.
