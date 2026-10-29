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
    addr="10.255.1.64",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC", 
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.1.65",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC", 
    version="8221-1",
)

_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
#_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
#_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_attenuator = RadioRack(
    ip_addr="10.42.60.142",
    port=50000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="8-220",
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7172320823",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.210", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7165024761",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.208", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172532295",
    rus=[],	
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172532300",
    rus=[],	
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="F7171770092",
    rus=[_rmod_1, _rmod_2],
)
_smod_1 = Flexi([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.15.236.209"),
    instance_id=10809,
)
_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.236", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
#_rnc = RNC(
#    rnc_id=252,
#    oms_ip=NetworkAddress("10.27.141.158"),
#    logging_ssh_connection_details=SshServiceDetails(
#        addr="10.27.141.158", username="Nemuadmin", password="systeM123!"
#    ),
#)
_bsc = BSC(
    name="Astra",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="SYSTEM", password="SYSTEM"
    ),
)
_pdus = [_pdu_1, _pdu_2]

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
    serial_number="b29fed30",
    ue_pc_address="10.5.30.97",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.30.97",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="555109900000961",
    imei="864678050486933",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
    #    airplane_mode_switcher_text ="",
    #    airplane_mode_confirm_button_text ="",
    #    path_to_network_mode_type ="",
    is_rooted="no",
    secret_code='*#*#4636#*#*',
    capabilities=["NOKIA_42_5G"],
)

# ---------------- STOP TAF_UE_PROXY UEs -----------------


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_LG_10809_1FSMF_2FBBC_2FXED",
    attenuator=[_attenuator],
    pdus=_pdus,
    bscs=[_bsc],
#    rncs=[_rnc],
)

__all__ = ["tl"]
