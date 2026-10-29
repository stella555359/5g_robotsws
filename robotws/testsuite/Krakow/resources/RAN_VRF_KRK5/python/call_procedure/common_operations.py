import json
import os
import taf.rfrl.utilities.logger.custom_logger as logger
from prettytable import PrettyTable
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.call_exceptions \
    import DataTransferStatsFileNotFound, IncorrectTrafficMatrix


def convert_data_transfer_stats(data_transfer_stats):
    """
    Finds and matches cells based on data transfer statistics.

    This method processes the provided `data_transfer_stats` to group and match cells by their identifiers,
    data direction, and run index. It handles both regular and rerun cases.

    Parameters:
    data_transfer_stats (dict): A dictionary containing data transfer statistics with cell identifiers as keys.

    Returns:
    dict: A dictionary where keys are cell identifiers and values are dictionaries with data directions as keys.
    """
    converted_stats = {}
    for dt_name, dt_stats in data_transfer_stats.items():
        att = None
        if "att" in dt_name:
            dt_name, att = dt_name.rsplit("_", 1)
        if "rerun" not in dt_name:
            cell_id, data_direction, index_run = dt_name.rsplit("_", 2)
            cell_id = f"{cell_id}_{index_run}"
        else:
            cell_id, data_direction, index_run, rerun = dt_name.rsplit("_", 3)
            cell_id = f"{cell_id}_{index_run}_{rerun}"
        if att:
            cell_id += f'_{att}'
        if cell_id not in converted_stats:
            converted_stats[cell_id] = {}
        converted_stats[cell_id].update({data_direction: dt_stats})
    return converted_stats


def load_data_from_json_file(path_to_json_file):
    """
    Loads data from a JSON file.

    This method checks if the specified JSON file exists at the given path. If the file exists,
    it reads and parses the JSON content and returns it as a dictionary. If the file does not exist,
    it raises a DataTransferStatsFileNotFound exception.

    Parameters:
    path_to_json_file (str): The path to the JSON file to be loaded.

    Returns:
    dict: The parsed JSON content as a dictionary.

    Raises:
    DataTransferStatsFileNotFound: If the JSON file is not found at the specified path.
    """
    if os.path.isfile(path_to_json_file):
        with open(path_to_json_file) as json_file:
            file = json.load(json_file)
            return file
    else:
        raise DataTransferStatsFileNotFound(f"Cannot find file in provided path {path_to_json_file}")


def calculate_deviation(cell_data):
    """
    Calculates the deviation percentage of actual throughput from expected throughput for a given cell.

    This method computes the deviation by dividing the actual throughput by the expected throughput
    and multiplying the result by 100 to get the percentage.

    Parameters:
    cell_data (dict): A dictionary containing 'actual_tput' and 'expected_tput' keys with their respective values.

    Returns:
    float: The deviation percentage of actual throughput from expected throughput.
    """
    if cell_data['expected_tput'].split(" ")[0] == '0':
        return 0
    return float(cell_data['actual_tput']) / float(cell_data['expected_tput'].split(" ")[0]) * 100


def get_test_case_name():
    """
    Retrieves the name of the current test case.

    This method uses the Robot Framework's BuiltIn library to get the value of the `${TEST NAME}` variable,
    which contains the name of the currently executing test case.

    Returns:
    str: The name of the current test case.
    """
    return BuiltIn().get_variable_value("${TEST NAME}")


def get_output_dir():
    """
    Retrieves the output directory path.

    This method uses the Robot Framework's BuiltIn library to get the value of the `${OUTPUT DIR}` variable,
    which contains the path to the output directory.

    Returns:
    str: The path to the output directory.
    """
    return BuiltIn().get_variable_value("${OUTPUT DIR}")


def get_output_dir_to_save_dt_data():
    """
    Retrieves the directory path to save data transfer statistics.

    This method constructs the path to the directory where data transfer statistics (DT stats) should be saved.
    It uses the output directory and appends the 'DT_stats' subdirectory to it. If the directory does not exist,
    it creates it.

    Returns:
    str: The path to the directory for saving data transfer statistics.
    """
    return create_dt_dir(get_output_dir() + "/DT_stats/")


def get_output_dir_to_save_dt_jsons():
    """
    Retrieves the directory path to save data transfer JSON files.

    This method constructs the path to the directory where data transfer JSON files should be saved.
    It uses the directory path for saving data transfer statistics and appends the 'DT_jsons' subdirectory to it.
    If the directory does not exist, it creates it.

    Returns:
    str: The path to the directory for saving data transfer JSON files.
    """
    return create_dt_dir(get_output_dir_to_save_dt_data() + "/DT_jsons/")


