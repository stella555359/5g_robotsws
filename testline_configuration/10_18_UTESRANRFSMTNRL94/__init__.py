__maintainer__ = "larisa.garban@nokia.com"
__owner__ = "larisa_garban@nokia.com"
__email__ = "larisa.garban@nokia.com"

import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.17", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.22",
    user="ftp4_5g",
    expected_prompt="ftp",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.142",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    binary_path="C:/Iperf/",
    interface_name="Eth_Askey_eb3b834e",
    interval=1,
    server_close_delay=50,
    # version=2,
    dt_from_uepc=True,
)

_android1 = TafUeAndroid(
    serial_number="H2J9FI1G803C2100308",
    ue_pc_address="10.5.53.203",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.203", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_LTE25"],
)

_android2 = TafUeAndroid(
    serial_number="HZQN1876AAK90900805",
    ue_pc_address="10.5.53.203",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.203", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_NR66"],
)

_android3 = TafUeAndroid(
    serial_number="AQKSLVH002N61600170",
    ue_pc_address="10.5.53.203",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.203", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_LTE66"],
)

_at1 = TafUeAt(
    com_port="4",
    serial_number="eb3b834e",
    capabilities=["ASKEY_N25"],
    ue_pc_address="10.5.53.203",
    ue_pc_login="rfsharing",
    ue_pc_password="Nokia2022!@1",
    ue_pc_expected_prompt="rfsharing@ROTMSRANU50099",
    data_transfer=[_data_transfer_iperf_2],
    ue_pc_port="81",
)

_pdu_1 = Gude(
    addr="10.255.5.76",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.5.77",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="K9234912890",
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="K9233825587",
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="NQ242897620",
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9231215065",
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPB.value,
    serial_number="K9191504783",
    pdu_port=_pdu_2.pdu_ports[7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASOE",
    hardware_version="A.102",
    serial_number="EA221253241",
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=623094,
    oam_ip=NetworkAddress("10.0.65.102"),
)


_test_pc_master.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_ASOE_MTNRL94_3xAQQJ_1xAHPB_1xAHPJ",
)


UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANMTNRL94/ues.yaml"
CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL94/cell_target_bw.yaml"
)
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "LK_USERNAME": "bogdan.hurduzeu@nokia.com",
    "LK_PASSWORD": "Nokia123!",
    "USER_RTWP_CHECK": False,
}

__all__ = ["tl"]
