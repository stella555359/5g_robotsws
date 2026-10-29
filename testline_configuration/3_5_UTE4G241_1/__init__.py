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
    SshServiceDetails(addr="10.68.195.178", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.68.195.179", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.106.243.49", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")
_pdu_2 = Gude("10.106.243.44", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")
_pdu_3 = Gude("10.106.243.47", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170306532",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211511290",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="FBBA",
    hardware_version="472182A.102",
    serial_number="L6132218051",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212562677",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_3.pdu_ports[4],
    hardware_type="FSMF",
    hardware_version="084792A.105",
    serial_number="EA173863758",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Flexi([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXCA,
    serial_number="L1112901240",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.202", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_4T4R",
    radio_type=RadioTypes.AHEGC,
    serial_number="EA210555996",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_2T4R",
    radio_type=RadioTypes.AHPD,
    serial_number="6Q203001054",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.106.243.16"),
    instance_id=10034,
)


_rnc = RNC(
    rnc_id=505,
    oms_ip=NetworkAddress("10.107.118.211"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.171.138", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_mcBSC1",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.107.151.150", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIO_1FSMF_1FBBA_1FXCA_1AHEGC_1AHPD",
    bscs=[_bsc],
    rncs=[_rnc],
)
# CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIO_1FSMF_1FBBA_1FXCA_1AHEGC_1AHPD

__all__ = ["tl"]
