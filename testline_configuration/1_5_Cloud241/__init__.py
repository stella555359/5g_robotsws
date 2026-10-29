__owner__ = "Wang Deli"
__maintainer__ = "Wang Deli"
__email__ = "deli.wang@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_pdu_1 = FACOM(
    addr="10.108.190.66",
    port_numbers=[5,8],
)

_pdu_2 = HBTE(
    addr="10.108.190.67",
    port_numbers=[1],
)

_pdu_3 = FPFH(
    addr="10.108.190.68",
    port_numbers=[2],
)

_pdu_4 = FPFH(
    addr="10.108.190.74",
    port_numbers=[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="DH204663017",
    pdu_port=_pdu_1.pdu_ports[5],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA213850686",
    pdu_port=_pdu_1.pdu_ports[5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204601124",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233400602",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="473764A.101",
    serial_number="L1213511653",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1213506778",
    capacity_units=[_fsp_4],
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

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="AEHC:eCPRI_RRH_64T64R",
    radio_type="AEHC",
    serial_number="L1202407675",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="AHFII:FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245001213",
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="AHLOA:FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1930G11T8",
    pdu_port=_pdu_4.pdu_ports[3],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_2, _rmod_3])
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_1], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.97", username="ute", password="uteUTE!"
    ),
    connections=[
        _enb_sbts_1.system_module.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.40", username="ute", password="UTE.debian12"
    ),
    connections=[
        _enb_sbts_2.system_module.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_4G_5G_CLASSICAL_ASIB_ABIO_AEHC_CLOUD241",
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
