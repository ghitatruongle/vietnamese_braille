/// Bảng ký tự tiếng Việt dùng chung cho converter, reverse converter và
/// preprocessor — một nguồn duy nhất thay cho việc liệt kê tay ở nhiều nơi.
library;

/// 12 nguyên âm cơ sở (không thanh) của tiếng Việt viết thường.
const String kVietnameseBaseVowels = 'aăâeêioôơuưy';

/// Toàn bộ nguyên âm viết thường kèm 5 thanh (72 ký tự, dạng NFC).
/// Thứ tự: mỗi nguyên âm cơ sở theo sau bởi huyền, sắc, hỏi, ngã, nặng.
const String kVietnameseTonedVowels =
    'aàáảãạ'
    'ăằắẳẵặ'
    'âầấẩẫậ'
    'eèéẻẽẹ'
    'êềếểễệ'
    'iìíỉĩị'
    'oòóỏõọ'
    'ôồốổỗộ'
    'ơờớởỡợ'
    'uùúủũụ'
    'ưừứửữự'
    'yỳýỷỹỵ';

/// Phụ âm/chữ cái riêng của tiếng Việt ngoài bảng Latin cơ bản.
const String kVietnameseExtraLetters = 'đ';

/// 5 dấu thanh dạng combining (huyền, sắc, hỏi, ngã, nặng).
const List<String> kVietnameseToneMarks = [
  '\u0300',
  '\u0301',
  '\u0309',
  '\u0303',
  '\u0323',
];
