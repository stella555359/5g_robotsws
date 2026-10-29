import os
import taf.rfrl.utilities.logger.custom_logger as logger
import testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.common_operations as common_operations


def get_class_for_td(expected_dev, actual_dev, expected_tput):
    """
    Determines the CSS class for a table cell based on the deviation and expected throughput.

    Parameters:
    expected_dev (str): The expected deviation as a percentage string (e.g., "10%").
    actual_dev (float): The actual deviation as a float.
    expected_tput (str): The expected throughput as a string (e.g., "100 Mbits/sec").

    Returns:
    str: The CSS class for the table cell.
    """
    expected_dev = float(expected_dev.rstrip("%"))
    expected_tput_value = int(expected_tput.split(' ')[0])

    if expected_tput_value == 0:
        return "background-color: gray"
    elif not (100.0 - expected_dev <= actual_dev <= 100.0 + expected_dev):
        return "background-color: red"
    return "background-color: green"


def generate_html_file(tput_stats, path_to_json_file):
    """
    Generates an HTML file with throughput statistics.

    This method creates an HTML file containing a table with throughput statistics for each cell.
    It includes actual and expected throughput values for both downlink (DL) and uplink (UL) directions,
    along with their deviations.

    Parameters:
    tput_stats (dict): A dictionary containing throughput statistics for each cell.
    path_to_json_file (str): The path to the JSON file containing the throughput statistics.

    Returns:
    str: The generated HTML content as a string.
    """
    try:
        test_name = common_operations.get_test_case_name()
    except Exception:
        test_name = f"DT Transfer Stats for file {path_to_json_file}"

    html_file = (f'<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>{test_name}</title>'
                 '<meta name="viewport" content="width=device-width, initial-scale=1">'
                 '<style>table, th, td {border: 1px solid black;border-collapse: collapse; '
                 'margin-left: auto; margin-right: auto;}'
                 'body {text-align: center;}</style>'
                 '</head><body><div class="container"><h1>' + test_name + '</h1>'
                 '<table><tr>'
                 '<th>Cell ID</th>'
                 '<th>Actual Tput DL</th>'
                 '<th>Expected Tput DL</th>'
                 '<th>% DL</th>'
                 '<th>Actual Tput UL</th>'
                 '<th>Expected Tput UL</th>'
                 '<th>% UL</th>'
                 '</tr>')

    for cell, stats in tput_stats.items():
        dl_stats = stats.get('DL', {'actual_tput': '0', 'expected_tput': '0', 'deviation': '0', 'iperf_data': []})
        ul_stats = stats.get('UL', {'actual_tput': '0', 'expected_tput': '0', 'deviation': '0', 'iperf_data': []})

        dl_dev = round(common_operations.calculate_deviation(dl_stats), 2)
        ul_dev = round(common_operations.calculate_deviation(ul_stats), 2)

        dl_background = get_class_for_td(dl_stats["deviation"], dl_dev, dl_stats["expected_tput"])
        ul_background = get_class_for_td(ul_stats["deviation"], ul_dev, ul_stats["expected_tput"])

        html_file += (f'<tr>'
                      f'<td>{cell}</td>'
                      f'<td style="{dl_background}">{dl_stats["actual_tput"]} Mbits/sec</td>'
                      f'<td style="{dl_background}">{dl_stats["expected_tput"]}</td>'
                      f'<td style="{dl_background}">{dl_dev} %</td>'
                      f'<td style="{ul_background}">{ul_stats["actual_tput"]} Mbits/sec</td>'
                      f'<td style="{ul_background}">{ul_stats["expected_tput"]}</td>'
                      f'<td style="{ul_background}">{ul_dev} %</td>'
                      f'</tr>')
    end_of_file = '</div></body></html>'
    return html_file + end_of_file


def save_html_file(html_data, path_to_output_file=None, run_num='1'):
    """
    Saves the HTML data to a file.

    This method writes the provided HTML data to a file. If no output file path is provided,
    it generates a default path based on the test case name and run number.

    Parameters:
    html_data (str): The HTML content to be saved.
    path_to_output_file (str, optional): The path to the output HTML file. Defaults to None.
    run_num (str, optional): The run number to be included in the output file name. Defaults to '1'.

    Returns:
    None
    """
    if path_to_output_file is None:
        path_to_output_file = os.path.join(
            common_operations.get_output_dir_to_save_dt_data(),
            f"{common_operations.get_test_case_name()}_run_{run_num}.html"
        )

    with open(path_to_output_file, "w") as html_file:
        html_file.write(html_data)


def generate_html_thput_table(data_transfer_stats=None, path_to_json_file=None, path_to_output_file=None, run_num='1'):
    """
    Generates an HTML table with throughput statistics.

    This method processes data transfer statistics and generates an HTML file containing a table with throughput
    statistics for each cell.

    Parameters:
    data_transfer_stats (dict, optional): A dictionary containing data transfer statistics. Defaults to None.
    path_to_json_file (str, optional): The path to the JSON file containing the data transfer statistics.
                                       Defaults to None.
    path_to_output_file (str, optional): The path to the output HTML file. Defaults to None.
    run_num (str, optional): The run number to be included in the output file name. Defaults to '1'.

    Returns:
    None
    """
    if path_to_json_file:
        data_transfer_stats = common_operations.load_data_from_json_file(path_to_json_file)

    if not data_transfer_stats:
        logger.log_warn_to_console('No data transfer statistics provided to save in HTML.')
        return

    if path_to_output_file:
        path_to_output_file += f"_DT_stats_run_{run_num}.html"

    matched_cells = common_operations.convert_data_transfer_stats(data_transfer_stats)
    html_file = generate_html_file(matched_cells, path_to_json_file)
    save_html_file(html_file, path_to_output_file, run_num)
