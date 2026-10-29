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
    addr="10.255.1.140",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.1.141",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.255.1.65",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_pdu_4 = Gude(
    addr="10.255.1.146",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_attenuator = RadioRack(
	    ip_addr="10.255.1.170",
	    port=50000,
	    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],    
    model="8-220",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_VirtWB",
    radio_type="AHLOA",
    serial_number="K9182017455",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
    ],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_VirtWB",
    radio_type="AHLOA",
    serial_number="BL1933G10OO",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
    attenuation_ports=[
        _attenuator.attenuator_ports[2],
    ],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHLOA",
    serial_number="BL2248G1DI6",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5], 
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHFIB",
    serial_number="BL2307V0GXZ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    attenuation_ports=[
	_attenuator.attenuator_ports[3],
    ],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHFIB",
    serial_number="BL2231V05OO",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    attenuation_ports=[
	_attenuator.attenuator_ports[4],
    ],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHFIB",
    serial_number="K9174641482",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    attenuation_ports=[
	_attenuator.attenuator_ports[5],
    ],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHFIB",
    serial_number="BL2215V011C",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    attenuation_ports=[
	_attenuator.attenuator_ports[6],
    ],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHFIB",
    serial_number="BL2231V05ON",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHFIB",
    serial_number="BL2236V08SL",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_rmod_10 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="K9203428370",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.158", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
    attenuation_ports=[
        _attenuator.attenuator_ports[7],
    ],
)

_rmod_11 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="K9202714125",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.157", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
    attenuation_ports=[
        _attenuator.attenuator_ports[8],
    ],
)

_rmod_12 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="K9203123226",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.156", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[11],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240102423",
	rus=[_rmod_1, _rmod_2,_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171221126",
	rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
	
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1241101900",
	rus=[_rmod_10, _rmod_11,_rmod_12],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1241104181",
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1241104187",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1214313517",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1200708102",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2,_rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    oam_ip=NetworkAddress("10.15.236.212"),
    instance_id=10812,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_10, _rmod_11,_rmod_12], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.7", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.8", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

#_rnc = RNC(
#    rnc_id=252,
#    oms_ip=NetworkAddress("10.92.249.149"),
#    logging_ssh_connection_details=SshServiceDetails(
#        addr="10.91.190.126 ", username="_nokadmin", password="_P@ssword123"
#    ),
#)

_bsc = BSC(
    name="Astra",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="SYSTEM", password="SYSTEM"
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
    serial_number="AQ5003H048PC1100628",
    ue_pc_address="10.5.60.152",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.152",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="244084710003053",
    imei="350693142516275",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
##    airplane_mode_switcher_text ="",
##    airplane_mode_confirm_button_text ="",
##    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83_NR","NR_SA"],

)

_android_2 = TafUeAndroid(
    serial_number="AQ5003H048PC1100778",
    ue_pc_address="10.5.60.152",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.152",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="540018000002235",
    imei="350693142513272",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
##    airplane_mode_switcher_text ="",
##    airplane_mode_confirm_button_text ="",
##    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83_NR","LTE_only"],

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
    ues=[_android_1, _android_2],
    tl_cloud_topology="CLOUD_SRAN_NLG_10812_1ASIM_1ABIO_1ABIA_1ASIM_3ABIP_3AHLOA_6AHFIB_3AEHC",
	pdus=_pdus,
    attenuator=[_attenuator],
    bscs=[_bsc],
#    rncs=[_rnc],
)

__all__ = ["tl"]

