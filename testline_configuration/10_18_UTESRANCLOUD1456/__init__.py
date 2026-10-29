__maintainer__ = "Catalin Lazar"
__email__ = "iulian_catalin.lazar@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.ran import BSC

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.20.78", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_bsc = BSC(
    name="BSC_ASTRA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="SYSTEM", password="SYSTEM"
    ),
)

_pdu_3 = Gude(
    addr="10.255.1.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1 = Gude(
    addr="10.255.1.22",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.1.20",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164817862",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164816653",
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233203422",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233302569",
)


_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXCB.value,
    serial_number="1M161069528",
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXCB.value,
    serial_number="1M161069936",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FRGU.value,
    serial_number="K9170432301",
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1919G10I3",
    pdu_port=_pdu_1.pdu_ports[5],
)

_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.15.247.156"),
    instance_id=10456,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIB_2ABIA_1ABIL_1FRGU_2FXCB_1AHOLA",
    bscs=[_bsc],
)

__all__ = ["tl"]
