__maintainer__ = "albert.vienescu@nokia.com"
__owner__ = "albert.vienescu@nokia.com"
__email__ = "albert.vienescu@nokia.com"

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
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
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
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.193", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(addr="10.255.5.9", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(addr="10.255.5.8", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(addr="10.255.5.7", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="EA170632238",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.128", port=2323),
    pdu_port=_pdu_2.pdu_ports[8],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHEL.value,
    serial_number="YK162500208",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.130", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHED.value,
    serial_number="K9154114175",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.132", port=2323),
    pdu_port=_pdu_2.pdu_ports[11],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="EA170632237",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.140", port=2323),
    pdu_port=_pdu_3.pdu_ports[9],
    attenuation_ports=[],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHEL.value,
    serial_number="YK162500211",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.138", port=2323),
    pdu_port=_pdu_2.pdu_ports[7],
    attenuation_ports=[],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9170343207",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.142", port=2323),
    pdu_port=_pdu_2.pdu_ports[9],
    attenuation_ports=[],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="EA170632242",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.144", port=2323),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHED.value,
    serial_number="K9154114177",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.136", port=2323),
    pdu_port=_pdu_2.pdu_ports[12],
    attenuation_ports=[],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHEL.value,
    serial_number="YK162500202",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.134", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
    attenuation_ports=[],
)

_fsp_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="B.101",
    serial_number="L1224207722",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abio],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212874118",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale(common_units=[_fct_1])

#DCAP
_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.193", port="9443", username="dcapuser", password="dcapadmin!"
    )
)

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    instance_id=621091,
    dcap=_dcap_1,
)

# Append the above created entity to the Test PC where it is connected to via LMP

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.134")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_android1 = TafUeAndroid(serial_number='AQKSLVH002MC0200628',
                         ue_pc_address='10.5.53.91',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.91',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE'])

_android2 = TafUeAndroid(serial_number='HZQN1876BAK92101084',
                         ue_pc_address='10.5.53.91',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.91',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['LTE_UE'])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_lte_1],
	ues=[_android1,_android2,],
)
#UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL91/ues.yaml"
TARGET_LOGICAL_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL91/logical_config.yaml"
)
DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL91/dcap_profiles.yaml"
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK":  False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
}
__all__ = ["tl"]
