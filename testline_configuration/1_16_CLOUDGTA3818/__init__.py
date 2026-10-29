__maintainer__ = "Agnieszka Brzoska"
__team__ = "uuf"
__email__ = "agnieszka.brzoska@nokia.com"
__owner_email__ = "agnieszka.brzoska@nokia.com"

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
    SshServiceDetails(addr="10.42.82.239", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.42.80.233", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171402053",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1173810150",
)

_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHIB",
    serial_number="LBALLUPNS1443E8560",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHIB",
    serial_number="LBALLUPNS1438E8231",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.0", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHIB",
    serial_number="LBALLUPNS1443E8553",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.1", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RF_AIL_B1_3107_1a2_3xUHIB",
)

__all__ = ["tl"]

# from ta_gve_conf.interface import ta_gve_conf
#
# TL1 = {
#     'HOST_IP': '10.42.82.239',
#     'FR': {'LBALLUPNS1438E8231': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 2}},
#             'LBALLUPNS1443E8560': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 3}},
#             'LBALLUPNS1443E8553': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 1}}},
#     'FSM':  {'L1171503055': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 5}}},
#     'BBMOD': {'K9172230584': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 5}}},
#
# }
#
# tl = ta_gve_conf(TL1)
#
#
# NODES = {
#     'TEAM': 'UUF',
#     'TL1': {'HOST_IP': '10.42.82.239',
#     'FR': {'LBALLUPNS1438E8231': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 2}},
#             'LBALLUPNS1443E8560': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 3}},
#             'LBALLUPNS1443E8553': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 1}}},
#     'FSM': {'L1171503055': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 5}}},
#     'EC': {'K9172230584': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.233', 'port': 5}}},
#             }
# }
