# Kế hoạch nâng cấp v1.5.0 — "Hoàn thiện 100% để dùng được"

**Ngày lập:** 2026-08-25 · **Cấu trúc chốt bởi người dùng:** 4 Wave ↔ phát hành
theo mapping **Wave 1+2 → Beta 1**, **Wave 3 → Beta 2**, **Wave 4 → Stable
"Phát hành chính thức"**. Làm xong Wave 2 phải DỪNG để người dùng TEST trước
khi đóng gói Beta 1. Mỗi Wave gồm các Track, mỗi Track gồm các Phase.

**Quy tắc xuyên suốt (RULE người dùng):**
1. Không commit/push khi chưa được duyệt riêng từng lần.
2. Làm đúng tuyệt đối theo chỉ dẫn đã chốt.
3. Nguyên tắc sản phẩm: công nghệ cao · chính xác minh bạch · Việt Nam trên
   hết · mọi yêu cầu công nghệ cao đều thực hiện không từ chối ([[core-principles]]
   trong bộ nhớ dự án).

---

## Tổng quan trạng thái

| Wave | Bản phát hành | Trạng thái |
|---|---|---|
| Wave 1 — Đóng băng nền tảng | **Beta 1** (gộp với Wave 2) | ✅ Kỹ thuật xong trên máy, chưa commit |
| Wave 2 — Tính năng hoàn thiện | **Beta 1** | ✅ Kỹ thuật xong trên máy — ĐÃ DỪNG chờ người dùng TEST |
| Wave 3 — Feature freeze + xác thực bên ngoài | **Beta 2** | ⏳ Chưa bắt đầu |
| Wave 4 — Phát hành chính thức | **Stable** | ⏳ Chưa bắt đầu |

### Kết quả Wave 1 (2026-08-25)

- Core 259/259 test · App 730/730 · API 31/31 — tất cả xanh.
- Coverage: core 95,27% (gate 90) · app 80,50% (gate 80) · api 90,94% (gate 90).
- `python tools/verify.py --all`: **PASS** toàn bộ (format, docs, TT15, OpenAPI,
  version consistency, analyze ×3, test ×3).
- Phát hiện & sửa 2 bug thật: (1) cờ markdown B5 chưa được truyền qua API
  chuyển đổi; (2) batch `convertAll` crash `RangeError` khi có ≥ 2 tệp.

---

## WAVE 1 — v1.5.0-beta1 · "Đóng băng nền tảng"

> Mục tiêu: toàn bộ công việc v1.2.5 đang treo trở thành một bản phát hành sạch.

### Track 1A — Chốt nền công việc treo
- [x] **Phase 1A.1:** Sao lưu nguyên trạng (tar + patch ngoài repo); tạo nhánh
  `release/v1.5.0`; soạn kế hoạch 2 commit → **chờ duyệt commit** (RULE 1).
- [x] **Phase 1A.2:** Dọn tool probe — còn giữ `verify_b5`, `verify_b5_cells`,
  `verify_symbols`, `verify_tt15`.

### Track 1B — Sửa nợ lỗi chính xác
- [x] **Phase 1B.1:** Root cause thật: cờ `enableMarkdown` chưa được truyền qua
  API `convert`/`convertWithDetails` (regex thứ tự đã đúng). Đã nối API +
  regression test markdown tiếng Việt có dấu.
- [x] **Phase 1B.2:** A6 hoàn tất từ phiên trước (`kAppVersion`); bản này bump
  lên `1.5.0-beta1+4`.

### Track 1C — Chuẩn hóa phiên bản & tài liệu
- [x] **Phase 1C.1:** app `1.5.0-beta1+4` / core+api `1.5.0-beta1`;
  `openapi.json` đồng bộ; CHANGELOG gốc thêm mục `[1.5.0-beta1]`; lockfile
  app/api refresh ghim core mới.
- [x] **Phase 1C.2:** user-guide thêm mục Braille→Text, Batch, toggle định
  dạng; symbol_extensions bổ sung ghi chú cờ enableMarkdown;
  `docs/metrics.md` + badge regenerate.

### Track 1D — Kiểm chứng phát hành beta1
- [x] **Phase 1D.1:** `tools/verify.py --all` PASS; coverage gate đạt cả 3
  module (95,27% / 80,50% / 90,94%); analyze sạch ×3.
