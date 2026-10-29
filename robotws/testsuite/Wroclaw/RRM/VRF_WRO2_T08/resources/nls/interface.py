from functools import wraps

from robot import __version__ as robot_version
from robot.api import logger
from robot.running import EXECUTION_CONTEXTS
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.rfrl.utilities.robot.RobotWrapper import RobotWrapper
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh

from .nls_page import NlsPage

admin_api = admin()
ssh = ssh()
nls_page = None


def logged_keyword(function):
    @wraps(function)
    def logged_function(*args, **kwargs):
        arguments = " | ".join([f"{arg}" for arg in args] + [f"{kwarg}={value}" for kwarg, value in kwargs.items()])
        function_formatted_name = " ".join([word.title() for word in function.__name__.split("_")])
        if EXECUTION_CONTEXTS.current:
            logger.info(f"Robot Framework version: {robot_version}", also_console=False)
            wrap_type = "keyword" if robot_version >= "5.0" else "kw"
            with RobotWrapper(f"{function_formatted_name}", wrap_type):
                logger.info(f"Arguments: [{arguments}]", also_console=False)
                result = function(*args, **kwargs)
                logger.info(f"Return: {result}", also_console=False)
                return result
        return function(*args, **kwargs)

    return logged_function


@logged_keyword
def change_nls_parameters_b1_activation():
    nls_page.change_parameter_value("MeasurementQuantities", "TimingAdvanceNR")
    nls_page.change_parameter_value("ReportCharacteristics", "OnDemand")


@logged_keyword
def change_nls_parameters(measurement_quantitiees: str, report_characteristics: str):
    nls_page.change_parameter_value("MeasurementQuantities", measurement_quantitiees)
    nls_page.change_parameter_value("ReportCharacteristics", report_characteristics)


@logged_keyword
def teardown_nls_connection_and_restore_initial_values():
    nls_page.close()


@logged_keyword
def setup_nls_page_and_open_nrppa_parameter_page():
    global nls_page
    nls_page = NlsPage()
    nls_page.log_to_nls()
    nls_page.go_to_parameters("NRPPA")


@logged_keyword
def trigger_lcs(lmf_connection_details, lmf_filepath):
    trigger_cmd = f"curl -v http://{lmf_connection_details['hostname']}:9210 -d @{lmf_filepath}"
    log_info_to_console(f"Triggering LCS with cmd: {trigger_cmd}")
    try:
        ssh.connect_to(**lmf_connection_details)
        ssh.execute(trigger_cmd)
    except Exception as e:
        logger.error(f"Failed to trigger LCS: {e}")
        raise
    finally:
        ssh.disconnect()


@logged_keyword
def trigger_lcs_end2end(lmf_connection_details, lmf_filepath):
    try:
        setup_nls_page_and_open_nrppa_parameter_page()
        change_nls_parameters_b1_activation()
        trigger_lcs(lmf_connection_details, lmf_filepath)
    finally:
        teardown_nls_connection_and_restore_initial_values()


@logged_keyword
def download_translog(lmf_connection_details, local_filepath):
    log_dir = "/var/lib/tlr/translog"
    try:
        ssh.connect_to(**lmf_connection_details)
        date_dir = ssh.execute(f'ls -r1 {log_dir} | head -1').strip()
        filename = ssh.execute(f'ls -t1 {log_dir}/{date_dir} | head -1').strip()
        remote_filepath = f"{log_dir}/{date_dir}/{filename}"
        if "//" in remote_filepath:
            remote_filepath = remote_filepath.split('//')[0]
        log_info_to_console(f"Downloading {remote_filepath}")
        ssh.download_file(remote_filepath, local_filepath)
    except Exception as e:
        logger.error(f"Failed to download translog: {e}")
        raise
    finally:
        ssh.disconnect()


@logged_keyword
def download_nrppa_log(lmf_connection_details, local_filepath):
    remote_filepath = "/opt/nls/nls_run/log/lmf/nrppa.log"
    try:
        ssh.connect_to(**lmf_connection_details)
        log_info_to_console(f"Downloading {remote_filepath}")
        ssh.download_file(remote_filepath, local_filepath)
    except Exception as e:
        logger.error(f"Failed to download nrppa.log: {e}")
        raise
    finally:
        ssh.disconnect()
