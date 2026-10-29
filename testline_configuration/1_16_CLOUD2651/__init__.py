__maintainer__ = "Piotr Baranowski"
__team__ = "siso"
__email__ = "piotr.baranowski@nokia.com"
__owner_email__ = "piotr.baranowski@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.198", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.197", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.45.168.75", [2, 3, 6, 8, 9, 11, 12], "EPC", "")
_pdu_2 = Gude("10.45.168.79", [1, 2, 3, 7, 11, 12], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIL",
    serial_number="L1194703262",
    pdu_port=_pdu_1.pdu_ports[11],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    serial_number="L1162604075",
    pdu_port=_pdu_1.pdu_ports[12],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIK",
    serial_number="L1200104568",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIB",
    serial_number="L1192401204",
)

_node_1 = Airscale([_fct_1])
_node_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="EA193810249",
    pdu_port=_pdu_1.pdu_ports[3],
)  # FRPD_1
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="EA193810292",
    pdu_port=_pdu_1.pdu_ports[6],
)  # FRPD_2
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="EA193610702",
    pdu_port=_pdu_1.pdu_ports[9],
)  # FRPD_3
_rmod_4 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="L1145003737",
    pdu_port=_pdu_1.pdu_ports[2],
)  # FHFB
_rmod_5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9173913035",
    pdu_port=_pdu_2.pdu_ports[1],
)  # FRGY rfsharing
_rmod_6 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="6Q165321585",
    pdu_port=_pdu_2.pdu_ports[2],
)  # FRIG
_rmod_7 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9162008133",
    pdu_port=_pdu_2.pdu_ports[3],
)  # FXEB
_rmod_8 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="1M204604291",
    pdu_port=_pdu_2.pdu_ports[11],
)  # AHPE_1
_rmod_9 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="1M204604170",
    pdu_port=_pdu_2.pdu_ports[12],
)  # AHPE_2
_rmod_10 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="1M204604163",
    pdu_port=_pdu_2.pdu_ports[7],
)  # AHPE_3
_rmod_11 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9190906179",
    pdu_port=_pdu_1.pdu_ports[8],
)  # AHEGB 4G

_du_1 = DU(
    _node_1,
    rus=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
    ],
)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.45.168.109"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=1459)
_enb_sbts_2 = RealEnb(system_module=_node_2, rms=[_rmod_11])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts_2],
)

__all__ = ["tl"]
# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# NODES = {
#     'TEAM': 'SISO_CRT',
#     'TL1': {
#         'HOST_IP': '10.42.121.198',
#         'FR': {
#                 'EA193810249': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 3},#FRPD
#                       'fiber_length': {'physical_port0': 5, 'physical_port1': 7, 'physical_port2': 3, 'delta': 20},
#                       'link_proto': 'O6',
#                       'feg_without_mha': 30,
#                       'qc': {'hw_config': '#3617_CL_3d'}},
#                 'EA193810292': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 6},#FRPD
#                       'fiber_length': {'physical_port0': 5, 'physical_port1': 7, 'physical_port2': 3, 'delta': 20},
#                       'link_proto': 'O6',
#                       'feg_without_mha': 30,
#                       'qc': {'hw_config': '#3617_CL_3d'}},
#                 'EA193610702': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 9},#FRPD
#                       'fiber_length': {'physical_port0': 5, 'physical_port1': 7, 'physical_port2': 3, 'delta': 20},
#                       'link_proto': 'O6',
#                       'feg_without_mha': 30,
#                       'qc': {'hw_config': '#3617_CL_3d'}},
#                 'L1145003737': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 2},#FHFB
#                       'fiber_length': {'physical_port0': 5, 'physical_port1': 7, 'physical_port2': 3, 'delta': 20},
#                       'link_proto': 'O6',
#                       'feg_without_mha': 30,
#                       'qc': {'hw_config': '#3617_CL_3d'}},
#                 'K9173913035': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.79', 'port': 1},#FRGY
#                       'fiber_length': {'physical_port0': 5, 'physical_port1': 7, 'physical_port2': 3, 'delta': 20},
#                       'link_proto': 'O6',
#                       'feg_without_mha': 30,
#                       'qc': {'hw_config': '#3617_CL_3d'}},
#                 '6Q165321585': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.79', 'port': 2},#FRIG
#                       'fiber_length': {'physical_port0': 5, 'physical_port1': 7, 'physical_port2': 3, 'delta': 20},
#                       'link_proto': 'O6',
#                       'feg_without_mha': 30,
#                       'qc': {'hw_config': '#3617_CL_3d'}},
#                 'K9162008133': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.79', 'port': 3},#FXEB
#                       'fiber_length': {'physical_port0': 5, 'physical_port1': 7, 'physical_port2': 3, 'delta': 20},
#                       'link_proto': 'O6',
#                       'feg_without_mha': 30,
#                       'qc': {'hw_config': '#3617_CL_3d'}},
#
#
#              },
#
#         'FSM': {'L1200104568': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 11}}},#5G
#                 # 'L1192401204': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 6}}},#4G
#         'EC':  {'L1194703262': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.168.104', 'port': 11}}},
#         'FHS': {'6Q200303826': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 7}}},#FHS
#         'FHS_FAN': {'fhsfan1932': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 1}},
#                     'fhsfan1933': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 4}}},
#             },
#
#     'TL2': {
#         'HOST_IP': '10.42.121.197',
#         'FR': {
#                 'K9190906179': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 8},#AHEGB
#                       'fiber_length': {'physical_port0': 5, 'physical_port1': 7, 'physical_port2': 3, 'delta': 20},
#                       'link_proto': 'O6',
#                       'feg_without_mha': 30,
#                       'qc': {'hw_config': '#3617_CL_3d'}},
#               },
#
#         'FSM': {'L1192401204': {'pdu': {'type': 'EPC', 'ip_addr': '10.45.168.75', 'port': 12}}},#4G
#         'EC':  {'L1162604075': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.168.104', 'port': 11}}},
#         }
# }
#
# # SiSo additional variables
#
# SCFC_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Wroclaw/1_16_CLOUD3813/node1/BTS_CLOUD_RF_AILR_B1-6_CRT16_CHM_01_FL18.xml"
# SW_BUILDS_DIR_PATH = "/home/ute/SW/"
#
#
#
# ALLOWED_ALARMS = ['Vendor BTS certificate',
#                   'Synchronization lost',
#                   'Diagnostic Files collected',
#                   'Diagnostic Files collected',
#                   'BTS booted at .*? due to trs management reset',
#                   '.*? ToP master service .*? unusable',
#                   'NTP Server .*?',
#                   'BTS time not corrected']
#
#
