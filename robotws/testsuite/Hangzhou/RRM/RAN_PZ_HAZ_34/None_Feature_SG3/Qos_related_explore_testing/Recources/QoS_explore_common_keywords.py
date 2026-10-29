import pandas as pd
from typing import List


def insert_value_to_specific_sheet(excel_file: str,
                                   target_sheet: str,
                                   insert_column: int,
                                   column_data: List,
                                   column_name: str):
    """
    Args:
        excel_file: excel file name
        target_sheet: the sheet required to insert value
        insert_column: insert column(start from 0)
        column_data: insert values list to new column
        column_name: new column name

    Returns:

    """
    # read all sheets
    all_sheets = pd.read_excel(excel_file, sheet_name=None)
    # new data
    new_sheets = {}
    # handle all sheets
    for sheet_name, df in all_sheets.items():
        if sheet_name == target_sheet:
            # check length of data
            if len(column_data) != len(df):
                if len(column_data) < len(df):
                    column_data.extend([None] * (len(df) - len(column_data)))
                else:
                    column_data = column_data[: len(df)]
            # insert value to specific sheet
            df.insert(insert_column, column_name, column_data)
            print(f"insert column {column_name} to column {insert_column + 1} of sheet {sheet_name}")
        else:
            print(f"data of sheet '{sheet_name}' keep same")
        new_sheets[sheet_name] = df

    # write new data to excel
    with pd.ExcelWriter(path=excel_file, engine="openpyxl") as writer:
        for sheet_name, df in new_sheets.items():
            df.to_excel(writer, sheet_name=sheet_name, index=False)

    return new_sheets


def compare_results_with_last_time(excel_file: str,
                                   target_sheet: str,
                                   compare_column: int = 1,
                                   current_column: int = 2):
    """
    Args:
        excel_file: excel file name
        target_sheet: the sheet required to read data
        compare_column: the int num of required compare column
        current_column: the int num of current compare column

    Returns:

    """
    compare_columns = [compare_column, current_column]
    df = pd.read_excel(io=excel_file, sheet_name=target_sheet, usecols=compare_columns)
    compare_columns_results = [df.iloc[:, 0].tolist(), df.iloc[:, 1].tolist()]
    print(compare_columns_results)

    return compare_columns_results
