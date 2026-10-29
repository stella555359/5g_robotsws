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
    SshServiceDetails(addr="10.42.62.228", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.62.229", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.42.80.246",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.42.80.192",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.42.60.80",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172909004",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172909007",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172903746",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172908904",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171216169",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1173103188",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1173810039",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr4.3b_4T4R_Halo",
    radio_type="FRIJ",
    serial_number="EA173184159",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="FRMr4.3b_4T4R_Halo",
    radio_type="FRIJ",
    serial_number="EA173482479",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr4.3b_4T4R_Halo",
    radio_type="FRIJ",
    serial_number="EA173184162",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group="FRMr4.3b_4T4R_Halo",
    radio_type="FRIJ",
    serial_number="EA173184062",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="K9172602371",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="K9172558268",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_7 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="K9172602425",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_8 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="K9172602403",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_9 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="L1151403687",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_10 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="K9172602400",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_11 = RU(
    ru_hw_group="FRMr4.0b_4T2R_Corona",
    radio_type="FRBG",
    serial_number="K9172901404",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_12 = RU(
    ru_hw_group="FRMr4.0b_4T2R_Corona",
    radio_type="FRBG",
    serial_number="K9172901387",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_13 = RU(
    ru_hw_group="FRMr4.0b_4T2R_Corona",
    radio_type="FRBG",
    serial_number="K9172901393",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_14 = RU(
    ru_hw_group="FRMr4.0b_4T2R_Corona",
    radio_type="FRBG",
    serial_number="K9172901319",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_15 = RU(
    ru_hw_group="FRMr4.3b_4T4R_Halo",
    radio_type="FRIJ",
    serial_number="EA173184069",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_16 = RU(
    ru_hw_group="FRMr4.3b_4T4R_Halo",
    radio_type="FRIJ",
    serial_number="EA163884956",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_17 = RU(
    ru_hw_group="FRMr4.3b_4T4R_Halo",
    radio_type="FRIJ",
    serial_number="EA163885424",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_18 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHOA",
    serial_number="K9181312024",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_19 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHOA",
    serial_number="K9174719899",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_20 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHOA",
    serial_number="K9174719898",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[1],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
        _rmod_13,
        _rmod_14,
    ],
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_15, _rmod_16, _rmod_17, _rmod_18, _rmod_19, _rmod_20],
    master=_enb_sbts_1,
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_RF_AILR_B1_B2_B3_B4_B6_7FRIJ_6FHFB_4FRBG_3FHOA",
)

__all__ = ["tl"]
