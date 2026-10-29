# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "linsun"
__email__ = "lingjie.sun@nokia-sbell.com"
__owner_email__ = "lingjie.sun@nokia-sbell.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.205.54", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.108.166.198",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="FACOM",
)
_pdu_2 = Gude(
    addr="10.108.166.200",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="FACOM",
)


# _fsp_1 = CapacityUnit(addr='None', hardware_type='ABIA', hardware_version='473096A.103',  serial_number='K9174042844')


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="EA142161814",
)

_smod_1 = Flexi([_fct_1])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.UHEF,
    serial_number="YP160708538",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1], oam_ip=NetworkAddress("10.106.205.12")
)


tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RF_F_COMMON_UHEF",
)

__all__ = ["tl"]
