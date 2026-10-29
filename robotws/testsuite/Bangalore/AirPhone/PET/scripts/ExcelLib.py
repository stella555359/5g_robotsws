# -*- coding: utf-8 -*-
"""
ExcelLib.py - Final Version (Option B1 + Safe Float Casting incl. Append Merge + Min 1 Decimal)
----------------------------------------------------------------------------------------------
- Preserves robot dict types when building DataFrames (dtype=object).
- Safely converts ONLY float-like numeric strings (e.g., "0.", "0.0", "1.23") to floats so Excel can format them.
- DOES NOT convert integer-like strings (e.g., "42", "00123").
- Applies Excel number format 0.0############ so at least one decimal is shown (e.g., 0.0).
- Applies float casting on:
    a) New KPI data before first write
    b) Merged KPI data during append (fixes historic "0." strings)
- Prints a small audit of value types per dynamic column to help debugging.
"""

import json
import ast
import re
from pathlib import Path
from typing import Any, List, Iterable

import pandas as pd


class ExcelLib:
    """Utility to create/append KPI Excel files while preserving intended datatypes."""

    # -------------------------------------------------------------
    # Debug helpers
    # -------------------------------------------------------------
    def _audit_types(self, df: pd.DataFrame, header: str = "AUDIT") -> None:
        """Print dtypes and value-type counts per column (for quick debugging)."""
        try:
            # print(f"[AUDIT] {header}: dtypes -> {df.dtypes}")
            for c in df.columns:
                counts = {}
                for v in df[c].values:
                    t = type(v).__name__
                    counts[t] = counts.get(t, 0) + 1
                # print(f"[AUDIT] {header}: {c}: {counts}")
        except Exception as e:
            print(f"[AUDIT] failed: {e}")

    # -------------------------------------------------------------
    # Excel formatting helpers
    # -------------------------------------------------------------
    def _float_columns(self, df: pd.DataFrame) -> List[str]:
        """Return columns that contain at least one float value."""
        cols: List[str] = []
        for c in df.columns:
            for v in df[c].dropna().values:
                if isinstance(v, float):
                    cols.append(c)
                    break
        return cols

    def _apply_excel_float_format(
        self,
        writer,
        sheet_name: str,
        df: pd.DataFrame,
        fmt: str = "0.0############",
    ) -> None:
        """Apply a number format to float-containing columns (display only)."""
        ws = writer.book[sheet_name]
        headers = [cell.value for cell in ws[1]]
        colmap = {h: i + 1 for i, h in enumerate(headers)}
        for c in self._float_columns(df):
            if c not in colmap:
                continue
            col_idx = colmap[c]
            for col_cells in ws.iter_cols(
                min_col=col_idx, max_col=col_idx, min_row=2, values_only=False
            ):
                for cell in col_cells:
                    cell.number_format = fmt

    # -------------------------------------------------------------
    # Safe float casting from strings (floats only)
    # -------------------------------------------------------------
    def _auto_cast_numeric_strings_floats_only(
        self,
        df: pd.DataFrame,
        exclude_cols: Iterable[str] = ("PM_FILE", "KPI_TYPE"),
    ) -> pd.DataFrame:
        """Convert ONLY float-like strings to floats so Excel can format them numerically.

        Rules:
          - Matches values containing a decimal point and otherwise numeric (with optional sign/exponent).
          - Leaves integer-like strings (e.g., "42", "00123") untouched.
          - Leaves obvious text/IDs untouched.
        """
        float_re = re.compile(r'^[+-]?(?:\d*\.\d+|\d+\.\d*)(?:[eE][+-]?\d+)?$')
        cast_df = df.copy()
        for col in cast_df.columns:
            if exclude_cols and col in set(exclude_cols):
                continue
            s = cast_df[col]
            for idx, v in s.items():
                if isinstance(v, str):
                    vv = v.strip()
                    if "." in vv and float_re.match(vv):
                        try:
                            cast_df.at[idx, col] = float(vv)
                        except Exception:
                            # Keep original string on failure
                            pass
        return cast_df

    # -------------------------------------------------------------
    # Parse Robot Framework data
    # -------------------------------------------------------------
    def _parse(self, obj: Any):
        """Handle dict, list, JSON string, or Python literal strings."""
        if isinstance(obj, (dict, list)):
            return obj
        if isinstance(obj, str):
            try:
                return json.loads(obj)
            except json.JSONDecodeError:
                return ast.literal_eval(obj)
        raise TypeError(f"Unsupported Robot payload type: {type(obj)}")

    # -------------------------------------------------------------
    # Detect ALL dynamic KPI columns
    # -------------------------------------------------------------
    def _detect_dynamic_cols(self, df: pd.DataFrame) -> List[str]:
        """Everything except PM_FILE and KPI_TYPE is considered dynamic."""
        static = {"PM_FILE", "KPI_TYPE"}
        return [c for c in df.columns if isinstance(c, str) and c not in static]

    # -------------------------------------------------------------
    # Combine missing counters
    # -------------------------------------------------------------
    @staticmethod
    def _combine_counter_strings(series: pd.Series) -> str:
        """Combine comma-separated strings, deduplicate while preserving order."""
        vals: List[str] = []
        for s in series.dropna().astype(str):
            vals += [p.strip() for p in s.split(",") if p.strip()]
        seen = set()
        out: List[str] = []
        for x in vals:
            if x not in seen:
                seen.add(x)
                out.append(x)
        return ",".join(out)

    # -------------------------------------------------------------
    # Append/Merge existing workbook
    # -------------------------------------------------------------
    def _append_to_existing_excel(
        self,
        out_path: str,
        new_kpi_df: pd.DataFrame,
        new_cnt_df: pd.DataFrame,
        dedup_kpi: bool,
        combine_counters: bool,
    ) -> None:
        out_path = Path(out_path)
        kpi_sheet = "KPI_Calculation"
        cnt_sheet = "Missing_Counters"

        if out_path.exists():
            try:
                existing = pd.read_excel(
                    out_path, sheet_name=None, engine="openpyxl"
                )
            except Exception:
                existing = {}
        else:
            existing = {}

        # --- KPI MERGE ---
        if kpi_sheet in existing:
            old = existing[kpi_sheet]
            all_cols = list(
                dict.fromkeys(old.columns.tolist() + new_kpi_df.columns.tolist())
            )
            old = old.reindex(columns=all_cols)
            new = new_kpi_df.reindex(columns=all_cols)
            merged = pd.concat([old, new], ignore_index=True)
            if dedup_kpi:
                dyn = [c for c in merged.columns if c not in ("PM_FILE", "KPI_TYPE")]
                merged = merged.drop_duplicates(
                    subset=["PM_FILE", "KPI_TYPE"] + dyn,
                    keep="last",
                )
        else:
            merged = new_kpi_df.copy()

        # SAFE CASTING ON MERGED DATA (critical for historic "0.")
        merged = self._auto_cast_numeric_strings_floats_only(
            merged, exclude_cols=("PM_FILE", "KPI_TYPE")
        )
        self._audit_types(merged, header="POST-MERGE KPI")

        # --- MISSING COUNTERS MERGE ---
        if cnt_sheet in existing:
            old = existing[cnt_sheet]
            if combine_counters:
                merged_cnt = pd.concat([old, new_cnt_df], ignore_index=True)
                merged_cnt = merged_cnt.groupby("PM_FILE", as_index=False)[
                    "Missing_counters"
                ].agg(self._combine_counter_strings)
            else:
                merged_cnt = pd.concat([old, new_cnt_df], ignore_index=True)
        else:
            merged_cnt = new_cnt_df.copy()

        # --- WRITE BACK ---
        with pd.ExcelWriter(str(out_path), engine="openpyxl", mode="w") as writer:
            merged.to_excel(writer, index=False, sheet_name=kpi_sheet)
            merged_cnt.to_excel(writer, index=False, sheet_name=cnt_sheet)
            self._apply_excel_float_format(writer, kpi_sheet, merged)

    # -------------------------------------------------------------
    # MAIN: Create Excel + Add Data
    # -------------------------------------------------------------
    def create_exl_add_data(
        self,
        robot_data,
        miss_data,
        exec_dir,
        out_path: str = "kpi.xlsx",
        cell_cols=None,
        append: bool = True,
        dedup_kpi: bool = False,
        combine_counters: bool = True,
    ) -> str:
        """Create (or append to) the KPI workbook from Robot inputs."""
        # Parse inputs
        robot_data = self._parse(robot_data)
        miss_data = self._parse(miss_data)

        # DataFrames as object to avoid unwanted coercion
        df = (
            pd.DataFrame([robot_data], dtype=object)
            if isinstance(robot_data, dict)
            else pd.DataFrame(robot_data, dtype=object)
        )
        df1 = (
            pd.DataFrame([miss_data], dtype=object)
            if isinstance(miss_data, dict)
            else pd.DataFrame(miss_data, dtype=object)
        )

        # Mandatory fields
        if "PM_FILE" not in df.columns:
            df["PM_FILE"] = None
        if "KPI_TYPE" not in df.columns:
            df["KPI_TYPE"] = None

        # Dynamic columns
        if cell_cols is None:
            cell_cols = self._detect_dynamic_cols(df)

        # KPI block
        keep = ["PM_FILE", "KPI_TYPE"] + cell_cols
        long_df = df.reindex(columns=keep).copy()

        # Safe float casting on NEW data
        long_df = self._auto_cast_numeric_strings_floats_only(
            long_df, exclude_cols=("PM_FILE", "KPI_TYPE")
        )
        self._audit_types(long_df, header="NEW KPI")

        # Missing counters block
        if "PM_FILE" not in df1.columns:
            df1["PM_FILE"] = None

        if "missing" in df1.columns:
            def _to_list(x):
                if pd.isna(x):
                    return []
                if isinstance(x, (list, tuple, set)):
                    return [str(v).strip() for v in x if str(v).strip()]
                s = str(x).strip()
                return [p.strip() for p in s.split(",") if p.strip()] if s else []

            df1 = df1.copy()
            df1["missing"] = df1["missing"].apply(_to_list)
            df1 = df1.explode("missing", ignore_index=True)
            tmp = df1.rename(columns={"missing": "value"}).dropna(subset=["value"])
            long_df1 = (
                tmp.assign(value=lambda d: d["value"].astype(str))
                .groupby("PM_FILE", as_index=False)["value"]
                .agg(",".join)
                .rename(columns={"value": "Missing_counters"})
            )
        else:
            val_cols = [c for c in df1.columns if c != "PM_FILE"]
            melted = df1.melt(
                id_vars=["PM_FILE"],
                value_vars=val_cols,
                var_name="_",
                value_name="v",
            )
            long_df1 = (
                melted.dropna(subset=["v"])
                .assign(v=lambda d: d["v"].astype(str))
                .groupby("PM_FILE", as_index=False)["v"]
                .agg(",".join)
                .rename(columns={"v": "Missing_counters"})
            )

        # Write or Append
        exec_dir = Path(exec_dir)
        out_path = exec_dir / "kpi.xlsx"
        out_path = str(Path(out_path).absolute())
        Path(out_path).parent.mkdir(parents=True, exist_ok=True)

        if append and Path(out_path).exists():
            self._append_to_existing_excel(
                out_path,
                long_df,
                long_df1,
                dedup_kpi,
                combine_counters,
            )
        else:
            with pd.ExcelWriter(out_path, engine="openpyxl", mode="w") as writer:
                long_df.to_excel(writer, index=False, sheet_name="KPI_Calculation")
                long_df1.to_excel(writer, index=False, sheet_name="Missing_Counters")
                self._apply_excel_float_format(
                    writer,
                    "KPI_Calculation",
                    long_df,
                )
            # print(f">>> Excel written to: {out_path}")

        return out_path
