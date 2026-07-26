# viet_braille_core

Package pure Dart chuyển văn bản tiếng Việt sang Unicode Braille 6 chấm và
chuyển ngược. Package không phụ thuộc Flutter.

## API chính

- `BrailleMappingImpl`: ánh xạ ký tự, NFC/NFD và các indicator.
- `BrailleConverterImpl`: text → Unicode Braille.
- `BrailleReverseConverterImpl`: Unicode Braille → text theo ngữ cảnh.
- `NabccBrailleAsciiCodec`: Unicode Braille 6 chấm ↔ Braille ASCII.
- `BrfFormatterImpl`: mã hóa Braille ASCII và ngắt dòng BRF.

```dart
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  final mapping = BrailleMappingImpl();
  final forward = BrailleConverterImpl(mapping);
  final reverse = BrailleReverseConverterImpl(mapping);

  final unicodeBraille = forward.convert('Việt Nam');
  final text = reverse.convert(unicodeBraille);
  final brf = BrfFormatterImpl().format(unicodeBraille);

  print(unicodeBraille);
  print(text);
  print(brf); // Braille ASCII, kết thúc bằng newline
}
```

## Chế độ lossless

Trong bảng Braille chuẩn, `?` va chạm với thanh hỏi và `-` va chạm với thanh
ngã. Khi cần kiểm tra round-trip máy:

```dart
final encoded = forward.convert(
  'Có?Ai',
  mode: BrailleConversionMode.lossless,
);
final decoded = reverse.convert(
  encoded,
  mode: BrailleConversionMode.lossless,
);
```

Chế độ này dùng `losslessBrailleEscape` là ô 8 chấm riêng. Nó không thuộc
chuỗi Braille 6 chấm chuẩn và codec BRF sẽ chủ động từ chối.

## Kiểm chứng

```bash
dart format --output=none --set-exit-if-changed lib test tool
dart analyze
dart run tool/verify_tt15.dart
dart test
```

Fixture TT15 độc lập nằm tại `../../tools/data/tt15_rules.json`.
