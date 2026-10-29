"""
Validation script: validates stdMaxModeFlag against isBlerTargetForMcsDowngradedCalculated.

Supports: .csv and .xlsx / .xls (Excel) files.

Rules:
- Maxmode: isBlerTargetForMcsDowngradedCalculated must be 0 only; any other value = FAIL
- STDMODE: isBlerTargetForMcsDowngradedCalculated must be 0 or 1; any other value = FAIL
- STDMODE + isBlerTargetForMcsDowngradedCalculated=1: blerTargetForMcsDowngraded must be
  40, 60, 80, or 100; any other value = FAIL

Dependencies: pip install pandas openpyxl
"""

import sys
from collections import Counter

import pandas as pd


def load_data(file_path, sheet_name=0):
    """Load CSV or Excel into a DataFrame."""
    path_lower = str(file_path).lower()
    if path_lower.endswith(".csv"):
        return pd.read_csv(file_path)
    if path_lower.endswith(".xlsx"):
        return pd.read_excel(file_path, sheet_name=sheet_name, engine="openpyxl")
    if path_lower.endswith(".xls"):
        return pd.read_excel(file_path, sheet_name=sheet_name, engine="xlrd")
    raise ValueError(f"Unsupported format. Use .csv, .xlsx, or .xls. Got: {file_path}")


VALID_BLER_TARGETS = (40, 60, 80, 100)


def _to_num(val):
    """Convert to int/float for comparison; None if not a number."""
    if pd.isna(val):
        return None
    if isinstance(val, (int, float)):
        return int(val) if val == int(val) else val
    try:
        x = float(val)
        return int(x) if x == int(x) else x
    except (TypeError, ValueError):
        return None


def _bler_target_ok(val):
    """True if value is 40, 60, 80, or 100 (int or float)."""
    n = _to_num(val)
    if n is None:
        return False
    return n in (40, 60, 80, 100)


def validate_row(mode_value, bler_calc_value, bler_target_value):
    """
    Return (passed: bool, failure_messages: list of str, pass_messages: list of str).

    failure_messages: reasons when failed.
    pass_messages: which validations passed (for tester clarity).
    """
    mode_str = str(mode_value).strip() if pd.notna(mode_value) else ""
    bler_calc = _to_num(bler_calc_value)
    bler_target = bler_target_value  # keep raw for error message
    failures = []
    pass_msgs = []

    if mode_str.lower() == "maxmode":
        if bler_calc == 0:
            pass_msgs.append("maxmode_bler_0")
            return True, [], pass_msgs
        fail_msg = (
            f"FAIL: Maxmode requires isBlerTargetForMcsDowngradedCalculated=0, "
            f"got {bler_calc_value}"
        )
        return False, [fail_msg], []

    if mode_str.lower() in ("stdmode", "standard mode"):
        # Validation 1: isBlerTargetForMcsDowngradedCalculated must be 0 or 1
        if bler_calc not in (0, 1):
            fail_msg = (
                f"FAIL: Standard mode requires isBlerTargetForMcsDowngradedCalculated "
                f"= 0 or 1, got {bler_calc_value}"
            )
            failures.append(fail_msg)
        else:
            pass_msgs.append("stdmode_bler_01")
            # Validation 2: when it is 1, blerTargetForMcsDowngraded must be
            # 40, 60, 80, or 100
            if bler_calc == 1:
                if not _bler_target_ok(bler_target_value):
                    fail_msg = (
                        f"FAIL: STDMODE with isBlerTargetForMcsDowngradedCalculated=1 "
                        f"requires blerTargetForMcsDowngraded in (40, 60, 80, 100), "
                        f"got {bler_target_value}"
                    )
                    failures.append(fail_msg)
                else:
                    pass_msgs.append("stdmode_bler_target")
        if failures:
            return False, failures, []
        return True, [], pass_msgs

    return False, [f"FAIL: Unknown stdMaxModeFlag value: {mode_value}"], []


