import os
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value
from ta5g_pm_counters import ta5g_pm_counters


def get_sn_remote_host_ip():
    tl_cfg = get_builtin_value(param_name="tl")
    try:
        return tl_cfg.test_pcs[1].default_ssh_connection_details.addr
    except IndexError:
        pass


def download_counters_reports(counters_type='pm', wait_for_next_interval=True):
    """
    Download RD or PM reports from both gNBs, e.g. RD.BTS-1.20220929.075500.ANY.xml.gz
    Report from gNB1 and gNB2 is downloaded with use of ta5g_pm_counters library.

    :param counters_type: (str) 'rd' or 'pm'
    :param wait_for_next_interval: (bool)
    """

    pm_counters_instance = ta5g_pm_counters()
    gnb2_ip = get_sn_remote_host_ip()
    if counters_type.lower() == 'rd':
        report_filepath_gnb1 = pm_counters_instance.get_next_unpacked_raw_rd_counters_file(
            output_dirpath=os.path.join(_get_log_dir(), f'{counters_type}_counters_gnb1'))
        report_filepath_gnb2 = pm_counters_instance.get_next_unpacked_raw_rd_counters_file(
            output_dirpath=os.path.join(_get_log_dir(), f'{counters_type}_counters_gnb2'))
    elif counters_type.lower() == 'pm':
        if wait_for_next_interval:
            pm_counters_instance.wait_for_next_full_pm_interval()
        report_filepath_gnb1 = pm_counters_instance.get_latest_unpacked_full_pm_counters_file(
            output_dirpath=os.path.join(_get_log_dir(), f'{counters_type}_counters_gnb1'))
        report_filepath_gnb2 = pm_counters_instance.get_latest_unpacked_full_pm_counters_file(
            output_dirpath=os.path.join(_get_log_dir(), f'{counters_type}_counters_gnb2'), remote_host=gnb2_ip)
    else:
        raise ValueError(f'Not supported value for parameter counters_type: {counters_type}')

    report_filename = os.path.basename(report_filepath_gnb1)
    _validate_if_log_files_exist(
        [f'{counters_type}_counters_gnb1/{report_filename}', f'{counters_type}_counters_gnb2/{report_filename}']
    )
    pwd_list = [report_filepath_gnb1, report_filepath_gnb2]
    return pwd_list


def _get_log_dir(suite_log_dir=False):
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    if not suite_log_dir:
        try:
            return os.path.join(output_dir, BuiltIn().get_variable_value("${TEST_NAME}"))
        except TypeError:
            logger.info(f'Logs collected in suite logs dir.')
    return os.path.join(output_dir, BuiltIn().get_variable_value("${SUITE_NAME}"))


def _validate_if_log_files_exist(filenames, log_dir=None):
    """
    Check if path to log exist on local VM.

    :param filenames: (list or str)
    :param log_dir: (str)
    """

    log_dir = log_dir if log_dir else _get_log_dir()
    if not isinstance(filenames, list):
        filenames = [filenames]
    for filename in filenames:
        assert os.path.exists(os.path.join(log_dir, filename)), \
            f'File: {os.path.join(log_dir, filename)} does not exist!'
        logger.info(f'File: {os.path.join(log_dir, filename)} exists')
