#!/usr/bin/env python3
"""
Script to merge multiple NR summary Excel files into a single consolidated file.

Each input file has the structure:
    kpi_name | object_name | date1 | date2 | date3 | ...

The script will:
1. Read all input files
2. Merge them by combining date columns
3. Create a consolidated output file

Usage:
    python merge_multiple_nr_summaries.py <output_file.xlsx> <input_file1.xlsx> <input_file2.xlsx> ...

Example:
    python merge_multiple_nr_summaries.py consolidated.xlsx summary1.xlsx summary2.xlsx summary3.xlsx
"""

import sys
import os
from pathlib import Path
import pandas as pd
from openpyxl import Workbook
from openpyxl.styles import Font


def merge_nr_summary_files(output_file, input_files):
    """
    Merge multiple NR summary Excel files into one consolidated file.

    Args:
        output_file: Path to the output Excel file
        input_files: List of paths to input Excel files to merge

    Returns:
        Path to the created consolidated file
    """

    if not input_files:
        print("Error: No input files provided.")
        sys.exit(1)

    print(f"\nMerging {len(input_files)} NR summary file(s)...")

    # Dictionary to store all data: key = (kpi_name, object_name), value = dict of {date: value}
    consolidated_data = {}
    all_dates = set()

    # Read each input file
    for idx, input_file in enumerate(input_files, 1):
        file_path = Path(input_file)

        if not file_path.exists():
            print(f"Warning: File not found: {input_file} - skipping")
            continue

        print(f"  [{idx}/{len(input_files)}] Reading {file_path.name}...")

        try:
            # Read the Excel file (assuming first sheet)
            df = pd.read_excel(file_path, sheet_name=0)

            # Verify the structure
            if len(df.columns) < 3:
                print(f"  Warning: File has fewer than 3 columns - skipping {file_path.name}")
                continue

            if df.columns[0] != 'kpi_name' or df.columns[1] != 'object_name':
                print(f" Warning: Expected 'kpi_name' and 'object_name' as first columns - skipping {file_path.name}")
                continue

            # Get date columns (all columns except first two)
            date_columns = df.columns[2:].tolist()
            all_dates.update(date_columns)

            # Process each row
            for _, row in df.iterrows():
                kpi_name = row['kpi_name']
                object_name = row['object_name']
                key = (kpi_name, object_name)

                # Initialize if first time seeing this key
                if key not in consolidated_data:
                    consolidated_data[key] = {}

                # Add values for each date
                for date_col in date_columns:
                    value = row[date_col]
                    # Only add if not None/NaN and not already present
                    if pd.notna(value) and value != 'None':
                        consolidated_data[key][date_col] = value
                    elif date_col not in consolidated_data[key]:
                        # Keep None for dates without data
                        consolidated_data[key][date_col] = 'None'

            print(f"    - Added {len(date_columns)} date column(s)")

        except Exception as e:
            print(f"  Error reading {file_path.name}: {e}")
            continue

    if not consolidated_data:
        print("Error: No data found in any input file.")
        sys.exit(1)

    # Sort dates chronologically
    sorted_dates = sorted(all_dates)

    print(f"\nConsolidating data...")
    print(f"  - {len(consolidated_data)} unique (KPI x Object) combinations")
    print(f"  - {len(sorted_dates)} unique date columns")

    # Create output Excel file
    wb = Workbook()
    ws = wb.active
    ws.title = "Consolidated_Summary"

    # Write headers
    ws.cell(1, 1, "kpi_name")
    ws.cell(1, 2, "object_name")
    for col_idx, date in enumerate(sorted_dates, start=3):
        ws.cell(1, col_idx, date)

    # Make headers bold
    for cell in ws[1]:
        cell.font = Font(bold=True)

    # Write data rows
    row_idx = 2
    for (kpi_name, object_name), date_values in sorted(consolidated_data.items()):
        ws.cell(row_idx, 1, kpi_name)
        ws.cell(row_idx, 2, object_name)

        for col_idx, date in enumerate(sorted_dates, start=3):
            value = date_values.get(date, 'None')
            ws.cell(row_idx, col_idx, value)

        row_idx += 1

    # Adjust column widths
    ws.column_dimensions['A'].width = 15
    ws.column_dimensions['B'].width = 15
    for col_idx in range(3, 3 + len(sorted_dates)):
        col_letter = ws.cell(1, col_idx).column_letter
        ws.column_dimensions[col_letter].width = 20

    # Save the workbook
    output_path = Path(output_file)
    wb.save(output_path)

    print(f"\n✓ Consolidation complete!")
    print(f"  Output file: {output_path}")
    print(f"  - {row_idx - 2} data rows")
    print(f"  - {len(sorted_dates)} date columns")

    return output_path


def main():
    """Main entry point."""
    if len(sys.argv) < 3:
        print("Usage: python merge_multiple_nr_summaries.py <output_file.xlsx> <input_file1.xlsx> <input_file2.xlsx>")
        print("\nExamples:")
        print("  python merge_multiple_nr_summaries.py consolidated.xlsx summary1.xlsx summary2.xlsx")
        print("  python merge_multiple_nr_summaries.py /path/to/output.xlsx /path/to/file1.xlsx /path/to/file2.xlsx")
        sys.exit(1)

    output_file = sys.argv[1]
    input_files = sys.argv[2:]

    merge_nr_summary_files(output_file, input_files)


if __name__ == "__main__":
    main()
