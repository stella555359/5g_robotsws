"""
Variables related to UUF tests

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
from taf.rfrl.bts.alarms.classical_alarms_definition import CLASSICAL_FAULT_6134, CLASSICAL_FAULT_4759, \
    CLASSICAL_FAULT_6351, CLASSICAL_FAULT_7513, CLASSICAL_FAULT_7306, CLASSICAL_FAULT_7107
from taf.ul.alarms_watchdog import Alarm
from taf.rfrl.utilities.robot.general import get_builtin_value


CUSTOMERS = ["Generic"]
SOURCE_SW = None
TARGET_SW = None
STOP_TEST_AFTER_FAIL = False
USE_TESTPACKAGE = False
RESTORE_TO_TARGET_SW = True
REPORT = True

UPDATE_TEST_ITERATION = 5
SITE_RESET_TEST_ITERATION = 15

QC_DOMAIN = "MN_RAN"
QC_PROJECT = "RAN_VRF"
QC_ID_UPGRADE = None
QC_ID_RESET = None
RP_LOCATION = "VRF_KRK"
RP_ORGANIZATION = "VRF_KRK_T06"
RP_CA = "VRF_OAM"

tl = get_builtin_value('tl')

FAULT_7107_BEFORE_26R2 = {'fault_id': '7107',
                          'fault_name': 'Cell problem due to associated X2 links and/or NG links and/or '
                                        'E1 link unavailability'}

NODE0 = {
    "bts_host_ip": tl.gnbs[0].cu.oam_http_connection_details.addr,
    "testline_object": tl.gnbs[0],
    "source_sw": SOURCE_SW,
    "target_sw": TARGET_SW,
    "temporary_allowed_alarms": [Alarm(**CLASSICAL_FAULT_6134), Alarm(**CLASSICAL_FAULT_4759),
                                 Alarm(**CLASSICAL_FAULT_6351), Alarm(**CLASSICAL_FAULT_7513),
                                 Alarm(**CLASSICAL_FAULT_7306)],
}
NODE1 = {
    "bts_host_ip": tl.gnbs[1].cu.oam_http_connection_details.addr,
    "testline_object": tl.gnbs[1],
    "source_sw": SOURCE_SW,
    "target_sw": TARGET_SW,
    "temporary_allowed_alarms": [Alarm(**CLASSICAL_FAULT_7107), Alarm(**FAULT_7107_BEFORE_26R2)],
}

NODES = [NODE0, NODE1]
