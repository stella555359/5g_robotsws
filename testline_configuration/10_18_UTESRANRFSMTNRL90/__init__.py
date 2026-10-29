__maintainer__ = "constantin.diaconu@nokia.com"
__owner__ = "constantin.diaconu@nokia.com"
__email__ = "constantin.diaconu@nokia.com"

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
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.fhs import FHS, FhsType

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.226", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.227", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.200", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# DCAP class defines details about DCAP server used by test to collect logs; one ore more DCAP objects can be declared
# Data you need to provide: DCAP IP, username, pass, port(default=9443) for usage of local VM installed DCAP or 443 for external DCAP
# Automation and DCAP is supported by using local test-line VM installed DCAP usage, please set DCAP addr to test-line VM-1 IP address
_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.226", port="9443")
)


_pdu_1 = Gude(
    addr="10.255.5.105",
    port_numbers=[7, 8, 10],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.106",
    port_numbers=[1, 2, 5, 7, 8, 9, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="L1145104135",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="L1145108045",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="L1145108044",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2208V0X50",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.45.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2208V0WL5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.45.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2208V0WMF",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.45.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_2.pdu_ports[2],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.41.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="6Q211103120",
    product_code="473922A.102",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104949",
    fhs=[_fhs_1],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="474020B.102",
    serial_number="L1204008371",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193774604",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201902157",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212873475",
    test_pc=_test_pc_2,
)
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1204103081",
    test_pc=_test_pc_3,
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2, _fct_3])


_cu_1 = CU(
    backhaul_site_oam_ip="10.0.65.90",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.90", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.90", username="Nemuadmin", password="nemuuser"
    ),
)
_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_gnb_nr_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], instance_id=43290, dcap=_dcap_1)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=623090,
    dcap=_dcap_1,
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[1],
        interface_type="lmp",
    )
)

_bsc = BSC(
    name="BSC_BUICK",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.5.8.132", username="SYSTEM", password="SYSTEM"
    ),
)
_rnc = RNC(
    rnc_id="10290",
    oms_ip="10.27.31.235",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="_nokadmin", password="_P@ssword123"
    ),
)


_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.24",
    user="ftp3_5g",
    password="Aikon_4321",
    bind_interface_ip="10.5.61.138",
)

_app_server_2 = TafUeAppServer(
    app_server_name="APP_2",
    address="10.9.146.30",
    user="iperf_user",
    password="Treperf",
    bind_interface_ip="10.9.146.30",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_2, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
#    serial_number="0123456789ABCDEF",
    serial_number="H0J9DE1CN01C0900182",
    ue_pc_address="10.5.53.195",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.195", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS1_NR"],
)

_android2 = TafUeAndroid(
    serial_number="H0D9FI1CN0261600803",
    ue_pc_address="10.5.53.195",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.195", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS2_LTE"],
)

_android3 = TafUeAndroid(
    serial_number="58bf4f3a",
    ue_pc_address="10.5.53.195",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.195", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS2_WCDMA"],
)

_android4 = TafUeAndroid(
    serial_number="5203ab9d5a9b2409",
    ue_pc_address="10.5.53.195",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.195", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS2_GSM"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_lte_1],
    gnbs=[_gnb_nr_1],
    rncs=[_rnc],
    bscs=[_bsc],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIR_B4_AILR_B4_B5_MTNRL90_3xFHFB_3xAHFIB_1xMDEA",
    ues=[_android1, _android2, _android3, _android4],
)

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL90/dcap_profiles.yaml"
)

CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL90/cell_target_bw.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "POWER_ON_FLAG": True,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_SCF_VALIDATION_CHECK": False,
}
__all__ = ["tl"]
