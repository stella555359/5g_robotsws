__maintainer__ = "marc.jurca@nokia.com"
__owner__ = "marc.jurca@nokia.com"
__email__ = "marc.jurca@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)

from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.nb import NB
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import Calient
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local,Remote

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.106", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.107", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.61",
    port_numbers=[7, 8],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.5.60",
    port_numbers=[3, 4, 5],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.255.5.62",
    port_numbers=[3,6],
    model="EPC",
    version="8221-1",
)

_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHQU.value,
    serial_number="EB2313R0187",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3]
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHQU.value,
    serial_number="EB2313R0195",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4]
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHQU.value,
    serial_number="EB2313R0175",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.38", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5]
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHNA.value,
    serial_number="EB2352R0598",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6]
)


_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQC.value,
    serial_number="AH193501029",
    pdu_port=_pdu_3.pdu_ports[3] 
)

_ABIP_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004047",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_ABIO_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224009420",
    rus=[_rmod_4],
)
_ABIO_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1221102656",
    rus=[_rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_ABIP_1, _ABIO_1, _ABIO_2],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="475765A.102",
    serial_number="L1230610640",
    test_pc=_test_pc_1,
)

_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",  # ?
    serial_number="L1223402771",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_abio_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",  # ?
    serial_number="L1213010375",
    rus=[_rmod_4],
)

_abio_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010377",
    rus=[_rmod_5],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio, _abio_2, _abio_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1215007530",
    test_pc=_test_pc_2,
)


_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.113", port="9443", username=None, password=None)
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=623078,
    dcap=_dcap_1,
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=621078,
    dcap=_dcap_1,
)


_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
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
    password="Aikon_123456",
    bind_interface_ip="10.5.61.131",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_3 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_4 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="H0D9FI1LV0230900520",
    ue_pc_address="10.5.55.178",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.178", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_android2 = TafUeAndroid(
    serial_number="H0D9FI1LV0232300326",
    ue_pc_address="10.5.55.178",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.178", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)

_android3 = TafUeAndroid(
    serial_number="Y13K530002390602528",
    ue_pc_address="10.5.55.178",
    data_transfer=[_data_transfer_iperf_3],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.178", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_3"],
)

_android4 = TafUeAndroid(
    serial_number="H0J9DE1CN01A2200747",
    ue_pc_address="10.5.55.178",
    data_transfer=[_data_transfer_iperf_4],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.178", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_4"],
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
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1, _enb_lte_2],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL78",  # it can remain None, until TL is fully integrated in Cloud Manager and Topology is provided
    ues=[_android1, _android2, _android3, _android4],
    optical_switches=[_calient],
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL78/ues.yaml"
ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL78/pa.yaml"
)
DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL78/dcap_profiles.yaml"
)
CELL_TARGET_BW_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL78/cell_target_bw.yaml"
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": True,
    "USER_RTWP_CHECK_Master": True,
    "USER_RTWP_CHECK_Slave": True,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "LK_USERNAME": "nicoleta.frumosu@nokia.com",
    "LK_PASSWORD": "$Nicoleta3",
    "USER_STOP_AND_FIX": False,
}


OPTICAL_SWITCH_CONFIG = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL78/optical_switch_ports.yaml"
)
__all__ = ["tl"]
