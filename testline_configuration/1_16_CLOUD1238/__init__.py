# from ta_gve_conf.interface import ta_gve_conf
#
#
# TL1 = {
#       'HOST_IP': '10.42.62.125',
#       'FR':     {'K9170950516': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 9}},
#                  'K9161558865': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 8}},
#                  'K9161911075': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 7}},
#                  'K9144905714': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 6}},
#                  'L6153800666': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 5}},
#                  'K9144725062': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 4}},
#                  'F7164917483': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 3}},
#                  'F7164823180': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 2}}},
#       'FSM':    {'L1171207367': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 10}}},
#       'BBMOD':  {'L1171216194': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 10}},
#                  'K9172606309': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 10}}}
#        }
#
# tl = ta_gve_conf(TL1, hw_type='fsmr4')
#
#
# NODES = {
#     'TEAM': 'UUF',
#     'TL1': {'HOST_IP': '10.42.62.125',
#             'FR':     {'K9170950516': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 9}},
#                        'K9161558865': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 8}},
#                        'K9161911075': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 7}},
#                        'K9144905714': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 6}},
#                        'L6153800666': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 5}},
#                        'K9144725062': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 4}},
#                        'F7164917483': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 3}},
#                        'F7164823180': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 2}}},
#             'FSM':    {'L1171207367': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 10}}},
#             'EC':     {'L1171216194': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 10}},
#                        'K9172606309': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.86', 'port': 10}}}
#             }
# }
#
#
# TA_UE_CONFIG = '/home/ute/robotlte/config/Wroclaw/1_16_CLOUD1238/GVE_WRO_CLOUD1238.yml'

__maintainer__ = "Karolina Polaczanska"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "karolina.polaczanska@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.125", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.42.60.86",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163112858",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172606309",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1171214660",
)

_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type="FRMA",
    serial_number="K9170950516",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type="FRMA",
    serial_number="K9161558865",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type="FXEE",
    serial_number="K9161911075",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type="FRHA",
    serial_number="K9144905714",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_5 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type="FRGS",
    serial_number="L6153800666",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_6 = RU(
    ru_hw_group="FRMr2.2_2T4R_Medusa",
    radio_type="FXCC",
    serial_number="K9144725062",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_7 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRMC",
    serial_number="F7164917483",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_8 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7164823180",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[2],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_pdus = [_pdu_1]

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_RF_AIR_B4_B5_2FRMA_FXED_FRMC_FXEE_FRHA_FRGS_FXCC",
)

__all__ = ["tl"]