def create_dt_dir(path_to_dir):
    """
    Creates a directory if it does not already exist.

    This method checks if the specified directory exists at the given path. If the directory does not exist,
    it creates the directory.

    Parameters:
    path_to_dir (str): The path to the directory to be created.

    Returns:
    str: The path to the directory.
    """
    if not os.path.exists(path_to_dir):
        os.mkdir(path_to_dir)
    return path_to_dir


def save_data_to_json(data, run_num, filepath=get_output_dir_to_save_dt_jsons(), filename=None):
    """
    Saves data to a JSON file.

    This method saves the provided `data` to a JSON file. If a file with the same name already exists,
    it updates the existing file with the new data. If no filename is provided, it generates a filename
    based on the current test case name and the run number.

    Parameters:
    data (dict): The data to be saved to the JSON file.
    run_num (int): The run number to be included in the filename.
    filepath (str, optional): The path to the directory where the JSON file will be saved. Defaults to the output
                              directory for saving DT JSONs.
    filename (str, optional): The name of the JSON file. If not provided, a default name is generated.

    Returns:
    None
    """
    if filename is None:
        filename = f"{get_test_case_name()}_{run_num}.json"

    full_path = os.path.join(filepath, filename)

    if os.path.exists(full_path):
        with open(full_path, 'r') as file:
            existing_data = json.load(file)

        existing_data.update(data)

        with open(full_path, 'w') as file:
            json.dump(existing_data, file)
    else:
        with open(full_path, 'w') as file:
            json.dump(data, file)


def verify_if_element_belongs_to_list(element, elements_list):
    """
    Checks if an element belongs to a given list.

    This method verifies whether the specified `element` is present in the `elements_list`.

    Parameters:
    element (any): The element to be checked in the list.
    elements_list (list): The list in which the element is searched.

    Returns:
    bool: True if the element is found in the list, False otherwise.
    """
    if element in elements_list:
        return True
    return False


def traffic_matrix_validator(traffic_matrix, cells_list, bidirect):
    """
    Validates the structure and content of a traffic matrix.

    This method checks the provided `traffic_matrix` for mandatory keys and validates the structure
    and content of each cell and its attributes. It ensures that the necessary keys.

    Parameters:
    traffic_matrix (dict): A dictionary representing the traffic matrix with cell configurations.
    cells_list (list): A list of cell identifiers that should be verified in the traffic matrix.
    bidirect (bool): A flag indicating whether bidirectional throughput would be run in test.

    Raises:
    IncorrectTrafficMatrix: If the traffic matrix structure or content is incorrect.
    """
    def check_mandatory_keys(mandatory_keys, data, context):
        for key in mandatory_keys:
            if key not in data:
                faults.append(f'Mandatory `{key}` key is missing {context}.')

    def check_cell_keys(cell_name, context):
        check_mandatory_keys(mandatory_keys=cell_mandatory_keys, data=traffic_matrix[cell_name], context=context)
        if bidirect:
            if 'UL' not in traffic_matrix[cell_name] or 'DL' not in traffic_matrix[cell_name]:
                faults.append(f'Both `DL` and `UL` keys for {cell_name} must be defined when bi-direct '
                              f'throughput is to be used.')
        else:
            if 'DL' not in traffic_matrix[cell_name] and 'UL' not in traffic_matrix[cell_name]:
                faults.append(f'Mandatory `DL` or `UL` key for {cell_name} is missing.')
        if 'protocol' in traffic_matrix[cell_name]:
            cell_tput_mandatory_keys.remove('protocol')
        for direction in {'DL', 'UL'} & set(traffic_matrix[cell_name].keys()):
            check_mandatory_keys(mandatory_keys=cell_tput_mandatory_keys, data=traffic_matrix[cell_name][direction],
                                 context=f'for {direction} for {cell_name}')

    def check_attenuators(cell_name, bidirect_flag=False):
        if 'atten_default_values' in traffic_matrix.keys():
            for index, attenuator in enumerate(traffic_matrix[cell_name]['attenuators']):
                check_mandatory_keys(mandatory_keys=atten_mandatory_keys, data=attenuator,
                                     context=f'for attenuator{index} for {cell_name}')
                if bidirect_flag:
                    if 'atten_both' not in attenuator:
                        faults.append(f'`atten_both` key is missing for attenuator{index} for {cell_name}.')
                else:
                    if 'DL' in traffic_matrix[cell_name] and 'atten_dl' not in attenuator:
                        faults.append(f'`atten_dl` key is missing for attenuator{index} for {cell_name}.')
                    if 'UL' in traffic_matrix[cell_name] and 'atten_ul' not in attenuator:
                        faults.append(f'`atten_ul` key is missing for attenuator{index} for {cell_name}.')

    faults = []
    matrix_mandatory_keys = ['linux_congestion', 'parallel_streams', 'buffer_client', 'buffer_server', 'size_packet',
                             'interval']
    cell_mandatory_keys = ['global_cell_id', 'real_cell_id']
    atten_mandatory_keys = ['ip_address', 'att_port', 'vendor', 'ports']

    check_mandatory_keys(mandatory_keys=matrix_mandatory_keys, data=traffic_matrix,
                         context='in `traffic_matrix` variable')

    for cell in cells_list:
        cell_tput_mandatory_keys = ['tput', 'protocol']
        check_cell_keys(cell, f'for {cell}')
        if 'attenuators' in traffic_matrix[cell]:
            check_attenuators(cell, bidirect)

    if 'atten_default_values' in traffic_matrix:
        for vendor in traffic_matrix['atten_default_values']:
            if sorted(traffic_matrix['atten_default_values'][vendor].keys()) != sorted(['avg', 'max']):
                faults.append(f'Mandatory key `avg` or `max` is missing for {vendor} in `atten_default_values`.')

    matrix_cells_ids = [key for key in traffic_matrix if 'CEL' in key]
    not_used_cells_ids = set(matrix_cells_ids) - set(cells_list)
    for cell in not_used_cells_ids:
        cell_tput_mandatory_keys = ['tput', 'protocol']
        check_cell_keys(cell, f'`traffic_matrix` variable for {cell}')
        if 'attenuators' in traffic_matrix[cell]:
            check_attenuators(cell)

    if faults:
        logger.log_warn_to_console('Wrong structure of `traffic_matrix` variable:')
        for fault in faults:
            logger.log_warn_to_console(fault, log_hierarchy=2)
        raise IncorrectTrafficMatrix('Wrong structure of `traffic_matrix` variable.')
    else:
        logger.log_info_to_console('`traffic_matrix` variable structure is correct.')


