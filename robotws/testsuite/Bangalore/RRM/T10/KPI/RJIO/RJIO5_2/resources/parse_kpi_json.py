import json
import os
import sys
from typing import Dict


def ensure_packages_installed():
    """Ensure required packages are installed - called every time compare_kpi_trend runs."""
    required_packages = ["pandas", "openpyxl"]

    missing_packages = []
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)

    if missing_packages:
        print("Installing missing packages: {}".format(", ".join(missing_packages)))
        try:
            import subprocess
            import platform

            for package in missing_packages:
                if platform.system() == "Linux":
                    subprocess.check_call(
                        [sys.executable, "-m", "pip", "install", package, "--user"]
                    )
                else:
                    subprocess.check_call(
                        [sys.executable, "-m", "pip", "install", package]
                    )
            print("All packages installed successfully!")
        except subprocess.CalledProcessError as e:
            print("Failed to install packages. Error: {}".format(e))
            print("Please install manually: pip install pandas openpyxl")
            raise ImportError("Required packages missing")


def _load_report(json_path: str):
    """Load JSON report and extract 'report' list."""
    if not os.path.exists(json_path):
        raise FileNotFoundError("JSON file not found: {}".format(json_path))
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, list):
        raise ValueError("Expected top-level JSON to be a list.")
    report_items = []
    report_id = None
    for entry in data:
        if isinstance(entry, dict) and "report" in entry:
            report_items = entry["report"]
            report_id = entry["id"]
            break
    if not isinstance(report_items, list):
        raise ValueError("'report' should be a list of dictionaries.")
    return report_items, report_id


def _extract_global_kpi_values(report_items) -> Dict[str, dict]:
    """Extract only global KPI values keyed by KPI Code."""
    result = {}
    for item in report_items:
        if not isinstance(item, dict):
            continue
        code = item.get("code", "")
        global_result = item.get("global_result", {}) or {}
        g_val = global_result.get("value", None)
        result[code] = {
            "KPI Code": code,
            "KPI Name": item.get("name", ""),
            "Group Name": item.get("group_name", ""),
            "Unit": item.get("unit", ""),
            "Global Value": g_val,
        }
    return result


