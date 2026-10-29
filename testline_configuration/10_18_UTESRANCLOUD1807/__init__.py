# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Dorin Nadasan"
__team__ = "VRF_TSR1_T05_04"
__email__ = "I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com"
__owner_email__ = "dorin.nadasan@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CoreUnit
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
    addr="10.255.1.64",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    addr="10.255.1.147",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"


_attenuator = RadioRack(
    ip_addr="10.255.1.176",
    port=50000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],    
    model="8-220",
)

_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="LR252809747",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.127", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
    ],
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="LR252809824",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
    attenuation_ports=[
        _attenuator.attenuator_ports[2],
    ],
)

_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="LR252809745",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
    attenuation_ports=[
        _attenuator.attenuator_ports[3],
    ],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="AS195003426",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
    attenuation_ports=[
        _attenuator.attenuator_ports[4],
    ],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1244506245",
        rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.15.239.207"),
    instance_id=10807,
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
    serial_number="AQ5003H048PA0800732",
    ue_pc_address="10.5.60.106",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.106",
        username="noklab\wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="244084710003039",
    imei="350693141315992",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
#    airplane_mode_switcher_text ="",
#    airplane_mode_confirm_button_text ="",
#    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83"],
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.73", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.127"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2]

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_NLG_10807_1ASOG_3AHPMDG_1AHCA",
    attenuator=[_attenuator],
	pdus=_pdus,
)

__all__ = ["tl"]
