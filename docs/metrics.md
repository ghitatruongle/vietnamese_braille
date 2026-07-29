# Số liệu chất lượng (sinh tự động)

Cập nhật: 2026-07-30 bằng `python tools/refresh_metrics.py --write`.
Không sửa tay file này; số liệu coverage lấy từ `coverage/lcov.info`
của từng module (chạy test với coverage trước để làm mới).

| Module | Version | File test | Test khai báo | Coverage dòng |
|---|---|---:|---:|---|
| core | 1.2.0 | 6 | 77 | 816/878 = 92.94% |
| app | 1.2.0+3 | 30 | 668 | 877/1040 = 84.33% |
| api | 1.2.0 | 3 | 31 | 261/287 = 90.94% |

Số test lúc chạy có thể cao hơn số khai báo tĩnh do test tham số hóa.
