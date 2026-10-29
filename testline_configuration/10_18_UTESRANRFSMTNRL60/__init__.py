__maintainer__ = "iuga.dacian@nokia.com"
__owner__ = "iuga.dacian@nokia.com"
__email__ = "iuga.dacian@nokia.com"

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
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAndroid

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.219", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.220", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.221", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.145", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.146", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="L1144804034",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.225", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9174138303",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.227", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="L1144804038",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.223", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
    attenuation_ports=[],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7173122108",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.223", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104709",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="AS172530629",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="AS172530365",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="AS181125578",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="EA185224450",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1232804563",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="AS172061847",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="KQ170730006",
    test_pc=_test_pc_3,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_smod_1 = Airscale(common_units=[_fct_1])
_smod_2 = Flexi(common_units=[_fct_2, _fct_3])

_cu_smod = CU(
    backhaul_site_oam_ip="10.0.65.60",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.60", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.60", username="Nemuadmin", password="nemuuser"
    ),
)

_du_smod = DU(airscale=Airscale([_fct_1]), rus=[_rmod_1, _rmod_2, _rmod_3])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.21.219", port="9443", username=None, password=None
    )
)

_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623060, dcap=_dcap_1)

_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    master=_gnb_nr_1,
    instance_id=621060,
    dcap=_dcap_1,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_3.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[1], interface_type="lmp"))

_rnc = RNC(
    rnc_id="8",
    oms_ip="10.44.44.219",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="_nokadmin", password="_P@ssword123"
    ),
)


_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.61.134"
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                app_server=_app_server_1,
                                                interval=1,
                                                server_close_delay=50
)



_app_server_2 = TafUeAppServer(app_server_name="APP_2",
                               address="10.9.146.30",
                               user="iperf_user",
                               password="Treperf",
                               bind_interface_ip="10.9.146.30"
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                app_server=_app_server_2,
                                                interval=1,
                                                server_close_delay=50
)


_android1 = TafUeAndroid(serial_number='HZQN1876FAKA2200161',
                        ue_pc_address='10.5.55.160',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.160',
                                                                username='rfsharing',
                                                                password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['REAL_ANDROID_UE1']
)


_android2 = TafUeAndroid(serial_number='520372ceee8d8415',
                        ue_pc_address='10.5.55.160',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.160',
                                                                username='rfsharing',
                                                                password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['REAL_ANDROID_UE2']
)

_android3 = TafUeAndroid(serial_number='5200c9e452d43513',
                        ue_pc_address='10.5.55.160',
                        data_transfer=[_data_transfer_iperf_2],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.160',
                                                                username='rfsharing',
                                                                password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['REAL_ANDROID_UE3']
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_lte_1],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_FCC_MTNRL60_3FRGY",
    rncs=[_rnc],
    ues=[_android1, _android2, _android3]
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
}

DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL60/dcap_profiles.yaml"
CELL_TARGET_BW_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL60/cell_target_bw.yaml"

__all__ = ["tl"]
