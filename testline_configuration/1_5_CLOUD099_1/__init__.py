__owner__ = "vera he"
__maintainer__ = "vera he"
__email__ = "vera.he@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_pdu_1 = FACOM(
    addr="10.68.94.19",
    port_numbers=[3],
)

_pdu_2 = HBTE(
    addr="10.68.94.53",
    port_numbers=[4],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1215008458",
    product_code="475266A.104",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.101",
    serial_number="L1182811443",
    capacity_units=[_fsp_1],
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AEHB:eCPRI_RRH_64T64R",
    radio_type="AEHB",
    serial_number="L1212814010",
    pdu_port=_pdu_2.pdu_ports[4],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.235", username="ute", password="ute"
    ),
    connections=[
        _enb_sbts.system_module.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_AEHB_CLOUD099",
)

__all__ = ["tl"]

# #from ta_gve_conf.interface import ta_gve_conf
# from .env import *
#
# REQUIRE_PACKAGES= "Active"
#
# TL1={
#           'HOST_IP': '10.68.94.122',
#           'FR': {'L1202407675': {'pdu': {'type': 'FACOM', 'ip_addr': '10.68.94.91', 'port': 6},
#                 'qc': {'hw_config': 'Single Radio'}},
#
#               },
#          'EC': {'6Q191510126': {'pdu': {'type': 'FACOM', 'ip_addr': '10.68.94.91', 'port': 3}},
#                 },
#          'FSM':  {'L1191001901': {'pdu': {'type': 'FACOM', 'ip_addr': '10.68.94.91', 'port': 3}}}
#     }
#
#
# NODES = {
#     'TEAM': 'SISO_CRT',
#     'TL1': {
#           'HOST_IP': '10.68.94.122',
#           'FR': {'L1202407675': {'pdu': {'type': 'FACOM', 'ip_addr': '10.68.94.91', 'port': 6},
#                 'qc': {'hw_config': 'Single Radio'}},
#
#               },
#          'EC': {'6Q191510126': {'pdu': {'type': 'FACOM', 'ip_addr': '10.68.94.91', 'port': 3}},
#                 },
#          'FSM':  {'L1191001901': {'pdu': {'type': 'FACOM', 'ip_addr': '10.68.94.91', 'port': 3}}}
#     },
# }
#
#
#
#
# SW_BUILDS_DIR_PATH= "/home/ute/Downloads/"
# # RF_FACTORY_SW_STORAGE = {
# #     'LOGIN': 'siso',
# #     'PASSWORD': 'siso',
# #     'HOST_IP': '10.106.211.194',
# #     'SW_PATH': '/home/siso/LTE/Factory_SW/',
# #     'CONFIG_PATH': '/home/siso/LTE/Factory_SW/',
# #     'CONFIG_FILE': 'config.py'
# # }
#
# RF_FACTORY_SW_STORAGE = {
#     'LOGIN': 'siso',
#     'PASSWORD': 'siso',
#     'HOST_IP': '10.106.211.194',
#     'SW_PATH': '/home/siso/LTE/Factory_SW/',
#     'RRUpassword': 'bdS%ztWG3v7%SjreCVA79wTPb',
#     'IMAGE_FILE': 'rfsw-package-aehb_0x93A24039.tar',
#     'checksum': '0x93A24039',
#     'fileVersion': 'CHB01.02.R03',
#     'BuildName': 'rfsw-package-aehb_0x93A24039.tar',
#     'BuildVersion': 'CHB01.02.R03'
# }
#
#
# TESTLINE_TYPE="FlexibleShare"
#
# ALLOWED_ALARMS = ['Vendor BTS certificate',
#                   'Synchronization lost',
#                   'Diagnostic Files collected',
#                   'BTS booted at .*? due to trs management reset',
#                   '.*? ToP master service .*? unusable',
#                   'NTP Server .*?',
#                   'BTS time not corrected',
#                   'SSH enabled',
#                   'R&D Service Port enabled',
#                   'LMP access via port .*?',
#                   'BTS Reset Cause',
#                   'Beamforming Calibration Detect Continuous Exception',
#                   'Service account root access is enabled',
#                   'Ethernet port security is disabled',
#                   'Sanity Check Error'
#                   ]
