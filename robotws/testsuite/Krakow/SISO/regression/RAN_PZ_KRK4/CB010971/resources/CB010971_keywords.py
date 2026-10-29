import re
import os
import logging
from moler.device import DeviceFactory
from taf.rfrl.bts.parsers.snapshot_analyzer import parse_snapshot_file_list
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from robot.libraries.BuiltIn import BuiltIn, logger
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu

tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)


def check_if_entry_exist_in_file(file_path: str, first_keyword: str, second_keyword: str) -> None:
    """
    Check if entry keywords exist in given file

    :param file_path: path to file to check
    :param str first_keyword: first keyword - keyword to check if exist in file
    :param str second_keyword: second keyword - keyword to check if exist in file
    :return: None
    """
    softver = GnbBbu().get_bts_sw_version()
    entries = search_in_file(file_path, first_keyword, second_keyword, softver)

    if len(entries) < 1:
        raise Exception(f"No lines with '{first_keyword}' and '{second_keyword}' found")


def search_in_file(file_path: str, first_keyword: str, second_keyword: str, softver: str) -> list:
    """
    Search if file contains given keywords

    :param softver: current SW version loaded to BTS
    :param file_path: path to file where search given keywords
    :param str first_keyword: first keyword - keyword to search in file
    :param str second_keyword: second keyword - keyword to search in file
    :return: list of lines contains given keywords, if not found then empty list
    """
    mlogger = logging.getLogger("moler")
    founds = []
    with open(file_path, 'r') as file_content:
        for line in file_content:
            if first_keyword in line and second_keyword in line and softver in line:
                mlogger.log(level=logging.INFO, msg=f"Found '{first_keyword}'"
                                                    f" and '{second_keyword}' = '{softver}' in line "
                                                    f"'{line}' from file {file_path}.")
                founds.append(line.strip())
            # elif first_keyword in line and second_keyword in line and softver not in line:
            #     raise Exception(f"Incorrect SW version recorded. Should be: '{softver}'")

    if len(founds) == 0:
        mlogger.log(level=logging.INFO, msg=f"Not found a line with '{first_keyword}' and "
                                            f"{second_keyword} in file {file_path}.")
    return founds


def search_file_in_snapshot(file_name_to_find: str, snapshot_path: str,
                            primary_file_regex=None) -> str:
    """
    Search file in given snapshot

    :param file_name_to_find: file name to find in snapshot
    :param snapshot_path: path to snapshot
    :param primary_file_regex: compiled regex to match file name
    :return: return_file : searched file
    """

    if primary_file_regex is None:
        primary_file_regex = re.compile(r"^BTS.*.zip")
    output_dir = os.path.join(os.path.dirname(snapshot_path), "extracted_files")
    unpack_zip_file(snapshot_path, output_dir)
    file_name_to_find_regex = re.compile(file_name_to_find)

    all_snapshot_files = parse_snapshot_file_list(os.path.join(output_dir, 'snapshot_file_list.txt'))
    for files in all_snapshot_files:
        if primary_file_regex.search(files['file_name']):
            for secondary_file in files['sub_files']:
                if file_name_to_find_regex.search(secondary_file):
                    return_file = os.path.join(output_dir, files['file_name'], secondary_file)
                    logging.info("File was found: {0}".format(return_file))
                    return return_file
    raise Exception("Cannot find {} file".format(file_name_to_find))


def extract_file_from_zip_snapshot(file_name_to_extract: str, snapshot_path: str,
                                   extracted_dir_name: str = 'extracted_files') -> str:
    """
    Extract given file from snapshot

    :param file_name_to_extract: file name to extract from snapshot
    :param snapshot_path: path to zip snapshot contains file to extract
    :param extracted_dir_name: path to extracted_files
    :return: full path to extracted file
    """

    extracted_dir_path = os.path.join(os.path.dirname(snapshot_path), extracted_dir_name)
    found_file = search_file_in_snapshot(file_name_to_extract, snapshot_path)
    primary_file = found_file.split("/")[-2]
    secondary_file = found_file.split("/")[-1]
    unpack_zip_file(os.path.join(extracted_dir_path, primary_file), extracted_dir_path)
    extracted_secondary_file_name = ".".join(secondary_file.split(".")[:-1])
    return os.path.join(extracted_dir_path, extracted_secondary_file_name)


@load_moler_configuration_from_tl()
def unpack_zip_file(file_path: str, output_dir: str) -> None:
    """
    Unpack file in zip format

    :param: file_path: path to file to unpack
    :param: output_dir: directory for extract file
    :return :None
    """

    device = DeviceFactory.get_device(name='UnixLocal', initial_state="UNIX_LOCAL")
    device.get_cmd(cmd_name='unzip', cmd_params={"zip_file": file_path, "options": "",
                                                 "extract_dir": output_dir,
                                                 "overwrite": True})()


@load_moler_configuration_from_tl()
def unpack_xz_file(file_path: str) -> None:
    """
    Unpack file in xz format

    :param: file_path: path to file to unpack
    :return :None
    """

    device = DeviceFactory.get_device(name='UnixLocal', initial_state="UNIX_LOCAL")
    zf_cmd = device.get_cmd(cmd_name='unxz', cmd_params={"xz_file": file_path,
                                                         "options": "-f"})
    zf_cmd()


@load_moler_configuration_from_tl()
def unpack_gz_file(file_path: str, output_dir: str) -> None:
    """
    Unpack file in gz format

    :param: file_path: path to file to unpack
    :param: output_dir: directory for extract file
    :return :None
    """

    device = DeviceFactory.get_device(name='UnixLocal', initial_state="UNIX_LOCAL")
    if output_dir is not None:
        cmd_cd = device.get_cmd(cmd_name="cd", cmd_params={'path': output_dir})
        cmd_cd()
    try:
        cmd_gzip = device.get_cmd(cmd_name='gzip', cmd_params={"file_name": file_path,
                                                               "options": "-dkvf"})
        cmd_gzip()
    finally:
        if output_dir is not None:
            cmd_cd = device.get_cmd(cmd_name="cd", cmd_params={'path': "-"})
            cmd_cd()


def check_snapshot_10971() -> None:
    logs = GnbLog()
    snapshot_zip_path = logs.collect_snapshot()
    moler_logger = logging.getLogger("moler")

    moler_logger.log(level=logging.INFO, msg=f"snapshot_zip_path={snapshot_zip_path}")
    file = extract_file_from_zip_snapshot(
        file_name_to_extract='UnitOAM_SOAP',
        snapshot_path=snapshot_zip_path)
    moler_logger.log(level=logging.INFO, msg=f"file={file}")
    output_dir = os.path.split(file)[0]
    moler_logger.log(level=logging.INFO, msg=f"output_dir={output_dir}")
    unpack_zip_file(file_path=f"{file}.zip", output_dir=output_dir)

    unpack_gz_file(file_path="UnitOAM_SOAP_Log0.xml.gz", output_dir=output_dir)
    check_if_entry_exist_in_file(
        file_path=os.path.join(output_dir, "UnitOAM_SOAP_Log0.xml"),
        first_keyword='moduleDetectedLocation',
        second_keyword='BtsVersion')
