# Đối chiếu Thông tư 15/2019/TT-BGDĐT

Dự án ghim SHA-256 của bản nguồn TT15:

```text
4b0a4d75a0913a51b0ce2e42dac71f48effdd2e042ccc12bac5b89f13fdb4872
```

Tài liệu gốc là tài liệu nội bộ, **không vendored trong repo**. Người có
tài liệu đặt file vào
`quytac/501196e24bee7141a3d2d37f879d04a615_2019_TT_BGDDT.pdf`
(thư mục đã gitignore) để được đối chiếu hash nghiêm ngặt; khi thiếu file,
báo cáo ghi trung thực `source.integrity = not_vendored` và gate dựa trên
141 phép kiểm fixture; hash **sai** làm gate thất bại ngay.

Fixture `tools/data/tt15_rules.json` ghi nguồn đến Mục VI–VII và ảnh render
7–8 của phụ lục. Bộ kiểm chứng hiện so sánh:

- 29 chữ cái tiếng Việt, 4 chữ cái Latin mở rộng và 5 dấu thanh;
- tất cả ký hiệu đã khai báo theo cả số chấm và Unicode;
- 15 ví dụ chính xác, gồm `oán`, `quyết`, `giảng giải`, `UNESCO`,
  `Việt Nam` và `VIỆT NAM`;
- SHA-256 thực tế của tệp PDF với giá trị đã ghim (khi tệp hiện diện).

Chạy cổng kiểm chứng:

```bash
python tools/compliance_report.py
```

## Phạm vi chưa triển khai

API hiện nhận văn bản thuần nên chưa thể mang thông tin định dạng đậm, nghiêng
hoặc gạch chân. Ba quy tắc này được ghi rõ là `not_implemented` trong fixture;
chúng không được tính nhầm là đã tuân thủ.

Fixture chỉ ghi ô chỉ báo (đậm `⠘` d4,5; nghiêng `⠐` d5; gạch chân `⠸`
d4,5,6) chứ **không** ghi *quy tắc áp dụng* (đặt chỉ báo trước từng từ hay cả
cụm, có cặp đóng/mở hay không). Triển khai mà tự suy diễn quy tắc sẽ vi phạm
kỷ luật dựa-trên-bằng-chứng (ADR-0002). Ngoài ra ô gạch chân `⠸` (d4,5,6)
trùng với chỉ báo viết hoa cả từ, khiến chiều ngược nhập nhằng. Vì vậy
ba quy tắc này vẫn chờ hai điều kiện bên ngoài: (1) tài liệu nguồn TT15
để trích quy tắc áp dụng, và (2) xác nhận của chuyên gia Braille — giống
như các cổng thẩm định khác.

## Trạng thái thẩm định

Các ví dụ đã được đối chiếu nội bộ với PDF và ảnh render. Trạng thái hiện tại là
`pending_external`: chưa có biên bản xác nhận của chuyên gia Braille độc lập.
Vì vậy tài liệu và báo cáo phát hành không được tuyên bố “tuân thủ 100%” cho đến
khi bằng chứng thẩm định bên ngoài được bổ sung.

Người thẩm định phải xác nhận cả SHA-256 của PDF nguồn và SHA-256 của fixture
đang được phát hành. Bản tóm tắt được ghi vào `release_evidence/<tag>.json`;
`tools/release_evidence.py` sẽ từ chối tag nếu hash không còn khớp với repository.
