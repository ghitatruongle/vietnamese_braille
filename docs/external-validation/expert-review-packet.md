# Gói đối chiếu dành cho chuyên gia Braille

> File này sinh tự động bằng `python tools/expert_review_packet.py --write` từ fixture đã ghim hash — không sửa tay.

## Thông tin nguồn cần xác nhận

- Chuẩn: Thông tư 15/2019/TT-BGDĐT
- Tài liệu nguồn: `quytac/501196e24bee7141a3d2d37f879d04a615_2019_TT_BGDDT.pdf` (tài liệu nội bộ, ban dự án cung cấp riêng cho chuyên gia)
- SHA-256 PDF nguồn phải khớp: `4b0a4d75a0913a51b0ce2e42dac71f48effdd2e042ccc12bac5b89f13fdb4872`
- SHA-256 fixture tại thời điểm sinh gói: `2cf66071ec582889fb272c0d22aa08419f38f23d2a61340b0ff8cce1fb68d9ad`

Chuyên gia xác nhận hai hash trên trong biên bản; nếu lệch, gói này vô hiệu và phải sinh lại.

## Cách đánh giá

Với từng dòng: đối chiếu số chấm và ô Unicode với bản TT15 gốc,
đánh dấu ✔ (đúng) / ✘ (sai, ghi rõ) vào cột Xác nhận.

## Bảng chữ cái (29 mục)

| Mục | Số chấm | Unicode | Xác nhận | Ghi chú |
|---|---|---|---|---|
| `a` | 1 | `⠁` | | |
| `ă` | 3,4,5 | `⠜` | | |
| `â` | 1,6 | `⠡` | | |
| `b` | 1,2 | `⠃` | | |
| `c` | 1,4 | `⠉` | | |
| `d` | 1,4,5 | `⠙` | | |
| `đ` | 2,3,4,6 | `⠮` | | |
| `e` | 1,5 | `⠑` | | |
| `ê` | 1,2,6 | `⠣` | | |
| `g` | 1,2,4,5 | `⠛` | | |
| `h` | 1,2,5 | `⠓` | | |
| `i` | 2,4 | `⠊` | | |
| `k` | 1,3 | `⠅` | | |
| `l` | 1,2,3 | `⠇` | | |
| `m` | 1,3,4 | `⠍` | | |
| `n` | 1,3,4,5 | `⠝` | | |
| `o` | 1,3,5 | `⠕` | | |
| `ô` | 1,4,5,6 | `⠹` | | |
| `ơ` | 2,4,6 | `⠪` | | |
| `p` | 1,2,3,4 | `⠏` | | |
| `q` | 1,2,3,4,5 | `⠟` | | |
| `r` | 1,2,3,5 | `⠗` | | |
| `s` | 2,3,4 | `⠎` | | |
| `t` | 2,3,4,5 | `⠞` | | |
| `u` | 1,3,6 | `⠥` | | |
| `ư` | 1,2,5,6 | `⠳` | | |
| `v` | 1,2,3,6 | `⠧` | | |
| `x` | 1,3,4,6 | `⠭` | | |
| `y` | 1,3,4,5,6 | `⠽` | | |

## Chữ cái Latin mở rộng (4 mục)

| Mục | Số chấm | Unicode | Xác nhận | Ghi chú |
|---|---|---|---|---|
| `f` | 1,2,4 | `⠋` | | |
| `j` | 2,4,5 | `⠚` | | |
| `w` | 2,4,5,6 | `⠺` | | |
| `z` | 1,3,5,6 | `⠵` | | |

## Thanh điệu (5 mục)

| Mục | Số chấm | Unicode | Xác nhận | Ghi chú |
|---|---|---|---|---|
| `huyền` | 5,6 | `⠰` | | |
| `sắc` | 3,5 | `⠔` | | |
| `hỏi` | 2,6 | `⠢` | | |
| `ngã` | 3,6 | `⠤` | | |
| `nặng` | 6 | `⠠` | | |

## Ký hiệu (6 mục)

