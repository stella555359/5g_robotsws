__maintainer__ = "ricardo.maia@nokia.com"
__owner__ = "ricardo.maia@nokia.com"
__email__ = "ricardo.maia@nokia.com"

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
_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.157",
        username="ute",
        password="ute",
        # SBTS1
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.158",
        username="ute",
        password="ute",
        # SBTS2
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
##### PDU definition #####
_pdu_1 = Gude(
    addr="10.255.5.87",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.88",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# _dcap_1 = DcapRnD(
#    HttpConnectionDetails(
#        addr="10.5.19.224", port="9443", username="dcapuser", password="dcapadmin!"
#    )
# )
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"

##### RFs #####
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9190720642",
    pdu_port=_pdu_2.pdu_ports[8],
)
# _rmod_2 = RU(
#    ru_hw_group="",
#    radio_type=RadioTypes.AHPDC.value,
#    serial_number="RW232100516",
#    pdu_port=_pdu_2.pdu_ports[9],
# )
# _rmod_3 = RU(
#    ru_hw_group="",
#    radio_type=RadioTypes.AHPDC.value,
#    serial_number="RW232100522",
#    pdu_port=_pdu_2.pdu_ports[10],
# )
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="K9192414079",
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHQ2.value,
    serial_number="EB2321R0352",
    pdu_port=_pdu_2.pdu_ports[11],
)
##### BBmods #####
_abio_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211704623",
    rus=[_rmod_1],
)
_abio_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010376",
    rus=[_rmod_5],
)
_abia_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163409982",
)
_abia_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181409532",
    rus=[_rmod_1, _rmod_4],
)
# _dcap_1 = DcapRnD(
#    HttpConnectionDetails(
#        addr="10.5.21.230", port="9443", username="dcapuser", password="dcapadmin!"
#    )
# )
##### Smods #####
_asil = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1, _abio_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH223747227",
    test_pc=_test_pc_master,
)
_asib = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212874078",
    test_pc=_test_pc_slave,
)
##### BTS2 - right side - node 1 - master #####
_cu_asil_1 = CU(
    backhaul_site_oam_ip="10.0.65.48",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.48", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.48", username="Nemuadmin", password="nemuuser"
    ),
)
_du_asil_1 = DU(airscale=Airscale([_asil]), rus=[_rmod_1, _rmod_5])
# _classicalBts_1 = ClassicalBts(cu=_cu_asil_1, dus=[_du_asil_1], instance_id=623115, dcap=_dcap_1)
_classicalBts_1 = ClassicalBts(cu=_cu_asil_1, dus=[_du_asil_1], instance_id=623115)
_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)
###### BTS1 - left side - node 2 - slave #####
_cu_asib_1 = CU(
    backhaul_site_oam_ip="10.0.69.48",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.69.48", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.69.48", username="Nemuadmin", password="nemuuser"
    ),
)
_du_asib_1 = DU(airscale=Airscale([_asib]), rus=[_rmod_1, _rmod_4])
# _classicalBts_2 = ClassicalBts(cu=_cu_asib_1, dus=[_du_asib_1], instance_id=621115, dcap=_dcap_1)
_classicalBts_2 = ClassicalBts(cu=_cu_asib_1, dus=[_du_asib_1], instance_id=621115)
_test_pc_slave.connections.append(
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
# UEs data not updated with the ones on teh TL
_android1 = TafUeAndroid(
    serial_number="H0J9DE1LV0211700062",
    ue_pc_address="10.5.53.148",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.148", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)
_android2 = TafUeAndroid(
    serial_number="H0J9DE1CN01A2200747",
    ue_pc_address="10.5.53.148",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.148", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)
tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    gnbs=[_classicalBts_1, _classicalBts_2],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1-2_AIR_B4-2_MTNRL48_1xAHFIB_1xAHFIC_1xAWHQ2",
    # tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1-2_AIR_B4-2_MTNRL48_1xAHFIB_1xAHFIC_1xAWHQ2_2xAHPDC",
    ues=[_android1, _android2],
)
DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL48/dcap_profiles.yaml"
)
ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL48/pa.yaml"
)
##### Custom config Flags #####
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
}
__all__ = ["tl"]
