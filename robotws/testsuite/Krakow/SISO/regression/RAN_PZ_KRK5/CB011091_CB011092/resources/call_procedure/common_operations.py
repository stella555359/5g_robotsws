import os
import json
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK5.CB011091_CB011092.resources.call_procedure.call_tmp_vars \
    import deviation_per_cell_type
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK5.CB011091_CB011092.resources.call_procedure.call_exceptions \
    import DataTransferStatsFileNotFound


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


def get_output_dir():
    return BuiltIn().get_variable_value("${OUTPUT DIR}")


def get_output_dir_to_save_dt_data():
    return create_dt_dir(get_output_dir() + "/DT_stats/")


def get_output_dir_to_save_dt_jsons():
    return create_dt_dir(get_output_dir_to_save_dt_data() + "/DT_jsons/")


def create_dt_dir(path_to_dir):
    if not os.path.exists(path_to_dir):
        os.mkdir(path_to_dir)
    return path_to_dir


def get_proper_deviation(deviation, cell, auto_dev):
    if deviation is None or auto_dev is True:
        cell_type, x = cell.split('CEL')
        return deviation_per_cell_type[cell_type], True
    return deviation, False


def save_data_to_json(data, run_num, filepath=get_output_dir_to_save_dt_jsons(), filename=None):
    if filename is None:
        filename = f"{get_test_case_name()}_{run_num}.json"

    full_path = os.path.join(filepath, filename)
    print(f"[mizajac]  {full_path}")

    if os.path.exists(full_path):
        with open(full_path, 'r') as file:
            existing_data = json.load(file)

        existing_data.update(data)
        # print("[mizajac] nadpisuje jsona")
        # existing_data = data

        with open(full_path, 'w') as file:
            json.dump(existing_data, file)
    else:
        with open(full_path, 'w') as file:
            json.dump(data, file)
