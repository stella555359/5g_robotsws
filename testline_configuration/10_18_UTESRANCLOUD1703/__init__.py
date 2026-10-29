# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "None"
__email__ = "None"

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
    SshServiceDetails(addr="10.5.20.32", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.33", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.255.1.8", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.1.9", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_OPENED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS171630802",
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK170231180",
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS171630739",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="F7163523349",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="F7163523308",
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGX,
    serial_number="EA163510243",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.228", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGX,
    serial_number="EA163510197",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.226", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXJB,
    serial_number="K9171116608",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.230", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXJB,
    serial_number="K9170226105",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.198", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHDB,
    serial_number="6Q190905756",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.225", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_4],
    oam_ip=NetworkAddress("10.15.236.103"),
    instance_id=10703,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_5], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2


_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
    ),
)

_bsc = BSC(
    name="BSC_SARA_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.92.14.108", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LW_1FSMF_1FBBC_1FSMF_2FBBC_2FRGX_2FXJB_1AHDB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
