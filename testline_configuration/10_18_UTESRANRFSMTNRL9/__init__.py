__maintainer__ = "ovidiu.vasi@nokia.com"
__owner__ = "ovidiu.vasi@nokia.com"
__email__ = "ovidiu.vasi@nokia.com"
import os
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
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.optical_switch import Calient

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.137", username="ute", password="setpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_dcap_n = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.137", port="9443", username=None, password=None
    )
)

_pdu_1 = Gude("10.255.5.223", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude("10.255.5.222", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M214207539",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M214207536",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M214207537",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.18", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_fsp_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104699",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_asib = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abio],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1211110267",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_asib])

_cu_asib = CU(
    backhaul_site_oam_ip="10.0.65.9",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.9", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.9", username="Nemuadmin", password="nemuuser"
    ),
)

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=623009,
    oam_ip=NetworkAddress(v4="10.0.65.9"),
    dcap=_dcap_n,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.28",
    user="ftp_5g",
    password="Aikon_4321",
    bind_interface_ip="10.5.61.134",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="HZQN1876AAK92100205",
    ue_pc_address="10.5.55.113",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.113", username="rfs_5g", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_android2 = TafUeAndroid(
    serial_number="H0D9FI1LV0180800016",
    ue_pc_address="10.5.55.113",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.113", username="rfs_5g", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)

_calient = Calient(
    addr="10.255.5.250",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_lte_1],
    optical_switches=[_calient],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1-2_MTNRL9_3xAENB",
    ues=[_android1, _android2],
)


UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL9/ues.yaml"

ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL9/pa.yaml"
)

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL9/dcap_profiles.yaml"
)

OPTICAL_SWITCH_CONFIG = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL9/optical_switch_ports.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
}

__all__ = ["tl"]
