__maintainer__ = "andreea.circeag@nokia.com"
__owner__ = "andreea.circeag@nokia.com"
__email__ = "andreea.circeag@nokia.com"
import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.dcap import DcapRnD
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
from taf.config.testline.optical_switch import Calient
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote

_calient = Calient(
    addr="10.255.5.250",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.19", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.20", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude("10.255.5.110", [5, 6, 7, 10], "EPC", "8221-1")
_pdu_2 = Gude("10.255.5.111", [5, 6], "EPC", "8221-1")
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2217N402A",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[10],
    attenuation_ports=[],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.98", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM4")],  # windows
    ),
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2216N400Z",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[7],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREC.value,
    serial_number="L1252500825",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREC.value,
    serial_number="L1252600836",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[6],
    attenuation_ports=[],
)
_fsp_1 = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="A.104", serial_number="L1221102661", rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="A.104", serial_number="L1213010353", rus=[_rmod_3, _rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="", hardware_type="ABIP", hardware_version="A.101", serial_number="L1232004086", rus=[_rmod_3, _rmod_4]
)
_fsp_4 = CapacityUnit(
    addr="", hardware_type="ABIQ", hardware_version="A.102", serial_number="L1233103416", rus=[_rmod_1, _rmod_2]
)
_fsp_5 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.103", serial_number="L1181415991", rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4]
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234206607",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1223402815",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_smod = DU(airscale=Airscale([_fct_1]), rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.19", port="9443", username="dcapuser", password="dcapadmin!"
    )
)

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=621098,
    dcap=_dcap_1,
)
_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=622098,
    dcap=_dcap_1,
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
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

_android1 = TafUeAndroid(
    serial_number="HZQN1876BAK92100761",
    ue_pc_address="10.5.53.202",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.202", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["NR_BTS1"],
)

_android2 = TafUeAndroid(
    serial_number="HZQN1876AAK82902625",
    ue_pc_address="10.5.53.202",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.202", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["LTE_BTS1"],
)

_android3 = TafUeAndroid(
    serial_number="HZQN1876FAL33100401",
    ue_pc_address="10.5.53.202",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.202", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["NR_BTS2"],
)

_android4 = TafUeAndroid(
    serial_number="HZQN1876AAK92100069",
    ue_pc_address="10.5.53.202",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.202", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["LTE_BTS2"],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1, _enb_lte_2],
    ues=[_android1, _android2, _android3, _android4],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL98",
    optical_switches=[_calient],
)

OPTICAL_SWITCH_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL98/optical_switch_ports.yaml"

DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL98/dcap_profiles.yaml"
CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL98/cell_target_bw.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "USER_RSI_INFO_COLLECT":True,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL98/rsi_config.yaml",
    "RMOD_UDP_LOG_CONFIG_PATH": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL98/auto_udp.yaml"
}

__all__ = ["tl"]
