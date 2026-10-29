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
        addr="10.5.19.70", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.69", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.226", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.225", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M234304780",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M234304769",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M234304778",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_abip_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1233201691",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_abip_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1233201696",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_asim_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="A.102",
    serial_number="L1230610661",
    test_pc=_test_pc_1,
)

_asim_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="A.102",
    serial_number="L1230610620",
    test_pc=_test_pc_2,
)

_cu_asim_1 = CU(
    backhaul_site_oam_ip="10.0.67.41",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.41", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.41", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asim_1 = DU(airscale=Airscale([_asim_1]), rus=[_rmod_1, _rmod_2, _rmod_3])

_classicalBts_1 = ClassicalBts(
    cu=_cu_asim_1, dus=[_du_asim_1], instance_id=624041
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_cu_asim_2 = CU(
    backhaul_site_oam_ip="10.0.65.41",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.41", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.41", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asim_2 = DU(airscale=Airscale([_asim_2]), rus=[_rmod_1, _rmod_2, _rmod_3])

_classicalBts_2 = ClassicalBts(
    cu=_cu_asim_2, dus=[_du_asim_2], instance_id=624062
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_2.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.134")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_android1 = TafUeAndroid(serial_number='AQKSLVH040M93000030',
                         ue_pc_address='10.5.28.161',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.28.161',
                                                                  username='rfs_5g',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE_1'],
                         )

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classicalBts_1, _classicalBts_2],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1_B2_B3_B4_B5_B6_MTNRL41_3xAZQR",
    ues=[_android1],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
}

__all__ = ["tl"]
