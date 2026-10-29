__owner__ = "iasmina.dragity@nokia.com"
__maintainer__ = "ariel.ciucurita@nokia.com"
__email__ = "ariel.ciucurita@nokia.com"


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
from taf.config.testline.nb import NB
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, PSU
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.dcap import DcapRnD, DcapBasic

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.19.230", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.19.231", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.130")],
)


_pdu_1 = Gude("10.255.5.179", [9, 10], "EPC", "8221-1")
_pdu_2 = Gude("10.255.5.180", [1, 2, 3, 10], "EPC", "8221-1")


_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="YK203400057",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.49.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="YK203400063",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.49.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="YK203400045",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.48.34", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="EA223661209",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232001217",
    rus=[_rmod_3, _rmod_4],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223402976",
    rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204604560",
    rus=[_rmod_2],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004059",
    rus=[_rmod_3, _rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211704622",
    rus=[_rmod_2],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204206375",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH223747235",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="DH214547137",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.230", port="9443", username=None, password=None
    )
)

_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=624030,
    oam_ip=NetworkAddress("10.0.67.30"),
    dcap=_dcap_1,
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_cu_1 = CU(
    backhaul_site_oam_ip="10.0.65.30",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.30", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.30", username="Nemuadmin", password="nemuuser"
    ),
)

_du_1 = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], instance_id=623030, dcap=_dcap_1)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.24",
    user="ftp3_5g",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.138",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.5.53.130",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr='10.5.53.130', username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["NR_UE"],
)

_android2 = TafUeAndroid(
    serial_number="H0J9DE1LV0190600351",
    ue_pc_address="10.5.53.130",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr='10.5.53.130', username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["LTE_UE"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_2],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1_B4_B5_B6_MTNRL30_3xAZHL",
    ues=[_android1, _android2],
)

# ATTENUATOR_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL30/pa.yaml"

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL30/dcap_profiles.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": False,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
}

__all__ = ["tl"]
