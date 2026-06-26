# Kiến trúc Vietnamese Braille

## Tổng quan

Dự án sử dụng **Clean Architecture** với 4 lớp chính:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Screens, Widgets, Providers)      │
├─────────────────────────────────────┤
│          Domain Layer               │
│  (Business Logic, Entities)         │
├─────────────────────────────────────┤
│           Data Layer                │
│  (OCR, File I/O, History)           │
├─────────────────────────────────────┤
│           Core Layer                │
│  (Braille Mapping, Theme, Errors)   │
└─────────────────────────────────────┘
```

## Layers

### Core Layer (`lib/core/`)

Chứa các thành phần cơ bản, không phụ thuộc vào Flutter:

| File | Responsibility |
|------|---------------|
| `braille_mapping.dart` | Bảng mapping Braille Unicode, NFD→NFC composition |
| `braille_dots.dart` | Helpers cho Braille dots |
| `app_theme.dart` | Theme configuration (light/dark) |
| `error_handler.dart` | Error handling utilities |

### Domain Layer (`lib/domain/`)

Chứa business logic, không phụ thuộc vào UI hoặc data sources:

| File | Responsibility |
|------|---------------|
| `braille_converter.dart` | Text → Braille conversion |
| `braille_reverse_converter.dart` | Braille → Text conversion |
| `brf_formatter.dart` | BRF file formatting |

### Data Layer (`lib/data/`)

Chứa các data sources và external services:

| File | Responsibility |
|------|---------------|
| `ocr_processor.dart` | Google ML Kit OCR integration |
| `text_extractor.dart` | Text extraction from files |
| `history_service.dart` | Conversion history persistence |
| `file_picker_service.dart` | File selection |
| `file_exporter.dart` | File export (BRF, PDF) |
| `speech_service.dart` | Speech-to-text |

### Presentation Layer (`lib/presentation/`)

Chứa UI components:

```
presentation/
├── screens/
│   ├── home_screen.dart       # Main conversion screen
│   ├── history_screen.dart    # Conversion history
│   └── settings_screen.dart   # App settings
├── widgets/
│   ├── text_input_section.dart    # Text input with buttons
│   ├── braille_display_section.dart # Braille output display
│   ├── status_section.dart        # Status messages
│   ├── app_drawer.dart            # Navigation drawer
│   └── readonly_field.dart        # Read-only text field
└── providers/
    ├── conversion_provider.dart   # Conversion state management
    ├── theme_provider.dart        # Theme + font scale state
    └── history_provider.dart      # History state
```

## Data Flow

### Text → Braille Conversion

```
User Input
    ↓
TextInputSection (Widget)
    ↓
ConversionNotifier.convertText()
    ↓
BrailleConverter.convertWithDetails()
    ↓
BrailleMapping.mapChar() [per character]
    ↓
ConversionResult {brailleText, warnings}
    ↓
BrailleDisplaySection (Widget)
```

### Braille → Text (Reverse)

```
Braille Input
    ↓
ConversionNotifier.convertReverse()
    ↓
BrailleReverseConverter.convert()
    ↓
CapState (immutable state per call)
    ↓
Text Output
```

### OCR Flow

```
File Selected
    ↓
FilePickerService.pickFile()
    ↓
OcrProcessor.recognizeImage()
    ↓ (Google ML Kit)
Recognized Text
    ↓
BrailleConverter.convertWithDetails()
    ↓
Braille Output
```

## State Management

Sử dụng **Riverpod** với `StateNotifier` pattern:

```dart
// Provider definition
final conversionProvider = StateNotifierProvider<ConversionNotifier, ConversionState>((ref) {
  return ConversionNotifier();
});

// State class
class ConversionState {
  final String originalText;
  final String brailleText;
  final bool isLoading;
  final String? error;
}

// Notifier
class ConversionNotifier extends StateNotifier<ConversionState> {
  void convertText(String text) { ... }
  void convertReverse(String braille) { ... }
}
```

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9    # State management
  go_router: ^14.8.1          # Navigation
  google_mlkit_text_recognition: ^0.15.0  # OCR
  file_picker: ^8.0.0         # File selection
  docx_to_text: ^1.0.0       # DOCX parsing
  path_provider: ^2.1.1       # File system paths
  share_plus: ^10.0.0         # Share functionality
  shared_preferences: ^2.5.3  # Persistence
  speech_to_text: ^6.6.0     # Voice input
  pdf: ^3.10.0               # PDF generation
  printing: ^5.12.0          # Print/share PDF
```

## Testing Strategy

```
test/
├── core/                    # Unit tests for core layer
├── domain/                  # Unit tests for domain layer
├── data/                    # Unit tests for data layer
├── presentation/
│   ├── screens/             # Widget tests for screens
│   └── providers/           # Unit tests for providers
├── integration/             # Integration tests (full flow)
├── edge_cases/              # Edge case tests
├── performance/             # Performance benchmarks
└── helpers/                 # Test utilities
```

## Python Tools Architecture

```
tools/
├── verify.py                # Unified CLI entry point
├── requirements.txt         # Python dependencies
├── verify/
│   └── verify_braille.py    # Mapping verification
├── analysis/
│   ├── deep_analysis.py     # Deep analysis
│   └── extract_braille.py   # Braille extraction
├── comparison/
│   ├── ueb_comparison.py    # UEB comparison
│   ├── compare_detail.py    # Detailed comparison
│   └── compare_rules_vs_app.py  # Rules vs app
└── data/
    └── tt15_rules.json      # Parsed rules (generated)
```

## CI/CD Pipeline

```yaml
# .github/workflows/test.yml
jobs:
  test:
    steps:
      - Checkout
      - Setup Flutter
      - flutter pub get
      - dart format --set-exit-if-changed
      - dart analyze
      - flutter test --coverage
      - Upload coverage to Codecov
```

## Future Architecture Plans

### Package Extraction (B5)

```
packages/
└── viet_braille_core/       # Standalone Dart package
    ├── lib/
    │   ├── braille_mapping.dart
    │   ├── braille_converter.dart
    │   ├── braille_reverse_converter.dart
    │   └── brf_formatter.dart
    └── test/
```

### API Server (B6)

```
api_server/
├── bin/server.dart          # Entry point
├── lib/handlers/
│   └── convert_handler.dart # REST endpoints
└── pubspec.yaml             # Shelf + viet_braille_core
```
