#!/usr/bin/env python3
"""Check expanded CSV with rule on type=3/4 against same-index CRNTI.

Rule:
- For each pair i, if type_i is 3 or 4, compare crnti_i with target
  CRNTI.
- If equal -> FAIL
- If not equal -> PASS
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Dict, List, Sequence, Tuple


DEFAULT_INPUT_FILE = "pcmd_expanded.csv"
DEFAULT_FRAME_COLS = ("frame.num", "frame.number")
WATCH_TYPES = {"3", "4"}


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Validate expanded CSV (typeN/crntiN) by checking "
        "same-index CRNTI when type is 3/4."
    )
    parser.add_argument(
        "--input",
        default=None,
        help=f"Input CSV path (default: {DEFAULT_INPUT_FILE} in script)",
    )
    parser.add_argument(
        "--target-crnti",
        required=True,
        help="Target CRNTI value to compare with crnti item",
    )
    parser.add_argument(
        "--out",
        default=None,
        help="Output detail CSV path (default: <stem>_check_result.csv)",
    )
    return parser.parse_args()


def resolve_paths(
    input_arg: str | None, out_arg: str | None
) -> Tuple[Path, Path]:
    """Resolve input and output file paths."""
    default_input = Path(__file__).resolve().with_name(
        DEFAULT_INPUT_FILE
    )
    input_path = Path(input_arg) if input_arg else default_input
    output_path = (
        Path(out_arg)
        if out_arg
        else input_path.with_name(f"{input_path.stem}_check_result.csv")
    )
    return input_path, output_path


def find_frame_col(fieldnames: Sequence[str]) -> str:
    """Find frame column name from header."""
    for col in DEFAULT_FRAME_COLS:
        if col in fieldnames:
            return col
    raise ValueError(
        f"Missing frame column. Expected one of: {DEFAULT_FRAME_COLS}"
    )


def collect_pair_indexes(fieldnames: Sequence[str]) -> List[int]:
    """Extract pair indexes from typeN columns."""
    indexes: List[int] = []
    for name in fieldnames:
        if name.startswith("type"):
            suffix = name[len("type"):]
            if suffix.isdigit():
                indexes.append(int(suffix))
    return sorted(set(indexes))


def get_indexed_value(
    row: Dict[str, str], base_name: str, idx: int
) -> str:
    """Read value using no-underscore naming (e.g. crnti1, type1)."""
    value = row.get(f"{base_name}{idx}", "")
    return str(value).strip() if value else ""


def check_rows(
    rows: List[Dict[str, str]],
    frame_col: str,
    pair_indexes: List[int],
    target_crnti: str,
) -> List[Dict[str, str]]:
    """Check rows and return detailed results for each pair."""
    results: List[Dict[str, str]] = []

    for row in rows:
        frame_value = row.get(frame_col, "")
        for idx in pair_indexes:
            type_value = get_indexed_value(row, "type", idx)
            if type_value not in WATCH_TYPES:
                continue

            current_crnti = get_indexed_value(row, "crnti", idx)
            result = (
                "FAIL" if current_crnti == target_crnti else "PASS"
            )

            results.append(
                {
                    frame_col: frame_value,
                    "pair_index": str(idx),
                    "type_item": type_value,
                    "crnti_item": current_crnti,
                    "target_crnti": target_crnti,
                    "result": result,
                }
            )

    return results


def write_results(
    path: Path, frame_col: str, rows: List[Dict[str, str]]
) -> None:
    """Write detailed check results to CSV file."""
    fieldnames = [
        frame_col,
        "pair_index",
        "type_item",
        "crnti_item",
        "target_crnti",
        "result",
    ]
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def run_check(
    input_arg: str | None,
    target_crnti: str,
    out_arg: str | None = None,
) -> str:
    """Run the CSV check and return overall result: PASS or FAIL."""
    input_path, output_path = resolve_paths(input_arg, out_arg)
    target_crnti = str(target_crnti)

    if not input_path.exists():
        raise FileNotFoundError(
            f"Input CSV not found: {input_path}"
        )

    with input_path.open("r", newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None:
            raise ValueError("CSV has no header")
        frame_col = find_frame_col(reader.fieldnames)
        pair_indexes = collect_pair_indexes(reader.fieldnames)
        if not pair_indexes:
            raise ValueError("No typeN columns found")
        rows = list(reader)

    results = check_rows(rows, frame_col, pair_indexes, target_crnti)
    write_results(output_path, frame_col, results)

    fail_count = sum(
        1 for row in results if row["result"] == "FAIL"
    )
    pass_count = sum(
        1 for row in results if row["result"] == "PASS"
    )
    overall = "FAIL" if fail_count > 0 else "PASS"

    print(f"Done. details -> {output_path}")
    print(
        f"Checked rows: {len(results)}, PASS: {pass_count}, "
        f"FAIL: {fail_count}, OVERALL: {overall}"
    )
    return overall


# run_check("pcmd_expanded.csv", "24496")
