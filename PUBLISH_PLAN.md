# 🚀 Kế hoạch hoàn thiện dự án Vietnamese Braille để xuất bản

**Ngày tạo:** 2026-07-03  
**Trạng thái hiện tại:** Gần sẵn sàng — cần hoàn thiện một số mục còn lại

---

## ✅ Đã hoàn thành

| # | Công việc | Trạng thái |
|---|-----------|-----------|
| 1 | Thay `<owner>` → `ghiatruongle` trong tất cả file | ✅ Done |
| 2 | Dọn dẹp git status (commit tất cả thay đổi) | ✅ Done |
| 3 | Thêm `.gitignore` cho `.dart_tool/`, `build/`, `pubspec.lock` | ✅ Done |
| 4 | Thiết lập `viet_braille_app` làm git submodule | ✅ Done |
| 5 | Code quality: `dart analyze` — 0 issues | ✅ Done |
| 6 | Tests: 662/662 passed | ✅ Done |
| 7 | Fix bugs: infinite loop, phrase grouping, tone reordering | ✅ Done |
| 8 | Documentation: README, CONTRIBUTING, CHANGELOG, user-guide | ✅ Done |
| 9 | CI/CD: GitHub Actions (format + analyze + test + coverage) | ✅ Done |
| 10 | No hardcoded secrets/API keys | ✅ Done |

---

## 📋 Các việc còn lại để xuất bản

### 🔴 Ưu tiên cao — PHẢI làm

#### 1. Push code lên GitHub
```bash
# Push outer repo
cd E:/vietnamese_braille
git push origin master

# Push submodule
cd E:/vietnamese_braille/viet_braille_app
git push origin main
```

#### 2. Tạo GitHub Release cho v1.0.0
- Tag version: `v1.0.0`
- Title: `Vietnamese Braille v1.0.0`
- Description: Copy từ CHANGELOG.md
- Attach APK (nếu build được)

#### 3. Bật GitHub Pages cho docs
- Vào repo Settings → Pages
- Source: Deploy from branch `master` / `docs/` folder
- Hoặc dùng GitHub Actions workflow `docs.yml` đã có

#### 4. Chạy `flutter test --coverage` và upload Codecov
```bash
cd viet_braille_app
flutter test --coverage
# Codecov sẽ tự động upload qua CI workflow
```

---

### 🟡 Ưu tiên trung bình — NÊN làm

#### 5. Thêm LICENSE cho `viet_braille_app/`
```bash
cp LICENSE viet_braille_app/LICENSE
```

#### 6. Thêm README cho `packages/viet_braille_core/`
- Mô tả package: Vietnamese Braille core conversion library
- Usage examples
- API documentation

#### 7. Chuyển `flutter_lints` → `lints` hoặc `very_good_analysis`
```yaml
# pubspec.yaml
dev_dependencies:
  lints: ^4.0.0  # hoặc very_good_analysis
```

#### 8. Xóa `print()` trong production code
- `packages/viet_braille_core/lib/braille_converter.dart:70` — dùng `logging` package hoặc xóa

#### 9. Thêm test cho `SpeechService`
- File: `test/data/speech_service_test.dart`
- Test: initialize, startListening, stopListening

#### 10. Thêm widget test cho `teaching/` screens
- `test/presentation/screens/learning_screen_test.dart`
- `test/presentation/screens/quiz_screen_test.dart`

---

### 🟢 Ưu tiên thấp — CÓ THỂ làm sau

#### 11. Build APK cho Android
```bash
cd viet_braille_app
flutter build apk --release
# File: build/app/outputs/flutter-apk/app-release.apk
```

#### 12. Build cho Web
```bash
flutter build web --release
# Deploy lên GitHub Pages
```

#### 13. Publish `viet_braille_core` lên pub.dev
```bash
cd packages/viet_braille_core
dart pub publish --dry-run  # Kiểm tra trước
dart pub publish            # Publish thật
```

#### 14. Thêm `analysis_options.yaml` cho `viet_braille_core`
```yaml
include: package:lints/recommended.yaml
```

#### 15. Viết blog post / demo video
- Giới thiệu dự án
- Cách sử dụng
- Technical details

---

## 📊 Tổng kết

| Tiêu chí | Trạng thái |
|----------|-----------|
| Code quality | ✅ Hoàn hảo (0 issues) |
| Tests | ✅ 662/662 passed |
| Documentation | ✅ Đầy đủ |
| CI/CD | ✅ GitHub Actions |
| Git structure | ✅ Submodule setup |
| Owner info | ✅ ghitatruongle |
| Secrets | ✅ Không có |

**Kết luận:** Dự án **đã sẵn sàng để xuất bản** sau khi push code lên GitHub và tạo release.

---

## 🎯 Thứ tự thực hiện

1. **Push code** → `git push origin master`
2. **Tạo Release** → GitHub → Releases → New Release
3. **Bật GitHub Pages** → Settings → Pages
4. **Thêm LICENSE** cho app
5. **Build APK** (nếu cần)
6. **Thông báo / chia sẻ**

---

*Plan created: 2026-07-03*
