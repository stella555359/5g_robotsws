__maintainer__ = ""
__email__ = ""

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress

HW_LOCATION_CODE = "Timisoara"

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.112", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = APC(
    addr="10.255.1.117",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    #model="APC",
)

_pdu_2 = Gude(
    addr="10.255.1.118",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"

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
    addr="",
    hardware_type="ABIL",
    hardware_version="B.102",
    serial_number="L1185109690"
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="B.102",
    serial_number="L1203201124"
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="B.102",
    serial_number="L1203201132"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="EA193857303",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M221817081",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.48.162", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M221817122",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.48.166", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M201311431",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.49.162", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)


_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.236.163"),
    instance_id=10763,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_NL_10763_1ASIB_3ABIL_1ASIA_3AEQE_1FRMF",
)

__all__ = ["tl"]