- [x] **Phase 1D.2:** Lệnh tag `v1.5.0-beta1` + pre-release đã soạn →
  **chờ duyệt**, không tự chạy (RULE 1).

---

## WAVE 2 — (nội dung của Beta 1) · "Tính năng hoàn thiện"

> Mục tiêu: đóng 6 tính năng giá trị cao; mỗi Track độc lập, commit riêng từng Phase.

### Track 2A — Nền đo lường chất lượng *(làm đầu tiên)*
- [x] **Phase 2A.1:** Corpus reverse standard ≥99% round-trip (tin bài, hành chính,
  toán văn bản) — kết quả ghi `docs/metrics.md`.
- [x] **Phase 2A.2:** Perf baseline bộ chuyển đổi.

### Track 2B — Nhập Braille 6 phím kiểu Perkins
- [x] **Phase 2B.1:** Widget bàn phím 6 chấm (`S D F`=chấm 1-2-3, `J K L`=chấm 4-5-6,
  Space=ô trống) + logic gộp chấm thành ô.
- [x] **Phase 2B.2:** Tích hợp màn Braille→Text + chế độ luyện gõ `/learn`; widget test.

### Track 2C — TTS đọc kết quả
- [x] **Phase 2C.1:** Service `flutter_tts` + capability gating theo nền tảng.
- [x] **Phase 2C.2:** Nút đọc to văn bản gốc/kết quả + Settings tốc độ/cao độ; test.

### Track 2D — Sao lưu / khôi phục lịch sử
- [x] **Phase 2D.1:** Export lịch sử ra JSON + validate schema.
- [x] **Phase 2D.2:** Import với hộp thoại merge/replace; test.

### Track 2E — Drag & drop tệp (desktop)
- [x] **Phase 2E.1:** Kéo TXT/DOCX → pipeline convert; kéo ảnh → pipeline OCR nơi hỗ trợ.
- [x] **Phase 2E.2:** UX hint vùng thả + test.

### Track 2F — OCR trên Windows *(mục nặng nhất, làm cuối)*
- [x] **Phase 2F.1:** Spike kỹ thuật win32 FFI (Windows.Media.Ocr) vs MethodChannel →
  báo cáo phương án để người dùng chốt.
- [x] **Phase 2F.2:** Implement OCR service + capability gating + UI ngôn ngữ OCR.
- [x] **Phase 2F.3:** Test + cập nhật ma trận nền tảng README/docs.
- *Rủi ro: nếu 2F.1 kết luận vượt khả thi → chuyển backlog 1.6.x theo sự đồng ý.*

### Track 2G — Đóng bản beta2
- [x] **Phase 2G.1:** Full verify + build release Windows/Web/Android.
- [x] **Phase 2G.2:** DỪNG — mời người dùng TEST toàn bộ tính năng mới. Chỉ khi nhận "Duyệt/OK" mới trình tag `v1.5.0-beta1` + pre-release.


### Kết quả Wave 2 (2026-08-25)

- **2A:** corpus 67 câu reverse chuẩn đạt **100%** (gate ≥99%) — phát hiện & sửa
  lỗi thật vị trí dấu thanh vần âm đệm "o+a" (*xoài/ngoái/hòa/toàn*) kèm
  regression test; perf baseline tại `docs/wave2_quality.md`.
- **2B:** bàn phím Perkins 6 phím (`S D F`/`J K L`) tích hợp Braille→Text,
  xem trước ô, Chốt ô, ⌫ — 11 test xanh.
- **2C:** TTS `flutter_tts` — service + gating (`supportsTts`) + nút loa ở
  màn chính & Braille→Text + Settings tốc độ/cao độ lưu prefs — 5 test xanh.
- **2D:** backup/khôi phục lịch sử JSON — export schema v1, import validate
  chặt + dialog Gộp/Thay thế, service thêm `replaceAll`/`mergeEntries`
  (dedup theo bản sắc) — 5 test service/UI xanh.
- **2E:** DropZone với lớp gợi ý khi kéo tệp; định tuyến ảnh → OCR nơi hỗ trợ,
  TXT/DOCX → chuyển đổi (`convertDroppedFile`) — 5 test xanh.
- **2F.1:** spike OCR Windows hoàn thành — báo cáo 4 phương án tại
  `docs/spike_ocr_windows.md`, **đề xuất phương án C (tự viết plugin WinRT)**;
  2F.2/2F.3 chờ người dùng chốt sau khi test Beta 1.
