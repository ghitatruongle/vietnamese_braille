#!/usr/bin/env python3
"""Sinh gói đối chiếu cho chuyên gia Braille từ fixture TT15.

Đọc tools/data/tt15_rules.json (nguồn sự thật đã ghim SHA-256) và xuất
docs/external-validation/expert-review-packet.md: bảng chữ cái, thanh điệu,
ký hiệu và 15 ví dụ chính xác kèm cột xác nhận để chuyên gia đánh dấu.

Gói này phục vụ gate `tt15_external_review` trong tools/release_evidence.py:
chuyên gia độc lập đối chiếu từng dòng với bản TT15 gốc, ghi biên bản và
xác nhận cả SHA-256 của PDF nguồn lẫn SHA-256 của fixture.

Cách dùng:
    python tools/expert_review_packet.py          # in ra stdout
    python tools/expert_review_packet.py --write  # ghi file packet
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FIXTURE = ROOT / "tools" / "data" / "tt15_rules.json"
TARGET = ROOT / "docs" / "external-validation" / "expert-review-packet.md"


def _dots_text(dots: object) -> str:
    if isinstance(dots, list) and dots and isinstance(dots[0], list):
        return " + ".join(_dots_text(part) for part in dots)
    return ",".join(str(dot) for dot in dots)  # type: ignore[union-attr]


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def build_packet() -> str:
    fixture = json.loads(FIXTURE.read_text(encoding="utf-8"))
    metadata = fixture["metadata"]
    lines: list[str] = [
        "# Gói đối chiếu dành cho chuyên gia Braille",
        "",
        "> File này sinh tự động bằng `python tools/expert_review_packet.py"
        " --write` từ fixture đã ghim hash — không sửa tay.",
        "",
        "## Thông tin nguồn cần xác nhận",
        "",
        f"- Chuẩn: {metadata['standard']}",
        f"- Tài liệu nguồn: `{metadata['source_file']}` (tài liệu nội bộ,"
        " ban dự án cung cấp riêng cho chuyên gia)",
        f"- SHA-256 PDF nguồn phải khớp: `{metadata['source_sha256']}`",
        f"- SHA-256 fixture tại thời điểm sinh gói: `{_sha256(FIXTURE)}`",
        "",
        "Chuyên gia xác nhận hai hash trên trong biên bản; nếu lệch, gói"
        " này vô hiệu và phải sinh lại.",
        "",
        "## Cách đánh giá",
        "",
        "Với từng dòng: đối chiếu số chấm và ô Unicode với bản TT15 gốc,",
        "đánh dấu ✔ (đúng) / ✘ (sai, ghi rõ) vào cột Xác nhận.",
        "",
    ]

    for category, title in [
        ("alphabet", "Bảng chữ cái"),
        ("extended", "Chữ cái Latin mở rộng"),
        ("tones", "Thanh điệu"),
        ("symbols", "Ký hiệu"),
    ]:
        entries = fixture[category]
        lines += [f"## {title} ({len(entries)} mục)", ""]
        lines += ["| Mục | Số chấm | Unicode | Xác nhận | Ghi chú |"]
        lines += ["|---|---|---|---|---|"]
        for key, info in entries.items():
            lines.append(
                f"| `{key}` | {_dots_text(info['dots'])} |"
                f" `{info['unicode']}` | | |"
            )
        lines.append("")

    examples = fixture["exact_examples"]
    lines += [f"## Ví dụ chính xác ({len(examples)} mục)", ""]
    lines += ["| ID | Văn bản | Braille | Nguồn trích | Xác nhận | Ghi chú |"]
    lines += ["|---|---|---|---|---|---|"]
    for example in examples:
        lines.append(
            f"| {example['id']} | {example['input']} |"
            f" `{example['unicode']}` | {example['source']} | | |"
        )
    lines.append("")

    unsupported = fixture["unsupported_rules"]
    lines += [
        f"## Quy tắc đã khai báo là chưa triển khai ({len(unsupported)} mục)",
        "",
        "Chuyên gia xác nhận việc khai báo `not_implemented` là phù hợp,",
        "và nếu có thể, trích quy tắc áp dụng từ TT15 để dự án triển khai",
        "ở phiên bản sau.",
        "",
        "| ID | Lý do đã khai báo | Nhận xét chuyên gia |",
        "|---|---|---|",
    ]
    for rule in unsupported:
        lines.append(f"| {rule['id']} | {rule['reason']} | |")
    lines += [
        "",
        "## Kết luận của chuyên gia",
        "",
        "```text",
        "Mã người review (reviewer_id):        ............",
        "Độc lập với nhóm phát triển:          có / không",
        "Thời điểm (ISO-8601 + múi giờ):       ............",
        "SHA-256 PDF nguồn đã xác nhận:        ............",
        "SHA-256 fixture đã xác nhận:          ............",
        "Số dòng sai phát hiện (blocking):     ....",
        "Kết luận (result):                    passed / failed",
        "Mã hồ sơ (attestation_reference):     ............",
        "```",
        "",
        "Kết quả được chép vào mục `tt15_external_review` của"
        " `release_evidence/<tag>.json`.",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--write",
        action="store_true",
        help="ghi gói vào docs/external-validation/expert-review-packet.md",
    )
    args = parser.parse_args()

    packet = build_packet()
    if args.write:
        TARGET.write_text(packet, encoding="utf-8")
        print(f"Đã ghi {TARGET}")
    else:
        print(packet)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