def validate_file(file_path, sheet_name=0):
    """
    Read file (CSV or Excel) and validate each row.

    Returns list of (row_index, passed, message).
    """
    df = load_data(file_path, sheet_name=sheet_name)

    required = [
        "stdMaxModeFlag",
        "isBlerTargetForMcsDowngradedCalculated",
        "blerTargetForMcsDowngraded"
    ]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise ValueError(f"Missing columns: {missing}. Available: {list(df.columns)}")

    results = []
    for idx, row in df.iterrows():
        mode_val = row["stdMaxModeFlag"]
        bler_calc_val = row["isBlerTargetForMcsDowngradedCalculated"]
        bler_target_val = row["blerTargetForMcsDowngraded"]
        passed, failure_msgs, pass_msgs = validate_row(
            mode_val, bler_calc_val, bler_target_val
        )
        # +2 for 1-based and header row
        results.append((idx + 2, passed, failure_msgs, pass_msgs))

    return results


def _build_summary(file_path, results):
    passed_count = sum(1 for r in results if r[1])
    fail_count = len(results) - passed_count

    lines = [
        f"Validation results for: {file_path}",
        f"Total rows: {len(results)} | PASS: {passed_count} | FAIL: {fail_count}",
    ]

    if fail_count > 0:
        lines.append("Failed row(s):")
        for row_num, passed, failure_msgs, pass_msgs in results:
            if not passed:
                for msg in failure_msgs:
                    lines.append(f"  Row {row_num}: {msg}")
        lines.append(f"Overall: FAILED ({fail_count} row(s) failed)")
    else:
        lines.append("Overall: PASSED")
        # High-level summary only when all passed
        # (avoid showing passed validations when run failed)
        PASS_LABELS = {
            "maxmode_bler_0": (
                "Maxmode: All {} row(s) — isBlerTargetForMcsDowngradedCalculated "
                "values are 0 as expected — PASSED"
            ),
            "stdmode_bler_01": (
                "STDMODE: All {} row(s) — isBlerTargetForMcsDowngradedCalculated "
                "values are in (0, 1) as expected — PASSED"
            ),
            "stdmode_bler_target": (
                "STDMODE (when calculated=1): All {} row(s) — "
                "blerTargetForMcsDowngraded values are in (40, 60, 80, 100) "
                "as expected — PASSED"
            ),
        }
        validation_counts = Counter()
        for row_num, passed, failure_msgs, pass_msgs in results:
            if passed and pass_msgs:
                for key in pass_msgs:
                    validation_counts[key] += 1
        if validation_counts:
            lines.append("")
            lines.append("Passed validations (high-level):")
            for key, count in sorted(validation_counts.items()):
                lines.append(f"  {PASS_LABELS[key].format(count)}")

    return "\n".join(lines), fail_count


def link_adapation(file_path, sheet_name=0):
    """
    Robot Framework-friendly keyword.

    Returns summary string when all rows pass.
    Raises AssertionError when any row fails.
    """
    results = validate_file(file_path, sheet_name=sheet_name)
    summary, fail_count = _build_summary(file_path, results)
    if fail_count > 0:
        raise AssertionError(summary)
    return summary


def link_adaption(file_path, sheet_name=0):
    """Alias keyword spelling for Robot Framework usage."""
    return link_adapation(file_path, sheet_name=sheet_name)


def main():
    if len(sys.argv) < 2:
        print(
            "Usage: python excel_validation_script.py <path_to_file> "
            "[sheet_name_or_index]"
        )
        print("       Supports .csv, .xlsx, .xls")
        print("Example: python excel_validation_script.py data.csv")
        print("Example: python excel_validation_script.py data.xlsx Sheet1")
        sys.exit(1)

    file_path = sys.argv[1]
    if len(sys.argv) > 2:
        sheet_name = (
            int(sys.argv[2]) if sys.argv[2].isdigit() else sys.argv[2]
        )
    else:
        sheet_name = 0

    try:
        summary = link_adapation(file_path, sheet_name=sheet_name)
        print(f"\n{summary}")
        sys.exit(0)
    except AssertionError as e:
        print(f"\n{e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
