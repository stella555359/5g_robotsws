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

HW_LOCATION_CODE = "Timisoara"
TESTLINE_NAME = "SBTS_CR1_SRAN17_10761"

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
    addr="", hardware_type="ABIA", hardware_version="A.102", serial_number="L1164303983"
)

_fsp_2 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.102", serial_number="L1164303984"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="AH173511292",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165057160",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.139", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165057297",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.141", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGU.value,
    serial_number="K9170318722",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.135", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGU.value,
    serial_number="K9170432281",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.137", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRMF.value,
    serial_number="AS174831360",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.15.0", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_8],
    oam_ip=NetworkAddress("10.15.236.161"),
    instance_id=10761,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

_bsc = BSC(
    name="BSC_TIMISOARA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.92.249.108", username="TIMISO", password="TI2019"
    ),
)

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.121", username="", password=""
    ),
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_LWG_10761_1ASIA_3ABIA_1MDEA_1ExtASIB_2FXDB_3FRGU_2FXED_1FRMF",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
