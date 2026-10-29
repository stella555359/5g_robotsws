__maintainer__ = "Andrei Maria"
__email__ = "andrei.maria@nokia.com"

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
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

_pdu_1 = Gude(
    addr="10.255.3.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.3.22",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3 = Gude(
    addr="10.255.3.13",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_4 = Gude(
    addr="10.255.3.23",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_5 = Gude(
    addr="10.255.3.18",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_5.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_5.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_4.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_OPENED"

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="AH192301669",
    pdu_port=_pdu_1.pdu_ports[2],
    radio_type="AHIB",
)
_rmod_2 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="AH193900637",
    pdu_port=_pdu_1.pdu_ports[1],
    radio_type="AHIB",
)
_rmod_3 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="EA185013661",
    pdu_port=_pdu_3.pdu_ports[6],
    radio_type="AHIB",
)
_rmod_4 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="AH202100853",
    pdu_port=_pdu_1.pdu_ports[5],
    radio_type="AHFB",
)
_rmod_5 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="AH192201586",
    pdu_port=_pdu_1.pdu_ports[4],
    radio_type="AHFB",
)
_rmod_6 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="AH192201621",
    pdu_port=_pdu_1.pdu_ports[3],
    radio_type="AHFB",
)
_rmod_7 = RU(
    radio_type="AZHL",
    ru_hw_group="cMAAr6.1_8T8R",
    product_code="475432A.101",
    serial_number="YK203400028",
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_8 = RU(
    radio_type="AZHL",
    ru_hw_group="cMAAr6.1_8T8R",
    product_code="475432A.101",
    serial_number="AH212400219",
    pdu_port=_pdu_5.pdu_ports[8],
)
_rmod_9 = RU(
    radio_type="AZHL",
    ru_hw_group="cMAAr6.1_8T8R",
    product_code="475432A.101",
    serial_number="AH211900773",
    pdu_port=_pdu_4.pdu_ports[6],
)
_fsp_1 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211704567",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211709882",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214208624",
    rus=[_rmod_7],
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214208614",
    rus=[_rmod_8],
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104706",
    rus=[_rmod_9],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224807385",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224807381",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.223"),
    instance_id=10823,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.222", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.223", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)


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
    serial_number="Y13K990002551317634",
    ue_pc_address="10.5.60.41",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.41",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="244084710003072",
    imei="354499420458370",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
##    airplane_mode_switcher_text ="",
##    airplane_mode_confirm_button_text ="",
##    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83_NR","NR_NSA","LTE_only"],

)

_android_2 = TafUeAndroid(
    serial_number="Y13K990002551317643",
    ue_pc_address="10.5.60.41",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.41",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="54001800002233",
    imei="354499420076222",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
##    airplane_mode_switcher_text ="",
##    airplane_mode_confirm_button_text ="",
##    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83_NR","NR_SA"],

)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NL_10823_1ASIL_2ABIO_1ASIL_3ABIO_3AHIB_3AHFB_3AZHL",
)

__all__ = ["tl"]
