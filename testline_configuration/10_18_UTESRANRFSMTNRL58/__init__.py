__maintainer__ = "alexandra.fratila@nokia.com"
__owner__ = "alexandra.fratila@nokia.com"
__email__ = "alexandra.fratila@nokia.com"

import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
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
from taf.config.testline.dcap import DcapRnD, DcapBasic

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.165", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.166", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude("10.255.2.9", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude("10.255.2.10", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M192827854",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M192827880",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.UHFA.value,
    serial_number="LBALLU-YD18040R11E",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.UHFA.value,
    serial_number="LBALLU-YD153001KMF",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.UHFA.value,
    serial_number="LBALLU-YD18040R10H",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.UHIE.value,
    serial_number="LBALLU-YD18040QXUU",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.UHIE.value,
    serial_number="LBALLU-YD18040QXTW",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M192827898",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="RW232200998",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201707646",
    rus=[_rmod_1, _rmod_2, _rmod_9, _rmod_8],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1191006979",
    rus=[_rmod_3, _rmod_4, _rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1191006954",
    rus=[_rmod_6, _rmod_7],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181412135",
    rus=[_rmod_1, _rmod_2, _rmod_8],
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173003790",
    rus=[_rmod_3, _rmod_4, _rmod_5],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173805564",
    rus=[_rmod_6, _rmod_9, _rmod_7],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1181305755",
    test_pc=_test_pc_2,
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="EA193857420",
    test_pc=_test_pc_1,
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.165", port="9443", username=None, password=None)
)

_cu_smod = CU(
    backhaul_site_oam_ip="10.0.65.58",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.58", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.58", username="Nemuadmin", password="nemuuser"
    ),
)


_du_smod = DU(
    airscale=Airscale([_fct_1]),
    rus=[
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
)
_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623058, dcap=_dcap_1)
_enb_lte_1 = RealEnb(
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
    instance_id=621058,
    oam_ip=NetworkAddress(v4="10.0.69.58"),
    dcap=_dcap_1,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
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
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=100
)

_android1 = TafUeAndroid(
    serial_number="H0J9DE1LV01C2900186",
    ue_pc_address="10.5.55.148",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.148", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["NR_UE"],
)
_android2 = TafUeAndroid(
    serial_number="434d445935573398",
    ue_pc_address="10.5.55.148",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.148", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["LTE_UE"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_nr_1],
    ues=[_android1, _android2],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1-6_MTNRL58_3AHCA_3UHFA_2UHIE_1AHEGG",
)
ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL58/pa.yaml"
)

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL58/dcap_profiles.yaml"
)
#RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANMTNRL23/rsi_config.yaml"
RFS_TL_FLAGS = {
    "SYSLOG_CHECK": False,
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": True,
    "USER_STOP_AND_FIX": False,
    "USER_RSI_INFO_COLLECT": False,
    #    "USER_DCAP_TRACE_COLLECT": True,
    #    "USER_DCAP_TRACE_COLLECT_Master": True,
    #    "USER_DCAP_TRACE_COLLECT_Slave": True,
}

__all__ = ["tl"]
