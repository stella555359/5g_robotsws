import os
import re

from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pdml import pdml
from taf.collectors.btslog import btslog
from taf.collectors.core import core
from taf.converters.pcaptopdml import pcaptopdml
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from ute_tshark.interface import ute_tshark

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

_builtin = BuiltIn()
_core = core()
_btslog = btslog()
_pcaptopdml = pcaptopdml()
_pdml = pdml()
_ssh = ssh()
_admin = admin()
ute_tshark = ute_tshark()

CONFIGS = {
    "gNB50831": {
        "VM_IP": "10.44.149.146",
    },
    "gNB50832": {
        "VM_IP": "10.44.149.147",
    },
}


HO_1 = r'.*?ANR is enabled - execute neighbour update after finished HO procedure with status: hoSucceeded.'
HO_2 = r'.*?Update for inter-GNB relation from source cell:832815105 to target cell:832831489 ' \
       r'with PhyCellId:<LOG_SCRAM_11>60</LOG_SCRAM_11> with ssbFrequency: 176410 with new status: hoSucceeded'


def get_path() -> str:
    """
    Constructs a file path using the output directory and test name.

    :returns: A string representing the file path.
    :rtype: str
    """
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def collect_scf_before_test() -> None:
    """
    Collects a backup SCF file before running tests.

    This function logs the start of the SCF collection process and uses the
    Admin5G API to retrieve the current SCF file, saving it as 'backup_scf.xml'.

    :raises Exception: If there is an issue with collecting the SCF file.
    """
    log_info_to_console("Collecting backup SCF...")
    with Admin5G() as admin_api:
        admin_api.get_current_scf_file(get_path(), 'backup_scf.xml', timeout=60)


def collect_bts_snapshot() -> None:
    """
    Collects a BTS snapshot and saves it to a specified path.

    The snapshot is saved as a ZIP file named according to the current test name
    in the log path.

    :raises Admin5GError: If there is an issue with collecting the snapshot.
    """
    log_info_to_console("Collecting BTS Snapshot...")
    with Admin5G() as admin_api:
        admin_api.get_snapshot(f"{_builtin.get_variable_value('${LOG_PATH}')}/"
                               f"{_builtin.get_variable_value('${test_name}')}_snapshot.zip")


def check_ho_in_syslog(syslog_path: str | bytes) -> bool:
    """
    Check for specific handover messages in a syslog file.

    :param syslog_path: Path to the syslog file. Can be a string or bytes.
    :type syslog_path: str | bytes
    :raises ValueError: If the check procedure fails and both messages are not found.
    :return: True if both handover messages are found in the syslog, otherwise raises an error.
    :rtype: bool
    """
    pattern_1 = re.compile(HO_1, re.IGNORECASE)
    pattern_2 = re.compile(HO_2, re.IGNORECASE)
    msg_1 = msg_2 = False
    for line in file_reader(syslog_path):
        if pattern_1.match(line):
            msg_1 = True
        if pattern_2.match(line):
            msg_2 = True
        if all([msg_1, msg_2]):
            return True
    raise ValueError(f"Check procedure failed. Messages status: msg_1={msg_1}, msg_2={msg_2} ")
