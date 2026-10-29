from openpyxl import load_workbook
from openpyxl.styles import PatternFill
import argparse
import os
import json
import datetime
import re

import numpy as np
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots


class CompareKPI(object):
    """
    A class to compare KPI data for a specific run by reading and summarizing feature ON and OFF data.

    Attributes:
    __run_number (str): The run number identifier.
    __feat_on_path (str): The file path to the feature ON KPI data.
    __feat_off_path (str): The file path to the feature OFF KPI data.
    __feat_on_kpi_df (DataFrame): DataFrame to store the feature ON KPI data.
    __feat_off_kpi_df (DataFrame): DataFrame to store the feature OFF KPI data.
    __summarized_df (DataFrame): DataFrame to store the summarized KPI data for the run.
    """

    def __init__(self, run_number, feat_on_path, feat_off_path):
        """
        Initializes the CompareKPI object with the provided run number and file paths.

        Parameters:
        run_number (str): The run number identifier.
        feat_on_path (str): The file path to the feature ON KPI data.
        feat_off_path (str): The file path to the feature OFF KPI data.
        """
        self.__run_number = run_number
        self.__feat_on_path = feat_on_path
        self.__feat_off_path = feat_off_path
        self.__feat_on_kpi_df = None
        self.__feat_off_kpi_df = None
        self.__summarized_df = None

    def __read_lte_pat_output(self):
        """
        Reads the LTE PAT output from the provided file paths and stores the data in DataFrames.
        """
        # Read the feature ON KPI data from the specified Excel file and sheet
        self.__feat_on_kpi_df = pd.read_excel(self.__feat_on_path, sheet_name="System KPIs")
        self.__feat_on_kpi_df = self.__feat_on_kpi_df[self.__feat_on_kpi_df["StartDate"] == "System Level"].T.drop(
            index=["StartTime", "StartDate"])
        self.__feat_on_kpi_df.columns = ["ON"]

        # Read the feature OFF KPI data from the specified Excel file and sheet
        self.__feat_off_kpi_df = pd.read_excel(self.__feat_off_path, sheet_name="System KPIs")
        self.__feat_off_kpi_df = self.__feat_off_kpi_df[self.__feat_off_kpi_df["StartDate"] == "System Level"].T.drop(
            index=["StartTime", "StartDate"])
        self.__feat_off_kpi_df.columns = ["OFF"]

    def get_summarized_kpi_per_run(self):
        """
        Summarizes the KPI data for the run by merging the feature ON and OFF DataFrames.

        Returns:
        DataFrame: The summarized KPI data for the run with prefixed column names.
        """
        # Read the LTE PAT output data
        self.__read_lte_pat_output()

        # Merge the feature ON and OFF DataFrames on their indices
        self.__summarized_df = self.__feat_on_kpi_df.merge(
            self.__feat_off_kpi_df, left_index=True, right_index=True, how="outer")

        # Add a prefix to the column names based on the run number
        self.__summarized_df = self.__summarized_df.add_prefix(f'{self.__run_number}_')

        # Return the summarized DataFrame
        return self.__summarized_df


def get_mapped_df(pgm_kpi_path, all_run_summary_df):
    """
    Map the run summary DataFrame with the program KPI DataFrame by mapping and merging KPI IDs.

    Parameters:
    pgm_kpi_path (str): The file path to the program KPI data in an Excel file.
    all_run_summary_df (DataFrame): The DataFrame containing summarized KPI data for all runs.

    Returns:
    DataFrame: The consolidated DataFrame with mapped and merged KPI IDs.
    """
    # Read the program KPI data from the specified Excel file and sheet
    pgm_kpi_df = pd.read_csv(pgm_kpi_path)

    # Get the index list from the run summary DataFrame
    run_idx_list = all_run_summary_df.index

    # Get the KPI IDs from the program KPI DataFrame
    pgm_short_idx_list = pgm_kpi_df["KPI IDs"]

    # Map short index to long index where short index is a substring of long index
    all_run_summary_df["pgm_kpi_ids"] = run_idx_list.map(lambda x: next((i for i in pgm_short_idx_list if i in x),
                                                                        None))

    # Reset the index of the run summary DataFrame
    all_run_summary_df.reset_index(inplace=True)

    # Merge the run summary DataFrame with the program KPI DataFrame on the mapped KPI IDs
    mapped_df = all_run_summary_df.merge(pgm_kpi_df, left_on="pgm_kpi_ids", right_on="KPI IDs",
                                         how="outer").rename(columns={"index": "run_kpi_ids"})
    mapped_df = mapped_df[~mapped_df["run_kpi_ids"].isna()]
    unit_pattern = r"(\([^\(\)]*(?:\([^\(\)]*\))*[^\(\)]*\))$"
    # Apply regex to extract KPI unit
    mapped_df["kpi_unit"] = mapped_df["run_kpi_ids"].astype(str).apply(lambda x: re.findall(unit_pattern, x)[-1]
                                                                       if re.findall(unit_pattern, x) else None)
    # Return the consolidated DataFrame
    return mapped_df


