# ADR-0003: Xử lý va chạm ô Braille `?`/thanh hỏi và `-`/thanh ngã

- Trạng thái: `accepted`
- Ngày: 30/07/2026

## Bối cảnh

Theo bảng TT15, dấu chấm hỏi `?` dùng cùng ô với thanh hỏi, và gạch ngang `-`
dùng cùng ô với thanh ngã. Chỉ nhìn một ô đơn lẻ không thể phân biệt hai nghĩa;
bộ chuyển ngược chuẩn buộc phải suy luận theo ngữ cảnh và không thể đảm bảo
song ánh cho mọi chuỗi đầu vào. Đây là nhập nhằng của chính chuẩn nguồn, không
phải lỗi implementation.

## Quyết định

1. Chế độ chuẩn (`standard`) giữ đúng bảng TT15, chấp nhận nhập nhằng và giải
   quyết bằng heuristic ngữ cảnh trong reverse converter (vị trí ô trong âm
   tiết, trạng thái number mode). Các chuỗi không phân giải được là giới hạn
   đã ghi nhận, được khóa bằng test hồi quy thay vì che giấu.
2. Chế độ `lossless` dùng escape marker 8 chấm nằm ngoài bảng TT15 để đảm bảo
   round-trip chính xác tuyệt đối, chỉ phục vụ đối chiếu nội bộ và bị cấm xuất
   BRF (formatter từ chối ô ngoài dải 6 chấm).
3. Không tự chế ô mới trong chế độ chuẩn để "sửa" chuẩn: đầu ra phải đọc được
   bởi người dùng đã học bảng TT15.
4. Cải tiến heuristic ngữ cảnh (nếu có) phải kèm bộ test đặc tả trước khi đổi
   hành vi, và phải được chuyên gia Braille xác nhận trước khi công bố là quy
   tắc phân giải chính thức.

## Hệ quả

Người dùng chế độ chuẩn có thể gặp trường hợp reverse không khớp nguyên bản
với chuỗi chứa `?`/`-` ở vị trí nhập nhằng; giới hạn này được nêu trong README
và user guide. Chế độ lossless không tương thích thiết bị nhúng chỉ hỗ trợ
6 chấm, nên bị giới hạn ở mục đích kiểm tra. Mọi thay đổi heuristic là thay
đổi hành vi công khai và phải ghi vào CHANGELOG.
