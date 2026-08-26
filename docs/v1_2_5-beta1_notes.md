Upgrade plan v1.2.5-beta1 — Vietnamese Braille
Date: 2026-08-24

Goal: Improve accuracy and versatility; ensure features operate without bugs, with no commits/pushes during the process.
Platform focus: Windows (maintain cross-platform compatibility).

What has been completed in this session:
- Track A completed (A1–A6)
- Track B completed (B1–B5) except B5 which is in progress and under design for formatting markers
- Track C: C1 Misc fixes completed; C2–C4 tested; C5 planned (beta release prep)

What remains in this beta plan (C5 and beyond):
- Prepare beta release notes and upgrade notes for 1.2.5-beta1
- Update CHANGELOG/ docs with beta entries
- Update version constants in app/core (kAppVersion) and pubspec if needed for beta tag
- Create a non-commit/test-only release plan: run all tests locally, verify with Python tooling if CI gates are referenced
- Ensure docs (docs/symbol_extensions.md) reflect app-level extensions introduced in this beta

Notes on current status:
- All core tests pass for core/app/api suites where applicable.
- B5 formatting markers design is being finalized to avoid collisions with mathPrefix and allCapsWord markers. The approach in this session uses app-defined markers and docs to communicate the extension.
- A5 and C5 tasks are aligned with plan; no commits/pushes will occur until you review and approve.

Next steps for you to review and approve:
- Confirm the approach for B5 markers (bold/italic/underline) and whether to move forward with app-extension markers or adjust the TT15 incorporation.
- Approve the beta release notes and version bump strategy for 1.2.5-beta1.
- If approved, we would surface a concise CHANGELOG entry and upgrade_notes for the reviewer.

End of note.
