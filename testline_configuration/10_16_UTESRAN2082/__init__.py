# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Marcin Berkowski"
__email__ = "marcin.berkowski@nokia.com"


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
    SshServiceDetails(addr="10.42.133.81", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.82", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.42.80.50", [1, 2, 3, 4, 5, 6, 7, 8], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK152730008",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK163630488",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.35",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK152730013",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L1143813846",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="FSMF",
    hardware_version="084792A.103",
    serial_number="EA144665252",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="084792A.105",
    serial_number="NK163560485",
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRM31.02.R03",
    radio_type=RadioTypes.FRMC,
    serial_number="L1143523892",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.228", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="MED28.02.R52A",
    radio_type=RadioTypes.FRGP,
    serial_number="K9130521531",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.226", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="VEG21.02.R02",
    radio_type=RadioTypes.FXDB,
    serial_number="L1131404969",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.230", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_6],
    oam_ip=NetworkAddress("10.42.18.53"),
    instance_id=5017,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_rnc = RNC(
    rnc_id=9,
    oms_ip=NetworkAddress("10.44.44.218"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.94.92.155",
        username="nokiadmin",
        password="system",
    ),
)

_bsc = BSC(
    name="BSC_Leopard",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.89.4", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_1FSMF_1FBBA_1FSMF_1FBBC_1FRMC_1FRGP_1FXDB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