def compare_kpi_trend(
    json_run1: str,
    json_run2: str,
    source_build: str,
    target_build: str,
    output_excel: str = "kpi_comparison_report1.xlsx",
):
    """
    Compare Run 1 vs Run 2 KPI values and generate formatted Excel.
    First arg = Run 1 (baseline), Second arg = Run 2 (comparison)
    SAFE FOR ROBOT FRAMEWORK IMPORT - auto-installs packages on every call
    """
    ensure_packages_installed()

    import pandas as pd
    from openpyxl import load_workbook
    from openpyxl.utils import get_column_letter
    from openpyxl.styles import Font, Alignment, PatternFill

    report_run1, report1_id = _load_report(json_run1)
    report_run2, report2_id = _load_report(json_run2)

    vals_run1 = _extract_global_kpi_values(report_run1)
    vals_run2 = _extract_global_kpi_values(report_run2)
    all_codes = sorted(set(vals_run1.keys()) | set(vals_run2.keys()))

    rows = []
    for code in all_codes:
        v_run1 = vals_run1.get(code)
        v_run2 = vals_run2.get(code)
        run1_val = v_run1.get("Global Value") if v_run1 else None
        run2_val = v_run2.get("Global Value") if v_run2 else None
        meta = v_run2 or v_run1 or {}
        kpi_name = meta.get("KPI Name", "")
        group_name = meta.get("Group Name", "")
        unit = meta.get("Unit", "")

        trend = "Not comparable"
        delta_pct = None
        # --- START MODIFICATION FOR BLER KPI DELTA ---
        is_bler_kpi = "BLER" in kpi_name.upper()
        if (
            is_bler_kpi
            and isinstance(run1_val, (int, float))
            and run1_val < 1
            and isinstance(run2_val, (int, float))
            and run2_val < 1
        ):
            delta_pct = 0
            trend = "Same"

        # FIXED: no ×100 here; Excel handles percentage formatting
        elif (
            isinstance(run1_val, (int, float))
            and isinstance(run2_val, (int, float))
            and run1_val is not None
            and run2_val is not None
            and run1_val != 0
        ):

            delta_pct = (run2_val - run1_val) / abs(run1_val)
            if run2_val > run1_val:
                trend = "Increased"
            elif run2_val < run1_val:
                trend = "Decreased"
            else:
                trend = "Same"

        rows.append(
            {
                "KPI Code": code,
                "Group Name": group_name,
                "KPI Name": kpi_name,
                "Unit": unit,
                source_build: run1_val,
                target_build: run2_val,
                "Delta (%)": delta_pct,
                "Trend": trend,
            }
        )

    df = pd.DataFrame(rows)
    df_with_deltas = df[df["Delta (%)"].notna()].copy()
    df_with_deltas["Delta (%)"] = df_with_deltas["Delta (%)"] * 100
    df_with_deltas["Absolute Delta (%)"] = df_with_deltas["Delta (%)"].abs()
    top_5_deltas_info = df_with_deltas.sort_values(
        by="Absolute Delta (%)", ascending=False
    ).head(10)[["KPI Code", "KPI Name", "Delta (%)", "Trend"]]

    # Convert to JSON (list of dicts)
    top_impacted_list = top_5_deltas_info.to_dict(orient="records")
    print(top_impacted_list)

    with pd.ExcelWriter(output_excel, engine="openpyxl") as writer:
        df.to_excel(writer, index=False, sheet_name="KPI Comparison")

    wb = load_workbook(output_excel)
    ws = wb["KPI Comparison"]

    header_fill = PatternFill(
        start_color="4472C4", end_color="4472C4", fill_type="solid"
    )
    header_font = Font(bold=True, color="FFFFFF")
    for cell in ws[1]:
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(
            horizontal="center", vertical="center", wrap_text=True
        )

    for row_idx in range(2, ws.max_row + 1):
        delta_cell = ws.cell(row=row_idx, column=7)
        delta_cell.number_format = "0.00%"
        delta_cell.alignment = Alignment(horizontal="center")

        for col_letter in ["E", "F"]:
            col_num = ord(col_letter) - ord("A") + 1
            ws.cell(row=row_idx, column=col_num).alignment = Alignment(
                horizontal="center"
            )

    # FIXED: Avoid bare except
    for col in ws.columns:
        max_length = 0
        column = get_column_letter(col[0].column)
        for cell in col:
            try:
                if cell.value is not None:
                    cell_length = len(str(cell.value))
                    max_length = max(max_length, cell_length)
            except Exception:
                # Catch only expected runtime conversion issues
                pass
        ws.column_dimensions[column].width = min(max_length + 2, 50)

    wb.save(output_excel)
    print("Excel saved: {} ({} KPIs)".format(output_excel, len(rows)))
    return (
        dict(zip(df["KPI Name"], df["Trend"])),
        top_impacted_list,
        report1_id,
        report2_id,
    )


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python parse_kpi_json.py <run1_json> <run2_json> [output.xlsx]")
        print("Example: python parse_kpi_json.py run1.json run2.json kpi_trend.xlsx")
        sys.exit(1)

    run1_json = sys.argv[1]
    run2_json = sys.argv[2]
    output_file = sys.argv[3] if len(sys.argv) > 3 else "kpi_trend.xlsx"

    if not output_file.lower().endswith(".xlsx"):
        output_file += ".xlsx"
        print("Added .xlsx extension: {}".format(output_file))

    try:
        trends = compare_kpi_trend(run1_json, run2_json, output_file)
        print("Analysis complete! Check the Excel file.")
        print("Summary:")
        for name, trend in list(trends.items())[:10]:
            print("  {}: {}".format(name, trend))
        if len(trends) > 10:
            print("  ... and {} more".format(len(trends) - 10))
    except Exception as e:
        print("Error: {}".format(e))
        sys.exit(1)
