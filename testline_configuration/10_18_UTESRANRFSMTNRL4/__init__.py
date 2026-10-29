__maintainer__ = "alexandra.ragman@nokia.com"
__owner__ = "alexandra.ragman@nokia.com"
__email__ = "alexandra.ragman@nokia.com"
import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
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
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.fhs import FHS, FhsType
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote


_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.52.11", port="9443", username=None, password=None)
)


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.11", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.12", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.2.117",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.2.116",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_OPENED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA201650199",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.46",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM18"
            )
        ]
    )
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA201650195",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.46",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM19"
            )
        ]
    )
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA201650189",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.46",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM20"
            )
        ]
    )
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHPD.value,
    serial_number="EA203753784",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
    attenuation_ports=[],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHPD.value,
    serial_number="YK170300015",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
    attenuation_ports=[],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHPD.value,
    serial_number="EA203753920",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    attenuation_ports=[],
)

_fhs_1 = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu_1.pdu_ports[1],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.41.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="6Q202905739",
    product_code="475700A.102",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_fhs_2 = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu_1.pdu_ports[2],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="6Q201020814",
    product_code="475700A.102",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="A.101",
    serial_number="L1204214781",
    fhs=[_fhs_1],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="A.101",
    serial_number="L1204214752",
    fhs=[_fhs_1],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="A.101",
    serial_number="L1204214777",
    fhs=[_fhs_2],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="A.101",
    serial_number="L1204212532",
    fhs=[_fhs_2],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1212705950",
    test_pc=_test_pc_1,
)


_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224209047",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=623004,
    dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.0.65.184"),
)

_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=624004,
    dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.0.67.184"),
)


_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               expected_prompt='ftp',
                               password="Aikon_123456",
                               bind_interface_ip="10.5.61.134")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="H0J9DE1CN01A2200246",
    ue_pc_address="10.5.55.46",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.46", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_android2 = TafUeAndroid(
    serial_number="H0D9FI1LV0221400677",
    ue_pc_address="10.5.55.46",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.46", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)

_android3 = TafUeAndroid(
    serial_number="H0J9DE1CN01A2200496",
    ue_pc_address="10.5.55.46",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.46", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_3"],
)

_android4 = TafUeAndroid(
    serial_number="AQKSLVH002N61600087",
    ue_pc_address="10.5.55.46",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.46", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_4"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_1, _enb_2],
    ues=[_android1, _android2, _android3, _android4],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL4",
)

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL4/dcap_profiles.yaml"
)
CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL4/cell_target_bw.yaml"
)

ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL4/pa.yaml"
)
RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL4/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_RSI_INFO_COLLECT": True,
    "USER_STOP_AND_FIX": True,
    #    "USER_DCAP_TRACE_COLLECT": True,
    #    "USER_DCAP_TRACE_COLLECT_Master": True,
    #    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL4/MTNRL4_custom_rmod_setup.yaml",
    "SYSLOG_CHECK": False,
}

__all__ = ["tl"]
