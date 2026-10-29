# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "nanli"
__email__ = "nan.3.li@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.205.57", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.205.58", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.108.151.210",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="HBTE",
)
_pdu_2 = Gude(
    addr="10.108.151.88",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="FACOM",
)
_pdu_3 = Gude(
    addr="10.108.166.202",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="FACOM",
)
_pdu_4 = Gude(
    addr="10.108.166.201",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="FACOM",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212650627",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1174201714",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1182603804",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.101",
    serial_number="DH212563170",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.101",
    serial_number="L1185203389",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXEB,
    serial_number="1M182605929",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.161", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXCA,
    serial_number="K9151716311",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.34", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXED,
    serial_number="1M181944809",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.33", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[6],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1], oam_ip=NetworkAddress("10.108.151.211")
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2, _rmod_3], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_rnc = RNC(
    rnc_id=505,
    oms_ip=NetworkAddress("10.107.118.211"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.171.138", username="nokiadmin", password="system"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_RF_AILR_B1_B6_OAM_COMMON_MDEA_FXED",
    rncs=[_rnc],
)

__all__ = ["tl"]
