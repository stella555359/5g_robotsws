# Here you have a template for TAF config format in LTE-GSM/WCDMA-LTE/NR-LTE/NR-NR Cases.
# Spacing and indentation MUST be taken into account, otherwise Gerrit commits will FAIL
# Please remove ALL comments before any commit
# add your email to the following 3 lines
__maintainer__ = "adrian.ierulescu@nokia.com"
__owner__ = "adrian.ierulescu@nokia.com"
__email__ = "adrian.ierulescu@nokia.com"
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
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.fhs import FHS, FhsType

# TestPc class defines details about VMs/PC UEs connected to eNB
# Data you need to provide: VM ip, username, pass(defined in Cloud Manager user profile settings), eth1 lmp ip
# You can create as many TestPc objects as you need (for VM1, VM2, PC UE). NetworkAddress for VM2 (192.168.255.130) and for PC (192.168.255.131)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.120", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.121", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.28",
    user="ftp_5g",
    expected_prompt="ftp",
    password="Aikon_4321",
    bind_interface_ip="10.5.61.134",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    binary_path="C:/Iperf/",
    interface_name="Cellular 4",
    interval=1,
    server_close_delay=50,
    dt_from_uepc=True,
)

_at1 = TafUeAt(
    com_port="43",
    serial_number="HZQN1876BAK92100936",
    capabilities=["AT_UE"],
    ue_pc_address="10.5.53.13",
    ue_pc_login="rfsharing",
    ue_pc_password="Nokia2022!@1",
    ue_pc_expected_prompt="rfsharing@ROTMSRANU15013",
    data_transfer=[_data_transfer_iperf_1],
    ue_pc_port="81",
)

_dcap_n = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.120", port="9443", username=None, password=None)
)
# Gude class for PDU defining.
# Data you need to provide: PDU IP, port (12 by default), type
# Then, for each port, specify it's contactor position: NORMALLY_OPEN or NORMALLY_CLOSED
# You can create as many Gude objects as you need (in case your SMODs/RMODs are connected to multiple PDUs)
_pdu_1 = Gude(
    "10.255.7.10", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", version="8221-1"
)
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude(
    "10.255.7.9", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", version="8221-1"
)
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_3 = Gude(
    "10.255.7.8", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", version="8221-1"
)
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA172180690",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA163984554",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA170783084",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHBCA.value,
    serial_number="BL1917M000Y",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHBCA.value,
    serial_number="BL1836M000A",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHBCA.value,
    serial_number="BL1914M002G",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGQ.value,
    serial_number="K9144929220",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.202", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGQ.value,
    serial_number="K9144929191",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.204", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGQ.value,
    serial_number="K9144929187",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="L1152210032",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7164423456",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.125", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="K9221141011",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_13 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA213550068",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_14 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGP.value,
    serial_number="L9114300839",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.226.127", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_15 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGP.value,
    serial_number="L1115204087",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.226.125", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_2.pdu_ports[12],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="6Q193802684",
    product_code="473922A.102",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_fhs_2 = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu_2.pdu_ports[4],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="6Q210202810",
    product_code="475700A.102",
    rus=[_rmod_14, _rmod_15, _rmod_11, _rmod_10, _rmod_12, _rmod_13],
)

_fsp_abio1 = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="A.104", serial_number="L1221100805"
)
_fsp_abio2 = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="A.104", serial_number="DH221645050", fhs=[_fhs_1],
)
_fsp_abin3 = CapacityUnit(
    addr="", hardware_type="ABIN", hardware_version="A.103", serial_number="L1213709065", fhs=[_fhs_2],
)
_fsp_abio4 = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="A.102", serial_number="L1212210193", fhs=[_fhs_2],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abio1, _fsp_abio2],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224102557",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abin3, _fsp_abio4],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1202606192",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1, _fct_2])

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
        _rmod_13,
        _rmod_14,
        _rmod_15,
    ],
    instance_id=42140,
    oam_ip=NetworkAddress(v4="10.0.66.33"),
    dcap=_dcap_n,
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
# BSC class for defining BSC entity used by GSM.
# Data you need to provide: name, TELNET/SSH connection details (IP address, username, pass)
# Please keep only the relevant connection details (either telenet or ssh), not both
# RNC class for defining RNC entity used by WCDMA.
# Data you need to provide: id, OMS ip, SSH connection details (IP address, username, pass)
##### FINAL SECTION #####
# TestLine class for defining the whole Testline. This object should be unique
# Data you need to provide: main TestPC object (master), RealEnb object, Bts2G object (If defined), NB object (If defined),
# ClassicalBts object (If defined), Testline Type from Cloud Manager (If defined), BSC and RNC objects (if define); if not, None should be used
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    ues=[_at1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1_B2_B4_B5_MTNRL33_3AHBCA_2AREA_2FXED_2FRGP_3FRGQ_3FRIJ",
)
##### ADDITIONAL VARIABLES  #####
# Path to ues.yaml configuration file. Useful for ute_ue automated voice call/data transfer tests
# Path to logical_config.yaml configuration file. Useful for logical HW config changes automated tests
# Flags for enabling/disabling automated test behaviour when encountering unexpected alarms or exceeding predefined KPI thresholds
# If flag is set to False, automated test will ignore unexpected alarms or the event of exceeding thresholds => verdict will be PASSED
# If flag is set to True, automated test will consider unexpected alarms or the event of exceeding thresholds => verdict will be FAILED
# If flag is not set, their values will be considered True by default.
# Flags LK_USERNAME and LK_PASSWORD are useful for QCAT licenses used by 5G automated TC RFS__NR_LTE_NSA_Data_Transfer_Ute_Ue
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_SCF_VALIDATION_CHECK": True,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
}
DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL33/dcap_profiles.yaml"
)
__all__ = ["tl"]
