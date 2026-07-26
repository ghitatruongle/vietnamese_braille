import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:viet_braille_app/data/speech_service.dart';

import 'speech_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SpeechToText>()])
void main() {
  late MockSpeechToText mockSpeech;
  late SpeechService service;

  setUp(() {
    mockSpeech = MockSpeechToText();
    service = SpeechService(speech: mockSpeech);
  });

  group('SpeechService', () {
    test('initialize() ủy quyền cho SpeechToText và trả về kết quả', () async {
      when(mockSpeech.initialize()).thenAnswer((_) async => true);

      final result = await service.initialize();

      expect(result, isTrue);
      verify(mockSpeech.initialize()).called(1);
    });

    test(
      'startListening() tự initialize khi chưa khởi tạo rồi gọi listen',
      () async {
        when(mockSpeech.initialize()).thenAnswer((_) async => true);

        await service.startListening(onResult: (_) {});

        verify(mockSpeech.initialize()).called(1);
        verify(
          mockSpeech.listen(
            onResult: anyNamed('onResult'),
            listenOptions: anyNamed('listenOptions'),
          ),
        ).called(1);
      },
    );

    test('startListening() không initialize lại khi đã khởi tạo', () async {
      when(mockSpeech.initialize()).thenAnswer((_) async => true);
      await service.initialize();
      clearInteractions(mockSpeech);

      await service.startListening(onResult: (_) {});

      verifyNever(mockSpeech.initialize());
    });

    test('stopListening() ủy quyền cho SpeechToText.stop', () async {
      await service.stopListening();

      verify(mockSpeech.stop()).called(1);
    });

    test('isListening ủy quyền cho SpeechToText.isListening', () {
      when(mockSpeech.isListening).thenReturn(true);

      expect(service.isListening, isTrue);
    });
  });
}
