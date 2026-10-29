import re
import os
import logging
import shutil

from moler.device import DeviceFactory
from taf.rfrl.bts.parsers.snapshot_analyzer import parse_snapshot_file_list
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from robot.libraries.BuiltIn import BuiltIn, logger
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations
from testsuite.Krakow.resources.asir.selenium.Dev_ASIR_Selenium import Dev_ASIR_Selenium
from selenium import webdriver

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


def cell_block_unblock_10752() -> None:
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


def load_asir_configuration(scf_path):
    asir_hub = GnbAsirHubOperations()
    cell_operations = GenericCellOperations()
    asir_selenium = Dev_ASIR_Selenium(debug=True)
    try:
        login_asir_webem(asir_selenium)
        # asir_selenium.asir_webem_login(browser=browser)
        # asir_selenium.asir_webem_login(browser=browser, browser_version="Firefox")
        asir_selenium.load_scf(scf_path, timeout=300, cancel=True)
        # asir_selenium.enter_config_man(sub_menu="Load file", overwrite=True, timeout=180)
        asir_selenium.enter_config_man(sub_menu="Edit", overwrite=True, timeout=300)
        # asir_selenium.enter_config_man(sub_menu="Continue", timeout=30)
        asir_selenium.activate(as_full_configuration=None, timeout=300)
        asir_selenium.logout()
    except Exception as e:
        if asir_selenium is not None:
            logs_dir = BuiltIn().get_variable_value("${OUTPUTDIR}") + '/selenium'
            shutil.copytree(asir_selenium.screenshot_dir, logs_dir, dirs_exist_ok=True)
        raise e

    # if cancel:
    #     cell_operations.verify_cell_statuses(availability_status='online', operational_state='enabled')
    # else:
    #     BuiltIn().sleep(5)
    #     assert asir_hub.get_all_hub_ids() == []
    #     asir_hub.verify_number_of_rfc(expected_rfc_number=0)
    #     cell_operations.wait_for_all_cells_statuses(availability_status=none, operational_state='enabled',
    #                                                 expected_cell_amount=10, timeout=120)


def login_asir_webem(asir_selenium, browser_version="Chrome"):
    asir_selenium.clean_browser()
    for _ in range(5):
        try:
            prepare_webdriver()
            browser = BuiltIn().get_variable_value("${webdriver}")
            asir_selenium.login(browser=browser, browser_version=browser_version)
        except Exception as e:
            logger.info(f"Cannot login to ASiR WemEM due to the following error: {e}", also_console=True)
            asir_selenium.clean_browser()
            BuiltIn().sleep(10)
        else:
            return


def prepare_webdriver():
    options = webdriver.ChromeOptions()
    options.add_argument("--ignore-certificate-errors")
    options.add_argument("--maximized")
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Chrome(chrome_options=options)
    BuiltIn().set_global_variable("${webdriver}", driver)
    logger.info(f'webdriver: {BuiltIn().get_variable_value("${webdriver}")}', also_console=True)


def asir_scf_A_path():
    main_path = os.path.dirname(os.path.abspath(__file__))
    main_path = main_path.split('testsuite')[0]
    main_path += 'commissionings'
    return main_path
