__maintainer__ = "Marta Bak"
__team__ = "siso"
__email__ = "marta.bak@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

_pdu_1 = Gude("10.42.169.6", [6], "EPC", "8220-1")  # SMOD
_pdu_2 = Gude("10.42.169.7", [2, 3, 4, 8], "EPC", "8220-1")
_pdu_3 = Gude("10.42.169.14", [5, 7, 8, 10, 11, 12], "EPC", "8220-1")
_pdu_4 = Gude("10.42.168.105", [4], "EPC", "8220-1")
_pdu_5 = Gude("10.42.168.100", [6], "EPC", "8220-1")
_pdu_6 = Gude("10.42.168.101", [8, 11, 12], "EPC", "8220-1")

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    serial_number="K9163284629",
    pdu_port=_pdu_2.pdu_ports[3],
    radio_type="FXJB",
)  # FXJB
_rmod_2 = RU(
    ru_hw_group="FRMr4.0a_2T4R_Corona",
    serial_number="RY161204339",
    pdu_port=_pdu_3.pdu_ports[11],
    radio_type="FRCJ",
)  # FRCJ
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="EA203856876",
    pdu_port=_pdu_3.pdu_ports[12],
    radio_type="AHEH",
)  # AHEH
_rmod_4 = RU(
    ru_hw_group="Fujitsu URKA",
    serial_number="TC09BM1110",
    pdu_port=_pdu_3.pdu_ports[10],
    radio_type="URKA",
)  # URKA
_rmod_5 = RU(
    ru_hw_group="FRMr4.1_2T2R",
    serial_number="6Q164804432",
    pdu_port=_pdu_4.pdu_ports[4],
    radio_type="FHGA",
)  # FHGA
_rmod_6 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    serial_number="LBALLU-YD1601033Y8",
    pdu_port=_pdu_3.pdu_ports[5],
    radio_type="UHIE",
)  # UHIE
_rmod_7 = RU(
    ru_hw_group="FRMr2.1_2T2R",
    serial_number="EA152161880",
    pdu_port=_pdu_3.pdu_ports[8],
    radio_type="FRMB",
)  # FRMB
_rmod_8 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="F7191708315",
    pdu_port=_pdu_2.pdu_ports[4],
    radio_type="FXDD",
)  # FXDD
_rmod_9 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    serial_number="16W344C70076",
    pdu_port=_pdu_3.pdu_ports[7],
    radio_type="UHCB",
)  # UHCB
_rmod_10 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA224756747",
    pdu_port=_pdu_5.pdu_ports[6],
    radio_type="AHEGF",
)  # AHEGF
_rmod_11 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    serial_number="LBALLU-YD162106DB6",
    pdu_port=_pdu_2.pdu_ports[2],
    radio_type="UDIA",
)  # UDIA
_rmod_12 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    serial_number="LBALLU-YD162106D84",
    pdu_port=_pdu_2.pdu_ports[8],
    radio_type="UDFA",
)  # UDFA
_rmod_13 = RU(
    ru_hw_group="FRMr4.0c_4T4R_Corona",
    serial_number="K9174220912",
    pdu_port=_pdu_6.pdu_ports[11],
    radio_type="FRBI",
)  # FRBI
_rmod_14 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    serial_number="LBALLU-YD17070GTLL",
    pdu_port=_pdu_6.pdu_ports[8],
    radio_type="UHFA",
)  # UHFA
_rmod_15 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    serial_number="LBALLU-YD16210691N",
    pdu_port=_pdu_6.pdu_ports[12],
    radio_type="UHBA",
)  # UHBA
_fsp_1 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ABIO",
    serial_number="L1204209891",
    product_code="475266A.101",
    pdu_port=_pdu_1.pdu_ports[6],
    rus=[_rmod_1, _rmod_3, _rmod_8, _rmod_10],
)

_fsp_2 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ABIA",
    serial_number="L1172805952",
    product_code="473096A.103",
    pdu_port=_pdu_1.pdu_ports[6],
    rus=[_rmod_2, _rmod_4, _rmod_6, _rmod_10, _rmod_11, _rmod_12],
)

_fsp_3 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ABIA",
    serial_number="L1172602546",
    product_code="473096A.103",
    pdu_port=_pdu_1.pdu_ports[6],
    rus=[_rmod_5, _rmod_7, _rmod_9, _rmod_13, _rmod_14, _rmod_15],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    serial_number="L1201102957",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    oam_ip=NetworkAddress("10.42.174.62"),
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
        _rmod_15,
    ],
    instance_id=1419,
)

_app_server_1 = TafUeAppServer(
    app_server_name="wg-srn-appserver-642",
    address="10.42.197.50",
    user="syslab",
    password="Pass4System!",
    # bind_interface_ip="10.42.129.2",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50,
    version=3,
    # bind_ue_ip='10.42.129.2',
)

_android1 = TafUeAndroid(
    serial_number="HZQN1876BAKA2800488",
    capabilities=["HZQN1876BAKA2800488"],
    ue_pc_address="10.42.172.116",
    proxy_mngr_port=9955,
    data_transfer=[_data_transfer_iperf],
    network_mode_switch_method="adb",
    is_rooted="no",
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.11", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    ues=[_android1],
)

__all__ = ["tl"]
