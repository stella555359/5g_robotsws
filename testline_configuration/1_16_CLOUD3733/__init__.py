__maintainer__ = "Kamil Szczesniak"
__team__ = "uuf"
__email__ = "kamil.szczesniak@nokia.com"
__owner_email__ = "kamil.szczesniak@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
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
    SshServiceDetails(addr="10.42.62.224", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.62.223", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.42.60.56", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.60.57", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS173810857",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS173810828",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.127", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="AS173605959",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.127", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="FSME",
    hardware_version="473095A.101",
    serial_number="1M145026207",
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type="FRGP",
    serial_number="K9113232012",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type="FRGP",
    serial_number="L6124808240",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7174200811",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7174200809",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="FRMr4.3a_2T2R_Halo",
    radio_type="FHKA",
    serial_number="EA172554709",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="FRMr4.3a_2T2R_Halo",
    radio_type="FHKA",
    serial_number="EA172753928",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_7 = RU(
    ru_hw_group="FRMr4.3a_2T2R_Halo",
    radio_type="FHKA",
    serial_number="EA172753931",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[3],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_RFS_FCC_WL20008_2xFXDA_2xFRGP_3xFHKA",
)

__all__ = ["tl"]


# from ta_gve_conf.interface import ta_gve_conf
#
# TL1 = {
#         'HOST_IP': '10.42.62.224',
#         'FR': {'K9113232012': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 5}},
#                 'L6124808240': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 6}},
#                 'F7174200811': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 4}},
#                 'F7174200809': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 3}},
#                 'EA172554709': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.57', 'port': 1}},
#                 'EA172753928': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.57', 'port': 2}},
#                 'EA172753931': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.57', 'port': 3}}},
#         'FSM': {'AS173605959': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 7}}},
#         'BBMOD': {'AS173810857': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 7}},
#                  'AS173810828': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 7}}}
#
#     }
#
# TL2 = {
#         'HOST_IP': '10.42.62.223',
#         'FSM': {'1M145026207': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 8}}},
# }
#
# tl = ta_gve_conf(TL1)
#
# NODES = {
#        'TEAM': 'UUF',
#
#     'TL1': {'HOST_IP': '10.42.62.224',
#         'FR': {'K9113232012': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 5}},
#                 'L6124808240': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 6}},
#                 'F7174200811': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 4}},
#                 'F7174200809': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 3}},
#                 'EA172554709': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.57', 'port': 1}},
#                 'EA172753928': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.57', 'port': 2}},
#                 'EA172753931': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.57', 'port': 3}}},
#         'FSM': {'AS173605959': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 7}}},
#         'EC': {'AS173810857': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 7}},
#                  'AS173810828': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 7}}}
#
#             },
#
#       'TL2': {'HOST_IP': '10.42.62.223',
#       'FSM': {'1M145026207': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.56', 'port': 8}}}
#         }
#     }
