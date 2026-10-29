"""
Variables related to UUF tests

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
from taf.rfrl.bts.alarms.classical_alarms_definition import CLASSICAL_FAULT_4459, CLASSICAL_FAULT_4779, \
    CLASSICAL_FAULT_1898
from taf.ul.alarms_watchdog import Alarm
from taf.rfrl.utilities.robot.general import get_builtin_value
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.common import Misc

CUSTOMERS = ["TMO US"]
SOURCE_SW = None
LTE_SOURCE_SW = SOURCE_SW
TARGET_SW = None
STOP_TEST_AFTER_FAIL = False
USE_TESTPACKAGE = False
RESTORE_TO_TARGET_SW = Misc.to_bool(get_builtin_value('RESTORE_TO_TARGET_SW'), False)
SETUP_ENERGY_SAVING = Misc.to_bool(get_builtin_value('SETUP_ENERGY_SAVING'), False)
SKIP_MUMIN_SETUP = Misc.to_bool(get_builtin_value('SKIP_MUMIN_SETUP'), False)

ROLLBACK_REVERSE_ORDER = True
REPORT = Misc.to_bool(get_builtin_value('REPORT'), True)

UPDATE_TEST_ITERATION = 5
SITE_RESET_TEST_ITERATION = 15

QC_ID_UPGRADE = None
QC_ID_RESET = None
QC_DOMAIN = "MN_RAN"
QC_PROJECT = "RAN_VRF"
RP_LOCATION = "VRF_KRK"
RP_ORGANIZATION = "VRF_KRK_T06"
RP_CA = "VRF_OAM"

tl = get_builtin_value('tl')

TEST_SETUP_CUSTOM_ALLOWED_ALARMS = [CLASSICAL_FAULT_4459]

NODE1 = {
    "bts_host_ip": tl.gnbs[0].cu.oam_http_connection_details.addr,
    "testline_object": tl.gnbs[0],
    "source_sw": SOURCE_SW,
    "target_sw": TARGET_SW,
    "temporary_allowed_alarms": [Alarm(**CLASSICAL_FAULT_4779)],
    "setup_energy_saving": SETUP_ENERGY_SAVING,
    "force_create_power_groups": False,
}
NODE2 = {
    "bts_host_ip": tl.enbs[0].oam_ip.v4.split('/')[0],
    "testline_object": tl.enbs[0],
    "source_sw": LTE_SOURCE_SW,
    "target_sw": TARGET_SW,
    "temporary_allowed_alarms": [Alarm(**CLASSICAL_FAULT_1898)],
    "setup_energy_saving": SETUP_ENERGY_SAVING,
    "force_create_power_groups": False,
}

NODES = [NODE1, NODE2]

if SKIP_MUMIN_SETUP:
    for node in NODES:
        node['mumin_config'] = []
