# Cổng chất lượng và kế hoạch phát hành

Tài liệu này mô tả bằng chứng cần có trước khi gọi một phiên bản là sẵn sàng
phát hành. Nó không tự xác nhận rằng các cổng đã đạt.

## Cổng bắt buộc

| Cổng | Lệnh hoặc bằng chứng |
|---|---|
| Định dạng, tài liệu, TT15, analyze và test | `python tools/verify.py --all` |
| Coverage | Core ≥ 90%, app ≥ 80%, API ≥ 90% |
| Build | Windows, Web và Android release build thành công từ cùng commit |
| Chuẩn Braille | Fixture độc lập, so sánh chính xác và có người thứ hai review |
| Accessibility | Báo cáo TalkBack/NVDA/VoiceOver và kiểm thử bàn phím |
| Bảo mật | Không còn lỗ hổng Critical/High; API có giới hạn body và rate limit |
| Quyền riêng tư | Privacy policy mô tả OCR, speech và lịch sử cục bộ |
| Artifact | Bản ký chính thức, SHA-256, SBOM và release notes |

## Trạng thái

Trạng thái được xác định từ CI và artifact của chính commit phát hành. Không
chép thủ công số lượng test hoặc dùng các từ như “hoàn hảo”, “tuân thủ toàn
diện” hay “production-ready” khi chưa có đủ bằng chứng ở bảng trên.

| Hạng mục | Trạng thái hiện tại |
|---|---|
| Format/docs/analyze/test cục bộ | Đạt ngày 27/07/2026 bằng `python tools/verify.py --all` |
| Coverage cục bộ | Đạt: core 92,92%; app 82,89%; API 92,31% |
| Build release cục bộ | Đạt: Windows x64, Web và Android AAB |
| Lỗ hổng dependency đã biết | OSV-Scanner 2.4.0: không phát hiện vấn đề trong 3 lockfile |
| TT15 fixture + SHA-256 + exact output | Đạt tự động; external review còn chờ |
| Accessibility tự động | Đạt cho màn hình chính, kết quả, lịch sử, cài đặt, học và quiz; gồm tương phản, mục tiêu chạm và chữ 200% |
| NVDA/TalkBack/VoiceOver và người dùng thật | Chưa thực hiện |
| API hardening/privacy/governance | Đạt cổng cục bộ; cần CI trên commit |
| Artifact ký/SBOM/provenance | Workflow đã có; đường dẫn ký Android đã được thử bằng khóa dùng một lần; chưa có khóa và artifact chính thức |

Tag phát hành còn bị chặn bởi `tools/release_evidence.py` nếu thiếu hồ sơ JSON
đúng commit. Mẫu và quy tắc lưu bằng chứng nằm tại
[`release_evidence/README.md`](release_evidence/README.md).
Ma trận nghiệm thu từng Phase được duy trì tại
[`docs/phase-0-5-audit.md`](docs/phase-0-5-audit.md).

## Quy trình phát hành

1. Cập nhật `CHANGELOG.md` và version của các package.
2. Chạy toàn bộ cổng chất lượng trên working tree sạch.
3. Tạo build từ commit dự kiến gắn tag.
4. Ký artifact bằng khóa do người phát hành quản lý.
5. Tạo SBOM và SHA-256 cho từng artifact.
6. Smoke test chính các artifact đã ký.
7. Tạo annotated Git tag trùng với version.
8. Tạo GitHub Release và đính kèm artifact, checksum, SBOM.
9. Kiểm tra lại trang tài liệu và link tải sau phát hành.

Không commit khóa ký, mật khẩu, token hoặc tệp `key.properties`.
