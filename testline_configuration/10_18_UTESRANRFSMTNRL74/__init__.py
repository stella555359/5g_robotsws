__maintainer__ = "nicoleta.frumosu@nokia.com"
__owner__ = "nicoleta.frumosu@nokia.com"
__email__ = "nicoleta.frumosu@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
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
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.242", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.243", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.244", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.209",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"  # AZQS1
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"  # AZQS2
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"  # AHEGA
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"  # AZQS3
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"  # AHPE

_pdu_2 = Gude(
    addr="10.255.5.210",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"  # ASIB_BTS1
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"  # ASIB_BTS2
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"  # FSMF

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M212807176",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.18.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M213114038",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" 172.22.18.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    attenuation_ports=[],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M213114112",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.16.162", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    attenuation_ports=[],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPE.value,
    serial_number="1M212503002",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    attenuation_ports=[],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9181421448",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="L1143025267",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="L1143809126",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1211204261",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201900009",
    test_pc=_test_pc_2,
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="KQ170730017",
    test_pc=_test_pc_3,
)

# _dcap_1 = DcapRnD(
#     HttpConnectionDetails(addr="10.5.21.198", port="9443", username=None, password=None)
# )

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Flexi([_fct_3])


_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=621074,
    # dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.0.66.74"),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=622174,
    # dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.0.66.174"),
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_enb_lte_3 = RealEnb(
    system_module=_smod_3,
    rms=[_rmod_5],
    instance_id=1230,
    # dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.5.17.74"),
    bcf_id="3074",
)

_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_3.system_module.common_units[0],
        interface_type="lmp",
    )
)

_bsc = BSC(
    name="BSC_PAAVAI",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.126.7 ", username="SYSTEM", password="SYSTEM"
    ),
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
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

# _android1 = TafUeAndroid(serial_number='H2J9FI1G803C2100144',
#                         ue_pc_address='10.5.29.200',
#                         data_transfer=[_data_transfer_iperf_1],
#                         ssh_connection_details=SshServiceDetails(addr='10.5.29.200',
#                                                                  username='rfsharing',
#                                                                  password='Nokia2022!@1'),
#                         ue_pc_port='80',
#                         capabilities=['NokiaXR21_UE'])
#
# _android2 = TafUeAndroid(serial_number='HZQN1876AAK82902493',
#                         ue_pc_address='10.5.29.200',
#                         data_transfer=[_data_transfer_iperf_2],
#                         ssh_connection_details=SshServiceDetails(addr='10.5.29.200',
#                                                                  username='rfsharing',
#                                                                  password='Nokia2022!@1'),
#                         ue_pc_port='85',
#                         capabilities=['Nokia83_UE'])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_lte_1, _enb_lte_2, _enb_lte_3],
    # ues=[_android1, _android2],
    tl_cloud_topology="CLOUD_RFS_2xASIB_FCC_MTNRL74_3xAZQS_1xAHPE_1xAHEGA",
    bscs=[_bsc],
)

# CELL_TARGET_BW_PATH = (
#           "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL74/cell_target_bw.yaml"
# )

# DCAP_PROFILES_CONFIG_PATH = (
#     "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL74/dcap_profiles.yaml"
# )

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": True,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_DCAP_TRACE_COLLECT_Slave1": False,
    "USER_RSI_INFO_COLLECT": True,
}

__all__ = ["tl"]
