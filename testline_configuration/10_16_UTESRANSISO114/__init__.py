__maintainer__ = "Konrad Koziol"
__team__ = "siso"
__email__ = "konrad.koziol@nokia.com"
__owner_email__ = "konrad.koziol@nokia.com"


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

_pdu_1 = Gude("10.42.168.246", [11, 12], "EPC", "8220-1")                #ASIB_008, ASIB_723
_pdu_2 = Gude("10.42.169.31", [11, 12], "EPC", "8220-1")                 #AHSA_497, AQHC_518
_pdu_3 = Gude("10.42.169.32", [1, 2, 3, 5, 6, 7, 8, 9, 10], "EPC", "8220-1")    #UHFD_402, AHSA_743, AHSA_744, AQHC_510, AHEGSA_746, AHSB_036, AHEGHA_654, AHEGHA_658, AHEGHA_655
_pdu_4 = Gude("10.42.169.33", [1, 3, 4, 5, 6, 10, 11], "EPC", "8220-1")          #AHPMDD_536, AHPMDD_331, AHPMDD_337, AHPL_106, UHLA_065, UHNA_5H6, #UHLC_788
_pdu_5 = Gude("10.42.169.12", [1], "EPC", "8220-1")                      #FRPA_909 

_rmod_1 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    serial_number="K9251016655",
    product_code="475767A.103",
    pdu_port=_pdu_3.pdu_ports[9],
    radio_type="AHEGHA",
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    serial_number="K9251016658",
    product_code="475767A.103",
    pdu_port=_pdu_3.pdu_ports[10],
    radio_type="AHEGHA",
)

_rmod_3 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    serial_number="K9251016654",
    product_code="475767A.103",
    pdu_port=_pdu_3.pdu_ports[7],
    radio_type="AHEGHA",
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="6Q204500337",
    product_code="475707A.101",
    pdu_port=_pdu_4.pdu_ports[3],
    radio_type="AHPMDD",
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="6Q205001536",
    product_code="475707A.101",
    pdu_port=_pdu_4.pdu_ports[1],
    radio_type="AHPMDD",
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="6Q204500331",
    product_code="475707A.101",
    pdu_port=_pdu_4.pdu_ports[4],
    radio_type="AHPMDD",
)

_rmod_7 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    serial_number="DH242832518",
    product_code="476108A.202",
    pdu_port=_pdu_2.pdu_ports[12],
    radio_type="AQHC",
)

_rmod_8 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    serial_number="DH242832510",
    product_code="476108A.202",
    pdu_port=_pdu_3.pdu_ports[5],
    radio_type="AQHC",
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="DH231942106",
    product_code="476514A.101",
    pdu_port=_pdu_4.pdu_ports[5],
    radio_type="AHPL",
)

_rmod_10 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="RW240800036",
    product_code="476343A.101",
    pdu_port=_pdu_3.pdu_ports[8],
    radio_type="AHSB",
)

_rmod_11 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    serial_number="16W323D90402",
    product_code="3JR39501AA",
    pdu_port=_pdu_3.pdu_ports[1],
    radio_type="UHFD",
)

_rmod_12 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="L9134900909",
    product_code="472703A.101",
    pdu_port=_pdu_5.pdu_ports[1],
    radio_type="FRPA",
)

_rmod_13 = RU(
    ru_hw_group="FRMr5.1_2T0R",
    serial_number="6Q192809744",
    product_code="475015A.101",
    pdu_port=_pdu_3.pdu_ports[3],
    radio_type="AHSA",
)

_rmod_14 = RU(
    ru_hw_group="FRMr5.1_2T0R",
    serial_number="6Q192809743",
    product_code="475015A.101",
    pdu_port=_pdu_3.pdu_ports[2],
    radio_type="AHSA",
)

_rmod_15 = RU(
    ru_hw_group="FRMr5.1_2T0R",
    serial_number="RW235000497",
    product_code="475015A.101",
    pdu_port=_pdu_2.pdu_ports[11],
    radio_type="AHSA",
)

_rmod_16 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    serial_number="12W332Z10065",
    product_code="109766345",
    pdu_port=_pdu_4.pdu_ports[6],
    radio_type="UHLA",
)

#_rmod_17 = RU(
#    ru_hw_group="FRMr6.2a_4T4R",
#    serial_number="1M251406746",
#    product_code="476128A.101",
#    pdu_port=_pdu_3.pdu_ports[6],
#    radio_type="AHEGSA",
#)

_rmod_18 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    serial_number="LBALLU-YD1539025H6",
    product_code="3JR41325AA",
    pdu_port=_pdu_4.pdu_ports[11],
    radio_type="UHNA",
)

_rmod_19 = RU(
    ru_hw_group="CPRI_A_RRH_2T0R",
    serial_number="19YD20078788",
    product_code="3JR38037AA",
    pdu_port=_pdu_4.pdu_ports[10],
    radio_type="UHLC",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1224108103",
    pdu_port=_pdu_1.pdu_ports[11],
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_13, _rmod_14, _rmod_15],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    serial_number="L1224108049",
    pdu_port=_pdu_1.pdu_ports[11],
    rus=[_rmod_1, _rmod_2, _rmod_3#, _rmod_17
    ],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    serial_number="L1172800009",
    pdu_port=_pdu_1.pdu_ports[11],
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_19],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    serial_number="DH242420787",
    pdu_port=_pdu_1.pdu_ports[12],
    rus=[_rmod_7, _rmod_8],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    serial_number="L1172902300",
    pdu_port=_pdu_1.pdu_ports[12],
    rus=[_rmod_10, _rmod_11, _rmod_16, #_rmod_17, 
    _rmod_18],
)
_fsp_6 = CapacityUnit(
    addr="192.168.252.30",
    hardware_type="ABIP",
    serial_number="L1234007310",
    pdu_port=_pdu_1.pdu_ports[12],
    rus=[_rmod_9, _rmod_10, _rmod_12],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIB",
    serial_number="L1202001008",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIB",
    serial_number="L1190608723",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_13,
        _rmod_14,
        _rmod_15,
#        _rmod_17,
        _rmod_19
    ],
    oam_ip=NetworkAddress("10.42.175.5"),
    instance_id=1460,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
        _rmod_16,
#        _rmod_17,
        _rmod_18,
    ],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.105", username="ute"),
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
    SshServiceDetails(addr="10.42.184.106", username="ute"),
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
    name="asBSC24",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.196.170", username="SYSTEM", password="SYSTEM"
    ),
)

_app_server_1 = TafUeAppServer(
    app_server_name="wg-srn-iperf-728",
    address="10.44.184.246",
    #bind_interface_ip="10.42.197.50",
    user="syslab",
    password="Pass4System!",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50,
    # bind_ue_ip='',
    version=3,
)

_android1 = TafUeAndroid(
    serial_number="d7382a19",
    ue_pc_address="10.42.172.161",
    data_transfer=[_data_transfer_iperf],
    capabilities=["d7382a19"],
    #ue_pc_port="9091",
    network_mode_switch_method="adb",
    airplane_mode_switcher_text="Aeroplane mode",
    is_rooted="no",
    proxy_mngr_port=9955,
)  # ieproxy manager will not be visible unless proxy_mngr_port is configured)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    ues=[_android1],
    bscs=[_bsc],
)

__all__ = ["tl"]
