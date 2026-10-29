__maintainer__ = ""
__email__ = ""

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.bts2g import Bts2G


HW_LOCATION_CODE = "Timisoara"
TESTLINE_NAME = "SBTS_CR1_SRAN17_10227"

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.151", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.152", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_2 = Gude(
    addr="10.255.1.24",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1 = Gude(
    addr="10.255.1.25",
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
    addr="",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1164819638"
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1164816615"
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1164816612"
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1164816640"
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1164814940"
)

_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9173814762"
)

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDD.value,
    serial_number="F7173732096",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRHB.value,
    serial_number="EA172663814",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.202", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRHB.value,
    serial_number="EA172663621",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.204", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRMC.value,
    serial_number="F7141904318",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGP.value,
    serial_number="L6122613728",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.224.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRHB.value,
    serial_number="EA172663652",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.205", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDA.value,
    serial_number="F7144021631",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.208", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGP.value,
    serial_number="RY121824998",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.224.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165206470",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.127", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXEA.value,
    serial_number="L1114906588",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.255", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXEA.value,
    serial_number="L1112419000",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.254", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1164604273",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1164604259",
    test_pc=_test_pc_2,
    rus=[_rmod_9, _rmod_10, _rmod_11],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])



_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
    oam_ip=NetworkAddress("10.15.236.99"),
    instance_id=10699,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_9, _rmod_10, _rmod_11],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))

_bsc = BSC(
    name="BSC_AVENSIS_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
    ),
)

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_10699_2ASIA_6ABIA_2FXEA_1FXED_1FXDD_1FXDA_2FRGP_3FRHB_1FRMC",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
