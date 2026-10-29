__maintainer__ = "madalina.sirbu@nokia.com"
__owner__ = "madalina.sirbu@nokia.com"
__email__ = "madalina.sirbu@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote
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
from taf.config.testline.airscale import CommonUnit, CoreUnit, CapacityUnit
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
        addr="10.5.21.198", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.199", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.200", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.2.119",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"  # AREA
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"  # FRMF
_pdu_1.pdu_ports[9].contactor = "NORMALLY_OPENED"  # FRGX

_pdu_2 = Gude(
    addr="10.255.2.120",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"  # ASOE
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"  # FSMF1
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"  # FSMF2

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRMF.value,
    serial_number="F7163910466",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.208", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA200150660",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    attenuation_ports=[],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.200",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM9"
            )
        ]
    )
)


_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGX.value,
    serial_number="EA170810004",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="NK161230272",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="AS173710431",
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="NK170130585",
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="AS180749838",
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASOE",
    hardware_version="A.103",
    serial_number="EA223155462",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="KQ170730009",
    test_pc=_test_pc_2,
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="KQ170630177",
    test_pc=_test_pc_3,
)

_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.21.198", port="9443", username=None, password=None)
)

_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Flexi([_fct_2])
_smod_3 = Flexi([_fct_3])


_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    instance_id=621123,
    dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.0.66.123"),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.core_units[0],
        interface_type="lmp",
    )
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1,  _rmod_3],
    instance_id=622123,
    dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.0.71.123"),
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
    rms=[_rmod_2],
    instance_id=1230,
    dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.5.17.123"),
    bcf_id="3123",
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
        addr="10.27.126.7", username="SYSTEM", password="SYSTEM"
    ),
)

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               expected_prompt='ftp',
                               password="Aikon_123456",
                               bind_interface_ip="10.5.61.134")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',  
                                                   app_server=_app_server_1,
                                                   interval=1,
                                                   server_close_delay=50)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',  
                                                   app_server=_app_server_1,
                                                   interval=1,
                                                   server_close_delay=50)
                                                   
_android1 = TafUeAndroid(serial_number='H2J9FI1G803C2100144',
                        ue_pc_address='10.5.55.200',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.200',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['NokiaXR21_UE'])

_android2 = TafUeAndroid(serial_number='HZQN1876AAK82902493',
                        ue_pc_address='10.5.55.200',
                        data_transfer=[_data_transfer_iperf_2],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.200',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['Nokia83_UE'])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_lte_1, _enb_lte_2, _enb_lte_3],
    ues=[_android1, _android2],
    tl_cloud_topology="CLOUD_HRAN_RFS_ASOE_FCC_FCC_MTNRL123_1xFRMF_1xAREA",
    bscs=[_bsc],
)

CELL_TARGET_BW_PATH = (
          "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL123/cell_target_bw.yaml"
)

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL123/dcap_profiles.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_DCAP_TRACE_COLLECT_Slave1": False,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL123/custom_rmod_setup.yaml",
    "SYSLOG_CHECK": False,
}

__all__ = ["tl"]