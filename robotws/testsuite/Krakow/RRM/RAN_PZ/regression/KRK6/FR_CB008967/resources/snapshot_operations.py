import logging
import lzma
import os
import re
import zipfile
from robot.libraries.BuiltIn import BuiltIn
import taf.rfrl.bts.parsers.snapshot_analyzer as sa

OUTPUT_DIR = BuiltIn().get_variable_value("${OUTPUTDIR}")
SNAPSHOT_UNPACKED_DIR = OUTPUT_DIR + '/snapshot_unpacked'
APHG_SN = "NH225300327"
APHA_SN = "NH193400581"


def get_snapshot_filepath():
    """Retrieves the filepath of the snapshot file from the output directory.

    :return: The filepath of the snapshot file.
    :rtype: str
    """
    filename = list(filter(lambda f: f.startswith('Snapshot'), os.listdir(f'{OUTPUT_DIR}/')))[0]
    filepath = OUTPUT_DIR + '/' + filename
    logging.info(f"Snapshot file path: {filepath}")
    return filepath


def get_blackbox_temperature_file():
    """Retrieves the decompressed blackbox temperature log file from the snapshot.

    :return: The decompressed blackbox temperature log file.
    :rtype: str
    """
    snapshot_filepath = get_snapshot_filepath()
    log_file = sa._get_specific_snapshot_file(
        zipfile_list=sa._get_bts_zip_files_list(directory=snapshot_filepath),
        filename_part="BTS77122_1011_blackbox_temperature.xz"
    )
    decompressed_log_file = _parse_xz_file(log_file)
    return decompressed_log_file


def _parse_xz_file(file_object):
    """Decompresses and decodes an XZ file.

    :param file_object: The file object to decompress.
    :type file_object: file
    :return: The decompressed and decoded data.
    :rtype: str
    """
    data = file_object.read()
    decompressed_data = lzma.decompress(data)
    return decompressed_data.decode('utf-8')


def fetch_fan_speed_values_from_blackbox_content(bbox_file):
    """Extracts fan speed values from blackbox content.

    :param bbox_file: The blackbox content as a string.
    :type bbox_file: str
    :return: Two lists containing fan speed values for EFanUnit_FsmFan1 and EFanUnit_FsmFan2.
    :rtype: tuple
    """
    bbox_content = bbox_file.split('\n')
    log_prints = False
    EFanUnit_FsmFan1_list, EFanUnit_FsmFan2_list = [], []
    for num, line in enumerate(bbox_content):
        if "TEMPANDSPEED" in line:
            log_prints = True
        elif "#yearly historical of temperatures" in line:
            log_prints = False
        if log_prints:
            logging.info(line)
            if "#" not in line:
                EFanUnit_FsmFan1_list.append(int(line.split('\t')[-3]))
                EFanUnit_FsmFan2_list.append(int(line.split('\t')[-2]))
    return EFanUnit_FsmFan1_list, EFanUnit_FsmFan2_list


def check_average_fan_speed(fan1_speed_list, fan2_speed_list):
    """Checks the average fan speed and asserts values are reported.

    :param fan1_speed_list: List of fan speed values for EFanUnit_FsmFan1.
    :type fan1_speed_list: list
    :param fan2_speed_list: List of fan speed values for EFanUnit_FsmFan2.
    :type fan2_speed_list: list
    """
    fan1_avg_speed = sum(fan1_speed_list)/len(fan1_speed_list)
    fan2_avg_speed = sum(fan2_speed_list)/len(fan2_speed_list)
    logging.info(f"EFanUnit_FsmFan1 avg speed: {fan1_avg_speed:.2f}")
    logging.info(f"EFanUnit_FsmFan2 avg speed: {fan2_avg_speed:.2f}")
    assert fan1_avg_speed > 0, "EFanUnit_FsmFan1 values are not reported in blackbox"
    assert fan2_avg_speed > 0, "EFanUnit_FsmFan2 values are not reported in blackbox"


def verify_that_cabinet_fan_speed_is_reported_in_blackbox():
    """Verifies that cabinet fan speed is reported in the blackbox.
    """
    bbox_content = get_blackbox_temperature_file()
    fan1_speed_list, fan2_speed_list = fetch_fan_speed_values_from_blackbox_content(bbox_content)
    calculate_average_fan_speed(fan1_speed_list, fan2_speed_list)


def fetch_asirmod_fan_speed_values_from_snapshot():
    """Fetches the log file containing ASIRMOD fan speed values from the snapshot.

    :return: The log file object.
    :rtype: file
    """
    snapshot_filepath = get_snapshot_filepath()
    assert os.path.exists(snapshot_filepath), f"Could not found snapshot {snapshot_filepath}"
    log_file = sa._get_specific_snapshot_file(
        zipfile_list=sa._get_bts_zip_files_list(directory=snapshot_filepath),
        filename_part=f"BTS_{APHG_SN}_RMOD_L_2_runtime.zip"
    )
    file_list = sa._get_bts_zip_files_list(snapshot_filepath)
    print(f"log_file: {log_file}")
    print(f"file_list: {file_list}")
    return log_file


