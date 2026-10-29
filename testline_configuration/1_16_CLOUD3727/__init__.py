# from ta_gve_conf.interface import ta_gve_conf
#
# TL1 = {
#         'HOST_IP': '10.42.62.218',
#         'FR':    {
#                 'LBALLU-Z11728000JN': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.54', 'port': 3}},
#                 'LBALLU-Z11701000LJ': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 6}},
#                 'LBALLU-Z11701000QA': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 4}},
#                 'LBALLU-YD1601033Y8': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 5}},
#                 'LBALLU-YD1602039CJ': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 6}},
#                 # 'LBALLU-YD1601033W1': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 7}},  UHIE HWS
#                 'LBALLU-YD153601YGB': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 10}},
#                 'LBALLU-YD1511004V8': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 9}},
#                 'LBALLU-YD1553031T1': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 11}}},
#     'FSM': {'L1173615740': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 7}}},
#     'BBMOD':  {'L1162818420': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 7}},
#                     'L1162808119': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 7}},
#                     'L1171212640': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 7}}}
# }
# tl = ta_gve_conf(TL1, hw_type='fsmr4')
#
# NODES = {
#     'TEAM': 'UUF',
#     'TL1': {'HOST_IP': '10.42.62.218',
#             'FR': {
#                  'LBALLU-Z11728000JN': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.54', 'port': 3}},
#                  'LBALLU-Z11701000LJ': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 6}},
#                  'LBALLU-Z11701000QA': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 4}},
#                  'LBALLU-YD1601033Y8': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 5}},
#                  'LBALLU-YD1602039CJ': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 6}},
#                  # 'LBALLU-YD1601033W1': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 7}}, UHIE HWS
#                  'LBALLU-YD153601YGB': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 10}},
#                  'LBALLU-YD1511004V8': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 9}},
#                  'LBALLU-YD1553031T1': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.52', 'port': 11}}},
#             'FSM': {'L1173615740': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 7}}},
#             'EC':  {'L1162818420': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 7}},
#                     'L1162808119': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 7}},
#                     'L1171212640': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 7}}}
#             }
#         }

__maintainer__ = "Karolina Polaczanska"
__team__ = "uuf"
__email__ = "karolina.polaczanska@nokia.com"
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
    SshServiceDetails(addr="10.42.62.218", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.42.60.54",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.42.60.52",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.42.60.55",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162818420",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162808119",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171212640",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="474403A.101",
    serial_number="L1173615740",
)

_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHBA",
    serial_number="LBALLU-Z11728000JN",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHBA",
    serial_number="LBALLU-Z11701000LJ",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHBA",
    serial_number="LBALLU-Z11701000QA",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHIE",
    serial_number="LBALLU-YD1601033Y8",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHIE",
    serial_number="LBALLU-YD1602039CJ",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHFA",
    serial_number="LBALLU-YD153601YGB",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_7 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHFA",
    serial_number="LBALLU-YD1511004V8",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_8 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHFA",
    serial_number="LBALLU-YD1553031T1",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[11],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_RF_AIL_B1_B2_B3_3UHIE_3UHFA_3UHBA",
)

__all__ = ["tl"]
