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
from taf.config.testline.pdu import HBTE


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.253.63", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.253.64", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.106.253.42", 
    port_numbers=[2, 4, 5, 6, 8], 
    model="FACOM",
)
_pdu_2 = HBTE(
    addr="10.106.253.6", 
    port_numbers=[2, 3], 
    model="FACOM",
)

_fsp_1 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.102", serial_number="L1163615155"
)

_fsp_2 = CapacityUnit(
    addr="", hardware_type="ABIN", hardware_version="A.102", serial_number="L1204707993"
)

_fsp_3 = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="A.102", serial_number="L1204601112"
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1193312104",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_fsp_4 = CapacityUnit(
    addr="", hardware_type="FBBA", hardware_version="A.102", serial_number="L1131716604"
)

_fsp_5 = CapacityUnit(
    addr="", hardware_type="FBBC", hardware_version="A.101", serial_number="EA174621270"
)


_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="A.102",
    serial_number="L6133500023",
    capacity_units=[_fsp_4, _fsp_5],
)

_smod_1 = Flexi([_fct_2])
_smod_2 = Flexi([_fct_1])

_rmod_1 = RU(ru_hw_group="", serial_number="BL2050W2LGM", pdu_port=_pdu_2.pdu_ports[3])

_rmod_2 = RU(ru_hw_group="", serial_number="K9184238567", pdu_port=_pdu_2.pdu_ports[2])

_rmod_3 = RU(ru_hw_group="", serial_number="1M175162868", pdu_port=_pdu_1.pdu_ports[6])

_rmod_4 = RU(ru_hw_group="", serial_number="1M172903029", pdu_port=_pdu_1.pdu_ports[4])

_enb_sbts_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.106.253.2"),
)
_enb_sbts_2 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_3], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_rnc = RNC(
    rnc_id=511,
    oms_ip=NetworkAddress("10.69.28.173"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.69.28.173", username="root", password="root"
    ),
)

_bsc = BSC(
    name="BSC_Leopard",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.107.151.137", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIN_1ABIO_1FSMF_1FBBA_1FBBC_1MDCD_1AHFIG_1AHPMDA_1FXJC_1FXDB_1810",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
