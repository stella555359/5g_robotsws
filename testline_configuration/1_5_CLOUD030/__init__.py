__owner__ = "qling"
__maintainer__ = "qling"
__email__ = "ling>qin@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.105", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.56.7.213",
    port_numbers=[1],
    model="facom",
)

_rmod_1 = RU(
    ru_hw_group="FZQE:CPRI_RP1_4T4R",
    serial_number="EA181311188",
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FZQE:CPRI_RP1_4T4R",
    serial_number="RY155302644",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBA",
    hardware_version="472182A.103",
    serial_number="L1133901259",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBA",
    hardware_version="472182A.103",
    serial_number="L1133610980",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="F7163132961",
    capacity_units=[_fsp_1, _fsp_2],
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

_smod = Flexi([_fct_1])
_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_FAA_CRT2_1030",
)

__all__ = ["tl"]
# from ta_gve_conf.interface import ta_gve_conf
# from .env import *
#
# NODES = {
#     'TEAM': 'SISO_CRT',
#     'TL1': {
#           'HOST_IP': '10.106.213.105',
#           'FR': {#'RY155302637': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.213', 'port': 2},#FZQE1
#                  #              'fiber_length': {'physical_port0': 80, 'delta': 30},
#                  #              'link_proto': 'CL9',
#                  #              'feg_without_mha': 30,
#                  #              'chain': '1.1.1.1',
#                  #              'qc': {'hw_config': 'Single Radio'}},
#                  # 'RY155302644': {'pdu': {'type': 'APC', 'ip_addr': '10.56.7.213', 'port': 2},#FZQE2
#                  #              'fiber_length': {'physical_port0': 36, 'delta': 30},
#                  #              'link_proto': 'CL9',
#                  #              'feg_without_mha': 30,
#                  #              'chain': '1.2.1.1',
#                  #              'qc': {'hw_config': 'Single Radio'}},
#                  # 'EA163311870': {'pdu': {'type': 'APC', 'ip_addr': '10.56.7.213', 'port': 2},  #FZQE3
#                  #                 'fiber_length': {'physical_port0': 36, 'delta': 30},
#                  #                 'link_proto': 'CL9',
#                  #                 'feg_without_mha': 30,
#                  #                 'chain': '1.2.1.1',
#                  #                 'qc': {'hw_config': 'Single Radio'}},
#                  # 'RY163900436': {'pdu': {'type': 'APC', 'ip_addr': '10.56.7.213', 'port': 2},  #FZQE4
#                  #                 'fiber_length': {'physical_port0': 36, 'delta': 30},
#                  #                 'link_proto': 'CL9',
#                  #                 'feg_without_mha': 30,
#                  #                 'chain': '1.2.1.1',
#                  #                 'qc': {'hw_config': 'Single Radio'}},
#                  # 'EA173716237': {'pdu': {'type': 'APC', 'ip_addr': '10.56.7.213', 'port': 2},  #FZQE5
#                  #                 'fiber_length': {'physical_port0': 36, 'delta': 30},
#                  #                 'link_proto': 'CL9',
#                  #                 'feg_without_mha': 30,
#                  #                 'chain': '1.2.1.1',
#                  #                 'qc': {'hw_config': 'Single Radio'}},
#                  # 'RY155207077': {'pdu': {'type': 'APC', 'ip_addr': '10.56.7.213', 'port': 2},  #FZQE6
#                  #                 'fiber_length': {'physical_port0': 36, 'delta': 30},
#                  #                 'link_proto': 'CL9',
#                  #                 'feg_without_mha': 30,
#                  #                 'chain': '1.2.1.1',
#                  #                 'qc': {'hw_config': 'Single Radio'}},
#                 },
#
#           'EC': {'L1133901259': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.213', 'port': 1}},
#                 'L1133610980': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.213', 'port': 1}},
#                 },
#            'FSM':  {'F7163111304': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.213', 'port': 1}}}
#     },
# }
#
# #tl = ta_gve_conf(TL1, hw_type="fsmr3")
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
# TESTLINE_TYPE = "Flexible" #this type is for GG
# REQUIRE_PACKAGES= "Active"
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
#                   'BTS Reset Cause',
#                   'Service account root access is enable',
#                   'Ethernet port security is disabled',
#                   'Sanity Check Error'
#                   ]
#
