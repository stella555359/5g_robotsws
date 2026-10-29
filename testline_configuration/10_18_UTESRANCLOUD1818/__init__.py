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
    addr="10.255.1.123",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    addr="10.255.1.124",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)

_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(
    addr="10.255.1.125",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)

_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_4 = Gude(
    addr="10.255.1.141",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)
#not working
_pdu_4.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_5 = Gude(
    addr="10.255.1.147",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)

_pdu_5.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[10].contactor = "NORMALLY_CLOSED"


_attenuator = RadioRack(
    ip_addr="10.255.1.168",
    port=50000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],    
    model="16-220",
#    version=None,
#    serial_number=None,
#    pdu_port=None,
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2248G1DIE",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
    ],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="K9182044955",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.123", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
    attenuation_ports=[
        _attenuator.attenuator_ports[2],
    ],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="K9182017489",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.127", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[2],
    attenuation_ports=[
        _attenuator.attenuator_ports[3],
    ],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL1911V00BI",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    attenuation_ports=[
        _attenuator.attenuator_ports[4],
    ],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2307V0GY4",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.126", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
    ],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2236V08Q3",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[12],
    attenuation_ports=[
        _attenuator.attenuator_ports[6],
    ],
)

_rmod_7 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="AH231800656",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.158", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[7],
    attenuation_ports=[
        _attenuator.attenuator_ports[7],
    ],
)

_rmod_8 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="AH231800632",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.157", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[10],
    attenuation_ports=[
        _attenuator.attenuator_ports[8],
    ],
)

_rmod_9 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="AH231900702",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.156", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[12],
    attenuation_ports=[
        _attenuator.attenuator_ports[9],
    ],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234800808",
	rus=[_rmod_1, _rmod_2,_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1243301319",
	rus=[_rmod_7, _rmod_8,_rmod_9],
	
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="LL1243301316",
	rus=[_rmod_4, _rmod_5,_rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234504071",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234205020",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.236.218"),
    instance_id=10818,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.229", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.230", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5]

#_rnc = RNC(
#    rnc_id=252,
#    oms_ip=NetworkAddress("10.27.141.158"),
#    logging_ssh_connection_details=SshServiceDetails(
#        addr="10.27.141.158 ", username="_nokadmin", password="_P@ssword123"
#   ),
#)

#_bsc = BSC(
#    name="Avensis",
#    logging_telnet_connection_details=TelnetConnectionDetails(
#        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
#    ),
#)


# ---------------- START TAF_UE_PROXY UEs ----------------

#_app_server_1 = TafUeAppServer(app_server_name="APP_1",
#                               address="10.5.26.71",
#                               user="ftp_user1",
#                               password="Aikon_1234@#",
#                               bind_interface_ip="10.5.26.71")

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
    serial_number="AQ5003H048PC1100926",
    ue_pc_address="10.5.60.81",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.81",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="244084710003042",
    imei="350693142499233",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
##    airplane_mode_switcher_text ="",
##    airplane_mode_confirm_button_text ="",
##    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83_NR","LTE_only"],

)

_android_2 = TafUeAndroid(
    serial_number="AQ5003H048PC1100779",
    ue_pc_address="10.5.60.81",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.81",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="540018000003115",
    imei="350693142516291",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
##    airplane_mode_switcher_text ="",
##    airplane_mode_confirm_button_text ="",
##    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83_NR","NR_SA"],

)

#_android_3 = TafUeAndroid(
#    serial_number="AQ5003H048PC1100956",
#    ue_pc_address="10.5.60.81",
#    data_transfer=[_data_transfer_iperf],
#    ssh_connection_details=SshServiceDetails(
#        addr="10.5.60.81",
#        username="wcdmata",
#        password="Aikon_123456*8",
#    ),
#    ue_pc_port="9090",
#    imsi="244084710003044",
#    imei="350693142499837",
#    qualcomm_prototype=False,
#    network_mode_switch_method="adb",
##    airplane_mode_switcher_text ="",
##    airplane_mode_confirm_button_text ="",
##    path_to_network_mode_type ="",
#    is_rooted ="no",
#    secret_code ='*#*#4636#*#*',
#    capabilities =["NOKIA83_NR","LTE_only"],
#
#)

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
    tl_cloud_topology="CLOUD_SRAN_NL_10818_1ASIM_1ABIP_1ASIM_2ABIP_3AHLOA_3AHFIB_3AEHC",
	pdus=_pdus,
    attenuator=[_attenuator],
#    bscs=[_bsc],
#    rncs=[_rnc],
)

__all__ = ["tl"]
