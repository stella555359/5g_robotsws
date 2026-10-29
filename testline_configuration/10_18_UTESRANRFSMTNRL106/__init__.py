__maintainer__ = "larisa.garban@nokia.com"
__owner__ = "larisa.garban@nokia.com"
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
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.128", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.129", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude(
    addr="10.255.5.213",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.214",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAFB.value,
    serial_number="BL2042H668",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAIB.value,
    serial_number="BL2030I23FP",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAFB.value,
    serial_number="BL2111H271N",
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAIB.value,
    serial_number="BL2110I27AL",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAFB.value,
    serial_number="BL2110H270F",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAIB.value,
    serial_number="BL2048I26MA",
    pdu_port=_pdu_2.pdu_ports[12],
)
_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="B.101",
    serial_number="L1211709903",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_abia = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1191508792",
    rus=[_rmod_1, _rmod_2],
)
_abia2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="RW190402229",
    rus=[_rmod_3, _rmod_4],
)
_abia3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1191508790",
    rus=[_rmod_5, _rmod_6],
)
_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1232801702",
    test_pc=_test_pc_master,
)
_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia, _abia2, _abia3],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1211200549",
    test_pc=_test_pc_slave,
)

_cu_asil = CU(
    backhaul_site_oam_ip="10.0.67.102",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.71.106", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.71.106", username="Nemuadmin", password="nemuuser"
    ),
)
_du_asil = DU(
    airscale=Airscale([_asil]),
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_classicalBts = ClassicalBts(cu=_cu_asil, dus=[_du_asil], instance_id=623106)
_enb_lte = RealEnb(
    system_module=Airscale([_asib]),
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=621106,
)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_slave.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.28",
    user="ftp_5g",
    expected_prompt="ftp",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.131",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="H0D9FI1LV0242400021",
    ue_pc_address="10.5.55.215",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.215", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["NR_n25"],
)

_android2 = TafUeAndroid(
    serial_number="H0R9FI1CN01C0200505",
    ue_pc_address="10.5.55.215",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.215", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["LTE_b2"],
)

_android3 = TafUeAndroid(
    serial_number="HZQN1876AAK92100032",
    ue_pc_address="10.5.55.215",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.215", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["NR_n66"],
)

_android4 = TafUeAndroid(
    serial_number="HZQN1876BAK92100940",
    ue_pc_address="10.5.55.215",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.215", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["LTE_b4"],
)

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    gnbs=[_classicalBts],
    enbs=[_enb_lte],
    ues=[_android1, _android2, _android3, _android4],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_AIL_B1-3_MTNRL106_3AAFIA",
)

CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL106/cell_target_bw.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": True,
}

__all__ = ["tl"]
