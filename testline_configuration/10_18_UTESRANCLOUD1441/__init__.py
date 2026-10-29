# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "None"
__email__ = "None"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
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


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.23", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.1.122",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.1.60",
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
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824684",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173814786",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173814660",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1172121083",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEB.value,
    serial_number="L1173517703",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.134", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEB.value,
    serial_number="L1173704349",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9180121433",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9180111152",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_5 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9180121453",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_6 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHED.value,
    serial_number="6Q174206216",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.247.141"),
    instance_id=10441,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="", password=""
    ),
)

_bsc = BSC(
    name="BSC_AVENSIS_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIA_3ABIA_2AHEB_1AHED_3AHEGA",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
