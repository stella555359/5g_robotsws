# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Valentin Suru"
__email__ = "valentin.suru@nokia.com"
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
from taf.config.testline import Connection
from taf.config.testline.attenuator import TopYoung

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
    addr="10.255.1.123",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    addr="10.255.1.124",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)

_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_attenuator = TopYoung(
    ip_addr="10.255.1.174",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],    
    model="TAS_24T24_02G6_90_1S_EJS",
#    version=None,
#    serial_number=None,
#    pdu_port=None,
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_VirtWB",
    radio_type="AZNA",
    serial_number="EA203554838",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_4T4R_Quattro",
    radio_type="AZNA",
    serial_number="EA203554835",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
    ],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AZNA",
    serial_number="EA203554851",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    attenuation_ports=[
     	_attenuator.attenuator_ports[9],
        _attenuator.attenuator_ports[10],
        _attenuator.attenuator_ports[11],
        _attenuator.attenuator_ports[12],  
    ],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHPMDA",
    serial_number="K9193742721",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    attenuation_ports=[
        _attenuator.attenuator_ports[13],
        _attenuator.attenuator_ports[14],
        _attenuator.attenuator_ports[15],
        _attenuator.attenuator_ports[16],  
    ],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHFIB",
    serial_number="BL2307V0GXU",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    attenuation_ports=[
        _attenuator.attenuator_ports[17],
        _attenuator.attenuator_ports[18],
        _attenuator.attenuator_ports[19],
        _attenuator.attenuator_ports[20],
    ],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234800803",
	rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233104919",
	rus=[_rmod_3],
	
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183142966",
	rus=[_rmod_4],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204214782",
	rus=[_rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234504076",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH211270116",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.236.219"),
    instance_id=10819,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_4,_rmod_5], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.231", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.232", username="ute"),
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
    rnc_id=252,
    oms_ip=NetworkAddress("10.27.141.158"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.141.158", username="Nemuadmin", password="systeM123!"
    ),
)

_bsc = BSC(
    name="Astra",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="SYSTEM", password="SYSTEM"
    ),
)

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.27.141.158"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.141.158", username="Nemuadmin", password="systeM123!"
    ),
)

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.26.73",
                               user="ftp1_user1",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.26.73")


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 version=3)

_android_1 = TafUeAndroid(
    serial_number="AQ5003H048PC1100626",
    ue_pc_address="10.5.60.92",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.92",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="244084710003041",
    imei="350693142513231",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
#    airplane_mode_switcher_text ="",
#    airplane_mode_confirm_button_text ="",
#    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83_NR"],
)

# ---------------- STOP TAF_UE_PROXY UEs -----------------
#with open(
#    os.path.join(os.path.dirname(os.path.abspath(__file__)), "ue_nokia.yaml")
#) as ue_config:
#   import yaml

#    ue_nokia = yaml.load(ue_config, yaml.SafeLoader)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_NLWG_10819_1ASIM_1ABIP_1ABIQ_1ASIB_1ABIA_1ABIN_3AZNA_1AHPMDA_1AHFIB_UTECA",
	pdus=_pdus,
    attenuator=[_attenuator],
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]

