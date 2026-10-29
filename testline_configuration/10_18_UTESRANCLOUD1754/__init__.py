__maintainer__ = "None"
__email__ = "None"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.ran import BSC
from taf.config.testline.lmi import SerialOverTcp, Remote


HW_LOCATION_CODE = "Timisoara"
TESTLINE_NAME = "SBTS_CR1_SRAN17_10754"


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.103", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = APC(
    addr="10.255.1.132",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    #model="APC",
    
)
_pdu_2 = Gude(
    addr="10.255.1.131",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.255.1.133",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"

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
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1214206700",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1220208633",
)

_smod_1 = Airscale([_fct_1])

#MUMIN_AQQL_L1221604143 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.12"), port=5001)])
#MUMIN_AQQL_L1221604144 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.12"), port=5002)])
#MUMIN_AQQL_L1221604146 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.12"), port=5003)])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1221604143",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
#    lmi=MUMIN_AQQL_L1221604143,
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1221604144",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
#    lmi=MUMIN_AQQL_L1221604144,
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1221604146",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.158", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
#    lmi=MUMIN_AQQL_L1221604146,
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="K9213530974",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.AHEGC.value,
    serial_number="K9213523822",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="K9213530975",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_7 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7164200964",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_8 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7172701592",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.134", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARMA.value,
    serial_number="1M203438204",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_10 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH232700003",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_11 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1213413670",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_12 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9214704628",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
    oam_ip=NetworkAddress("10.15.236.154"),
    instance_id=10754,
)

_bsc = BSC(
    name="BSC_ASTRA_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="VRFTSR", password="VRFTSR!@"
    ),
)


_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_NL_10754_1ASIB_1ABIO_3AQQL",
    bscs=[_bsc],
)

__all__ = ["tl"]
