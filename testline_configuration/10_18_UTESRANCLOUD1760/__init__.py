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
TESTLINE_NAME = "SBTS_CR1_SRAN17_10760"

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.111", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.110", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.1.136",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.1.137",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = APC(
    addr="10.255.1.138",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="APC",
    #version="",
)

_pdu_4 = Gude(
    addr="10.255.1.139",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_5 = APC(
    addr="10.255.1.107",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="APC",
    #version="",
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

_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_4.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_5.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA192071618"
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="DH221046348"
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9173805519"
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1173715451"
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="A.102",
    serial_number="L1194509172"
)

_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="A.102",
    serial_number="L1194509170"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH220446040",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_3.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1220208653",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDA.value,
    serial_number="EA214450666",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA200259216",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.133", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA213053914",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="K9221000365",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA201250305",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="K9221000367",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="K9221000370",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDA.value,
    serial_number="EA214450637",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDA.value,
    serial_number="K9190241694",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9220715517",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[2],
)

_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9220715523",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[1],
)

_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9220715524",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_13 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M203816455",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.162", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_14 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M203905168",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.162", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_15 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M203816446",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    oam_ip=NetworkAddress("10.15.236.160"),
    instance_id=10760,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_10, _rmod_11, _rmod_12, _rmod_13, _rmod_14, _rmod_15],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_bsc = BSC(
    name="BSC_ASTRA_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="VRFTSR", password="VRFTSR!@"
    ),
)


_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NL_10760_2ASIB_4ABIA_2ABIL_3AZNA_3AEQE_3AREA_3ARGA_3AHPMDA",
    bscs=[_bsc],
)

__all__ = ["tl"]