def get_comparison_df(pgm_vs_run_df, feat_on_col_list, feat_off_col_list):
    """
    Generates a comparison DataFrame by calculating averages and differences for ON and OFF feature columns.

    Parameters:
    pgm_vs_run_df (DataFrame): The input DataFrame containing KPI data for both program and runs.
    feat_on_col_list (list):   A list of column names representing the ON features
                               of the format [<run_id1>_ON, <run_id2>_ON, ...]
    feat_off_col_list (list):  A list of column names representing the OFF features
                               of the format [<run_id1>_OFF, <run_id2>_OFF, ...]

    Returns:
    DataFrame: The modified DataFrame with additional columns for ON average, OFF average,
               Difference between ON_average and OFF_average, and % Difference.
    """

    # Calculate the average values for the ON feature columns
    pgm_vs_run_df.loc[:, "ON_average"] = pgm_vs_run_df[feat_on_col_list].mean(axis=1, skipna=True)

    # Calculate the average values for the OFF feature columns
    pgm_vs_run_df.loc[:, "OFF_average"] = pgm_vs_run_df[feat_off_col_list].mean(axis=1, skipna=True)

    # Calculate the difference between OFF average and ON average
    pgm_vs_run_df.loc[:, "Difference"] = pgm_vs_run_df["ON_average"].fillna(0) - pgm_vs_run_df["OFF_average"].fillna(0)

    pgm_vs_run_df.loc[:, '% Difference'] = pgm_vs_run_df.apply(
        lambda row: np.nan if pd.isna(row['OFF_average']) or row['OFF_average'] == 0
        else (row["Difference"] / row['OFF_average']) * 100,
        axis=1
    )

    # Return the modified DataFrame with the new columns
    return pgm_vs_run_df


def get_summarized_kpi(pgm_kpi_path, runs_json, output_path):
    """
    Summarizes KPI data for multiple runs with feature ON/OFF scenario and consolidates it
    into a final comparison DataFrame.

    Parameters:
    pgm_kpi_path (str): The file path to the program provided KPI data.
    run_list (list): A list of tuples, where each tuple contains arguments for a run.
                     Each tuple should have three elements: (run_id,
                     SystemLevel_KPIs.xlsx from LTEPAT tool of ON scenario,
                     SystemLevel_KPIs.xlsx from LTEPAT tool of OFF scenario).
    output_path (str): The file path where the final summarized KPI data will be saved as a CSV file.

    Returns:
    None: The function saves the final summarized KPI data to the specified output path.
    """
    # Initialize variables to store the summary DataFrame and feature column lists
    all_run_summary_df = None
    feat_on_col_list = []
    feat_off_col_list = []

    with open(runs_json) as f:
        runs_to_be_compared = json.load(f)

    # Iterate through each run in the run list
    for run_id, feat_on_kpi_file, feat_off_kpi_file in runs_to_be_compared:
        # Append feature ON and OFF column names to respective lists
        feat_on_col_list.append(f'{run_id}_ON')
        feat_off_col_list.append(f'{run_id}_OFF')

        # Create a CompareKPI object with the provided run arguments
        kpi_obj = CompareKPI(run_id, feat_on_kpi_file, feat_off_kpi_file)

        # Get the summarized KPI DataFrame for the current run
        summary_per_run__df = kpi_obj.get_summarized_kpi_per_run()

        # If this is the first run, initialize the all_run_summary_df with the current run's summary
        if all_run_summary_df is None:
            all_run_summary_df = summary_per_run__df.copy()
        else:
            # Merge the current run's summary with the existing summary DataFrame
            all_run_summary_df = all_run_summary_df.merge(summary_per_run__df, left_index=True,
                                                          right_index=True, how="outer")

    # Get the consolidated DataFrame by comparing the program KPI path with the summarized run DataFrame
    pgm_vs_run_df = get_mapped_df(pgm_kpi_path, all_run_summary_df)

    # Get the final comparison DataFrame using the consolidated DataFrame and feature column lists
    final_df = get_comparison_df(pgm_vs_run_df, feat_on_col_list, feat_off_col_list)

    # Save the final comparison DataFrame to the specified output path as a CSV file
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    output_excel_file = os.path.join(output_path, f'kpi_comparison_result_{timestamp}.xlsx')
    html_report_file = os.path.join(output_path, f'kpi_report_{timestamp}.html')
    final_df.to_excel(output_excel_file, index=False)
    final_df["expected_effect"] = np.where(
        # case when "KPI value impact expected from feature" is 'yes' and 'Positive KPI trend' is blank
        final_df['Positive KPI trend'].isna(), '<span style="color:green;">▲▼</span>',
        np.where((final_df['KPI value impact expected from feature'].str.contains(
            'yes', case=False, na=False))
                 & (final_df['Positive KPI trend'] == 'Increase'),
                 '<span style="color:green;">▲</span>',
                 np.where(
                     (final_df['KPI value impact expected from feature'].str.contains('yes', case=False, na=False))
                     & (final_df['Positive KPI trend'] == 'Decrease'), '<span style="color:green;">▼</span>',
                     '❌'  # Default case when "KPI value impact expected from feature" is 'no'
                 )
                 ))

    prepare_data_visualization(final_df, feat_on_col_list, feat_off_col_list, html_report_file)
    apply_formatting_excel(output_excel_file)


