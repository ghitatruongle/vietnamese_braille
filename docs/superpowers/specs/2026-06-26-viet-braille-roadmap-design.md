# Vietnamese Braille — Roadmap Upgrade Design Spec

> **Date:** 2026-06-26
> **Author:** ZCode Brainstorming Session
> **Status:** Draft — pending user review
> **Timeline:** 5 months (10 sprints × 2 weeks)

---

## 1. Overview

### 1.1 Current State

The Vietnamese Braille project consists of:

1. **Flutter App** (`viet_braille_app/`) — cross-platform Vietnamese text ↔ Braille Unicode converter
   - Architecture: Clean architecture (core/data/domain/presentation)
   - Tech stack: Flutter 3.29.x, Dart, Riverpod, GoRouter, Google ML Kit OCR
   - Features: Text→Braille, reverse conversion, BRF export, OCR, history, dark mode
   - Tests: 19 test files covering core logic, providers, screens

2. **Python Research Scripts** (root level) — 6 standalone verification/analysis scripts
   - `verify_braille.py` — mapping verification against official rules
   - `deep_analysis.py` — conflict analysis between rules and app
   - `ueb_comparison.py` — comparison with Unified English Braille
   - `compare_detail.py`, `compare_detailed_v2.py` — detailed comparisons
   - `compare_rules_vs_app.py` — rules vs app mapping

3. **Reference Materials** (`quytac/`) — Official Vietnamese Braille rules
   - PDF: Thông tư 15/2019 của Bộ GD&ĐT (Braille toán học & trình bày)

### 1.2 Problems

- No project README or contribution guidelines
- Existing improvement plan (7 tasks) not executed
- Python scripts are scattered, not integrated into CI
- No web version or API for broader access
- No accessibility features for visually impaired users
- No teaching/learning features for educators
- Reverse converter has state leak issues
- No automated verification against official rules

### 1.3 Goals

- Serve all user groups: visually impaired, teachers, developers
- Deliver value continuously via parallel tracks
- 5-month roadmap with clear milestones
- Foundation + features running in parallel

---

## 2. Architecture

### 2.1 Parallel Tracks Model

```
Track A: Foundation ──── Code quality, testing, CI/CD
Track B: Features ────── Accessibility, web, API, teaching tools
Track C: Integration ─── Python tools, automation, rules compliance
Track D: Documentation ─ README, guides, docs site, community
```

### 2.2 Sprint Structure

- **Sprint duration:** 2 weeks
- **Total sprints:** 10 (Sprint 1–10)
- **Timeline:** 5 months

### 2.3 Dependencies

```
Track A (Foundation) ──────┬──▶ Track B (Features)
                          │
                          ├──▶ Track C (Integration)
                          │
                          └──▶ Track D (Docs)

Track B (Features) ────────┬──▶ Track D (Docs: API docs, user guide)
                          │
                          └──▶ Track C (Integration: API testing)

Track C (Integration) ────────▶ Track A (Foundation: CI verification)
```

**Rules:**
- Track A is the foundation — other tracks depend on code quality
- Tracks B and C can run in parallel after Sprint A2
- Track D runs continuously, depends on output from B and C

---

## 3. Track A — Foundation (Code Quality & Testing)

**Goal:** Solid technical foundation, clean code, high test coverage, CI/CD working.

### Sprint A1–A2 (Month 1): Setup & Refactor

| Task | Priority | Effort | Files |
|------|----------|--------|-------|
| Write official README.md | High | 1 day | `README.md` |
| Fix reverse converter state leak (immutable approach) | High | 2 days | `lib/domain/braille_reverse_converter.dart`, `test/domain/braille_reverse_converter_test.dart` |
| Refactor `_composeNfc` — extract shared logic | Medium | 1 day | `lib/core/braille_mapping.dart` |
| Add integration tests (full flow) | High | 2 days | `test/integration/full_flow_test.dart` |
| Clean pubspec.yaml | Low | 0.5 day | `pubspec.yaml` |
| Setup CI: dart format + dart analyze + flutter test | High | 1 day | `.github/workflows/test.yml` |

### Sprint A3–A4 (Month 2): Test Coverage

