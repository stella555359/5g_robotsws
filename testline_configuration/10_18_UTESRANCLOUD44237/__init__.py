__maintainer__ = "Cristian Chifan"
__email__ = "cristian.chifan@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.71.170.37", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FPFH(
    addr="100.71.170.141",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="Timisoara$cis",
)

_pdu_2 = FPFH(
    addr="100.71.170.142",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="Timisoara$cis",
)

_pdu_3 = FPFH(
    addr="100.71.170.143",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="Timisoara$cis",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162601203"
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162604093"
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="AH180101299"
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="474403A.101",
    serial_number="AH174603100",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.UHBA.value,
    serial_number="LBALLU-YD15010026G",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.UHBA.value,
    serial_number="LBALLU-YD152000FKQ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.1", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.UHBA.value,
    serial_number="LBALLU-YD161104KY8",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.3", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.UHIE.value,
    serial_number="LBALLU-YD17320M9DP",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.6", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.UHIE.value,
    serial_number="LBALLU-YD18070RLD1",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.0", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.UHIE.value,
    serial_number="LBALLU-YD16370A51J",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.7", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)


_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.UHFA.value,
    serial_number="LBALLU-YD1609046PY",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.5", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.UHFA.value,
    serial_number="LBALLU-YD152100W2V",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.UHFA.value,
    serial_number="LBALLU-YD161304UE5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.8", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)


_rmod_10 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1180802900",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_11 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1174200974",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_12 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1174911132",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
    oam_ip=NetworkAddress("10.15.227.37"),
    instance_id=44237,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_44237_1AASIA_3ABIA_1ExtASIK_3UHBA_3UHIE_3UHFA_3AHCA",
    #bscs=[_bsc],
    #rncs=[_rnc],
)


__all__ = ["tl"]
