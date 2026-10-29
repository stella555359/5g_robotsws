import importlib
import sys

from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from taf.config.testline.testline import TestLine as TafTestLine


def testline_rename():
    hostname = VmOs.execute_command('hostname').strip().split("-")
    return "_".join(hostname[:3])


class TestEnvData(object):
    """
    Stores all global variables and reads robot runtime to keep all constants in the same place
    """

    TRUNK_SW = "SBTS00"
    BUILD_SW_VERSION = BuiltIn().get_variable_value("${ENB_BUILD}")
    STREAM_SW = BUILD_SW_VERSION.split("_")[0] if BUILD_SW_VERSION else "STREAM_DEFAULT"
    MINOR_SW_VERSION = "_".join(BUILD_SW_VERSION.split('_')[1:]) if BUILD_SW_VERSION else "VERSION_DEFAULT"
    ADMIN_CONNECT_STREAM = "SBTS25R1" if STREAM_SW == TRUNK_SW else STREAM_SW
    RELEASE_SW_VERSION = BUILD_SW_VERSION.replace(TRUNK_SW, ADMIN_CONNECT_STREAM) \
        if BUILD_SW_VERSION else "STREAM_SW_DEFAULT"

    TESTLINE = BuiltIn().get_variable_value("${tl}")
    OUTPUT_DIR = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    EXEC_DIR = BuiltIn().get_variable_value("${EXEC_DIR}")
    HTTPS_PORT = 443
    BuiltIn().set_tags(BUILD_SW_VERSION)

    PDUS = TESTLINE.pdus
    UES = TESTLINE.ues
    GNBS = TESTLINE.gnbs
    ENBS = TESTLINE.enbs
    GNB_PDU_PORT_LIST = GNBS[0].dus[0].airscale.common_units[0].pdu_port

    VM_SSH_CONN_DETAILS = TESTLINE.test_pcs[0].default_ssh_connection_details
    VM_HOST = VM_SSH_CONN_DETAILS.addr
    VM_USER = VM_SSH_CONN_DETAILS.username
    VM_PASS = VM_SSH_CONN_DETAILS.password
    VM_SSH_PARAM_DICT = {"host": VM_HOST, "user": VM_USER, "password": VM_PASS}
    VM_TRACE_PORT = GNBS[0].instance_id

    try:
        LTE_VM_SSH_CONN_DETAILS = TESTLINE.test_pcs[1].default_ssh_connection_details
        LTE_VM_SSH_HOST = LTE_VM_SSH_CONN_DETAILS.addr
        LTE_VM_SSH_USER = LTE_VM_SSH_CONN_DETAILS.username
        LTE_VM_SSH_PASS = LTE_VM_SSH_CONN_DETAILS.password
        LTE_VM_SSH_PARAM_DICT = {"host": LTE_VM_SSH_HOST, "user": LTE_VM_SSH_USER, "password": LTE_VM_SSH_PASS}
    except IndexError:
        try:
            sys.path.append('\\home\\ute\\testline_configuration')
            tl_init = importlib.import_module(testline_rename())
            TESTLINE.test_pcs.extend(tl_init.test_line_additional_vms)
            LTE_VM_SSH_CONN_DETAILS = TESTLINE.test_pcs[1].default_ssh_connection_details
            LTE_VM_SSH_HOST = LTE_VM_SSH_CONN_DETAILS.addr
            LTE_VM_SSH_USER = LTE_VM_SSH_CONN_DETAILS.username
            LTE_VM_SSH_PASS = LTE_VM_SSH_CONN_DETAILS.password
            LTE_VM_SSH_PARAM_DICT = {"host": LTE_VM_SSH_HOST, "user": LTE_VM_SSH_USER, "password": LTE_VM_SSH_PASS}
        except AttributeError:
            LTE_VM_SSH_CONN_DETAILS = None
            LTE_VM_SSH_HOST = None
            LTE_VM_SSH_USER = None
            LTE_VM_SSH_PASS = None
            LTE_VM_SSH_PARAM_DICT = None

    GNB_ID = GNBS[0].instance_id
    GNB_SSH_CONNECTION_DETAILS = GNBS[0].cu.oam_ssh_connection_details
    GNB_GLOBAL_BTS_ID = GNBS[0].global_bts_id
    GNB_X2C_VLAN_ID = GNBS[0].cu.x2c.vlan_id
    GNB_HTTPS_CONNECTION_DETAILS = GNBS[0].cu.oam_http_connection_details
    GNB_HTTPS_CONNECTION_HOST = GNB_HTTPS_CONNECTION_DETAILS.addr
    GNB_HTTPS_CONNECTION_USER = GNB_HTTPS_CONNECTION_DETAILS.username
    GNB_HTTPS_CONNECTION_PASSWORD = GNB_HTTPS_CONNECTION_DETAILS.password
    try:
        GNB_TRACING_SOURCE_IP = GNBS[0].cu.f1m.v4
    except AttributeError:
        try:
            if isinstance(GNBS[0].cu.backhaul_site_oam_ip, str):
                GNB_TRACING_SOURCE_IP = GNBS[0].cu.backhaul_site_oam_ip
            else:
                GNB_TRACING_SOURCE_IP = GNBS[0].cu.backhaul_site_oam_ip.v4
        except AttributeError:
            GNB_TRACING_SOURCE_IP = GNBS[0].cu.backhaul_site_oam_ip.v6

    ENB_ID = ENBS[0].instance_id if ENBS else None
    ENB_HTTPS_CONNECTION_HOST = ENBS[0].oam_ip.v4 if ENBS else None

    BTS_LOG_DIR_5G = "/tmp/btslog2"
    BTS_LOG_DIR_4G = "/tmp/btslog2"
    BTSLOG_5G_ALIAS = "btslog5g"
    BTSLOG_4G_ALIAS = "btslog4g"
    BTSLOG_5G_2_ALIAS = "btslog5g2"
    BTSLOG_4G_2_ALIAS = "btslog4g2"
    BTSLOG_5G_SUITE_ALIAS = "btslog5g_suite"

    TCPDUMP_NAME = "tcpdump"
    TPCDUMP_EXECUTOR_DICT = {"host": GNB_HTTPS_CONNECTION_HOST,
                             "user": GNB_HTTPS_CONNECTION_USER,
                             "password": GNB_HTTPS_CONNECTION_PASSWORD,
                             "port": HTTPS_PORT,
                             "release": ADMIN_CONNECT_STREAM}

    SHERPA_VERSION_PER_RELEASE = {"SBTS22R1": "1.0.76.0",
                                  "SBTS22R2": "1.0.76.0",
                                  "SBTS22R3": "1.0.79.0",
                                  "SBTS22R4": "1.0.85.0",
                                  "SBTS23R1": "1.0.94.0",
                                  "SBTS23R2": "1.0.94.0",
                                  "SBTS23R3": "1.0.94.0",
                                  TRUNK_SW: "1.0.94.0"}

    @property
    def test_log_dir(self):
        log_dir = VmOs.join_path_elements(TestEnvData.OUTPUT_DIR,
                                          self._prepare_adjusted_path(BuiltIn().get_variable_value("${SUITE NAME}")),
                                          self._prepare_adjusted_path(BuiltIn().get_variable_value("${TEST NAME}")))
        VmOs.make_dir(log_dir)
        return log_dir

    @property
    def test_suite_dir(self):
        log_dir = VmOs.join_path_elements(TestEnvData.OUTPUT_DIR,
                                          self._prepare_adjusted_path(BuiltIn().get_variable_value("${SUITE NAME}")))
        VmOs.make_dir(log_dir)
        return log_dir

    def get_admin_release(self):
        return self.ADMIN_CONNECT_STREAM

    def is_trunk_sw_under_test(self):
        return self.STREAM_SW == self.TRUNK_SW

    def is_it_dryrun_check(self):
        return not isinstance(self.TESTLINE, TafTestLine)

    @staticmethod
    def set_suite_flag_if_was_attempt_to_commission_bts(value=True):
        BuiltIn().set_suite_variable("${BTS_COMMISSION_STATE}", value)

    @staticmethod
    def get_suite_flag_if_bts_commission_was_attempted():
        return BuiltIn().get_variable_value("${BTS_COMMISSION_STATE}")

    @staticmethod
    def set_suite_flag_if_stop_and_fix_is_raised():
        BuiltIn().set_suite_variable("${STOP_AND_FIX_STATE}", True)

    @staticmethod
    def is_suite_flag_stop_and_fix_raised():
        return BuiltIn().get_variable_value("${STOP_AND_FIX_STATE}")

    @staticmethod
    def _prepare_adjusted_path(path_element):
        import re
        import string
        chars = string.punctuation + " "
        return re.sub(r'[' + chars + ']', '_', path_element)

    @staticmethod
    def testline_name():
        return testline_rename()

    @staticmethod
    def testline_name_in_scout():
        if TestEnvData.testline_name() in ["7_16_UTE5GWPTAVQL1",
                                           "7_16_UTE5GSISOBENCH001"]:
            return TestEnvData.testline_name()
        return f"{TestEnvData.testline_name()}_MRBTS-{TestEnvData.GNB_ID}"
