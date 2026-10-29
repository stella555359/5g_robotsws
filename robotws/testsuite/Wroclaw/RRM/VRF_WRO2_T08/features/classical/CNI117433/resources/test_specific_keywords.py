import os
import tarfile

from robot.libraries.BuiltIn import BuiltIn
from taf.collectors.tcpdump import tcpdump
from taf.collectors.core import core
from taf.collectors.btslog import btslog
from taf.converters.pcaptopdml import pcaptopdml
from taf.analyzer.pdml import pdml
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.transport.ssh import ssh
from taf.sbts.oam.coam.admin import admin
from ute_tshark.interface import ute_tshark
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

xnap_setup_msgs = [
    "ip.src == 10.44.224.86 and ip.dst == 10.44.224.87 and xnap.XnAP_PDU == 0 and xnap.procedureCode == 17",
    "ip.src == 10.44.224.87 and ip.dst == 10.44.224.86 and xnap.XnAP_PDU == 2 and xnap.procedureCode == 17 "
    "and xnap.protocol == 6"
]


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


def extract_file() -> None:
    """
    Extracts files from a tar archive located in the BTS log directory.

    This function opens a tar archive named 'BtsLog.tgz' located in the
    'btslog' directory and extracts its contents to the same directory.

    :return: None
    """
    file_path = get_path()
    with tarfile.open(f"{file_path}/btslog/BtsLog.tgz", 'r') as tar:
        tar.extractall(file_path + "/btslog/")


def create_tcpdump_collector(pcap_file: str) -> None:
    """
    Create a TCPDump collector and set up collectors.

    :param pcap_file: The name of the pcap file where the TCPDump data will be stored.
    :type pcap_file: str
    :return: None
    :rtype: None
    """
    executor = {"host": "192.168.255.129",
                "user": "toor4nsn",
                "password": "oZPS0POrRieRtu"}
    tcpdump().create_tcpdump_collector(name="tcpdump", target_file_name=pcap_file, options="sctp -i any -p",
                                       executor=executor)
    _core.setup_collectors("tcpdump")


def start_tcp_dump() -> None:
    """
    Start the TCP dump collectors and set a global alias.

    :return: None
    """
    _core.start_collectors("tcpdump")
    tcpdump().set_global_alias("tcpdump")


def stop_and_collect_tcp_dump(file_dir: str) -> None:
    """
    Stop the TCP dump collectors and collect the data.

    :param file_dir: The directory where the collected data will be stored.
    :type file_dir: str
    :return: None
    """
    _core.stop_collectors("tcpdump")
    _core.collect_collectors("tcpdump", target_dir=file_dir)
    _core.teardown_collectors("tcpdump")


def verify_xnap_setup_failure() -> None:
    """
    Verifies XNAP setup failure by checking packet counts.

    :raises AssertionError: If the packet count does not match the expected value.
    """
    filter_list = xnap_setup_msgs
    source_filepath = f"{_builtin.get_variable_value('${LOG_PATH}')}/" \
                      f"{_builtin.get_variable_value('${TESTNAME}')}/tcpdump/step_1"
    pcap_alias = "xnap_pcap"
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[0],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 4, f"{packets} packets for filter: {filter_list[0]} in {source_filepath}-should be 4"
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[1],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 4, f"{packets} packets for filter: {filter_list[1]} in {source_filepath}-should be 4"
    ute_tshark.teardown_tshark(alias=pcap_alias)
