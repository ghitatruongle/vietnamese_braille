# Ma trận nghiệm thu Phase 0–5

Tài liệu này là nguồn trạng thái cho phạm vi Phase 0–5 đã dùng trong đợt nâng
cấp hiện tại. “Đạt kỹ thuật” chỉ có nghĩa là mã nguồn và cổng tự động đã qua;
không thay thế review độc lập, biên bản người dùng hoặc chữ ký phát hành.

| Phase | Yêu cầu nghiệm thu | Bằng chứng hiện tại | Trạng thái |
|---|---|---|---|
| 0 — Nền tảng | Format, docs, version/lockfile, analyze, test và CI đa nền tảng | `python tools/verify.py --all`; `.github/workflows/ci.yml` | Đạt kỹ thuật |
| 1 — Lõi chuyển đổi | Quy tắc Việt, round-trip lossless, không rò state, hiệu năng 100.000 ký tự, coverage core ≥90% | Test core; `performance_test.dart`; LCOV 92,92% | Đạt kỹ thuật |
| 2 — TT15 | PDF ghim SHA-256, fixture chấm/Unicode/ví dụ, so sánh implementation, review độc lập | `python tools/compliance_report.py`; 141 kiểm tra tự động | Tự động đạt; review độc lập còn thiếu |
| 3 — Trợ năng | Nhãn/role/state, bàn phím, mục tiêu chạm, tương phản, chữ 200%, NVDA/TalkBack/VoiceOver và người dùng thật | 709 test app; LCOV 82,89%; `flutter test test/accessibility`; `docs/accessibility-testing.md` | Tự động đạt; bốn phiên thiết bị và nghiệm thu người dùng còn thiếu |
| 4 — Bảo mật/phát hành | API auth/rate limit/CORS/giới hạn body, OpenAPI, privacy, OSV, build Windows/Web/Android, artifact ký/SBOM/provenance | 30 test API; LCOV 92,31%; `tools/check_openapi.py`; OSV; `.github/workflows/release.yml` | Build và workflow đạt; đường dẫn ký Android đã thử; khóa ký/artifact chính thức còn thiếu |
| 5 — Quản trị/kiểm toán | Security policy, threat model, CODEOWNERS, Dependabot, issue/PR template, ADR, release checklist và evidence gate | `python -m unittest discover -s tools/tests -v`; `tools/release_evidence.py` | Đạt kỹ thuật; hồ sơ external và phê duyệt release còn thiếu |

## Cổng tự động bắt buộc

```bash
python tools/verify.py --all
python tools/check_lcov.py \
  --file packages/viet_braille_core/coverage/lcov.info --minimum 90
python tools/check_lcov.py \
  --file api_server/coverage/lcov.info --minimum 90
python tools/check_lcov.py \
  --file viet_braille_app/coverage/lcov.info --minimum 80
python -m mkdocs build --strict
```

Build từ cùng source state:

```bash
cd viet_braille_app
flutter build windows --release --no-pub
flutter build web --release --no-pub
flutter build appbundle --release --no-pub
```

## Cổng external bắt buộc

Trước khi tạo tag, sao chép mẫu trong `release_evidence/`, ghi đúng full commit
SHA rồi chạy:

```bash
python tools/release_evidence.py \
  --file release_evidence/<tag>.json \
  --tag <tag> \
  --commit <FULL_GIT_SHA>
```

Trình xác minh yêu cầu:

1. Review TT15 độc lập, khớp hash PDF và fixture.
2. Windows/NVDA, Web/NVDA, Android/TalkBack và iOS/VoiceOver đều đạt, không còn
   lỗi chặn.
3. Ít nhất một phiên nghiệm thu đủ năm kịch bản với người dùng khiếm thị.
4. Phê duyệt phát hành có tham chiếu hồ sơ.
5. Workflow dùng khóa chính thức để ký và xác minh Windows/Android, sau đó tạo
   checksum, SPDX SBOM và provenance.

Nếu thiếu bất kỳ mục nào, trạng thái tổng thể vẫn là “chưa đạt 100%”, dù toàn bộ
test cục bộ đều xanh.
