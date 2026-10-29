"""
:copyright: Nokia Networks
:author: Damian Piasecki
:maintainer: Damian Piasecki
:contact: damian.piasecki@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import os

from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value

tl = get_builtin_value(param_name="tl")

ADMIN_ALIAS = 'default'
SYSLOG_ALIAS = 'syslog'
NOKIA_PASS = tl.gnbs[0].cu.oam_ssh_connection_details.password
NOKIA_LOGIN = tl.gnbs[0].cu.oam_ssh_connection_details.username
NOKIA_USERNAME = tl.gnbs[0].cu.oam_ssh_connection_details.username
GNB_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr
AP_IP = tl.ues[0].l1.common_units[0].lmp_connection.addr
AP_PASSWD = tl.ues[0].l1.common_units[0].lmp_connection.password
HTTP_PASS = tl.gnbs[0].cu.oam_http_connection_details.password
HTTP_LOGIN = tl.gnbs[0].cu.oam_http_connection_details.username

OUTPUT_DIR = BuiltIn().get_variable_value("${OUTPUT_DIR}")
SUITE_NAME = BuiltIn().get_variable_value("${SUITE_NAME}")

SCF_H_H19 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'scf_files', 'CB009576-H_H19_scf.xml')

IPHY_H_H19 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'iphy_files', 'CB009576-H_H19_iphy.xml')

WTS_H_H19 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'wts_files', 'CB009576-H_H19_wts.cfg')

AUTO_HEALING_DELTA = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files', 'auto_healing_delta.json')

THOR_L1_FRONTHAUL_PROCESS = [
    "/usr/bin/l1_application_rt"
]

MARLIN_CONTAINER_SW_CRITICAL_FAILURE_RAT_RESET = [
    "CPCL",
    "CPNB",
    "CPIF",
    "CPNRT",
    "CPRT",
    "TRACECC",
    "TRACECM"
]

PYTHON_PROCESS_LIST = [
    'tempd',
    'syscomconfig',
    'trbl_monitor',
    'trbl_daemon',
    'ecc-scanner',
    'bmu_watchdogd',
    'cocod',
    'postd',
    'log-synchronizerd',
    'memory-supervisord',
    'statusd'
]

CORE_DUMP_SWCONFIG_FLAG = [
    '0x100b7=1',
    '0x10079=300000',
    '0x1001E=1'
]
