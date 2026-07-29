# Checklist phát hành

## Trước khi tạo tag

- [ ] Working tree sạch; package version và tag dự kiến khớp.
- [ ] `python tools/verify.py --all` đạt từ commit phát hành.
- [ ] Coverage đạt ngưỡng trong `PUBLISH_PLAN.md`.
- [ ] TT15 report có hash nguồn đúng; review bên ngoài đã được ký xác nhận.
- [ ] NVDA/TalkBack/VoiceOver và thiết bị mục tiêu có biên bản, không còn lỗi chặn.
- [ ] Dependency review và workflow OSV không có lỗ hổng chưa xử lý.
- [ ] `release_evidence/<tag>.json` trỏ đúng commit và qua
      `python tools/release_evidence.py`.
- [ ] Changelog, privacy, giới hạn nền tảng và release notes đã cập nhật.

## Artifact

- [ ] Windows `.exe/.dll` có Authenticode hợp lệ.
- [ ] Android AAB qua `jarsigner -verify -strict`.
- [ ] Web archive smoke-test từ chính artifact đóng gói.
- [ ] Có SHA-256, SPDX JSON SBOM và GitHub provenance cho artifact.
- [ ] Kiểm tra `gh attestation verify` và checksum trên máy sạch.

## Phát hành

- [ ] Tạo annotated tag từ đúng commit; không di chuyển tag đã công bố.
- [ ] Environment `production-release` yêu cầu reviewer.
- [ ] Workflow “Signed release” hoàn tất; không tải artifact thủ công thay thế.
- [ ] Kiểm tra link tải, tài liệu, màn hình quyền riêng tư và rollback note.

Mục chưa có bằng chứng phải giữ nguyên chưa đánh dấu; không dùng checklist như
bằng chứng thay cho log, artifact hoặc biên bản thật.
