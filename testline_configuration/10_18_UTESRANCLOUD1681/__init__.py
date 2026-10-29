__maintainer__ = "None"
__email__ = "None"

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


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.147", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.3.92",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

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
    addr="None",
    hardware_type="FBBA",
    hardware_version="472182A.101",
    serial_number="L6132121356",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="FBBA",
    hardware_version="472182A.103",
    serial_number="F7165107003",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="NK163060846",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9220715526",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.232", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9220715525",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.231", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9220715527",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.233", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.5.38.9"),
    instance_id=10009,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_10009_1FSMF_2FBBA_3AZNA",
)


__all__ = ["tl"]
