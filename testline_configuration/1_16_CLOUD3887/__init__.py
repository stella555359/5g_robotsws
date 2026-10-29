__maintainer__ = "Kamil Szczesniak"
__team__ = "uuf"
__email__ = "kamil.szczesniak@nokia.com"
__owner_email__ = "kamil.szczesniak@nokia.com"

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
from taf.config.testline.testpc import TestPc

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.82.223", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.82.224", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.42.60.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.42.60.54",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.42.60.55",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1173514763",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171218042",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602175",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1173602134",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602131",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1192403295",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_3.pdu_ports[9],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1204505886",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHBA",
    serial_number="LBALLU-Z11728000JR",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHBA",
    serial_number="LBALLU-Z11728000JT",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="L1172402567",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="L1172801907",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="L1172402554",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
)


# _rmod_11 = RU(ru_hw_group='CPRI_A_RRH_4T4R', radio_type='UHIE', serial_number='LBALLU-YD17340MJXE',
#              default_telnet_connection_details=TelnetConnectionDetails(addr='', port=2323),
#              pdu_port=_pdu_1.pdu_ports[1])
# _rmod_6 = RU(ru_hw_group='CPRI_A_RRH_4T4R', radio_type='UHIE', serial_number='LBALLU-YD17340MJY6',
#              default_telnet_connection_details=TelnetConnectionDetails(addr='', port=2323),
#              pdu_port=_pdu_1.pdu_ports[2])
_rmod_7 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHIE",
    serial_number="LBALLU-YD17340MJYC",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_8 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHFA",
    serial_number="LBALLU-YD154802LGE",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_9 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHFA",
    serial_number="LBALLU-YD154602HDE",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_10 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHFA",
    serial_number="LBALLU-YD155203054",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5]
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_7, _rmod_8, _rmod_9, _rmod_10], master=_enb_sbts_1
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_RF_AIBLR_B1-B4_B6_2xUHBA_3xAHCA_UHIE_3xUHFA",
)

__all__ = ["tl"]
