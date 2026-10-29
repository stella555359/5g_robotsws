#!/usr/bin/env python3
"""Split nsetapx CSV columns into one-to-one pairs.

Input example columns:
- frame.num
- nsetapx.crnti                 (e.g. 24496|24496|24496)
- nsetapx.DuVendorExtensionRecordDataType (e.g. 4|9|23)

Output:
1) *_expanded.csv: one row per source row, with columns like crnti1,type1,crnti2,type2,...
2) optional *_paired.csv: one row per pair (if --paired-out is provided)
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import List


DEFAULT_FRAME_COL = "frame.num"
ALTERNATE_FRAME_COL = "frame.number"
DEFAULT_CRNTI_COL = "nsetapx.crnti"
DEFAULT_TYPE_COL = "nsetapx.DuVendorExtensionRecordDataType"
DEFAULT_INPUT_FILE = "bip_check.csv"


def split_multi_value(value: str, separator: str) -> List[str]:
    """Split a multi-value cell and strip spaces around each item."""
    if value is None:
        return []
    text = str(value).strip()
    if not text:
        return []
    effective_separator = separator
    if separator == "auto":
        if "|" in text:
            effective_separator = "|"
        elif "," in text:
            effective_separator = ","
        else:
            effective_separator = "|"
    return [part.strip() for part in text.split(effective_separator) if part.strip() != ""]


def build_paired_rows(
    rows: List[dict],
    frame_col: str,
    crnti_col: str,
    type_col: str,
    separator: str,
) -> List[dict]:
    paired_rows: List[dict] = []

    for row_index, row in enumerate(rows, start=1):
        frame_value = row.get(frame_col, "")
        crnti_values = split_multi_value(row.get(crnti_col, ""), separator)
        type_values = split_multi_value(row.get(type_col, ""), separator)

        max_len = max(len(crnti_values), len(type_values), 1)
        for i in range(max_len):
            paired_rows.append(
                {
                    "source_row_index": row_index,
                    frame_col: frame_value,
                    "pair_index": i + 1,
                    "crnti_item": crnti_values[i] if i < len(crnti_values) else "",
                    "type_item": type_values[i] if i < len(type_values) else "",
                }
            )

    return paired_rows


def write_paired_csv(output_path: Path, paired_rows: List[dict], frame_col: str, out_frame_col: str) -> None:
    fieldnames = [
        out_frame_col,
        "pair_index",
        "crnti_item",
        "type_item",
    ]
    with output_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(
            {
                out_frame_col: row[frame_col],
                "pair_index": row["pair_index"],
                "crnti_item": row["crnti_item"],
                "type_item": row["type_item"],
            }
            for row in paired_rows
        )


def write_wide_csv(output_path: Path, paired_rows: List[dict], frame_col: str, out_frame_col: str) -> None:
    grouped: dict[int, List[dict]] = {}
    max_pairs = 0
    for row in paired_rows:
        row_index = row["source_row_index"]
        grouped.setdefault(row_index, []).append(row)
        max_pairs = max(max_pairs, row["pair_index"])

    fieldnames = [out_frame_col]
    for i in range(1, max_pairs + 1):
        fieldnames.append(f"crnti{i}")
        fieldnames.append(f"type{i}")

    with output_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        for _, items in grouped.items():
            out_row = {out_frame_col: items[0][frame_col]}
            for item in sorted(items, key=lambda current: current["pair_index"]):
                i = item["pair_index"]
                out_row[f"crnti{i}"] = item["crnti_item"]
                out_row[f"type{i}"] = item["type_item"]
            writer.writerow(out_row)


def handle_pcmd_csv(csv_filename=None, out=None, separator="auto",
                    frame_col=DEFAULT_FRAME_COL, out_frame_col=None,
                    crnti_col=DEFAULT_CRNTI_COL, type_col=DEFAULT_TYPE_COL,
                    paired_out=None) -> str:
    """Expand pcmd CSV into wide format. Safe for Robot/Python import (no argv parsing).

    Returns the expanded output file path as a string.
    """
    default_input_path = Path(__file__).resolve().with_name(DEFAULT_INPUT_FILE)
    input_path = Path(csv_filename) if csv_filename else default_input_path

    if not input_path.exists():
        raise FileNotFoundError(f"Input CSV not found: {input_path}")

    expanded_out = Path(out) if out else input_path.with_name(input_path.stem + "_expanded.csv")
    paired_out_path = Path(paired_out) if paired_out else None
    resolved_out_frame_col = out_frame_col if out_frame_col else frame_col

    with input_path.open("r", newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None:
            raise ValueError("CSV has no header")

        resolved_frame_col = frame_col
        if (resolved_frame_col not in reader.fieldnames
                and frame_col == DEFAULT_FRAME_COL
                and ALTERNATE_FRAME_COL in reader.fieldnames):
            resolved_frame_col = ALTERNATE_FRAME_COL

        missing = [
            col for col in [resolved_frame_col, crnti_col, type_col]
            if col not in reader.fieldnames
        ]
        if missing:
            raise ValueError(f"Missing required columns: {missing}")

        rows = list(reader)

    paired_rows = build_paired_rows(
        rows=rows,
        frame_col=resolved_frame_col,
        crnti_col=crnti_col,
        type_col=type_col,
        separator=separator,
    )

    write_wide_csv(expanded_out, paired_rows, resolved_frame_col, resolved_out_frame_col)
    if paired_out_path is not None:
        write_paired_csv(paired_out_path, paired_rows, resolved_frame_col, resolved_out_frame_col)

    print(f"Done. expanded -> {expanded_out}")
    if paired_out_path is not None:
        print(f"Done. paired   -> {paired_out_path}")
    return str(expanded_out)

# handle_pcmd_csv('pcmd.csv')
