/// Trạng thái bất biến cho luồng chuyển đổi Braille của ứng dụng.
enum AppStatus { idle, loading, success, error }

class ConversionState {
  const ConversionState({
    this.originalText = '',
    this.brailleUnicode = '',
    this.reverseText = '',
    this.brfContent = '',
    this.status = AppStatus.idle,
    this.errorMessage,
    this.warningMessage,
  });

  final String originalText;
  final String brailleUnicode;
  final String reverseText;
  final String brfContent;
  final AppStatus status;
  final String? errorMessage;
  final String? warningMessage;

  ConversionState copyWith({
    String? originalText,
    String? brailleUnicode,
    String? reverseText,
    String? brfContent,
    AppStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? warningMessage,
    bool clearWarningMessage = false,
  }) {
    return ConversionState(
      originalText: originalText ?? this.originalText,
      brailleUnicode: brailleUnicode ?? this.brailleUnicode,
      reverseText: reverseText ?? this.reverseText,
      brfContent: brfContent ?? this.brfContent,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      warningMessage: clearWarningMessage
          ? null
          : warningMessage ?? this.warningMessage,
    );
  }
}
