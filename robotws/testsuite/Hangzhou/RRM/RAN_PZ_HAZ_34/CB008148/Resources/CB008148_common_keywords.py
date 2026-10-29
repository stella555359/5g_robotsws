from __future__ import annotations

from typing import Iterable, Union

import pandas as pd

FieldArg = Union[str, list[str], tuple[str, ...]]


def _normalize_fields(fields: FieldArg) -> tuple[list[str], bool]:
    """Normalize fields and return (field_list, is_single_field)."""
    if isinstance(fields, str):
        return [fields], True

    field_list = list(fields)
    if not field_list:
        raise ValueError("fields cannot be empty")
    return field_list, False


def _validate_columns(df: pd.DataFrame, required_fields: list[str]) -> None:
    """Raise an error if required columns are missing."""
    missing = [name for name in required_fields if name not in df.columns]
    if missing:
        raise KeyError(
            f"Missing columns: {missing}. Available columns: {list(df.columns)}"
        )


def _is_empty(value: object) -> bool:
    """Return True if value is None/NaN/blank string."""
    if pd.isna(value):
        return True
    return isinstance(value, str) and value.strip() == ""


def get_field_values(csv_file: str, fields: FieldArg) -> list:
    """
    Get all values from one or multiple CSV columns.

    Args:
        csv_file: CSV file path.
        fields: One column name or multiple column names.

    Returns:
        - Single column: list[column_value] (empty values removed)
        - Multiple columns: list[dict] (rows containing any empty value removed)
    """
    field_list, is_single_field = _normalize_fields(fields)
    df = pd.read_csv(csv_file, encoding="utf-8")
    _validate_columns(df, field_list)

    if is_single_field:
        values = df[field_list[0]].tolist()
        return [v for v in values if not _is_empty(v)]

    records = df[field_list].to_dict(orient="records")
    return [
        row
        for row in records
        if all(not _is_empty(row.get(field)) for field in field_list)
    ]


def filter_and_get_values(
        csv_file: str,
        filter_field: str,
        filter_values: Union[str, Iterable[str]],
        target_fields: FieldArg) -> list:
    """
    Filter rows by one column, then return values from target columns.

    Args:
        csv_file: CSV file path.
        filter_field: Column used for filtering.
        filter_values: One value or multiple values for filtering.
        target_fields: One target column or multiple target columns.

    Returns:
        - Single column: list[column_value] (empty values removed)
        - Multiple columns: list[dict] (rows containing any empty value removed)
    """
    field_list, is_single_field = _normalize_fields(target_fields)
    value_list = [filter_values] if isinstance(filter_values, str) else list(filter_values)

    if not value_list:
        return []

    df = pd.read_csv(csv_file, encoding="utf-8")
    _validate_columns(df, [filter_field, *field_list])

    filtered_df = df[df[filter_field].isin(value_list)]

    if is_single_field:
        values = filtered_df[field_list[0]].tolist()
        return [v for v in values if not _is_empty(v)]

    records = filtered_df[field_list].to_dict(orient="records")
    return [
        row
        for row in records
        if all(not _is_empty(row.get(field)) for field in field_list)
    ]

# if __name__ == "__main__":
# Usage examples: replace with your actual CSV path and field names.
# sample_csv = r"l2stream3_ttitrace_PR856608_1_ul.csv"

# 1) Get all values from one field -> list
# print(get_field_values(sample_csv, "ulFdSchedData.dciFormat"))

# 2) Get all values from multiple fields -> list[dict]
# [{'ulFdSchedData.dciFormat': 'UL_01', 'ulFdSchedData.puschTPstate': 'DISABLED'},
# {'ulFdSchedData.dciFormat': 'UL_01', 'ulFdSchedData.puschTPstate': 'DISABLED'}]
# print(get_field_values(sample_csv, ["ulFdSchedData.dciFormat", "ulFdSchedData.puschTPstate"]))

# 3) Filter by a field, then get one field -> list
# print(filter_and_get_values(sample_csv, "ulFdSchedData.dciFormat", "UL_01", "ulFdSchedData.puschTPstate"))

# 4) Filter by a field, then get multiple fields -> list[dict]
# print(filter_and_get_values(sample_csv, "ulFdSchedData.dciFormat", ["UL_01", "UL_01"],
#                             ["ulFdSchedData.puschTPstate", "ulFdSchedData.searchSpaceType"]))