| Mục | Số chấm | Unicode | Xác nhận | Ghi chú |
|---|---|---|---|---|
| `capital_indicator` | 4,6 | `⠨` | | |
| `capital_phrase` | 4,6 + 4,6 | `⠨⠨` | | |
| `number_indicator` | 3,4,5,6 | `⠼` | | |
| `bold` | 4,5 | `⠘` | | |
| `italic` | 5 | `⠐` | | |
| `underline` | 4,5,6 | `⠸` | | |

## Ví dụ chính xác (15 mục)

| ID | Văn bản | Braille | Nguồn trích | Xác nhận | Ghi chú |
|---|---|---|---|---|---|
| tone-oan | oán | `⠔⠕⠁⠝` | Phụ lục, Mục VI; ảnh 7 | | |
| tone-chinh | chính | `⠉⠓⠔⠊⠝⠓` | Phụ lục, Mục VI; ảnh 7 | | |
| tone-vung | vừng | `⠧⠰⠳⠝⠛` | Phụ lục, Mục VI; ảnh 7 | | |
| qu-qua | quả | `⠟⠥⠢⠁` | Phụ lục, Mục VI; ảnh 7 | | |
| qu-quyet | quyết | `⠟⠥⠔⠽⠣⠞` | Phụ lục, Mục VI; ảnh 7 | | |
| gi-gioi | giỏi | `⠛⠊⠢⠕⠊` | Phụ lục, Mục VI; ảnh 7 | | |
| gi-giang-giai | giảng giải | `⠛⠊⠢⠁⠝⠛ ⠛⠊⠢⠁⠊` | Phụ lục, Mục VI; ảnh 7 | | |
| gi-gin | gìn | `⠛⠰⠊⠝` | Phụ lục, Mục VI; ảnh 7 | | |
| gi-gi | gì | `⠛⠰⠊` | Phụ lục, Mục VI; ảnh 7 | | |
| capital-loan | Loan | `⠨⠇⠕⠁⠝` | Phụ lục, Mục VII; ảnh 7 | | |
| capital-song-hong | sông Hồng | `⠎⠹⠝⠛ ⠨⠓⠰⠹⠝⠛` | Phụ lục, Mục VII; ảnh 7 | | |
| capital-bac-an | bác Ẩn | `⠃⠔⠁⠉ ⠢⠨⠡⠝` | Phụ lục, Mục VII; ảnh 7 | | |
| capital-unesco | UNESCO | `⠸⠥⠝⠑⠎⠉⠕` | Phụ lục, Mục VII; ảnh 8 | | |
| capital-viet-nam-title | Việt Nam | `⠒⠨⠧⠠⠊⠣⠞ ⠝⠁⠍⠱` | Phụ lục, Mục VII; ảnh 8 | | |
| capital-viet-nam-upper | VIỆT NAM | `⠨⠨⠧⠠⠊⠣⠞ ⠝⠁⠍⠱` | Phụ lục, Mục VII; ảnh 8 | | |

## Quy tắc đã khai báo là chưa triển khai (3 mục)

Chuyên gia xác nhận việc khai báo `not_implemented` là phù hợp,
và nếu có thể, trích quy tắc áp dụng từ TT15 để dự án triển khai
ở phiên bản sau.

| ID | Lý do đã khai báo | Nhận xét chuyên gia |
|---|---|---|
| format-bold | API hiện nhận văn bản thuần, không mang thông tin định dạng đậm. | |
| format-italic | API hiện nhận văn bản thuần, không mang thông tin định dạng nghiêng. | |
| format-underline | API hiện nhận văn bản thuần, không mang thông tin gạch chân. | |

## Kết luận của chuyên gia

```text
Mã người review (reviewer_id):        ............
Độc lập với nhóm phát triển:          có / không
Thời điểm (ISO-8601 + múi giờ):       ............
SHA-256 PDF nguồn đã xác nhận:        ............
SHA-256 fixture đã xác nhận:          ............
Số dòng sai phát hiện (blocking):     ....
Kết luận (result):                    passed / failed
Mã hồ sơ (attestation_reference):     ............
```

Kết quả được chép vào mục `tt15_external_review` của `release_evidence/<tag>.json`.
