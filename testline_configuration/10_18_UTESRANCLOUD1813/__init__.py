# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Valentin Suru"
__email__ = "valentin.suru@nokia.com"
import os
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
from taf.config.testline.attenuator import RadioRack
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
    addr="10.255.1.142",
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

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"


_attenuator = RadioRack(
    ip_addr="10.255.1.167",
    port=50000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="8-220",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_2T2R_Reno",
    radio_type="FHEB",
    serial_number="1M164701864",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    attenuation_ports=[
	_attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
    ],

)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_2T2R_Reno",
    radio_type="FHEB",
    serial_number="1M164900751",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    attenuation_ports=[
	_attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
    ],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_2T2R_Reno",
    radio_type="FHEB",
    serial_number="1M164621598",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[
	_attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="AHFB",
    serial_number="EA183011396",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.134", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172904034",
    rus=[_rmod_4],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173643936",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240906505",
    rus=[],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1242210956",
)

_smod_1 = Airscale([_fct_1])



_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.236.213"),
    instance_id=10813,
)

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.26.71",
                               user="ftp1_user1",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.26.73")


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 version=3)

_android_1 = TafUeAndroid(
    serial_number="AQ5003H048PC1100627",
    ue_pc_address="10.5.29.155",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.29.155",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="244084710003039",
    imei="350693142513256",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
#    airplane_mode_switcher_text ="",
#    airplane_mode_confirm_button_text ="",
#    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#0808#',
    capabilities =["NOKIA_G42_5G"],
)


#--------------------------------- STOP TAF_UE_PROXY UEs -----------------------------------------------

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.71", username="ute"), 
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_L_10813_1ASIB_2ABIA_1ABIO_1AHFB_3FHEB",
    attenuator=[_attenuator],
    pdus=_pdus,
)
      
__all__ = ["tl"]