def prepare_data_visualization(final_df, feat_on_col_list, feat_off_col_list, html_report_file):
    # Filter columns if ON_average = 0 or blank to remove the KPIs that are not triggered
    final_df = final_df[~final_df['ON_average'].isna()]
    final_df.set_index('run_kpi_ids', inplace=True)
    expected_trend_series = final_df['expected_effect']
    final_df = final_df.apply(pd.to_numeric, errors='coerce').round(2)

    # Format feature ON KPIs
    cleaned_on_df = final_df[feat_on_col_list].T
    cleaned_on_df.index = cleaned_on_df.index.str.rstrip('_ON')

    # Format feature OFF KPIs
    cleaned_off_df = final_df[feat_off_col_list].T
    cleaned_off_df.index = cleaned_off_df.index.str.rstrip('_OFF')  # remove suffix from run ids

    plot_figures(cleaned_on_df, cleaned_off_df, expected_trend_series, html_report_file)


def plot_figures(df_on, df_off, expected_trend_series, html_report_file):
    # Descriptive statistics
    df_describe_on = df_on.describe()
    df_describe_off = df_off.describe()

    # Create figure with two subplots
    fig = make_subplots(rows=2, cols=2, specs=[[{"secondary_y": False}, {"type": "domain"}],
                                               [{"secondary_y": False}, {"type": "domain"}]],
                        subplot_titles=("Line Chart", "Data Table", "Box Plot"))

    # Initial column selection
    first_col = df_on.columns[0]

    # Add scatter plot traces
    scatter_on = go.Scatter(x=df_on.index, y=df_on[first_col], mode='lines+markers', name='Feature ON')
    scatter_off = go.Scatter(x=df_off.index, y=df_off[first_col], mode='lines+markers', name='Feature OFF')
    fig.add_trace(scatter_on, row=1, col=1)
    fig.add_trace(scatter_off, row=1, col=1)

    # Calculate QSM and add traces
    qsm_on = np.sqrt(np.mean(df_on[first_col] ** 2))
    qsm_off = np.sqrt(np.mean(df_off[first_col] ** 2))
    qsm_on_y = [qsm_on] * len(df_on.index)
    qsm_off_y = [qsm_off] * len(df_off.index)
    qsm_on_trace = go.Scatter(x=df_on.index, y=qsm_on_y, mode='lines', name='QSM ON',
                              line=dict(color='blue', dash='dash'))
    qsm_off_trace = go.Scatter(x=df_off.index, y=qsm_off_y, mode='lines', name='QSM OFF',
                               line=dict(color='red', dash='dash'))
    fig.add_trace(qsm_on_trace, row=1, col=1)
    fig.add_trace(qsm_off_trace, row=1, col=1)

    # Add box plot traces
    box_on_trace = go.Box(y=df_on[first_col], name='Feature ON', boxpoints='all', jitter=0.3, pointpos=-1.8,
                          fillcolor="lightblue", marker_color="blue")
    fig.add_trace(box_on_trace, row=2, col=1)
    box_off_trace = go.Box(y=df_off[first_col], name='Feature OFF', boxpoints='all', jitter=0.3, pointpos=-1.8,
                           fillcolor="lightsalmon", marker_color="red")
    fig.add_trace(box_off_trace, row=2, col=1)

    # Create table traces
    table_trace_1 = go.Table(
        header=dict(values=['Run', 'Feature ON', 'Feature OFF', 'Differences', "% Diff"]),
        cells=dict(values=[
            df_on.index.tolist(),
            df_on[first_col].round(2).tolist(),
            df_off[first_col].round(2).tolist(),
            (df_on[first_col] - df_off[first_col]).round(2).tolist(),
            (((df_on[first_col] - df_off[first_col])/df_off[first_col].abs())*100.0).round(2).tolist()
        ])
    )
    fig.add_trace(table_trace_1, row=1, col=2)

    # Create dropdown buttons
    dropdown_buttons = [
        {
            'label': col,
            'method': 'update',
            'args': [
                {
                    'y': [
                        df_on[col],
                        df_off[col],
                        [np.sqrt(np.mean(df_on[col] ** 2))] * len(df_on.index),
                        [np.sqrt(np.mean(df_off[col] ** 2))] * len(df_off.index)
                    ],
                    'cells': {
                        'values': [
                            df_on.index.tolist(),
                            df_on[col].round(2).tolist(),
                            df_off[col].round(2).tolist(),
                            (df_on[col] - df_off[col]).round(2).tolist(),
                            (((df_on[col] - df_off[col])/df_off[col].abs())*100.0).round(2).tolist()
                        ]
                    }
                },
                {
                    'title.text': f'Feature ON vs OFF - {col} {expected_trend_series[col]}'
                }
            ]
        }
        for col in df_on.columns
    ]

    # Add dropdown menu
    fig.update_layout(
        updatemenus=[{
            'buttons': dropdown_buttons,
            'direction': 'down',
            'showactive': True,
            'x': 0.25,  # Start at 25% of the page width
            'xanchor': 'left',
            'y': 1.15,
            'yanchor': 'top',
            'pad': {'r': 10, 't': 10},
            'borderwidth': 0.5  # 50% of the page width
        }],
        title='KPI Chart',
        xaxis_title='Runs',
        yaxis_title='Values',
        xaxis=dict(tickmode='linear', dtick=1)
    )

    # Show and save the plot
    fig.show()
    fig.write_html(html_report_file)
    print(f'HTML Report location: {html_report_file}')


