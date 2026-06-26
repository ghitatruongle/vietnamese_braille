# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- Official README with badges, features, quick start
- CONTRIBUTING.md with detailed contribution guide
- MIT LICENSE file
- CHANGELOG.md (this file)
- Integration tests for full conversion pipeline (20 tests)
- Edge case tests for tone stacking, qu/gi rules, special chars (18 tests)
- CI pipeline with dart format, analyze, test, coverage
- Screen reader support (Semantics labels) for all widgets
- Font size adjustment (0.8x to 2.0x) with persistence
- Voice input with Vietnamese speech-to-text
- Flutter web build support
- Organized Python tools into `tools/` directory with unified CLI
- Performance benchmarks for text conversion
- State isolation tests for reverse converter

### Changed
- Reverse converter uses immutable `_CapState` (no more state leak)
- `composeNfc` logic extracted to shared `_composeNfcCore` implementation
- `AppTheme.light`/`AppTheme.dark` converted from static fields to methods with `fontScale` parameter

### Fixed
- State leak between consecutive `convert()` calls in reverse converter
- Font size scaling with null fontSize handling
