__maintainer__ = "sergiu-mihail.rotaru@nokia.com"
__owner__ = "sergiu-mihail.rotaru@nokia.com"
__email__ = "sergiu-mihail.rotaru@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.dcap import DcapRnD, DcapBasic
import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt



##### VM definition - right side SMOD primary VM (BTS2) #####
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.224", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.225", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

##### PDU definition #####
_pdu_1 = Gude(
    addr="10.255.5.224",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.223",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.224", port="9443", username="dcapuser", password="dcapadmin!"
    )
)

_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"


##### RFs #####
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHQ2.value,
    serial_number="EB2334R0653",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHQ2.value,
    serial_number="EB2334R0648",
    pdu_port=_pdu_1.pdu_ports[10],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHQ2.value,
    serial_number="EB2334R0651",
    pdu_port=_pdu_1.pdu_ports[11],
)

##### BBmods #####
_abin = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="A.103",
    serial_number="L1222105298",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="DH221645062",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)


##### Smods #####
_asil = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abin],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224102469",
    test_pc=_test_pc_1,
)

_asib = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1211204999",
    test_pc=_test_pc_2,
)



##### BTS2 - right side - node 1 - master #####
_cu_asil_1 = CU(
    backhaul_site_oam_ip="10.0.65.115",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.115", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.115", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asil_1 = DU(airscale=Airscale([_asil]), rus=[_rmod_1, _rmod_2, _rmod_3])


_classicalBts_1 = ClassicalBts(cu=_cu_asil_1, dus=[_du_asil_1], instance_id=623115, dcap=_dcap_1)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_1.dus[0].airscale.common_units[0],

        interface_type="lmp",
    )
)




###### BTS1 - left side - node 2 - slave #####
_cu_asib_1 = CU(
    backhaul_site_oam_ip="10.0.67.115",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.115", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.115", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asib_1 = DU(airscale=Airscale([_asib]), rus=[_rmod_1, _rmod_2, _rmod_3])


_classicalBts_2 = ClassicalBts(cu=_cu_asib_1, dus=[_du_asib_1], instance_id=621115, dcap=_dcap_1)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_2.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)




##### Testline definition #####


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
    serial_number="H0J9DE1LV0211700062",
    ue_pc_address="10.5.53.226",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.226", username="rfs_5g", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_android2 = TafUeAndroid(
    serial_number="H0J9DE1CN01A2200747",
    ue_pc_address="10.5.53.226",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.226", username="rfs_5g", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classicalBts_1, _classicalBts_2],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_AIR_B4_MTNRL115_3xAWHQ2",
    ues=[_android1, _android2],
)

DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL115/dcap_profiles.yaml"
ATTENUATOR_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL115/pa.yaml"
##### Custom config Flags #####
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
}

__all__ = ["tl"]
