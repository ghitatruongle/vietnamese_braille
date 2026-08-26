# Số liệu chất lượng (sinh tự động)

Cập nhật: 2026-08-26 bằng `python tools/refresh_metrics.py --write`.
Không sửa tay file này; số liệu coverage lấy từ `coverage/lcov.info`
của từng module (chạy test với coverage trước để làm mới).

| Module | Version | File test | Test khai báo | Coverage dòng |
|---|---|---:|---:|---|
| core | 1.5.0-beta1 | 9 | 141 | 953/997 = 95.59% |
| app | 1.5.0-beta1+4 | 38 | 714 | 1399/1702 = 82.20% |
| api | 1.5.0-beta1 | 3 | 31 | 261/287 = 90.94% |

Số test lúc chạy có thể cao hơn số khai báo tĩnh do test tham số hóa.
