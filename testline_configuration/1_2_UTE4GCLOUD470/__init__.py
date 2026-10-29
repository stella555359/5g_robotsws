__maintainer__ = "Arpit Jhala"
__team__ = "MN_RAN_Pz_BLR_5"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "arpit.jhala@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.43.54.225", username="ute", password="BT5l@bus3rl0g1n"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
# _test_pc_2 = TestPc(
#     SshServiceDetails(addr="10.42.62.141", username="ute"),
#     connections=[NetworkAddress(v4="192.168.255.126")],
# )

_pdu_1 = Gude(
    addr="10.41.155.171",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="MYCOMP",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.41.155.175",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="MYCOMP",
    version="8220-1",
)
# _pdu_3 = Gude(
#     addr="10.41.155.144",
#     port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
#     model="EPC",
#     version="8220-1",
# )
# _pdu_2 = Gude(
#     addr="10.42.80.61",
#     port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
#     model="EPC",
#     version="8221-1",
# )

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170201080",
 )
# _fsp_2 = CapacityUnit(
#     addr="192.168.253.24",
#     hardware_type="ABIA",
#     hardware_version="473096A.104",
#     serial_number="L1173514746",
# )
# _fsp_3 = CapacityUnit(
#     addr="192.168.253.36",
#     hardware_type="ABIA",
#     hardware_version="473096A.103",
#     serial_number="L1171212687",
# )
# _fsp_4 = CapacityUnit(
#     addr="192.168.253.40",
#     hardware_type="ABIA",
#     hardware_version="473096A.103",
#     serial_number="L1172902988",
# )

# _fct_1 = CommonUnit(
#     SshServiceDetails(
#         addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     capacity_units=[_fsp_1],
#     pdu_port=_pdu_1.pdu_ports[2],
#     hardware_type="ASIL",
#     hardware_version="474767A.101,
#     serial_number="L1203506193",
# )
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1203506193",
)

_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEB",
    serial_number="EA192276335",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    radio_type="AHEGA",
    serial_number="K9184300882",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2])
# _enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2], master=_enb_sbts_1)

_pdus = [_pdu_1, _pdu_2]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_L_1ASIL_1ABIA_1AHEB_1AHEGA",
)

__all__ = ["tl"]
