__maintainer__ = "Bobocea Catalin"
__email__ = "catalin.bobocea@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

import os
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAndroid


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.79", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.80", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_ue = SshServiceDetails(
        addr="10.5.60.38", username="wro5gqt", password="5Gqtmoth"
    )


_pdu_1 = APC(
    addr="10.255.1.104",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    #model="APC",
)


_pdu_2 = Gude(
    addr="10.255.1.103",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_pdu_3 = Gude(
    addr="10.255.1.105",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_pdu_4 = Gude(
    addr="10.255.1.106",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
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
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
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
_pdu_4.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[12].contactor = "NORMALLY_CLOSED"



_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173915598",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240102431",
)

_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240102426",
)

_fsp_4 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240102305",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1241210688",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1242501096",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARDB.value,
    serial_number="K9203827591",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRMF.value,
    serial_number="F7171227959",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXED.value,
    serial_number="L1170711406",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[11],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARPA.value,
    serial_number="F7195111542",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[9],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARGA.value,
    serial_number="F7190312873",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[7],
)

_rmod_6 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type=RadioTypes.AVHQB.value,
    serial_number="1M251000685",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[2],
)

_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type=RadioTypes.AVHQB.value,
    serial_number="1M251000688",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_8 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type=RadioTypes.AVHQB.value,
    serial_number="1M251000686",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[11],
)




_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.15.247.18"),
    instance_id=10318,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_6, _rmod_7, _rmod_8],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))


_bsc = BSC(
    name="BSC_KAISA_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.92.249.108", username="TIMISO", password="TI2019"
    ),
)


# traffic 5G-NSA + LTE
_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.26.73",
                               user="ftp1_user1",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.26.73")  #traffic IP


# traffic LTE
_app_server_2 = TafUeAppServer(app_server_name="APP_2",
                               address="10.5.26.71",
                               user="ftp1_user1",
                               password="Aikon_2022@#")
# traffic GSM+WCDMA                            
_app_server_3 = TafUeAppServer(app_server_name="APP_3",
                               address="10.9.146.30",
                               user="iperf_user",
                               password="Treperf")   
# traffic 5G-SA  
_app_server_4 = TafUeAppServer(app_server_name="APP_4",
                               address="10.5.56.28",
                               user="ftp_5g",
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.132")   #traffic IP

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1)

_data_transfer_ping_1 = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_1,
                                                interval=1)

_data_transfer_ftp_1 = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_1,
                                               interval=1)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_2,
                                                 interval=1)

_data_transfer_ping_2 = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_2,
                                                interval=1)

_data_transfer_ftp_2 = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_2,
                                               interval=1)

_data_transfer_iperf_3 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_3,
                                                 interval=1)

_data_transfer_ping_3 = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_3,
                                                interval=1)

_data_transfer_ftp_3 = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_3,
                                               interval=1)

_data_transfer_iperf_4 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_4,
                                                 interval=1)

_data_transfer_ping_4 = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_4,
                                                interval=1)

_data_transfer_ftp_4 = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_4,
                                               interval=1)

_android1 = TafUeAndroid(serial_number='AQ5003H048PA0800789',
                         capabilities=['NR_NSA'],
                         ue_pc_address='10.5.60.38',
                         data_transfer=[_data_transfer_iperf_1,
                                        _data_transfer_ping_1,
                                        _data_transfer_ftp_1],
                         ue_pc_port='8080',
                         ssh_connection_details=_test_pc_ue,
                         service_call_attach='16',
                         service_call_detach='16',
                         network_mode_switch_method='secretcode',
                         airplane_mode_switcher_text='Airplane mode',
                         path_to_network_mode_type='Mobile networks/Preferred network type',
                         is_rooted='no')

_android2 = TafUeAndroid(serial_number='AQ5003H048PA0800789',
                         capabilities=['LTE_only'],
                         ue_pc_address='10.5.60.38',
                         data_transfer=[_data_transfer_iperf_1,
                                        _data_transfer_ping_1,
                                        _data_transfer_ftp_1],
                         ue_pc_port='8080',
                         ssh_connection_details=_test_pc_ue,
                         service_call_attach='16',
                         service_call_detach='16',
                         network_mode_switch_method='secretcode',
                         airplane_mode_switcher_text='Airplane mode',
                         path_to_network_mode_type='Mobile networks/Preferred network type',
                         is_rooted='no')
                         
						 
						 
_android3 = TafUeAndroid(serial_number='AQ5003H048PA0800749',
                         capabilities=['GSM_only'],
                         ue_pc_address='10.5.60.38',
                         data_transfer=[_data_transfer_iperf_4,
                                        _data_transfer_ping_4,
                                        _data_transfer_ftp_4],
                         ue_pc_port='8080',
                         ssh_connection_details=_test_pc_ue,
                         service_call_attach='16',
                         service_call_detach='16',
                         network_mode_switch_method='secretcode',
                         airplane_mode_switcher_text='Airplane mode',
                         path_to_network_mode_type='Mobile networks/Preferred network type',
                         is_rooted='no')		

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1,  _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_L_10318_1ASIB_1ABIA_1FRMF_1FXED_1ARGA",
    bscs=[_bsc],
    ues=[_android1,_android2,_android3]
)


__all__ = ["tl"]
