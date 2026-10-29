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
        addr="10.5.19.113", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.114", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_pdu_1 = Gude(
    addr="10.255.5.15",
    port_numbers=[1, 2],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.14",
    port_numbers=[4, 5, 6, 7,11,12],
    model="EPC",
    version="8221-1",
)


_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="EA213356580",
    pdu_port=_pdu_2.pdu_ports[5],
	lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.173",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM11"
            )
        ]
    )
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="EA203458569",
    pdu_port=_pdu_2.pdu_ports[6]
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="EA203458483",
    pdu_port=_pdu_2.pdu_ports[7]
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9214673098",
    pdu_port=_pdu_2.pdu_ports[4],
	lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.173",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM12"
            )
        ]
    )

)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNC.value,
    serial_number="6Q203405297",
    pdu_port=_pdu_2.pdu_ports[11]
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRIG.value,
    serial_number="6Q170239038",
    pdu_port=_pdu_2.pdu_ports[12]
)    


_ABIO_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",  # ?
    serial_number="L1213010416",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_ABIO_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",  # ?
    serial_number="DH221645050",
    rus=[_rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_ABIO_1, _ABIO_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224209051",
    test_pc=_test_pc_1,
)

_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1221102625",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_abiq = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="A.102",
    serial_number="L1233103924",
    rus=[_rmod_5],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio, _abiq],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="DH251432961",
    test_pc=_test_pc_2,
)


_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.113", port="9443", username=None, password=None)
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=623073,
    dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.0.65.73"),
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_5],
    instance_id=624073,
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

_data_transfer_iperf_4 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="Y13K530002390602521",
    ue_pc_address="10.5.55.173",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.173", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_android2 = TafUeAndroid(
    serial_number="H0D9FI1LV0180800046",
    ue_pc_address="10.5.55.173",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.173", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)

_android4 = TafUeAndroid(
    serial_number="H0D9FI1CN0261600779",
    ue_pc_address="10.5.55.173",
    data_transfer=[_data_transfer_iperf_4],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.173", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_4"],
)

_android3 = TafUeAndroid(
    serial_number="HZQN1876AAK82902538",
    ue_pc_address="10.5.55.173",
    data_transfer=[_data_transfer_iperf_3],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.173", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_3"],
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
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL73",  # it can remain None, until TL is fully integrated in Cloud Manager and Topology is provided
    ues=[_android1, _android2, _android3, _android4],
    optical_switches=[_calient],
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL73/ues.yaml"
ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL73/pa.yaml"
)
DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL73/dcap_profiles.yaml"
)

CELL_TARGET_BW_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL73/cell_target_bw.yaml"
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "LK_USERNAME": "marc.jurca@nokia.com",
    "LK_PASSWORD": "Nokia2024_",
    "USER_MASTER_TECH": "SBTS",
    "USER_SLAVE_TECH": "SBTS",
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_SCF_VALIDATION_CHECK":False,
}


OPTICAL_SWITCH_CONFIG = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL73/optical_switch_ports.yaml"
)

__all__ = ["tl"]
