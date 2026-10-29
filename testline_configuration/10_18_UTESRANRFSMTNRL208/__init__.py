__maintainer__ = "ioana-diana.pop@nokia.com"
__owner__ = "ioana-diana.pop@nokia.com"
__email__ = "ioana-diana.pop@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, APC
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
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.lmi import SerialOverTcp, Remote, Local, SerialOverHost

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.30", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.24", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.2.54", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.2.55", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude("10.255.2.53", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_4 = Gude("10.255.2.52", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_4.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1231102297",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1231102296",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1231105231",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHHD.value,
    serial_number="EB2237R0309",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHHD.value,
    serial_number="EB2237R0333",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="F7200506858",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="F7204203028",
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="AS212802820",
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="F7200506860",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH222130554",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH232302471",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH211900782",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_13 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2135V0JXY",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_14 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2135V0JZ7",
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_15 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHB.value,
    serial_number="L1205104254",
    pdu_port=_pdu_4.pdu_ports[10],
)

_rmod_16 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHB.value,
    serial_number="L1202504943",
    pdu_port=_pdu_4.pdu_ports[11],
)

_rmod_17 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHB.value,
    serial_number="L1205104253",
    pdu_port=_pdu_4.pdu_ports[12],
)

_rmod_18 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQY.value,
    serial_number="1M230404239",
    pdu_port=_pdu_3.pdu_ports[10],
)

_rmod_19 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQY.value,
    serial_number="1M230404247",
    pdu_port=_pdu_3.pdu_ports[12],
)

_rmod_21 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M201414037",
    pdu_port=_pdu_3.pdu_ports[7],
)

_rmod_22 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M211915357",
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_23 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M201413958",
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_25 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M211915356",
    pdu_port=_pdu_4.pdu_ports[8],
)

_rmod_26 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M211915355",
    pdu_port=_pdu_4.pdu_ports[7],
)

_rmod_27 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA215050697",
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_28 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA212351446",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_29 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9242154769",
    pdu_port=_pdu_2.pdu_ports[12],
)

_abip_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1240104875",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_abip_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1240104892",
    rus=[_rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_abip_3 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1240104902",
    rus=[_rmod_10, _rmod_11, _rmod_12, _rmod_13, _rmod_14],
)

_abip_4 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1243301335",
    rus=[_rmod_15, _rmod_16, _rmod_17, _rmod_21],
)

_abip_5 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1243301321",
    rus=[_rmod_18, _rmod_19],
)

_abip_6 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1243301269",
    rus=[
        _rmod_21,
        _rmod_22,
        _rmod_23,
        _rmod_25,
        _rmod_26,
        _rmod_27,
        _rmod_28,
        _rmod_29,
    ],
)

_asim = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_1, _abip_2, _abip_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234206593",
    test_pc=_test_pc_1,
)

_asil = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_4, _abip_5, _abip_6],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1244004856",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale(common_units=[_asim, _asil])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.52.30", port="9443", username=None, password=None)
)

_enb_lte = RealEnb(
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
        _rmod_13,
        _rmod_14,
        _rmod_15,
        _rmod_16,
        _rmod_17,
        _rmod_18,
        _rmod_19,
        _rmod_21,
        _rmod_22,
        _rmod_23,
        _rmod_25,
        _rmod_26,
        _rmod_27,
        _rmod_28,
        _rmod_29,
    ],
    instance_id=621208,
    oam_ip=NetworkAddress("10.0.65.208"),
    dcap=_dcap_1,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[1],
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

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="H0R9FI1CN0240200083",
    ue_pc_address="10.5.53.187",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.53.187", username="rfs_5g", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL208",
    ues=[_android1],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_RSI_INFO_COLLECT": False,
}
DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL208/dcap_profiles.yaml"
)

__all__ = ["tl"]
