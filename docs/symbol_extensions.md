# Ký hiệu mở rộng của ứng dụng (app-defined extensions)

Các ký hiệu dưới đây **không nằm trong Thông tư 15/2019/TT-BGDĐT**. Chúng là
quy ước riêng của ứng dụng Vietnamese Braille để hỗ trợ thêm ký hiệu phổ biến
trong văn bản toán học/kỹ thuật, được định nghĩa nhất quán giữa forward
converter, reverse converter và preprocessor.

## Nguyên tắc

- Mọi ký hiệu mở rộng dùng **prefix dot 5** (`⠐`, U+2810) — cùng quy ước với
  `+ = < >` chuẩn TT15.
- Mỗi ký hiệu có **base cell DUY NHẤT** để reverse converter phân biệt chính
  xác, tránh đụng độ với các ký hiệu đã có.
- Forward: ký hiệu → prefix + base. Reverse: `_handlePrefixCell` tiêu thụ cặp
  2 ô trước khi fallback single-cell, nên base cell trùng với chữ cái không
  gây nhầm lẫn.

## Bảng ánh xạ (prefix dot 5 + base)

| Ký hiệu | Base dots | Braille | Ghi chú |
|---------|-----------|---------|---------|
| `≈` | 1,3,4,5 | `⠐⠝` | xấp xỉ |
| `≤` | 2,3,4,5 | `⠐⠞` | nhỏ hơn hoặc bằng |
| `≥` | 1,2,4,5 | `⠐⠛` | lớn hơn hoặc bằng |
| `≠` | 2,3,4 | `⠐⠎` | khác |
| `±` | 1,2,3 | `⠐⠇` | cộng/trừ |
| `×` | 1,3,6 | `⠐⠥` | nhân |
| `÷` | 1,2,4 | `⠐⠋` | chia |
| `√` | 1,3,4 | `⠐⠍` | căn bậc hai |

## Preprocessor

`_numericOperatorSpacing` trong `text_preprocessor.dart` nhận diện tất cả các
ký hiệu trên (cùng `+ - * / x : = < > ≈ ≤ ≥ ≠ ± × ÷ √ !`) và bỏ khoảng trắng
quanh chúng giữa hai chữ số. Chuỗi toán tử nhiều ký tự (`>=`, `<=`, `!=`) được
khớp như một khối để không bị tách rời.

## Ký tự đặc biệt (bổ sung trong B2)

Quy ước: **symbolPrefix (dot 4)** + base cell duy nhất — cùng cơ chế với các
ký hiệu 2 ô chuẩn TT15 (`( ) \ _ $ ^`).

| Ký hiệu | Base dots | Braille | Ghi chú |
|---------|-----------|---------|---------|
| `«` | 2,3,6 | `⠈⠦` | guillemet trái |
| `»` | 3,5,6 | `⠈⠴` | guillemet phải |
| `–` | 3,6 | `⠈⠤` | en dash |
| `—` | 2,5,6 | `⠈⠲` | em dash |
| `₫` | 1,4,5,6 | `⠈⠹` | đồng Việt Nam |
| `‰` | 2,4,5,6 | `⠈⠺` | phần nghìn |
| `©` | 1,4 | `⠈⠉` | bản quyền |
| `®` | 1,2,3,5 | `⠈⠗` | nhãn hiệu đã đăng ký |
| `™` | 1,2,3,4,5,6 | `⠈⠿` | nhãn hiệu |
| `°` | 1,2,5,6 | `⠈⠳` | độ |
| `²` | 1,2,3 | `⠈⠇` | bình phương |
| `³` | 1,4,5 | `⠈⠙` | lập phương |
| `←` | 1,2,5 | `⠈⠓` | mũi tên trái |
| `→` | 2,3,5 | `⠈⠖` | mũi tên phải |
| `↑` | 1,2,3,4 | `⠈⠏` | mũi tên lên |
| `↓` | 2,3,4,5 | `⠈⠞` | mũi tên xuống |

## Marker định dạng văn bản (B5)

TT15 định nghĩa 3 marker định dạng ở các ô:
- bold = `⠘` (dots 4,5)
- italic = `⠐` (dot 5)
- underline = `⠸` (dots 4,5,6)

Trong app, ba ô này đã được dùng với vai trò khác:
- `⠐` (dot 5) = `mathPrefix`, dùng cho `+ - * / < > ≈ ≤ ≥ ≠ ± × ÷ √`
- `⠸` (dots 4,5,6) = `allCapsWord` marker
- `⠘` (dots 4,5) đang trống nhưng dùng làm base cell cho symbolPrefix sẽ
  làm `⠈⠘` mất ý nghĩa nhận biết

Quy ước ứng dụng: mỗi marker định dạng dùng `symbolPrefix` (dot 4) + base
cell RIÊNG, riêng biệt với các ký hiệu khác:

| Marker | Base dots | Braille | Vai trò |
|--------|-----------|---------|---------|
| bold | 4,5 | `⠈⠘` | in đậm |
| italic | 2,4 | `⠈⠊` | in nghiêng |
| underline | 2,3,4,6 | `⠈⠞` | gạch chân |

### Cú pháp markdown

Preprocessor chuyển đổi markdown sang control-char marker trước khi
forward converter dịch (chỉ khi bật — tham số `enableMarkdown` của
`convert`/`convertWithDetails`, nối với toggle "Hỗ trợ định dạng" trong
Settings của app):

- `**in đậm**` → `\u0002in đậm\u0002` → `⠈⠘⠊⠝ ⠮⠠⠡⠍⠈⠘`
- `*in nghiêng*` → `\u000Ein nghiêng\u000E` → `⠈⠊⠊⠝ ⠝⠛⠓⠊⠣⠝⠛⠈⠊`
- `_gạch chân_` → `\u001Fgạch chân\u001F` → `⠈⠞⠛⠠⠁⠉⠓ ⠉⠓⠡⠝⠈⠞`

Mặc định cờ tắt: văn bản chứa `*`/`_` literal được giữ nguyên hành vi cũ,
đảm bảo an toàn cho toán và URL.

Hạn chế: các control char (STX/SO/US) phân biệt markers với văn bản — nếu
nguồn chứa các ký tự này, chuyển đổi sẽ lẫn lộn. Chấp nhận được cho mục
đích hiển thị.

## Lưu ý round-trip

- Standard mode: các ký hiệu mở rộng round-trip chính xác; khoảng trắng quanh
  toán tử số bị preprocessor loại bỏ (hành vi có chủ đích).
- Lossless mode: round-trip tuyệt đối, kể cả khoảng trắng.
