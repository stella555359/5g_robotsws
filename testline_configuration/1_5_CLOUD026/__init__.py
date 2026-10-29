__owner__ = "Dong Vinton"
__maintainer__ = "Dong Vinton"
__email__ = "vinton.dong@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.101", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = FACOM(addr="10.56.7.187", port_numbers=[6])
_pdu_2 = FACOM(addr="10.56.7.125", port_numbers=[2])
_pdu_3 = FACOM(addr="10.106.211.86", port_numbers=[1, 3])
_pdu_4 = APC(addr="10.56.7.252", port_numbers=[3, 4])

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174907907",
    pdu_port=_pdu_1.pdu_ports[6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1203506116",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.101", username="ute", password="ute"
    ),
    connections=[_fct_1],
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

_rmod_1 = RU(
    ru_hw_group="AZNA",
    radio_type="FZNI",
    serial_number="6Q190208576",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FZNI",
    radio_type="FZNI",
    serial_number="RY130213418",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="FZNI",
    radio_type="FZNI",
    serial_number="RY144823465",
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="AZND",
    radio_type="FZNI",
    serial_number="6Q182201472",
    pdu_port=_pdu_4.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="AZND",
    radio_type="FZNI",
    serial_number="6Q181911570",
    pdu_port=_pdu_4.pdu_ports[4],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5])
# _enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1, _test_pc_2], enbs=[_enb_sbts_1, _enb_sbts_2])
tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts_1],
    appserver=_appserver,
)

__all__ = ["tl"]

# # # from ta_gve_conf.interface import ta_gve_conf
# # from .env import *
#
# # TL1 = {
# #        'HOST_IP': '10.106.213.101',
# #        'FR': {'6Q175121188': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.125', 'port': 4},#FHDI[35]
# #                               'fiber_length': {'physical_port0': 80, 'delta': 30},
# #                               'link_proto': 'CL9',
# #                               'feg_without_mha': 30,
# #                               'chain': '1.1.1.1',
# #                               'qc': {'hw_config': 'Single Radio'}},
# #               # 'L1162105358': {'pdu': {'type': 'APC', 'ip_addr': '10.69.80.250', 'port': 1},#FHDI[35]
# #               #                 'fiber_length': {'physical_port0': 36, 'delta': 30},
# #               #                 'link_proto': 'CL9',
# #               #                 'feg_without_mha': 30,
# #               #                 'chain': '1.2.1.1',
# #               #                 'qc': {'hw_config': 'Single Radio'}},
# #               },
# #     'BBMOD': {'L1172110772': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.187', 'port': 6}},
# #
# #               },
# #        'FSM':  {'L0987654321': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.187', 'port': 6}}}  #hw_version: X21, X31, A101; hw_type: FSME, FSMF, FSIP, FSIH
# # }
#
# # tl = ta_gve_conf(TL1, hw_type="fsmr4", fr=False)
# # tl = ta_gve_conf(TL1, hw_type="fsmr4",fr=True)
# # node1 = tl[1]
#
# NODES = {
#     'TEAM': 'SISO_CRT',
#     'TL1': {
#           'HOST_IP': '10.106.213.101',
#           'FR': {'6Q175121188': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.125', 'port': 4},#AHED
#                               'fiber_length': {'physical_port0': 15.93, 'physical_port1': 2, 'delta': 30},
#                               'link_proto': 'O3',
#                               'feg_without_mha': 30,
#                               'chain': '1.1.1',
#                               'qc': {'hw_config': 'Single Radio'}},
#
#                  '6Q173104565': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.125', 'port': 2},#AZNA[35]
#                               'fiber_length': {'physical_port0': 36, 'delta': 30},
#                               'link_proto': 'CL9',
#                               'feg_without_mha': 30,
#                               'chain': '1.2.1.1',
#                               'qc': {'hw_config': 'Single Radio'}},
#                 },
#
#           'EC': {'6Q174907907': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.187', 'port': 6}},
#                 },
#           'FSM':  {'L0987654321': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.187', 'port': 6}}}
#     },
# }
#
# # tl = ta_gve_conf(TL1, hw_type="fsmr4")
# # SiSo additional variables
#
# #SCFC_REFERENCE_FILE_PATH= "/home/ute/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT1/Airscale_RB_ALU/SCFC_1.xml"
# #SCFC_REFERENCE_FILE_PATH= "/home/ute/robotlte/config/Hangzhou/1_5_CLOUD023/node1/BTS_CLOUD_RF_AIR_B1-B2_CRT1_1023_TL18.xml"
# #SCFC_REFERENCE_FILE_PATH= "/home/ute/robotlte/config/Hangzhou/1_5_CLOUD012/node1/BTS_CLOUD_RF_AIL_B1-B3_CRT1_1007_TL00.xml"
# #SCFC_REFERENCE_FILE_PATH= "/home/ute/robotlte/config/Hangzhou/1_5_CLOUD012/node1/BTS_CLOUD_RF_AIL_B1-B3_CRT1_1007_SRAN18A.xml"
# #SCFC_REFERENCE_FILE_PATH= "/home/ute/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT1/R4P12_CRT1_02/SCFC_CIT.xml"
#
# #SW_BUILDS_DIR_PATH= "/home/ute/SW/FL17SP"
# SW_BUILDS_DIR_PATH= "/home/ute/Downloads/"
#
# # RF_FACTORY_SW_STORAGE = {
# #     'LOGIN': 'siso',
# #     'PASSWORD': 'siso',
# #     'HOST_IP': '10.106.211.170',
# #     'SW_PATH': '/home/siso/LTE/Factory_SW/',
# #     'CONFIG_PATH': '/home/siso/LTE/Factory_SW/',
# #     'CONFIG_FILE': 'config.py'
# # }
#
# ALLOWED_ALARMS = ['Vendor BTS certificate',
#                   'Synchronization lost',
#                   'Diagnostic Files collected',
#                   'BTS booted at .*? due to trs management reset',
#                   '.*? ToP master service .*? unusable',
#                   'NTP Server .*? unavailable',
#                   'SSH enabled',
#                   'R&D Service Port enabled',
#                   'LMP access via port.*',
#                   'BTS internal SW management problem',
#                   'Failure in optical interface',
#                   'Receiving failure in Optical Interface',
#                   'Unsigned software release has been successfully downloaded',
#                   'Cell disabled due to unknown problem; logs collected',
#                   'Unsigned software release has been successfully downloaded',
#                   'Service account root access is enabled',
#                   'Ethernet port security is disabled',
#                   'Sanity Check Error'
#                   ]
#
# REQUIRE_PACKAGES= "Active"
#
# RF_FACTORY_SW_STORAGE = {
#     'LOGIN': 'siso',
#     'PASSWORD': 'siso',
#     'HOST_IP': '10.106.211.194',
#     'SW_PATH': '/home/siso/LTE/Factory_SW/',
#     'RRUpassword': '',
#     'IMAGE_FILE': 'FRM-rfsw-image-install_20170901151555-multi.tar',
#     'checksum': '0xd516d872',
#     'fileVersion': 'install_20170901151555-multi',
#     'BuildName': 'FRM57.08.R03C',
#     'BuildVersion': 'FRM57.08.R03C'
# }