| Task | Priority | Effort |
|------|----------|--------|
| Add unit tests for edge cases (tone stacking, qu/gi rules) | High | 2 days |
| Add widget tests for HomeScreen, HistoryScreen | Medium | 2 days |
| Add golden tests for Braille display | Medium | 1 day |
| Setup Codecov integration | Low | 0.5 day |

### Sprint A5–A6 (Month 3): Code Health

| Task | Priority | Effort |
|------|----------|--------|
| Dart analyze strict mode | Medium | 1 day |
| Performance profiling for large text conversion | Medium | 1 day |
| Memory leak audit (OCR processor, text recognizer) | High | 1 day |

### Sprint A7–A10 (Month 4–5): Maintenance

| Task | Priority | Effort |
|------|----------|--------|
| Dependency updates (Flutter, packages) | Medium | ongoing |
| Regression test suite | Medium | 2 days |
| Code review checklist | Low | 0.5 day |

---

## 4. Track B — Features (New Capabilities)

**Goal:** Expand features to serve all user groups.

### Sprint B1–B2 (Month 1): Accessibility

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| Screen reader support (Semantics labels for all widgets) | High | 3 days | Every interactive widget needs a descriptive Semantics label in Vietnamese |
| Haptic feedback on convert | Medium | 1 day | Light vibration when conversion completes |
| Font size adjustment (large text mode) | High | 2 days | Settings slider, persisted via SharedPreferences |
| Voice input (speech-to-text) | Medium | 2 days | Use `speech_to_text` package, Vietnamese locale |

### Sprint B3–B4 (Month 2): Web Version

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| Flutter web build setup | High | 2 days | Enable web target, fix platform-specific code |
| Responsive web layout (desktop + tablet) | High | 2 days | Extend existing LayoutBuilder for wider breakpoints |
| Web-safe font for Braille Unicode | Medium | 1 day | Ensure U+2800–U+28FF renders correctly on all browsers |
| PWA support (offline mode) | Medium | 2 days | Service worker, manifest.json, caching strategy |

### Sprint B5–B6 (Month 3): API Layer

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| Dart package: `viet_braille_core` (extract from app) | High | 3 days | Extract `braille_mapping.dart`, `braille_converter.dart`, `braille_reverse_converter.dart` into standalone package |
| REST API server (Dart Shelf or Serverpod) | High | 3 days | Endpoints: POST /convert, POST /reverse, POST /batch |
| API docs (OpenAPI/Swagger) | Medium | 1 day | Auto-generated from code annotations |
| Rate limiting & auth | Medium | 1 day | API key based, rate limit 100 req/min |

### Sprint B7–B8 (Month 4): Teaching Tools

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| Interactive Braille learning mode (tap to learn dots) | High | 3 days | Grid of 6 dots, tap to see character, hear pronunciation |
| Quiz mode: text → Braille, Braille → text | Medium | 2 days | Multiple choice, scoring, difficulty levels |
| Progress tracking for learners | Medium | 2 days | Local storage, streak tracking, completion percentage |

### Sprint B9–B10 (Month 5): Advanced Features

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| Batch processing (file → multiple conversions) | Medium | 2 days | Upload .txt/.docx, convert all lines, export results |
| PDF export (Braille text as PDF) | Medium | 2 days | Use `pdf` package, Braille font embedding |
| Braille display device support (refreshable Braille) | Low | 3 days | Bluetooth HID protocol, sync with conversion output |

---

## 5. Track C — Integration (Python Tools & Automation)

**Goal:** Integrate Python research tools into workflow, automate verification.

### Sprint C1–C2 (Month 1): Organization

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| Create `tools/` directory, move Python scripts | High | 0.5 day | `tools/verify/`, `tools/analysis/`, `tools/comparison/` |
| Write `tools/requirements.txt` | High | 0.5 day | Pin versions for reproducibility |
| Unified CLI: `python tools/verify.py --all` | Medium | 2 days | Single entry point for all verification scripts |

### Sprint C3–C4 (Month 2): Automation

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| CI job: run Python verification scripts | High | 1 day | GitHub Actions, Python 3.11+, fail on mismatch |
| Auto-sync: extract mapping from Dart → Python test | Medium | 2 days | Parse `braille_mapping.dart`, generate Python test data |
| Diff report: rules PDF vs app mapping | Medium | 2 days | Structured comparison output, HTML report |

