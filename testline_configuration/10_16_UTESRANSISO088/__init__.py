__maintainer__ = "Wojciech Korona"
__email__ = "wojciech.korona@nokia.com"

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
from taf.config.testline import Connection, CUS
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude("10.42.169.245", [1, 2, 3, 4, 5, 6], "EPC", "8220-1")
_pdu_2 = Gude("10.42.169.246", [1, 2], "EPC", "8220-1")
_pdu_3 = Gude("10.42.169.247", [1, 2, 3, 4, 7], "EPC", "8220-1")
_pdu_4 = Gude("10.42.169.248", [1, 2, 3, 4, 5, 6, 7], "EPC", "8220-1")
_pdu_5 = Gude("10.42.169.249", [1, 2, 3, 4, 6, 7], "EPC", "8220-1")
_pdu_6 = Gude("10.42.169.250", [1, 5, 6, 9, 10], "EPC", "8221-1")
_pdu_7 = Gude("10.42.169.251", [1, 4, 5, 6, 7, 8, 9], "EPC", "8220-1")
_pdu_8 = Gude("10.42.169.252", [4, 5, 6, 7, 8, 9], "EPC", "8220-1")
#_pdu_5 = ATEN("10.42.169.16", [6], "ATEN", "")

_rmod_1 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH232011184",
    product_code="476136A.101", 
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH234520613",
    product_code="476136A.101",
    pdu_port=_pdu_4.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1222005477",
    product_code="476138A.101",
    pdu_port=_pdu_8.pdu_ports[8],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQE",
    serial_number="L1221501159",
    product_code="475544A.101",
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQE",
    serial_number="L1223804019",
    product_code="475544A.101",
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="L1230301082",
    product_code="476136A.101",
    pdu_port=_pdu_4.pdu_ports[1],
)
_rmod_7 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH232011179",
    product_code="476136A.101",
    pdu_port=_pdu_4.pdu_ports[6],
)
_rmod_8 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH242224802",
    product_code="476136A.101",
    pdu_port=_pdu_4.pdu_ports[2],
)
_rmod_9 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQE",
    serial_number="L1221102356",
    product_code="475544A.101",
    pdu_port=_pdu_4.pdu_ports[3],
)
_rmod_10 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1222005476",
    product_code="476138A.101",
    pdu_port=_pdu_5.pdu_ports[1],
)
_rmod_11 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQS",
    serial_number="L1222001453",
    product_code="093323A.101",
    pdu_port=_pdu_5.pdu_ports[6],
)
_rmod_12 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQE",
    serial_number="L1223804015",
    product_code="475544A.101",
    pdu_port=_pdu_5.pdu_ports[2],
)
_rmod_13 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQS",
    serial_number="L1222402862",
    product_code="093323A.101",
    pdu_port=_pdu_5.pdu_ports[3],
)
_rmod_14 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1221705854",
    product_code="476138A.101",
    pdu_port=_pdu_5.pdu_ports[4],
)
_rmod_15 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH242224812",
    product_code="476136A.101",
    pdu_port=_pdu_5.pdu_ports[7],
)
_rmod_16 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1222608123",
    product_code="476138A.101",
    pdu_port=_pdu_4.pdu_ports[7],
)
_rmod_17 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1222608125",
    product_code="476138A.101",
    pdu_port=_pdu_4.pdu_ports[5],
)
_rmod_18 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH234520614",
    product_code="476136A.101",
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_19 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQT",
    serial_number="L1230400865",
    product_code="093863A.101",
    pdu_port=_pdu_6.pdu_ports[10],
)
_rmod_20 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1221705851",
    product_code="476138A.101",
    pdu_port=_pdu_6.pdu_ports[6],
)
_rmod_21 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1221705852",
    product_code="476138A.101",
    pdu_port=_pdu_7.pdu_ports[5],
)
_rmod_22 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1221705855",
    product_code="476138A.101",
    pdu_port=_pdu_7.pdu_ports[6],
)
_rmod_23 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1221705859",
    product_code="476138A.101",
    pdu_port=_pdu_8.pdu_ports[5],
)
_rmod_24 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1222608124",
    product_code="476138A.101",
    pdu_port=_pdu_8.pdu_ports[6],
)
_rmod_25 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH243126339",
    product_code="476136A.101",
    pdu_port=_pdu_7.pdu_ports[1],
)
_rmod_26 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1223214937",
    product_code="476138A.101",
    pdu_port=_pdu_7.pdu_ports[7],
)
_rmod_27 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQE",
    serial_number="L1214308074",
    product_code="475544A.101",
    pdu_port=_pdu_8.pdu_ports[7],
)
_rmod_28 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AEQN",
    serial_number="CV193401391",
    product_code="474736A.102",
    pdu_port=_pdu_6.pdu_ports[9],
)
_rmod_29 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1225206316",
    product_code="476138A.101",
    pdu_port=_pdu_7.pdu_ports[8],
)
_rmod_30 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AEQN",
    serial_number="CV193301083",
    product_code="474736A.102",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_31 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQN",
    serial_number="L1220906101",
    product_code="093175A.101",
    pdu_port=_pdu_6.pdu_ports[1],
)
_rmod_32 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH243126350",
    product_code="474736A.101",
    pdu_port=_pdu_6.pdu_ports[5],
)
_rmod_33 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH243126341",
    product_code="476136A.101",
    pdu_port=_pdu_7.pdu_ports[9],
)
_rmod_34 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH243126343",
    product_code="476136A.101",
    pdu_port=_pdu_7.pdu_ports[4],
)
_rmod_35 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH243126349",
    product_code="476136A.101",
    pdu_port=_pdu_8.pdu_ports[4],
)
_rmod_36 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH243126351",
    product_code="476136A.101",
    pdu_port=_pdu_8.pdu_ports[9],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1234004854",
    pdu_port=_pdu_2.pdu_ports[1],
    rus=[_rmod_1,_rmod_2,_rmod_3,_rmod_4,_rmod_5,_rmod_6,_rmod_7,_rmod_8,_rmod_9,_rmod_10,_rmod_11,_rmod_12],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    serial_number="L1231800108",
    pdu_port=_pdu_2.pdu_ports[1],
    rus=[_rmod_13,_rmod_14,_rmod_15,_rmod_16,_rmod_17,_rmod_18,_rmod_19,_rmod_20,_rmod_21,_rmod_22,_rmod_23,_rmod_24],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    serial_number="L1231800060",
    pdu_port=_pdu_2.pdu_ports[1],
    rus=[_rmod_25,_rmod_26,_rmod_27,_rmod_28,_rmod_29,_rmod_30,_rmod_31,_rmod_32,_rmod_33,_rmod_34,_rmod_35,_rmod_36],
)

