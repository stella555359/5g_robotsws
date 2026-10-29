__maintainer__ = "None"
__email__ = "None"

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
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.102", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_bsc = BSC(
    name="BSC_TIMISOARA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.92.249.108", username="TIMISO", password="TI2019"  # ???
    ),
)


_pdu_1 = APC(
    addr="10.255.1.132",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    #model="APC",
)
_pdu_2 = Gude(
    addr="10.255.1.133",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

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
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"



_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9173759036",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9173643732",
)

_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9173814758",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="EA190273488",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="K9213530974",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.AHEGC.value,
    serial_number="K9213523822",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="K9213530975",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS214812117",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS220702905",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.134", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS220703616",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)


_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.153"),
    instance_id=10753,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_LG_10753_3ABIA_1ASIA_3AHEGC_3AHPMDB",
    bscs=[_bsc],
)

__all__ = ["tl"]