def apply_formatting_excel(output_excel_file):
    wb = load_workbook(output_excel_file)
    ws = wb.active  # Select the active sheet

    # Step 4: Define conditional formatting colors
    red_fill = PatternFill(start_color="FF9999", end_color="FF9999", fill_type="solid")  # Light Red
    yellow_fill = PatternFill(start_color="FFFF99", end_color="FFFF99", fill_type="solid")  # Light Yellow
    green_fill = PatternFill(start_color="99FF99", end_color="99FF99", fill_type="solid")  # Light Green

    # Step 5: Find column letter by name (e.g., "output_excel_file")
    percentage_diff_col_name = "% Difference"
    percentage_diff_col_index = None

    diff_col_name = "Difference"
    diff_col_index = None

    pgm_kpi_trend_expectation_col_name = "Positive KPI trend"
    pgm_kpi_trend_expectation_col_index = None

    on_avg_col_name = "ON_average"
    on_avg_col_index = None

    off_avg_col_name = "OFF_average"
    off_avg_col_index = None

    for col in ws.iter_cols(min_row=1, max_row=1):  # Iterate through the header row
        for cell in col:
            if cell.value == percentage_diff_col_name:
                percentage_diff_col_index = cell.column_letter
            elif cell.value == diff_col_name:
                diff_col_index = cell.column_letter
            elif cell.value == pgm_kpi_trend_expectation_col_name:
                pgm_kpi_trend_expectation_col_index = cell.column_letter
            elif cell.value == on_avg_col_name:
                on_avg_col_index = cell.column_letter
            elif cell.value == off_avg_col_name:
                off_avg_col_index = cell.column_letter

    # Step 6: Apply conditional formatting if column found
    if percentage_diff_col_index:
        # Apply conditional formatting with absolute values logic
        for row in range(2, ws.max_row + 1):

            # --------- check for % Difference with different threshold bins  START #
            percentage_diff_cell = ws[f"{percentage_diff_col_index}{row}"]
            if percentage_diff_cell.value is not None:
                abs_value = abs(percentage_diff_cell.value)  # Get the absolute value of the cell content
                if abs_value > 10:
                    percentage_diff_cell.fill = red_fill
                elif 5 <= abs_value <= 10:
                    percentage_diff_cell.fill = yellow_fill
                else:
                    percentage_diff_cell.fill = green_fill
            # --------- check for % Difference with different threshold bins  END #

            # --------- check for Difference with Positive KPI trend - START #
            trend_exp_cell = ws[f"{pgm_kpi_trend_expectation_col_index}{row}"]
            diff_cell = ws[f"{diff_col_index}{row}"]
            on_avg_cell = ws[f"{on_avg_col_index}{row}"]
            off_avg_cell = ws[f"{off_avg_col_index}{row}"]
            if ((trend_exp_cell.value is not None) and (diff_cell.value is not None) and
                    (trend_exp_cell.value.lower() != 'not applicable')):
                # values from both feat ON and feat OFF shall be non-zero, i.e., PMCs are triggered
                if on_avg_cell.value != 0 and off_avg_cell.value != 0:
                    if ((trend_exp_cell.value.lower() == 'increase' and diff_cell.value > 0) or
                            (trend_exp_cell.value.lower() == 'decrease' and diff_cell.value < 0)):
                        diff_cell.fill = green_fill  # ✅ Correct condition → Green
                    else:
                        diff_cell.fill = red_fill  # ❌ Incorrect condition → Red
            # --------- check for Difference with Positive KPI trend - END #

    # Add Legends
    legend_col = ws.max_column + 2
    legend_start_row = 2
    # Add legend labels for "Difference"
    ws.cell(row=1, column=legend_col, value="Legend for Difference:")
    ws.cell(row=legend_start_row, column=legend_col,
            value="✅ Positive KPI trend and Difference shall be aligned i.e., if former has increase or decrease, "
                  "the latter shall have a positive or negative value respectively."
            ).fill = green_fill
    ws.cell(row=legend_start_row + 1, column=legend_col, value="❌ If otherwise (Red)"
            ).fill = red_fill

    # Add legend labels for "% Difference"
    ws.cell(row=legend_start_row + 3, column=legend_col, value="Legend for % Difference:")
    ws.cell(row=legend_start_row + 4, column=legend_col, value="Absolute % difference is <5% ").fill = green_fill
    ws.cell(row=legend_start_row + 5, column=legend_col, value="Absolute % difference is >5% and <10% "
            ).fill = yellow_fill
    ws.cell(row=legend_start_row + 6, column=legend_col, value="Absolute % difference is >10% ").fill = red_fill

    # Step 7: Save the updated Excel file
    wb.save(output_excel_file)
    print(f'Result location: {output_excel_file}')


