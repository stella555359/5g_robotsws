__maintainer__ = "Harsha vardhan"
__team__ = "MN_RAN_Pz_BLR_1"
__email__ = "I_MN_RAN_PZ_BLR_SG1@internal.nsn.com"
__owner_email__ = "chittuluri.harshavardhan@nokia.com"

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
    SshServiceDetails(addr="10.43.54.234", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
# _test_pc_2 = TestPc(
#     SshServiceDetails(addr="10.42.53.233", username="ute"),
#     connections=[NetworkAddress(v4="192.168.255.126")],
# )

_pdu_1 = Gude(
    addr="10.41.155.133",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="MYCOMP",
    version="8220-1",
)

_pdu_2 = Gude(
   addr="10.41.155.159",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
   model="MYCOMP",
   version="8220-1",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9174334148",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.Y13",
    serial_number="L1223306857",
)

_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFB",
    serial_number="EA183110528",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AHIB",
    serial_number="EA174412618",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_1 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AZRB",
    serial_number="1M180528230",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AHCE",
    serial_number="EA185110089",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])
# _enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2], master=_enb_sbts_1)

_pdus = [_pdu_1, _pdu_2]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_L_1ASIM_1ABIA_1AHFB_1AHIB_1AZRB_1AHCE_CA",
)

__all__ = ["tl"]
