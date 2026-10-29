# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Tatiana Nowak"
__email__ = "tatiana.nowak@nokia.com"

import os
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import TopYoung
from taf.config.testline import Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


_pdu_1 = Gude(
    addr="10.42.212.10",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.42.212.13",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_attenuator = TopYoung(
    ip_addr="10.42.171.36",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 23, 24],
    model="TAS_24T24_02G6_90_1S_EJS",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1930G11LB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[
    _attenuator.attenuator_ports[1],
    _attenuator.attenuator_ports[2],
    _attenuator.attenuator_ports[3],
    _attenuator.attenuator_ports[4],
    ],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCA",
    serial_number="BL1821M0010",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    attenuation_ports=[
    _attenuator.attenuator_ports[5],
    _attenuator.attenuator_ports[6],
    _attenuator.attenuator_ports[7],
    _attenuator.attenuator_ports[8],
    ],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL1907V005V",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[
    _attenuator.attenuator_ports[13],
    _attenuator.attenuator_ports[14],
    _attenuator.attenuator_ports[15],
    _attenuator.attenuator_ports[16],
    ],

)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHED",
    serial_number="6Q175121186",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
    attenuation_ports=[
    _attenuator.attenuator_ports[23],
    _attenuator.attenuator_ports[24],
    ],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQP",
    serial_number="1M211915347",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[
    _attenuator.attenuator_ports[9],
    _attenuator.attenuator_ports[10],
    ],	
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162818420",
    rus=[_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224301034",
    rus=[_rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105706",
    rus=[_rmod_2],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233206249",
    rus=[_rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224505307",
    rus=[],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIQ",
    hardware_version="476397A.101",
    serial_number="L1232208159",
    rus=[_rmod_1, _rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version=".104",
    serial_number="L1233503541",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version=".104",
    serial_number="L1233505198",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.44.227.135"),
    instance_id=8588,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1,_rmod_4,_rmod_5],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.164.22", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.164.70", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2]

_rnc = RNC(
    rnc_id=9,
    oms_ip=NetworkAddress("10.27.127.36"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.94.92.155", username="Nemuadmin", password="Nemuadmin@123"
    ),
)

_bsc = BSC(
    name="mcBSC-R2D2",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.4.156", username="SYSTEM", password="SYSTEM"
    ),
)

# ---------------- START TAF_UE_PROXY UEs ----------------
_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.44.184.246",
                               user="syslab",
                               password="Pass4System!",
                               bind_interface_ip="10.44.184.246")


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 version=3)

_android_1 = TafUeAndroid(
    serial_number="HZQN1876AAKA2801785",
    ue_pc_address="10.42.172.79",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.172.79",
        username="labadmin",
        password="ZAQ!2wsxCDE#",
    ),
    ue_pc_port="9090",
    imsi="555109900000981",
    imei="353137111104298",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
#    airplane_mode_switcher_text ="",
#    airplane_mode_confirm_button_text ="",
#    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83"],
)
# ---------------- STOP TAF_UE_PROXY UEs -----------------

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIM_1ABIA_1ABIO_1ABIP_1ASIM_2ABIQ_1ABIO_1AEQP_1AHED_1AHBCA_1AHLOA_1AHFIB_UTECA",
    attenuator=[_attenuator],
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
