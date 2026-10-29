# ---- README ----
# This configuration file was generated automatically
# Before using this configuration file, please read the following documnent as some variables must be changed before
# running any Robot Test
# Link :

__owner__ = "adrian.beta@nokia.com"
__maintainer__ = "adrian.beta@nokia.com"
__email__ = "adrian.beta@nokia.com"

import os
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
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.fhs import FHS, FhsType

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.19.124", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.19.125", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.10", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.255.5.9", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type=RadioTypes.FRPD.value,
    serial_number="EA194510088",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.15.5", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA163984589",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.15.3", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type=RadioTypes.FRPD.value,
    serial_number="EA194510087",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.15.0", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="L1184911210",
    default_telnet_connection_details=SshServiceDetails(
        addr="172.16.77.130", username=[], password=[]
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_5 = RU(
    ru_hw_group="FRMrRH4.0_4T4R",
    radio_type=RadioTypes.FRHG.value,
    serial_number="K9170816454",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_6 = RU(
    ru_hw_group="FRMrRH4.0_4T4R",
    radio_type=RadioTypes.FRHG.value,
    serial_number="K9170816483",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_1.pdu_ports[9],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="6Q211103100",
    product_code="473922A.102",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_5, _rmod_6],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203201112",
    fhs=[_fhs_1],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1192702107",
    rus=[_rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1212612263",
    rus=[_rmod_4],
    fhs=[_fhs_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1211205013",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1220710059",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=42281,
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_cu_1 = CU(
    backhaul_site_oam_ip="10.0.65.81",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.81", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.81", username="Nemuadmin", password="nemuuser"
    ),
)

_du_1 = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], instance_id=43281)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_1.dus[0].airscale.common_units[0],
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

_android1 = TafUeAndroid(
    serial_number="HZQN1876AAK82902485",
    ue_pc_address="10.5.55.166",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.166", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android2 = TafUeAndroid(
    serial_number="HZQN1876BAK92100936",
    ue_pc_address="10.5.55.166",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.166", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_2],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1_B4_MTNRL81_2FRPD_2FRHG_1ARDB_1FRIJ",
    ues=[_android1, _android2],
)

ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL81/pa.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
}

__all__ = ["tl"]
