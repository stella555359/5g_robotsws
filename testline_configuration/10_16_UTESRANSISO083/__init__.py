__maintainer__ = "Tomasz Lojewski"
__team__ = "siso"
__email__ = "tomasz.lojewski@nokia.com"


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

_pdu_1 = Gude("10.42.168.99", [3, 4], "EPC", "8221-1")
_pdu_2 = Gude("10.42.212.18", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], "EPC", "8220-1")
_pdu_3 = Gude("10.42.168.86", [4], "EPC", "8221-1")
_pdu_4 = Gude("10.42.168.17", [10, 11, 12], "EPC", "8220-1")


_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="AH243007606",
    product_code="475910A.101",
    pdu_port=_pdu_2.pdu_ports[3],
    radio_type="AHLOB",
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="AH243007605",
    product_code="475910A.101",
    pdu_port=_pdu_2.pdu_ports[2],
    radio_type="AHLOB",
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="AH243007603",
    product_code="475910A.101",
    pdu_port=_pdu_2.pdu_ports[1],
    radio_type="AHLOB",
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="BL2221N4056",
    product_code="475656A.101",
    pdu_port=_pdu_2.pdu_ports[5],
    radio_type="AHFII",
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="BL2222N4078",
    product_code="475656A.101",
    pdu_port=_pdu_2.pdu_ports[6],
    radio_type="AHFII",
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="BL2216N4016",
    product_code="475656A.101",
    pdu_port=_pdu_2.pdu_ports[4],
    radio_type="AHFII",
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="BL2137W2PN1",
    product_code="475125A.101",
    pdu_port=_pdu_2.pdu_ports[7],
    radio_type="AHFIG",
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="EA191575394",
    product_code="474198A.101",
    pdu_port=_pdu_3.pdu_ports[4],
    radio_type="AREA",
)
_rmod_9 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    serial_number="L1251300674",
    product_code="476541A.101",
    pdu_port=_pdu_2.pdu_ports[8],
    radio_type="AVHA",
)
_rmod_10 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    serial_number="L1251300676",
    product_code="476541A.101",
    pdu_port=_pdu_2.pdu_ports[9],
    radio_type="AVHA",
)
_rmod_11 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    serial_number="L1251300675",
    product_code="476541A.101",
    pdu_port=_pdu_2.pdu_ports[10],
    radio_type="AVHA",
)
_rmod_12 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    serial_number="L1250710361",
    product_code="476596A.101",
    pdu_port=_pdu_4.pdu_ports[10],
    radio_type="AVQQA",
)
_rmod_13 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    serial_number="L1250710360",
    product_code="476596A.101",
    pdu_port=_pdu_4.pdu_ports[11],
    radio_type="AVQQA",
)
_rmod_14 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    serial_number="L1250710362",
    product_code="476596A.101",
    pdu_port=_pdu_4.pdu_ports[12],
    radio_type="AVQQA",
)
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    serial_number="L1232807055",
    product_code="475792A.102",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    serial_number="L1232807111",
    product_code="475792A.102",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_9, _rmod_10, _rmod_11, _rmod_12, _rmod_13, _rmod_14],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    serial_number="L1232807116",
    product_code="475792A.102",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    serial_number="L1224309117",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    serial_number="L1224309106",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    oam_ip=NetworkAddress("10.42.175.39"),
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_8],
    instance_id=1382,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
        _rmod_13,
        _rmod_14,
    ],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.115", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.184.117", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_bsc = BSC(
    name="BSC21",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.28.126", username="PZUSER", password="pzpassword"
    ),
)

_app_server_1 = TafUeAppServer(
    app_server_name="wg-srn-iperf-728",
    address="10.44.184.246",
    user="ranpz",
    # bind_interface_ip="10.42.129.2",
    password="Pass4Testers!",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50,
    # bind_ue_ip='10.42.129.2',
    version=3,
)

_android1 = TafUeAndroid(
    serial_number="3845e803",
    capabilities=["3845e803"],
    ue_pc_address="10.42.172.137",
    proxy_mngr_port=9955,
    data_transfer=[_data_transfer_iperf],
    network_mode_switch_method="adb",
    is_rooted="no",
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    bscs=[_bsc],
    ues=[_android1],
)

__all__ = ["tl"]
