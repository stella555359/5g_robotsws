__maintainer__ = "Kamil Szczesniak"
__team__ = "uuf"
__email__ = "kamil.szczesniak@nokia.com"
__owner_email__ = "kamil.szczesniak@nokia.com"

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
    SshServiceDetails(addr="10.42.83.158", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.42.199.197", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.80.233", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602162",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1171214662",
)

_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type="UHLA",
    serial_number="12W354Z10296",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.0", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type="UHLA",
    serial_number="12W357Z10036",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.1", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)


_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RF_AIR_B1_2722_1g1_2xUHLA",
)

__all__ = ["tl"]
# from ta_gve_conf.interface import ta_gve_conf
#
# TL1 = {
#     'HOST_IP': '10.42.83.158',
#     'FR':    {
#                 '12W357Z10036': {'pdu': {'type': 'APC', 'ip_addr': '10.42.199.197', 'port': 8}},
#                 '12W354Z10296': {'pdu': {'type': 'APC', 'ip_addr': '10.42.199.197', 'port': 7}}},
#     'FSM': {'L1171214662': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 10}}},
#     'BBMOD':  {'L1173602162': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 10}}},
# }
# tl = ta_gve_conf(TL1, hw_type='fsmr4')
#
# NODES = {
#     'TEAM': 'UUF',
#     'TL1': {'HOST_IP': '10.42.83.158',
#             'FR': {
#                 '12W357Z10036': {'pdu': {'type': 'APC', 'ip_addr': '10.42.199.197', 'port': 8}},
#                 '12W354Z10296': {'pdu': {'type': 'APC', 'ip_addr': '10.42.199.197', 'port': 7}}},
#             'FSM': {'L1171214662': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 10}}},
#             'EC':  {'L1173602162': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 10}}},
#             }
#         }