- **Verify cuối:** core 286 ✓ · app 754 ✓ · api 31 ✓; coverage 95,59% /
  82,20% / 90,94% đạt gate; `tools/verify.py --all` **PASS**.

> ⚠️ Toàn bộ Wave 1+2 CHƯA được commit/push — nằm ở dạng chưa-commit trên
> `main` @ db1e7c2, đúng yêu cầu của người dùng.

---

## WAVE 3 — v1.5.0-beta2 · "Feature freeze + xác thực bên ngoài"

> Từ đây chỉ sửa lỗi, không thêm tính năng.

### Track 3A — Ổn định hóa
- **Phase 3A.1:** Bug bash từ phản hồi beta1/beta2.
- **Phase 3A.2:** Accessibility pass nội bộ + tự chạy NVDA sơ bộ.

### Track 3B — Thẩm định chuyên gia Braille
- **Phase 3B.1:** Sinh gói thẩm định `expert_review_packet.py` → gửi chuyên gia
  *(người dùng xác định)*.
- **Phase 3B.2:** Tiếp nhận kết quả, lưu `release_evidence/`.

### Track 3C — Kiểm thử screen reader có biên bản
- **Phase 3C.1:** NVDA (Windows). · **Phase 3C.2:** TalkBack (Android). ·
  **Phase 3C.3:** VoiceOver (iOS).

### Track 3D — Nghiệm thu người dùng khiếm thị *(người dùng tổ chức)*
- **Phase 3D.1:** Chuẩn bị phiếu 5 kịch bản bắt buộc.
- **Phase 3D.2:** Tổng hợp kết quả vào `release_evidence/`.

### Track 3E — Hạ tầng ký & quy trình release
- **Phase 3E.1:** Android keystore + `key.properties` ngoài Git *(người dùng cung cấp)*.
- **Phase 3E.2:** Chứng chỉ Authenticode Windows *(người dùng mua/cấu hình)*.
- **Phase 3E.3:** Trình duyệt tag `v1.5.0-beta2` → chạy `release.yml` lần đầu
  (SBOM, provenance, checksum, artifact ký).

### Track 3F — Đồng bộ tài liệu
- **Phase 3F.1:** Cập nhật `tt15-compliance`, `accessibility-testing`, `metrics`,
  `user-guide` về trạng thái thật của beta3.

---

## WAVE 4 — v1.5.0 stable · "Phát hành chính thức"

### Track 4A — Gate cuối
- **Phase 4A.1:** Audit checklist — mọi dòng ⏳ trong README chuyển ✅ có bằng chứng;
  `release-checklist.md` tick đủ.
- **Phase 4A.2:** Full verify lần cuối trên commit stable.

### Track 4B — Phát hành
- **Phase 4B.1:** Trình duyệt tag `v1.5.0` + GitHub Release công khai kèm attestation.
- **Phase 4B.2:** Chốt CHANGELOG, README bỏ câu "chưa production-ready", thông báo.

### Track 4C — Sau phát hành
- **Phase 4C.1:** Thu phản hồi; mở backlog 1.6.x (PDF/EPUB input, xuất DOCX,
  giao diện tiếng Anh, CLI).

---

## Rủi ro & giảm thiểu

| Rủi ro | Mức | Giảm thiểu |
|---|---|---|
| Regex B5 đụng `*`/`_` trong văn bản thường | Trung bình | Regression test rộng; chỉ bật marker khi cú pháp khép kín |
| Windows.Media.Ocr qua FFI phức tạp | Cao | Spike trước; nếu vượt khả thi → backlog 1.6.x, beta2 vẫn đóng được |
| Reverse converter vỡ case cũ | Trung bình | Corpus ≥99% + lossless mode làm lớp an toàn |
| Coverage tụt dưới gate | Thấp | Test viết song song từng feature |
| Cổng con người chậm | Cao | Chuẩn bị packet/biên bản sớm từ beta2 |

## Hiện trạng nền (xác minh 2026-08-25)

- main = `db1e7c2` (v1.2.0); toàn bộ work v1.2.5 (17 file sửa + ~20 file mới)
  chưa commit: A1–A5 xong, B1–B5 xong (còn 1 test fail), C1–C4 xong, C5 chưa làm.
- Core fail đúng 1 test: `mapping_completeness_test.dart` › markdown bold preprocess.
- Version mọi module còn 1.2.0; 5 cổng xác thực bên ngoài chưa đóng.
