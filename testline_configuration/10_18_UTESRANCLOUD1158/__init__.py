__maintainer__ = "Vlad Slivilescu"
__email__ = "vlad.slivilescu@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G

# HW_LOCATION_CODE = "Timisoara"
# TESTLINE_NAME = "SBTS_CR1_SRAN17_10158"

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.16", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_bsc = BSC(
    name="BSC_TIMISOARA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.36", username="SYSTEM", password="SYSTEM"
    ),
)

_pdu_1 = Gude(
    addr="10.255.1.79",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.1.78",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)


_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK170231172",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK170231750",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="F7163743524",
)


_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FXDB,
    serial_number="F7164220998",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.208", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FXDB,
    serial_number="F7164310639",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FRMA,
    serial_number="K9164620207",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.210", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FRMA,
    serial_number="K9164620206",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.211", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FRHC,
    serial_number="F7163008774",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.214", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.5.38.158"),
    instance_id=10158,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC_1158_UTE_CA",
    bscs=[_bsc],
)

__all__ = ["tl"]