_fct_1  = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIM",
    serial_number="L1230613811",
)

_smod_1 = Airscale([_fct_1])
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
        _rmod_15,
        _rmod_16,
        _rmod_17,
        _rmod_18,
        _rmod_19,
        _rmod_20,
        _rmod_21,
        _rmod_22,
        _rmod_23,
        _rmod_24,
        _rmod_25,
        _rmod_26,
        _rmod_27,
        _rmod_28,
        _rmod_29,
        _rmod_30,
        _rmod_31,
        _rmod_32,
        _rmod_33,
        _rmod_34,
        _rmod_35,
        _rmod_36,
    ],
)

#_rnc = RNC(
#    rnc_id=3000,
#    oms_ip=NetworkAddress("10.44.44.218"),
#    logging_ssh_connection_details=SshServiceDetails(
#        addr="10.42.91.81", username="nokiadmin", password="system"
#    ),
#)

#_bsc = BSC(
#    name="BSC33",
#    logging_telnet_connection_details=TelnetConnectionDetails(
#        addr="10.44.146.2", username="SYSTEM", password="SYSTEM"
#    ),
#)

_app_server_1 = TafUeAppServer(
    app_server_name="wg-srn-iperf-728",
    address="10.44.184.246",
    user="ranpz",
    password="Pass4Tests!",
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

#_android1 = TafUeAndroid(
#    serial_number="HZQN1876AAK90100022",
#    ue_pc_address="10.42.172.137",
#    data_transfer=[_data_transfer_iperf],
#    capabilities=["HZQN1876AAK90100022"],
#    ue_pc_port="9090",
#    network_mode_switch_method="keyevents",
#    airplane_mode_switcher_text="Aeroplane mode",
#    is_rooted="no",
#)

#_android2 = TafUeAndroid(
#    serial_number="24c5c15d",
#    ue_pc_address="10.42.172.137",
#    data_transfer=[_data_transfer_iperf],
#    capabilities=["24c5c15d"],
#    ue_pc_port="9090",
#    network_mode_switch_method="keyevents",
#    airplane_mode_switcher_text="Airplane mode",
#    is_rooted="no",
#)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.184.133",
        username="ute",
        password="ute",),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_sbts_1.system_module.common_units[0],
        ),
    ]
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO088",
    pdus=[_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5, _pdu_6, _pdu_7, _pdu_8]
#    bscs=[_bsc],
#    rncs=[_rnc],
#    ues=[_android1],
)

__all__ = ["tl"]
