# NODES = {
#     'TEAM': 'OAM',
# 	'TL1': {'HOST_IP': '10.42.62.36',
#       		'FR': 	{'YP152501FB3': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.107', 'port': 11}},
# 			 		 'YP154803035': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.107', 'port': 12}},
#              		 'YP1602004B0': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.107', 'port': 10}}},
# 	 		'FSM': 	{'L1173106361': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.107', 'port': 3}}},
# 	  		'EC': 	{'L1171213709': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.107', 'port': 3}},
# 					 'L1171218103': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.107', 'port': 3}},
# 					 'L1171209708': {'pdu': {'type': 'EPC', 'ip_addr': '10.42.80.107', 'port': 3}}}}
# }


__maintainer__ = "Piotr Linek"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "piotr.linek@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.36", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.42.80.107",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A",
    serial_number="L1171213709",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A",
    serial_number="L1171218103",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A",
    serial_number="L1172915183",
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIA",
    hardware_version="473095A",
    serial_number="L1173106361",
)

_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="UZHB",
    radio_type="UZHB",
    serial_number="YP152501FB3",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)

_rmod_2 = RU(
    ru_hw_group="UZHB",
    radio_type="UZHB",
    serial_number="YP154803035",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.0", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)

_rmod_3 = RU(
    ru_hw_group="UZHB",
    radio_type="UZHB",
    serial_number="YP1602004B0",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.1", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])

_pdus = [_pdu_1]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_RF_AIL_B1_B3_3063_2CO1_T3_L_7_3xUZHB",
)

__all__ = ["tl"]