### Sprint C5–C6 (Month 3): Data Pipeline

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| Parse Thông tư 15 PDF → structured data | High | 3 days | Extract tables, rules, examples into JSON/YAML |
| Auto-generate test cases from rules PDF | Medium | 2 days | Generate pytest cases from parsed rules |
| Validation report: app compliance with Thông tư 15 | Medium | 2 days | Percentage compliance, list of gaps |

### Sprint C7–C10 (Month 4–5): Polish

| Task | Priority | Effort |
|------|----------|--------|
| Python tools documentation | Medium | 1 day |
| Contribution guide for Python tools | Low | 0.5 day |

---

## 6. Track D — Documentation & Onboarding

**Goal:** Project accessible to all audiences (users, developers, contributors).

### Sprint D1–D2 (Month 1): Basics

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| Official README.md | High | 1 day | Badges, screenshots, quick start, features list |
| CONTRIBUTING.md detailed | Medium | 1 day | Setup guide, code style, PR process |
| LICENSE file | High | 0.5 day | MIT or Apache 2.0 |

### Sprint D3–D4 (Month 2): User Docs

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| User guide (how to use the app) | High | 2 days | Step-by-step with screenshots |
| FAQ section | Medium | 1 day | Common questions about Braille, conversion |
| Video tutorial (screen recording) | Low | 2 days | 5-minute demo video |

### Sprint D5–D6 (Month 3): Developer Docs

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| Architecture overview (diagrams) | Medium | 1 day | Mermaid diagrams, component relationships |
| API documentation (auto-generated) | Medium | 1 day | OpenAPI spec, code examples |
| Changelog (CHANGELOG.md) | Low | 0.5 day | Keep a Changelog format |

### Sprint D7–D10 (Month 4–5): Community

| Task | Priority | Effort | Details |
|------|----------|--------|---------|
| GitHub Pages docs site | Medium | 2 days | MkDocs or Docusaurus |
| Issue templates (bug, feature, question) | Low | 0.5 day | YAML-based templates |
| PR template | Low | 0.5 day | Checklist for contributors |

---

## 7. Milestones & Success Criteria

| Milestone | Timeline | Criteria |
|-----------|----------|----------|
| **M1: Foundation Ready** | Month 1 | README ✓, CI ✓, 80% test coverage, no state leak, integration tests passing |
| **M2: Accessible App** | Month 2 | Screen reader ✓, web version ✓, font size ✓, voice input ✓ |
| **M3: API & Tools** | Month 3 | REST API ✓, Python CI ✓, PDF rules parsed, compliance report |
| **M4: Teaching Platform** | Month 4 | Learning mode ✓, quiz mode ✓, progress tracking, docs site |
| **M5: Production Ready** | Month 5 | All tracks complete, docs site ✓, community ready, all tests passing |

---

## 8. Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Flutter web Braille font rendering | High | Test early in Sprint B3, fallback to image-based rendering |
| PDF parsing complexity (Thông tư 15) | Medium | Use existing `pdf` package, manual validation |
| State leak refactor breaks existing tests | High | Run full test suite after each change, integration tests as safety net |
| Scope creep on teaching tools | Medium | MVP first: basic learning mode, iterate based on feedback |
| API security concerns | Medium | Start with API key auth, add OAuth later if needed |

---

## 9. Tech Stack Summary

| Component | Technology |
|-----------|------------|
| Mobile/Desktop App | Flutter 3.29.x, Dart |
| State Management | Riverpod |
| Routing | GoRouter |
| OCR | Google ML Kit Text Recognition |
| Web | Flutter Web (HTML renderer) |
| API Server | Dart Shelf or Serverpod |
| Python Tools | Python 3.11+, pytest, pdfplumber |
| CI/CD | GitHub Actions |
| Docs | MkDocs or Docusaurus |
| Testing | flutter_test, mockito, golden_toolkit |

---

## 10. File Map (New Files Created)

| Track | Files Created |
|-------|--------------|
| A | `README.md`, `.github/workflows/test.yml`, `test/integration/full_flow_test.dart` |
| B | `lib/accessibility/`, `web/`, `packages/viet_braille_core/`, `lib/teaching/` |
| C | `tools/verify/`, `tools/analysis/`, `tools/requirements.txt`, `tools/verify.py` |
| D | `docs/`, `CONTRIBUTING.md`, `LICENSE`, `CHANGELOG.md`, `.github/ISSUE_TEMPLATE/` |
