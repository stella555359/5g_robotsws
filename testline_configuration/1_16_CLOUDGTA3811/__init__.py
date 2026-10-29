# from ta_gve_conf.interface import ta_gve_conf
# TL1 = {
#       'HOST_IP': '10.42.82.232',
#       'FR': {
#               '13W342R60076': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 3}},
#               '13W338R60032': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 1}},
#               '14W333R60448': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 2}}},
#       'FSM': {'L1162013277': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 11}}},
#       'EC':  {'L1171402092': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 11}}},
#       }
#
# tl = ta_gve_conf(TL1)
#
# NODES = {
#     'TEAM': 'UUF',
#     'TL1': {'HOST_IP': '10.42.82.232',
#             'FR': {'13W342R60076': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 3}},
#                    '13W338R60032': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 1}},
#                    '14W333R60448': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 2}}},
#             'FSM': {'L1162013277': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 11}}},
#             'EC':  {'L1171402092': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.60.55', 'port': 11}}}}
#     }

__maintainer__ = "Marcin Baran"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "marcin.1.baran@nokia.com"

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
    SshServiceDetails(addr="10.42.82.232", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.42.60.55",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171402092",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1162013277",
)

_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type="UHID",
    serial_number="13W342R60076",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.0", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type="UHID",
    serial_number="13W338R60032",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.1", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type="UHID",
    serial_number="14W333R60448",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RF_AIR_B4_B5_3107_1a2_3xUHID",
)

__all__ = ["tl"]
