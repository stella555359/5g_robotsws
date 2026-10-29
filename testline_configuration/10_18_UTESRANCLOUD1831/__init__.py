__maintainer__ = "Cristinel Sava"
__email__ = "cristinel.sava@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN, APC, Gude, Pdu
from taf.config.testline.pdu import FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.testpc import TestPc

_pdu_1 = FPFH(
    addr="10.255.3.158",
    port_numbers=[1, 2, 3, 4, 5, 6],
    #    login="admin",
    #    password="admin",
    #    protocol="http",
)


_pdu_2 = FPFH(
    addr="10.255.3.156",
    port_numbers=[1, 2, 3, 4, 5, 6],
    #    login="admin",
    #    password="admin",
    #    protocol="http",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdus = [_pdu_1, _pdu_2]

_rmod_1 = RU(
    radio_type=RadioTypes.AEQY.value,
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2", username="rfsw", password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY="
    ),
    serial_number="1M210537344",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    radio_type=RadioTypes.AEQY.value,
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.10", username="rfsw", password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY="
    ),
    serial_number="1M213723379",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    radio_type=RadioTypes.AEQY.value,
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.18", username="rfsw", password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY="
    ),
    serial_number="1M210537342",
    pdu_port=_pdu_2.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0101",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225206963",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH204667333",
)
_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.236.231"),
    instance_id=10831,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.187", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
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
    serial_number="H0V9DE1CN01C1200072",
    ue_pc_address="10.5.60.45",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.45",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="244084710003030",
    imei="352179571697172",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
    #    airplane_mode_switcher_text ="",
    #    airplane_mode_confirm_button_text ="",
    #    path_to_network_mode_type ="",
    is_rooted="no",
    secret_code='*#*#4636#*#*',
    capabilities=["XR20"],
)

# ---------------- STOP TAF_UE_PROXY UEs -----------------

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NLWG_10831_1ASIB_1ABIO_1ABIN_1ABIA_1FXDB_1AHBCB_1AHBOA",
	pdus=_pdus,
    ues=[_android_1],
)

__all__ = ["tl"]
