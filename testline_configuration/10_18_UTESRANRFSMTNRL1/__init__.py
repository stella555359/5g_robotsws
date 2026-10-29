__maintainer__ = "samuel-andronic.sabou@nokia.com"
__owner__ = "samuel-andronic.sabou@nokia.com"
__email__ = "samuel-andronic.sabou@nokia.com"


import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, EPC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
#from taf.config.testline.dcap import DcapRnD, DcapBasic


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.161", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(addr="10.255.5.73", port_numbers=[3], model="EPC", version="8220-1")
_pdu_2 = Gude(addr="10.255.5.72", port_numbers=[5, 6, 9, 10], model="EPC", version="8220-1")

_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"


# _dcap_1 = DcapRnD(
#     HttpConnectionDetails(
#         addr="10.5.19.161", port="9443", username="dcapuser", password="dcapadmin!")
# )


_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXDD.value,
    serial_number="F7173533534",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.134", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXDD.value,
    serial_number="F7192129643",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.133", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRGX.value,
    serial_number="EA170810030",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRGX.value,
    serial_number="EA180511678",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323),
    pdu_port=_pdu_2.pdu_ports[10],
)



_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.104",
    serial_number="EA193774854",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4]
    )

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="A.102",
    serial_number="L1233103413",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4]
    )


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201004634",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])


_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=621001,
   # dcap=_dcap_1,
    bcf_id='3101',
   )

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))


_bsc = BSC(
    name="BSC_BUICK",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.8.132", username="SYSTEM", password="SYSTEM")
        )

_test_pc_1.connections.append(_bsc)


_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.24",
                               user="ftp3_5g",
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.138")

_app_server_2 = TafUeAppServer(
    app_server_name="APP_2",
    address="10.9.146.30",
    user="iperf_user",
    password="Treperf",
    bind_interface_ip="10.9.146.30",
)


_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)


_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_2,
                                                 interval=1,
                                                 server_close_delay=50)


_android1=TafUeAndroid(
     serial_number='HZQN1876AAK92100132',
     ue_pc_address='10.5.53.42',
     data_transfer=[_data_transfer_iperf_1],
     capabilities=['Nokia8.3_5GB1'],
     ue_pc_port='80',
     ssh_connection_details=SshServiceDetails(addr='10.5.53.42', username='rfsharing', password='Nokia2022!@1'))


_android2=TafUeAndroid(
     serial_number='HZQN1876AAK82902598',
     ue_pc_address='10.5.53.42',
     data_transfer=[_data_transfer_iperf_1],
     capabilities=['Nokia8.3_4GB8'],
     ue_pc_port='80',
     ssh_connection_details=SshServiceDetails(addr='10.5.53.42', username='rfsharing', password='Nokia2022!@1'))


_android3=TafUeAndroid(
     serial_number='HZQN1876BAKB2500414',
     ue_pc_address='10.5.53.42',
     data_transfer=[_data_transfer_iperf_1],
     capabilities=['Nokia8.3_5GB8'],
     ue_pc_port='80',
     ssh_connection_details=SshServiceDetails(addr='10.5.53.42', username='rfsharing', password='Nokia2022!@1'))


_android4=TafUeAndroid(
     serial_number='HZQN1876AAKA2801796',
     ue_pc_address='10.5.53.42',
     data_transfer=[_data_transfer_iperf_1],
     capabilities=['Nokia8.3_4GB1'],
     ue_pc_port='80',
     ssh_connection_details=SshServiceDetails(addr='10.5.53.42', username='rfsharing', password='Nokia2022!@1'))


_android5=TafUeAndroid(
     serial_number='5200c9e553153521',
     ue_pc_address='10.5.53.42',
     data_transfer=[_data_transfer_iperf_2],
     capabilities=['NokiaX20_WCDMA'],
     ue_pc_port='80',
     ssh_connection_details=SshServiceDetails(addr='10.5.53.42', username='rfsharing', password='Nokia2022!@1'))


_android6=TafUeAndroid(
     serial_number='5d30d4b7',
     ue_pc_address='10.5.53.42',
     data_transfer=[_data_transfer_iperf_2],
     capabilities=['2G_GSM'],
     ue_pc_port='80',
     ssh_connection_details=SshServiceDetails(addr='10.5.53.42', username='rfsharing', password='Nokia2022!@1'))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_lte_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1-2_MTNRL1_2xFXDD_2xFRGX",
    bscs=[_bsc],
    ues=[_android1, _android2, _android3, _android4, _android5, _android6],
    )



#TARGET_LOGICAL_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL1/logical_config.yaml"
#DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL1/dcap_profiles.yaml"
ATTENUATOR_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL1/pa.yaml"

#UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL1/ues.yaml"


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "LK_USERNAME": "raul.caraiman@nokia.com",
    "LK_PASSWORD": "Nokia1234",
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_STOP_AND_FIX": False,
    "POWER_ON_FLAG": True,
    }


__all__ = ["tl"]
