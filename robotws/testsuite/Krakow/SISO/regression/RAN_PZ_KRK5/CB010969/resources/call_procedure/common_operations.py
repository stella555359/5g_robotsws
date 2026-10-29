import os
import json
from robot.libraries.BuiltIn import BuiltIn
from call_exceptions import DataTransferStatsFileNotFound


def find_matching_cells_and_match(data_transfer_stats):
    parsed_cells = {}
    for cell in data_transfer_stats:
        if "rerun" not in cell:
            cell_id, data_direction, index_run = cell.rsplit("_", 2)
            cell_id = f"{cell_id}_{index_run}"
        else:
            cell_id, data_direction, index_run, rerun = cell.rsplit("_", 3)
            cell_id = f"{cell_id}_{index_run}_{rerun}"
        if cell_id not in parsed_cells:
            parsed_cells[cell_id] = {}
        parsed_cells[cell_id].update({data_direction: data_transfer_stats[cell]})
    return parsed_cells


def load_data_from_json_file(path_to_json_file):
    if os.path.isfile(path_to_json_file):
        with open(path_to_json_file) as json_file:
            file = json.load(json_file)
            return file
    else:
        raise DataTransferStatsFileNotFound(f"Cannot find file in provided path {path_to_json_file}")


def calculate_deviation(cell_data):
    return float(cell_data['actual_tput']) / float(cell_data['expected_tput'].split(" ")[0]) * 100


def get_test_case_name():
    return BuiltIn().get_variable_value("${TEST NAME}")


def get_output_dir_to_save_dt_data():
    return create_dt_dir(BuiltIn().get_variable_value("${OUTPUT DIR}") + "/DT_stats/")


def get_output_dir_to_save_dt_jsons():
    return create_dt_dir(get_output_dir_to_save_dt_data() + "//DT_jsons")


def create_dt_dir(path_to_dir):
    if not os.path.exists(path_to_dir):
        os.mkdir(path_to_dir)
    return path_to_dir
