__maintainer__ = "deiana-nicolia.stoianovici@nokia.com"
__owner__ = "deiana-nicolia.stoianovici@nokia.com"
__email__ = "deiana-nicolia.stoianovici@nokia.com"

from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote
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
from taf.config.testline.testpc import TestPc
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
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.45", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.46", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.2.11", [1, 2, 3, 9, 10, 11], "EPC", "8220-1")
_pdu_2 = Gude("10.255.2.12", [9, 10], "EPC", "8220-1")
_pdu_3 = Gude("10.255.2.13", [1, 5, 7], "EPC", "8220-1")

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQU.value,
    serial_number="1M213449553",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQU.value,
    serial_number="1M222314741",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPE.value,
    serial_number="1M202205233",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA201954418",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQU.value,
    serial_number="1M213449723",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M213114040",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M213114018",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username={"SBTS24R3": "rfsw",
                  "SBTS25R1": "rfsw",
                  "SBTS25R2": "rfsw",
                  "SBTS25R3": "rfsw",
                  "SBTS26R1": "serviceuser"},
        password={"SBTS24R3": "5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
                  "SBTS25R1": "5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
                  "SBTS25R2": "5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
                  "SBTS25R3": "5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
                  "SBTS26R1": "wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc="}
    ),    
    pdu_port=_pdu_3.pdu_ports[1],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.209",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM4"
            )
        ]
    )
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA201954887",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA201954422",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[11],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1212210196",
    rus=[_rmod_1, _rmod_2, _rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1212210190",
    rus=[_rmod_6, _rmod_7],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1204605739",
    rus=[_rmod_3, _rmod_4, _rmod_8, _rmod_9],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104U",
    serial_number="DH221940493",
    rus=[_rmod_1, _rmod_2, _rmod_5],
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1212114791",
    rus=[_rmod_6, _rmod_7],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1212114745",
    rus=[_rmod_3, _rmod_4, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[9],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212873504",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212873467",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
    instance_id=621104,
    oam_ip=NetworkAddress(v4="10.0.65.104"),
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
    instance_id=621204,
    oam_ip=NetworkAddress(v4="10.0.65.204"),
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
    address="10.5.56.28",
    user="ftp_5g",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.134",
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

_android1 = TafUeAndroid(
    serial_number="343748ae",
    ue_pc_address="10.5.55.210",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.210", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["NR1"],
)

_android2 = TafUeAndroid(
    serial_number="14cd501b",
    ue_pc_address="10.5.55.209",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.209", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["NR2"],
)
_android3 = TafUeAndroid(
    serial_number="H0V9DE1CN01C1200056",
    ue_pc_address="10.5.55.209",
    data_transfer=[_data_transfer_iperf_3],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.209", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["LTE"],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1, _enb_lte_2],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1_B2_B3_B4_B5_B6_MTNRL104_2AZQS_3AZQU_1AHPE_3AHEH",  # it can remain None, until TL is fully integrated in Cloud Manager and Topology is provided,
    ues=[_android1, _android2, _android3],
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL104/ues.yaml"
ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL104/pa.yaml"
)
CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL104/cell_target_bw.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RSI_INFO_COLLECT": True,
    "SYSLOG_CHECK": False,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL104/MTNRL104_custom_rmod_setup.yaml"
}

__all__ = ["tl"]
