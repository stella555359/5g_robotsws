__maintainer__ = "claudia-elisabeta.gruin@nokia.com"
__owner__ = "claudia-elisabeta.gruin@nokia.com"
__email__ = "claudia-elisabeta.gruin@nokia.com"
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
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.fhs import FHS, FhsType
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.47", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.48", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.47", port="9443", username=None, password=None)
)

_pdu_1 = Gude(
    addr="10.255.5.210",
    port_numbers=[7, 8, 9, 10],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    addr="10.255.5.211",
    port_numbers=[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(
    addr="10.255.5.209",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9171424410",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[11],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9180548882",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[12],
    attenuation_ports=[],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9171424301",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[9],
    attenuation_ports=[],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9171424411",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9175143405",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA164187109",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
    attenuation_ports=[],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA172180689",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
    attenuation_ports=[],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA172084509",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA172180691",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[4],
    attenuation_ports=[],
)
_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2116G1CFP",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[8],
    attenuation_ports=[],
)
_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2051G1TRD",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[7],
    attenuation_ports=[],
)
_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9190907514",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[10],
    attenuation_ports=[],
)

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_1.pdu_ports[9],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.85.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="6Q201905453",
    product_code="473922A.102",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171722173",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="RW190402228",
    rus=[_rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164304035",
    rus=[_rmod_10, _rmod_11, _rmod_12],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201204079",
    fhs=[_fhs_1],
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203201033",
    fhs=[_fhs_1],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1193209176",
    rus=[_rmod_10, _rmod_11, _rmod_12],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1181410759",
    test_pc=_test_pc_slave,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="DH200864034",
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_cu_smod = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.105"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.105", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.105", username="Nemuadmin", password="nemuuser"
    ),
)
_du_smod = DU(
    airscale=_smod_2,
    rus=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
    ],
)
_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623105, dcap=_dcap_1)
_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

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
        _rmod_10,
        _rmod_11,
        _rmod_12,
    ],
    instance_id=621105,
    oam_ip=NetworkAddress(v4="10.0.69.105"),
    dcap=_dcap_1,
)
_test_pc_slave.connections.append(
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
    password="Aikon_4321",
    bind_interface_ip="10.5.61.134",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="AQKSLVH040M93000020",
    ue_pc_address="10.5.53.213",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.213", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android2 = TafUeAndroid(
    serial_number="HZQN1876BAKB2500781",
    ue_pc_address="10.5.53.213",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.213", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)

tl = TestLine(
    test_pc=_test_pc_master,
    enbs=[_enb_lte_1],
    test_pcs=[_test_pc_master, _test_pc_slave],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIR_B4-6_AIL_B1-3_MTNRL105_4xFHFB_1xAHFIC_4xFRIJ_3xAHLOA_1xMDEA",
    ues=[_android1, _android2],
)

ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL105/pa.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
}

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL105/dcap_profiles.yaml"
)

__all__ = ["tl"]
