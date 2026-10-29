__maintainer__ = "alexandru.radu@nokia.com"
__owner__ = "adina-denisa.florea@nokia.com"
__email__ = "adina-denisa.florea@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.dcap import DcapRnD, DcapBasic
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
from taf.config.testline.airscale import CoreUnit, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import Calient
import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_calient = Calient(
    addr="10.255.5.250",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)

_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.133", port="9443", username=None, password=None)
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.133", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.134", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.81",
    port_numbers=[3, 5, 7, 8, 11],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    addr="10.255.5.82",
    port_numbers=[4, 5],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(
    addr="10.255.5.83",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9213892268",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9213892263",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[7],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9170817464",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[10],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHIB.value,
    serial_number="AH192600537",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
    attenuation_ports=[],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPCA.value,
    serial_number="BL2029B20IX",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[8],
    attenuation_ports=[],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHN.value,
    serial_number="1M214607490",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[11],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L1142712537",
    rus=[],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA213354008",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="KQ170630195",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_5],
)

_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=621039,
    oam_ip=NetworkAddress(v4="10.0.65.39"),
    dcap=_dcap_1,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.core_units[0],
        interface_type="lmp",
    )
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_5],
    instance_id=622039,
    oam_ip=NetworkAddress(v4="10.5.18.39"),
    dcap=_dcap_1,
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_bsc = BSC(
    name="BSC_TIMISOARA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
    ),
)

_rnc = RNC(
    rnc_id=8,
    oms_ip="10.55.1.178",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="_nokadmin", password="_P@ssword123"
    ),
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
    serial_number="H0R9FI1CN0290800140",
    ue_pc_address="10.5.53.139",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.139", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE1"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL39",
    rncs=[_rnc],
    bscs=[_bsc],
    optical_switches=[_calient],
    ues=[_android1],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "USER_RSI_INFO_COLLECT": True,
}

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL39/dcap_profiles.yaml"
)

OPTICAL_SWITCH_CONFIG = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL39/optical_switch_ports.yaml"
)

RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL39/rsi_config.yaml"

__all__ = ["tl"]
