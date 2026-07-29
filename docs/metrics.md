# Số liệu chất lượng (sinh tự động)

Cập nhật: 2026-07-30 bằng `python tools/refresh_metrics.py --write`.
Không sửa tay file này; số liệu coverage lấy từ `coverage/lcov.info`
của từng module (chạy test với coverage trước để làm mới).

| Module | Version | File test | Test khai báo | Coverage dòng |
|---|---|---:|---:|---|
| core | 1.1.0 | 6 | 77 | 814/876 = 92.92% |
| app | 1.1.0+2 | 30 | 668 | 877/1058 = 82.89% |
| api | 1.1.0 | 3 | 31 | 261/287 = 90.94% |

Số test lúc chạy có thể cao hơn số khai báo tĩnh do test tham số hóa.
