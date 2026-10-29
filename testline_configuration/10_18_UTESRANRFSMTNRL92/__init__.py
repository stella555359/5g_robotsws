__maintainer__ = "madalina.neag@nokia.com"
__owner__ = "madalina.neag@nokia.com"
__email__ = "madalina.neag@nokia.com"
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
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.dcap import DcapRnD, DcapBasic
import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local,Remote

 


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.79", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.80", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.58", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"   #ASIA
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"   #ASIB

_pdu_2 = Gude("10.255.5.59", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"   #AREC


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREC.value,
    serial_number="L1251203813",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.1", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3]
)
 
_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="A.102",
    serial_number="L1233003919",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.104",
    serial_number="EA193774833",
) 
 
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212873471",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1190701526",
    test_pc=_test_pc_2,
)
 
_smod_1 = Airscale([_fct_1, _fct_2])
 
_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],   
    instance_id=621092,
    oam_ip=NetworkAddress(v4="10.0.65.92")
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
        device=_enb_lte_1.system_module.common_units[1],
        interface_type="lmp",
    )
)

_bts2g_gsm = Bts2G(
    bcf_id="3092",
    system_module=_smod_1,
    rms=[_rmod_1],  
)

_bsc = BSC(
    name="BSC_PAAVAI",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.126.7", username="SYSTEM", password="SYSTEM"
    ),
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.28",
    user="ftp_5g",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.134",
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
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_3 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_2, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="ASCARLH009M61001532",
    ue_pc_address="10.5.55.92",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.92", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_android2 = TafUeAndroid(
    serial_number="H0E9DE1LV0390400100",
    ue_pc_address="10.5.55.92",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.92", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)

_android3 = TafUeAndroid(
    serial_number="H0D9FI1LV0180700107",
    ue_pc_address="10.5.55.92",
    data_transfer=[_data_transfer_iperf_3],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.92", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_3"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    bts2g_objects=[_bts2g_gsm],
    tl_cloud_topology="None",
    bscs=[_bsc],
    ues=[_android1, _android2, _android3],
    
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": True,
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_DCAP_TRACE_COLLECT_Slave1": False,
 }
 
__all__ = ["tl"]