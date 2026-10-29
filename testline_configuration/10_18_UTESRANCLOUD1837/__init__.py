__maintainer__ = "Goman Alexandru"
__email__ = "alexandru.goman@nokia.com"


from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import FPFH
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress

from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

_pdu_1 = FPFH(
    addr="10.255.3.115",
    port_numbers=[1, 2, 3, 4, 5, 6],
#    login="admin",
#    password="admin",
#    protocol="http",
)

_pdu_2 = FPFH(
    addr="10.255.3.119",
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


_rmod_1 = RU(
    radio_type="AVQA",
    ru_hw_group="RF.SRM7.trunk.20251130.004",
    serial_number="L1251900660",
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    radio_type="AVQA",
    ru_hw_group="RF.SRM7.trunk.20251130.004",
    serial_number="L1251604437",

    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    radio_type="AVQA",
    ru_hw_group="RF.SRM7.trunk.20251130.004",
    serial_number="L1251900665",

    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_4 = RU(
    radio_type="AHPB",
    ru_hw_group="RF.FRM5.trunk24.20251130.001",
    serial_number="DH252134655",

    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_5 = RU(
    radio_type="AHPJ",
    ru_hw_group="RF.FRM5.trunk24.20251130.001",
    serial_number="K9233036796",

    pdu_port=_pdu_2.pdu_ports[2],
)

_fct_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASOE",
    hardware_version="475587A.101",
    serial_number="EA211854161",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.15.232.237"),
    instance_id=10837,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.180", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
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
    serial_number="AQ5003H048Q60300543",
    ue_pc_address="10.5.60.42",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.42",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="540018000002234",
    imei="350693143492351",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
    #    airplane_mode_switcher_text ="",
    #    airplane_mode_confirm_button_text ="",
    #    path_to_network_mode_type ="",
    is_rooted="no",
    secret_code='*#*#4636#*#*',
    capabilities=["XR20","NR_SA"],
)

# ---------------- STOP TAF_UE_PROXY UEs -----------------

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],

    tl_cloud_topology="CLOUD_SRAN_N_10837_1ASOE_3AVQA_1AHPB_1AHPJ",
)

__all__ = ["tl"]

