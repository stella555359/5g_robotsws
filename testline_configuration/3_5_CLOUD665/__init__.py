# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "haifhuan"
__email__ = "haifeng.huang@nokia-sbell.com"
__owner_email__ = "haifeng.huang@nokia-sbell.com"

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


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.51", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.108.151.78",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_2 = Gude(
    addr="10.108.151.61",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_3 = Gude(
    addr="10.108.166.203",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q181636092",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9173315815",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="6Q181221468",
)

_smod = Airscale([_fct_1])

# _rmod_1 = RU(ru_hw_group='', serial_number='RY144109590', pdu_port=_pdu_1.pdu_ports[1])
_rmod_1 = RU(
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZNB",
    serial_number="6Q183912454",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="L1180603038",
    pdu_port=_pdu_3.pdu_ports[6],
)

_enb_sbts = RealEnb(
    system_module=_smod, rms=[_rmod_1, _rmod_2], oam_ip=NetworkAddress("10.108.151.128")
)

_rnc = RNC(
    rnc_id=301,
    oms_ip=NetworkAddress("10.108.151.128"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.171.138", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_mcBSC34",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.107.151.137", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_AIL_B1_AZNB_Oper2_CRT2572",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
