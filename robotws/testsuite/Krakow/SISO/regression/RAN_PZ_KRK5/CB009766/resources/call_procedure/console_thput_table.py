import json
import os
from call_tmp_vars import data_transfer_statistics
import taf.rfrl.utilities.logger.custom_logger as logger
from prettytable import PrettyTable
from robot.libraries.BuiltIn import BuiltIn
from common_operations import find_matching_cells_and_match, calculate_deviation, load_data_from_json_file


RED = "\033[0;31;40m"
GREEN = "\033[0;32;40m"
DEFAULT = "\033[0m"


def get_test_case_name():
    return BuiltIn().get_variable_value("${TEST NAME}")


def get_log_file():
    return BuiltIn().get_variable_value("${LOG FILE}")


def get_output_dir():
    return BuiltIn().get_variable_value("${OUTPUT DIR}")


def calculate_deviations(cell_data):
    if cell_data['UL']['deviation'] != cell_data['DL']['deviation']:
        raise ValueError("Inconsistent deviations")
    else:
        deviation = 100 - int(cell_data['DL']['deviation'].split("%")[0])

    value_dl = calculate_deviation(cell_data['DL'])
    value_ul = calculate_deviation(cell_data['UL'])

    print(deviation, value_dl, value_ul)
    if value_dl > deviation and value_ul > deviation:
        color = GREEN
    else:
        color = RED

    return value_dl, value_ul, color


def generate_console_thput_table(data=data_transfer_statistics, title=None):
    table = PrettyTable()
    if title:
        table.title = title
    else:
        table.title = get_test_case_name()

    table.field_names = ["Cell ID", "actual / expected thput DL", "actual / expected thput UL", "DL / UL deviation"]
    data = find_matching_cells_and_match(data)

    for cell in data:
        cell_data = data[cell]
        deviation_dl, deviation_ul, color = calculate_deviations(cell_data)

        table.add_row([
            f"{color} {cell}",
            f"{cell_data['DL']['actual_tput']} / {cell_data['DL']['expected_tput']}",
            f"{cell_data['UL']['actual_tput']} / {cell_data['UL']['expected_tput']}",
            f"{deviation_dl:.2f} / {deviation_ul:.2f} {DEFAULT}",
        ],
        )

    logger.log_info_to_console(f"\n{table}")


def generate_console_table_from_files(path_to_jsons_dir):
    files = os.listdir(path_to_jsons_dir)
    logger.log_info_to_console(f"In path {path_to_jsons_dir}, found files: {files}")

    for file in files:
        logger.log_info_to_console(f"Generating console table from file {file}")
        data = load_data_from_json_file(os.path.join(path_to_jsons_dir, file))
        generate_console_thput_table(data=data, title=file)