if __name__ == '__main__':

    # Create ArgumentParser object
    parser = argparse.ArgumentParser(description="Consolidates different feature ON and OFF KPI output.  Provides "
                                                 "comparison in the output file.")

    # Define two arguments for file paths
    parser.add_argument("-p", "--program_kpi_file", type=str, required=True,
                        help="Path to the list of KPIs in the csv file.  It shall contain 3 columns: \"KPI IDs\", "
                             "\"Positive KPI trend\" and \"KPI value impact expected from feature\" "
                             "Example: testsuite/Ulm/ET/CB013392/CB013392-E/"
                             "configurations/cb013392_program_kpi_list.csv")
    parser.add_argument("-i", "--input_json", required=True, type=str,
                        help="Path to the input JSON file that has the list of[<run_id>, "
                             "<SystemLevel_KPIs.xlsx file path from LTEPAT output with Feature ON>, "
                             "<SystemLevel_KPIs.xlsx file path from LTEPAT output feature OFF>]"
                             "Example: testsuite/Ulm/ET/CB013392/CB013392-E/"
                             "configurations/compare_cb013392_kpi.json")
    parser.add_argument("-o", "--output_path", type=str, help="Path to store the output file")

    # Parse the arguments
    args = parser.parse_args()
    output_path = os.getcwd()

    # Validate if the input file exists
    if not os.path.isfile(args.program_kpi_file):
        print(f"Error: Program KPI file '{args.program_kpi_file}' does not exist.")
        exit(1)

    if not os.path.isfile(args.input_json):
        print(f"Error: Input JSON file '{args.input_json}' does not exist.")
        exit(1)

    if not args.output_path:
        print(f'Output will be stored in: {output_path}')
    elif not os.path.exists(args.output_path):
        os.makedirs(args.output_path)
        output_path = args.output_path
    get_summarized_kpi(args.program_kpi_file, args.input_json, output_path)