def get_asirmods_runtime_logs_from_snaphot(asirmod):
    """Extracts ASIRMOD runtime logs from a snapshot. Creates file runtime_DEFAULT_{asirmod}.log

    :param asirmod: The ASIRMOD name (e.g., "APHG", "APHA").
    :type asirmod: str
    """
    snapshot_filepath = get_snapshot_filepath()
    _unzip_file(snapshot_filepath, SNAPSHOT_UNPACKED_DIR)
    if asirmod == "APHG":
        file_path = find_file_path_in_snapshot([[APHG_SN, 'runtime.zip', 'runtime_DEFAULT.log'],
                                                [APHG_SN, '_runtime.zip']])
    elif asirmod == "APHA":
        file_path = find_file_path_in_snapshot([[APHA_SN, 'runtime.zip', 'runtime_DEFAULT.log'],
                                                [APHA_SN, '_runtime.zip']])
    logging.info(f"Runtime filepath {asirmod}: {file_path}")
    for file in file_path.split('/'):
        if ".zip" in file:
            _unzip_file(SNAPSHOT_UNPACKED_DIR + f'/{file}', SNAPSHOT_UNPACKED_DIR)
    with lzma.open(SNAPSHOT_UNPACKED_DIR + '/runtime_DEFAULT.log.xz', mode='rt', encoding='ISO-8859-1') as xz_file:
        content = xz_file.read()
    with open(f"{SNAPSHOT_UNPACKED_DIR}/runtime_DEFAULT_{asirmod}.log", "w") as output_file:
        output_file.write("".join(content))


def get_MED_FanSpeed_from_runtime_log():
    """Extracts MED_FanSpeed values from runtime logs. Last values are logged and returned.

    :return: A dictionary containing MED_FanSpeed values for each ASIRMOD.
    :rtype: dict
    """
    fan_speeds_dict = {'APHG': ['', '', '', ''], 'APHA': ['', '', '', '']}
    syslog_lines = ['', '', '', '']
    for asirmod in ['APHG', 'APHA']:
        with open(f"{SNAPSHOT_UNPACKED_DIR}/runtime_DEFAULT_{asirmod}.log", "r") as runtime_log:
            content = runtime_log.readlines()
        for line in content:
            for index in range(4):
                if f"MED_FanSpeed, FanImpl::fanId: {index}" in line:
                    fan_speeds_dict[asirmod][index] = int(line[-3:])
                    syslog_lines[index] = line
        for fan in range(4):
            logging.info(f"{asirmod} Fan {fan}: {fan_speeds_dict[asirmod][fan]} - {syslog_lines[fan]}")
    return fan_speeds_dict


def get_FansServiceRpmControlLoop_from_runtime_log():
    """Extracts FansServiceRpmControlLoop values from runtime logs. Last values are logged and returned.

    :return: A dictionary containing FansServiceRpmControlLoop values for each ASIRMOD.
    :rtype: dict
    """
    pattern = r"filtered rpm: '(\d+)'"
    fan_speeds_dict = {'APHG': ['', '', '', ''], 'APHA': ['', '', '', '']}
    syslog_lines = ['', '', '', '']
    for asirmod in ['APHG', 'APHA']:
        with open(f"{SNAPSHOT_UNPACKED_DIR}/runtime_DEFAULT_{asirmod}.log", "r") as runtime_log:
            content = runtime_log.readlines()
        for line in content:
            for index in range(4):
                if f"For fan with Id: '{index}' filtered rpm" in line:
                    fan_speeds_dict[asirmod][index] = int(re.search(pattern, line).group(1))
                    syslog_lines[index] = line
        for fan in range(4):
            logging.info(f"{asirmod} Fan {fan}: {fan_speeds_dict[asirmod][fan]} rpm - {syslog_lines[fan]}")
    return fan_speeds_dict


def _unzip_file(file_path, directory):
    """Unzips a file to a specified directory.

    :param file_path: The path to the zip file.
    :type file_path: str
    :param directory: The directory to extract the files to.
    :type directory: str
    """
    assert os.path.exists(file_path), f"Could not found file {file_path}"
    with zipfile.ZipFile(file_path, 'r') as zip_ref:
        zip_ref.extractall(directory)
    assert os.path.exists(directory), f"Could not found directory {directory}"
    logging.info(f"File {file_path} has been extracted to {directory}")


def get_file_paths_from_snapshot():
    """Retrieves file paths from a snapshot file.

    :return: A list of file paths within the snapshot.
    :rtype: list
    """
    paths = []
    snapshot_filepath = get_snapshot_filepath()
    _unzip_file(snapshot_filepath, OUTPUT_DIR + '/snapshot_unpacked')
    with open(OUTPUT_DIR + '/snapshot_unpacked/snapshot_file_list.txt') as file:
        snapshot_file_list = file.readlines()
    for line in snapshot_file_list:
        if line[0].isalnum():
            header = line[:-2] if 'zip' in line else line
        elif len(line) > 10:
            paths.append(f"{header}/{line.lstrip()}")
    for path in paths:
        logging.debug(path)
    return paths


def find_file_path_in_snapshot(lists_of_keywords):
    """Finds the file path in a snapshot based on a list of keywords. Multiple lists can be passed.

    :param lists_of_keywords: A list of keywords to search for in the file paths.
    :type lists_of_keywords: list
    :raises Exception: If more than one file matches the keywords or no file matches.
    :return: The file path that matches the keywords.
    :rtype: str
    """
    paths = get_file_paths_from_snapshot()
    for keywords_list in lists_of_keywords:
        matches = [path for path in paths if all(keyword in path for keyword in keywords_list)]
        logging.info(f"Found files for keywords {keywords_list}:")
        if len(matches) == 0:
            logging.info(f"No file was found")
        else:
            logging.info(*matches)
            return matches[0].rstrip('\n')
    if len(matches) == 0:
        raise Exception(f"No file was found for {lists_of_keywords}")
