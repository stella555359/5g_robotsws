# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Anna Maciejewska"
__email__ = "anna.maciejewska@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.130", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.44.167.97", [3, 5, 11], "EPC", "")
_pdu_2 = Gude("10.44.167.111", [10], "EPC", version="8221-1")


_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:1101",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1220804864",
)
_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:233d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173831139",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1192403287",
)


_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHFII,
    serial_number="BL2222N407Q",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.131",
        username="rfsw",
        password="0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=",
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB,
    serial_number="BL1914V018F",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password="root"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB,
    serial_number="BL2215V011G",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password="root"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.44.166.99"),
    instance_id=1107,
)


_rnc = RNC(
    rnc_id=38,
    oms_ip=NetworkAddress("10.44.44.219"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.74", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_mcBSC32",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.4.132", username="SYSTEM", password="SYSTEM1"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
