# Hướng dẫn đóng góp / Contributing

Cảm ơn bạn quan tâm đến dự án **Vietnamese Braille App**! 🎉

## Quy tắc chung / General Rules

### 🇻🇳 Tiếng Việt
- **Ngôn ngữ**: Code comments và commit messages nên dùng tiếng Việt hoặc tiếng Anh
- **Code style**: Tuân thủ [Flutter style guide](https://dart.dev/guides/language/effective-dart)
- **Architecture**: Follow Clean Architecture (core / data / domain / presentation)

### 🇬🇧 English
- **Language**: Code comments and commit messages can be in Vietnamese or English
- **Code style**: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- **Architecture**: Stick to Clean Architecture (core / data / domain / presentation)

## Quy trình / Workflow

1. **Fork** repository
2. Tạo branch mới: `git checkout -b feature/ten-tinh-nang`
3. Thực hiện thay đổi
4. **Viết test** cho code mới (hoặc sửa test cũ nếu cần)
5. Chạy `flutter test` — **tất cả phải xanh**
6. Chạy `dart analyze` — không warning hoặc error
7. Commit: `git commit -m "feat: mô tả ngắn gọn"`
8. Push và tạo Pull Request

## Coding conventions

| Rule | Detail |
|------|--------|
| **Tên file** | `snake_case.dart` |
| **Import** | Group: dart → flutter → package → local (1 dòng trống giữa mỗi nhóm) |
| **Kiểu test** | `test('mô tả ngắn gọn', () { ... })` |
| **Widget test** | `testWidgets('mô tả', (tester) async { ... })` |
| **Braille cells** | Dùng `BrailleDots.cell()` — không hardcode Unicode |
| **Format** | `dart format lib/ test/` |

## Test coverage

- **Unit test**: Bắt buộc cho mọi logic mới trong domain/core
- **Widget test**: Bắt buộc cho mọi screen/widget mới
- **Data layer**: Mock dependencies (SharedPreferences, FilePicker, etc.)
- Mục tiêu coverage: ≥ 80%

## Commit message format

```
<type>: <mô tả ngắn>

- <chi tiết 1>
- <chi tiết 2>
```

Types: `feat`, `fix`, `test`, `docs`, `refactor`, `chore`, `ci`
