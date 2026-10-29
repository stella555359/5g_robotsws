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
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.ran import BSC, RNC

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.124", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.125", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = APC(
    addr="10.255.1.42",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    #model="APC",
    #version="",
)
_pdu_2 = Gude(
    addr="10.255.1.112",
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
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1182901115",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1173715417",
)

_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIP",
    hardware_version="A.Y16",
    serial_number="L1224707924",
)

_fsp_4 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1210302484",
)

_fsp_5 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1213010379",
)

_fsp_6 = CapacityUnit(
    addr="None",
    hardware_type="ABIN",
    hardware_version="A.102",
    serial_number="L1205007286",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.Y13",
    serial_number="L1224503550",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224807388",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FXED.value,
    serial_number="F7180625068",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FRGU.value,
    serial_number="K9170319064",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2236V08QE",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9174819438",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.AHFIC.value,
    serial_number="K9192414087",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9223211560",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.26", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.15.247.63"),
    instance_id=10363,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))


_bsc = BSC(
    name="BSC_ASTRA_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="VRFTSR", password="VRFTSR!@"
    ),
)
_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.120", username="Nemuadmin", password="Nokia@123"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_10363_2ASIM_2ABIA_3ABIO_1ABIN_1FXED_1FRGU_2AHFIB_1AHFIC_1AEHC",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
