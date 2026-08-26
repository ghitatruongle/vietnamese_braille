import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

/// Corpus tiếng Việt thực tế dùng để đo độ chính xác round-trip
/// forward → reverse ở chế độ chuẩn (standard).
///
/// Tiêu chí Wave 2 (Phase 2A.1): tỷ lệ khớp nguyên câu >= 99%.
const List<String> kCorpus = [
  // ── Giao tiếp thông thường ──
  'Xin chào các bạn.',
  'Cảm ơn bạn rất nhiều!',
  'Bạn có khỏe không?',
  'Hẹn gặp lại bạn ngày mai.',
  'Chúc mừng năm mới!',
  // ── Tin bài báo chí ──
  'Hà Nội là thủ đô của nước Việt Nam.',
  'Thành phố Hồ Chí Minh là trung tâm kinh tế lớn nhất cả nước.',
  'Sông Mekong chảy qua nhiều quốc gia Đông Nam Á.',
  'Dân số thế giới đang tăng nhanh trong thế kỷ 21.',
  'Giáo dục là quốc sách hàng đầu của đất nước.',
  'Nông sản Việt Nam được xuất khẩu sang nhiều thị trường khó tính.',
  'Đội tuyển bóng đá Việt Nam đã giành chiến thắng sôi nổi.',
  'Thời tiết hôm nay nắng đẹp, gió nhẹ.',
  'Bão số 5 hướng vào vùng biển miền Trung.',
  'Khoa học công nghệ thay đổi đời sống con người từng ngày.',
  // ── Hành chính, văn bản ──
  'Ủy ban nhân dân huyện Gia Lai ban hành kế hoạch số 25/KH-UBND.',
  'Thông tư này có hiệu lực thi hành từ ngày 01 tháng 9 năm 2026.',
  'Học sinh, sinh viên được miễn giảm học phí theo quy định.',
  'Người dân cần cập nhật giấy tờ tùy thân trước ngày 30/6.',
  'Văn phòng đăng ký đất đai tiếp nhận hồ sơ vào các buổi sáng.',
  'Bảo hiểm y tế toàn dân là chính sách lớn của Nhà nước.',
  // ── Thanh điệu đủ bộ + vần khó ──
  'Hỏi ngã sắc nặng huyền đều xuất hiện ở đây.',
  'Quả na, quả mãng cầu và quả xoài chín vàng.',
  'Cô ấy mặc áo sơ mi trắng và váy xòe.',
  'Những dãy núi hùng vĩ nằm phía Tây Bắc.',
  'Đi xa nhớ viết thư về nhà nhé.',
  'Rừng già che phủ kín triền đồi.',
  'Muốn ăn quay thì phải lên rừng.',
  'Dạy học phải lấy học sinh làm trung tâm.',
  'Nghiêng ngả trước gió bão vẫn kiên cường.',
  'Thuở còn thơ ngày hai buổi đến trường.',
  // ── Quy tắc qu / gi ──
  'Quê hương mỗi người chỉ một.',
  'Quyết tâm hoàn thành nhiệm vụ được giao.',
  'Gia đình em sống ở quãng đường kia.',
  'Kiến tha lâu đầy tổ.',
  'Giữa trưa nắng nóng, người nông dân vẫn cày.',
  'Quá trình cải cách diễn ra thuận lợi.',
  // ── Chữ hoa, từ viết tắt ──
  'UNESCO công nhận nhiều di sản của Việt Nam.',
  'UBND thành phố họp phiên thường kỳ.',
  'TS. Nguyễn Văn A trình bày báo cáo khoa học.',
  'TV và radio vẫn là kênh thông tin phổ biến.',
  'ASEAN gồm nhiều quốc gia thành viên.',
  // ── Số, ngày tháng, tiền tệ ──
  'Năm 2026 đánh dấu nhiều sự kiện quan trọng.',
  'Giá gạo tăng lên 25000 đồng một kilôgram.',
  'Tổng cộng 1234567 lượt người truy cập.',
  'Cuộc thi bắt đầu lúc 7 giờ 30 phút.',
  'Mua 5 cuốn sách hết 350000 đồng.',
  'Nhiệt độ giảm xuống 18 độ C vào đêm.',
  'Tỷ lệ đạt chuẩn gần 98%.',
  // ── Dấu câu, ngoặc kép, ngoặc đơn ──
  'Ông bà ta nói: "Uống nước nhớ nguồn."',
  'Truyện Kiều của Nguyễn Du là tác phẩm bất hủ.',
  '(Xem thêm trang 12 để biết chi tiết.)',
  'Câu hỏi đặt ra là: ai sẽ trả lời?',
  'Đường casep — con đường ven biển đẹp nhất tỉnh.',
  'Mùa xuân, hạ, thu, đông mỗi mùa một vẻ.',
  // ── Toán, đơn vị đo lường ──
  'Hai cộng hai bằng bốn.',
  'Diện tích hình vuông là cạnh nhân chính nó.',
  'Chiều dài đoạn thẳng AB bằng 5 cm.',
  'Khối lượng túi gạo là 10 kg.',
  'Nước sôi ở nhiệt độ 100 độ.',
  // ── Ký hiệu mở rộng của ứng dụng ──
  'Ký hiệu ₫ dùng cho tiền Việt Nam.',
  'Dấu ° thể hiện đơn vị đo nhiệt độ.',
  'Mũi tên → chỉ hướng đi tiếp.',
  // ── Câu dài phức hợp ──
  'Phát triển bền vững phải đi đôi với bảo vệ môi trường và nâng cao chất lượng cuộc sống của người dân.',
  'Học sinh giỏi văn hoá đồng thời rèn luyện kỹ năng sống sẽ tự tin hơn khi bước vào cuộc đời.',
  'Chính quyền địa phương đã triển khai nhiều chương trình hỗ trợ hộ nghèo, hộ cận nghèo trên địa bàn xã.',
  'Việc ứng dụng trí tuệ nhân tạo vào giáo dục mở ra cơ hội cá nhân hoá quá trình học tập cho từng em nhỏ.',
];

void main() {
  final mapping = BrailleMappingImpl();
  final forward = BrailleConverterImpl(mapping);
  final reverse = BrailleReverseConverterImpl(mapping);

  group('corpus accuracy — reverse chuẩn (Phase 2A.1)', () {
    final failures = <String>[];

    test('tỷ lệ khớp nguyên câu >= 99%', () {
      var matched = 0;
      for (final text in kCorpus) {
        final braille = forward.convert(text);
        final back = reverse.convert(braille);
        if (back == text) {
          matched++;
        } else {
          failures.add(text);
          // ignore: avoid_print
          print('FAIL: "$text"\n  braille : $braille\n  reverse : "$back"');
        }
      }
      final rate = matched / kCorpus.length;
      // ignore: avoid_print
      print(
        'Corpus round-trip chuẩn: $matched/${kCorpus.length} câu '
        '= ${(rate * 100).toStringAsFixed(2)}%',
      );
      expect(
        rate,
        greaterThanOrEqualTo(0.99),
        reason: 'Câu fail: ${failures.take(10)}',
      );
    });

    test('mọi câu đều tạo ra Braille không rỗng', () {
      for (final text in kCorpus) {
        expect(forward.convert(text), isNotEmpty, reason: text);
      }
    });
  });
}
