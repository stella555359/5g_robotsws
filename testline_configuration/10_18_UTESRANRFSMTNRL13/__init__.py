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
        addr="10.5.21.228", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.172", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.229", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_4 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.55.13", username="rfsharing", password="Nokia2022!@1"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_pdu_1 = Gude("10.255.5.30", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.31", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude("10.255.5.57", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1242207403",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.26", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1242114236",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.30", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1242114235",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2135V0JZ5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9182242750",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.132", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[11],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2135V0JUA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.133", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[12],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2032G1GNK",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2032G1GR5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2032G1GNH",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1193209223",
    rus=[_rmod_7, _rmod_8],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1193311168",
    rus=[_rmod_9],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204604558",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233201711",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181409557",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH180304746",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1232801737",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1232801724",
    test_pc=_test_pc_2,
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1173010828",
    test_pc=_test_pc_3,
)

_fct_4 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="NK163461758",
    test_pc=_test_pc_4,
)


_smod_1 = Airscale(common_units=[_fct_1, _fct_2])
_smod_2 = Airscale(common_units=[_fct_3, _fct_4])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.26.83", port="9443", username="dcapuser", password="dcapadmin!"
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
    ],
    instance_id=623013,
    oam_ip=NetworkAddress(v4="10.0.65.13"),
    dcap=_dcap_1,
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

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    instance_id=621013,
    oam_ip=NetworkAddress(v4="10.0.69.13"),
    dcap=_dcap_1,
)

_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_4.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[1],
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
    serial_number="R5CR60A8X3M",
    ue_pc_address="10.5.60.232",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.232", username="rfs_5g", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_1"],
)

_android2 = TafUeAndroid(
    serial_number="HZQN1876BAK92100478",
    ue_pc_address="10.5.60.232",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.232", username="rfs_5g", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["REAL_ANDROID_UE_2"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3, _test_pc_4],
    enbs=[_enb_lte_1, _enb_lte_2],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL13",
    ues=[_android1, _android2],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": False,
    "fail_if_wrn_threshold": False,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
}
DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL13/dcap_profiles.yaml"
)

__all__ = ["tl"]