def get_font_colour(expected_dev, actual_dev, expected_tput):
    """
    Returns specific colour depending on expected deviation, actual deviation and expected t-put.

    Parameters:
    expected_dev (str): Expected deviation.
    actual_dev (str): Actual deviation, calculated from current t-put results.
    expected_tput (str): Target t-put value.
    """

    expected_dev = float(expected_dev.rstrip("%"))
    expected_tput_value = int(expected_tput.split(' ')[0])

    if expected_tput_value == 0:
        return "\033[0m"
    elif not (100.0 - expected_dev <= actual_dev <= 100.0 + expected_dev):
        return "\033[0;31;40m"
    return "\033[0;32;40m"


def generate_console_thput_table(data_transfer_stats, title=None, run_num='1'):
    """
    Prints table with data transfer statistics.

    Parameters:
    data_transfer_stats (list): A dictionary containing data transfer statistics.
    title (str, optional): Table title. Defaults to None. When title is not specified than test case nane would be set
                           as table title.
    run_num (str, optional): The current run number. Defaults to '1'.
    """
    if not data_transfer_stats:
        logger.log_warn_to_console('No data transfer statistics provided to print in console.')
    else:
        table = PrettyTable()
        default_colour = "\033[0m"
        if title:
            table.title = title
        else:
            table.title = get_test_case_name()
        table.title += f"_run_{run_num}"

        data_stats = convert_data_transfer_stats(data_transfer_stats)

        table.field_names = ["Cell ID", "actual / expected thput DL", "actual / expected thput UL", "DL / UL deviation"]
        for cell, stats in data_stats.items():
            dl_stats = stats.get('DL', {'actual_tput': '0', 'expected_tput': '0', 'deviation': '0'})
            ul_stats = stats.get('UL', {'actual_tput': '0', 'expected_tput': '0', 'deviation': '0'})

            dl_dev = round(calculate_deviation(dl_stats), 2)
            ul_dev = round(calculate_deviation(ul_stats), 2)

            dl_colour = get_font_colour(dl_stats["deviation"], dl_dev, dl_stats["expected_tput"])
            ul_colour = get_font_colour(dl_stats["deviation"], ul_dev, ul_stats["expected_tput"])

            table.add_row([
                f"{default_colour}{cell}",
                f"{dl_colour}{dl_stats['actual_tput']} / {dl_stats['expected_tput']}",
                f"{ul_colour}{ul_stats['actual_tput']} / {ul_stats['expected_tput']}",
                f"{dl_colour}{dl_dev} {default_colour}/ {ul_colour}{ul_dev} ",
            ])
        logger.log_info_to_console(f"\n{table}")
