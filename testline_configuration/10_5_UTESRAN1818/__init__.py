__maintainer__ = "maintainer name"
__email__ = "maintainer mail"

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
    default_ssh_connection_details=SshServiceDetails(
        addr="10.97.78.51", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.97.78.52", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu = Gude(addr="10.97.78.72", port_numbers=[1, 2, 3, 4], model="FACOM")

_fsp_1 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="EA180320519",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="EA142867252",
    capacity_units=[_fsp_1],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="EA142867281",
    capacity_units=[],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(ru_hw_group="", serial_number="1M175162506", pdu_port=_pdu.pdu_ports[3])

_rmod_2 = RU(ru_hw_group="", serial_number="1M175162408", pdu_port=_pdu.pdu_ports[4])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1], oam_ip=NetworkAddress("10.68.159.210")
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_rnc = RNC(
    rnc_id=511,
    oms_ip=NetworkAddress("10.68.171.228"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.69.28.173", username="root", password="root"
    ),
)

_bsc = BSC(
    name="BSC_Leopard",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.107.151.140", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_1FSMF_1FBBC_1FSMF_2FXJC_1818",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
