__maintainer__ = "carla-iazmina.urezeanu@nokia.com"
__owner__ = "carla-iazmina.urezeanu@nokia.com"
__email__ = "carla-iazmina.urezeanu@nokia.com"
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
from taf.config.testline.nb import NB
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.94", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.95", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_pdu_1 = Gude("10.255.5.114", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.115", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M235231309",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M235231319",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M240507386",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_abio_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104941",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_abio_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1211704537",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_asim_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1240903541",
    test_pc=_test_pc_1,
)

_asil_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1213103076",
    test_pc=_test_pc_2,
)

_cu_asim_1 = CU(
    backhaul_site_oam_ip="10.0.65.50",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.50", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.50", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asim_1 = DU(airscale=Airscale([_asim_1]), rus=[_rmod_1, _rmod_2, _rmod_3])

_classicalBts_1 = ClassicalBts(cu=_cu_asim_1, dus=[_du_asim_1], instance_id=623050)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_cu_asil_2 = CU(
    backhaul_site_oam_ip="10.0.67.50",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.50", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.50", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asil_2 = DU(airscale=Airscale([_asil_2]), rus=[_rmod_1, _rmod_2, _rmod_3])

_classicalBts_2 = ClassicalBts(cu=_cu_asil_2, dus=[_du_asil_2], instance_id=624050)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_2.dus[0].airscale.common_units[0],
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
    serial_number="H2J9FI1CN03C2200362",
    ue_pc_address="10.5.55.50",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.50", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_android2 = TafUeAndroid(
    serial_number="H0J9DE1LV01C0401312",
    ue_pc_address="10.5.55.50",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.50", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)

ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL50/pa.yaml"
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classicalBts_1, _classicalBts_2],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_AIR_B4_MTNRL50_3xAVQC",
    ues=[_android1, _android2],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_SCF_VALIDATION_CHECK": False,
}

__all__ = ["tl"]
