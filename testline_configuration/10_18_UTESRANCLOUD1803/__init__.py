# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Alin Pop"
__email__ = "alin.pop@nokia.com"

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
from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC 
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline import Connection
from taf.config.testline.attenuator import RadioRack

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
    addr="10.255.1.97",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.1.98",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3 = FPFH(
    addr="10.255.1.179",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    )


_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_attenuator = RadioRack(
    ip_addr="10.255.1.170",
    port=50000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="8-220",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type="AHLOB",
    serial_number="AH243706263",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.202", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type="AHLOB",
    serial_number="AH243522013",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.203", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHLOB",
    serial_number="AH243522019",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
		_attenuator.attenuator_ports[2],
    ],	
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="AHFII",
    serial_number="K9245113384",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
#     pdu_port=_pdu_1.pdu_ports[6],
    attenuation_ports=[
        _attenuator.attenuator_ports[3],
    ],	
)
_rmod_5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHFII",
    serial_number="K9245113452",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
#     pdu_port=_pdu_1.pdu_ports[7],
    attenuation_ports=[
        _attenuator.attenuator_ports[4],
    ],	
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AHFII",
    serial_number="K9245113299",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
#	pdu_port=_pdu_1.pdu_ports[1],
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
    ],
)
_rmod_7 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AEHC",
    serial_number="AH231800653",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
#	pdu_port=_pdu_1.pdu_ports[4],
    attenuation_ports=[
        _attenuator.attenuator_ports[4],
    ],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AEHC",
    serial_number="AH231800620",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
#	pdu_port=_pdu_1.pdu_ports[11],
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
    ],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AEHC",
    serial_number="AH232700000",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
#	pdu_port=_pdu_1.pdu_ports[12],
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
    ],
)



_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240906490",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240906540",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183143056",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH234521862",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211602561",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1213413283",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.101U",
    serial_number="DH221041092",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])



_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.203"),
    instance_id=10803,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.15.236.203"),
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.47.70", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.47.71", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2]

_bsc = BSC(
    name="ASTRA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
    ),
)

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.26.71",
                               user="ftp_user1",
                               password="Aikon_1234@#",
                               bind_interface_ip="10.5.26.71")


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 version=3)

_android_1 = TafUeAndroid(
    serial_number="AQ5003H048PC1100628",
    ue_pc_address="10.5.29.150",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.29.150",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="244084710003038",
    imei="350693142513272",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
#    airplane_mode_switcher_text ="",
#    airplane_mode_confirm_button_text ="",
#    path_to_network_mode_type ="",
    is_rooted ="yes",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA_G42_5G"],
)

# ---------------- STOP TAF_UE_PROXY UEs -----------------

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_NLG_1803_1ASIL_2ABIO_1ABIA_1ASIL_2ABIO_3AHFII_3AEHC_3AHLOB",
    pdus=_pdus,
    attenuator=[_attenuator],
    bscs=[_bsc],
)

__all__ = ["tl"]
