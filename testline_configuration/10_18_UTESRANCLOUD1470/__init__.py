__maintainer__ = "None"
__email__ = "None"

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
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.116", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_ue = SshServiceDetails(
        addr="10.5.60.40", username="wro5gqt", password="5Gqtmoth"
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


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173643948",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184978833",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824981",
)
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="EA190273864",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXED.value,
    serial_number="L1182102975",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.136", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165057162",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.137", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.FRGU.value,
    serial_number="AS193612053",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.142", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.FRGU.value,
    serial_number="AS193612051",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.134", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_6T6",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7164057710",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_6 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7201305176",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_7 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU.value,
    serial_number="AS180411893",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_8 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRMF.value,
    serial_number="AS181336263",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.140", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
    oam_ip=NetworkAddress("10.15.247.170"),
    instance_id=10470,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.27.141.158"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.141.158", username="Nemuadmin", password="systeM123!"
    ),
)


_bsc = BSC(
    name="BSC_ASTRA_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="VRFTSR", password="VRFTSR!@"
    ),
)



# traffic 5G-NSA + LTE
#_app_server_1 = TafUeAppServer(app_server_name="APP_1",
#                               address="10.5.56.26",
#                               user="ftp_5g",
#                               password="Aikon_123456",
#                               bind_interface_ip="10.5.61.133")  #traffic IP
# TCP + UDP traffic 5G-NSA + LTE

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.26.73",
                               user="ftp1_user1",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.26.73")  #traffic IP


# traffic LTE
#_app_server_2 = TafUeAppServer(app_server_name="APP_2",
#                               address="10.5.26.71",
#                               user="ftp1_user1",
#                               password="Aikon_2022@#")
# TCP + UDP traffic 5G-NSA + LTE

_app_server_2 = TafUeAppServer(app_server_name="APP_2",
                               address="10.5.26.73",
                               user="ftp1_user1",
                               password="Aikon_123456")

# traffic GSM+WCDMA                            
_app_server_3 = TafUeAppServer(app_server_name="APP_3",
                               address="10.9.146.30",
                               user="iperf_user",
                               password="Treperf")
                                                        
# traffic 5G-SA  
#_app_server_4 = TafUeAppServer(app_server_name="APP_4",
#                               address="10.5.56.28",
#                               user="ftp_5g",
#                               password="Aikon_4321",
#                               bind_interface_ip="10.5.61.132")   #traffic IP

_app_server_4 = TafUeAppServer(app_server_name="APP_4",
                               address="10.5.26.73",
                               user="ftp1_user1",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.26.73")   #traffic IP


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

_android1 = TafUeAndroid(serial_number='AQ5003H048PC1400028',
                         capabilities=['NR_NSA'],
                         ue_pc_address='10.5.60.40',
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

_android2 = TafUeAndroid(serial_number='AQ5003H048PC1400028',
                         capabilities=['LTE_only'],
                         ue_pc_address='10.5.60.40',
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
                         
_android3 = TafUeAndroid(serial_number='AQ5003H048PC1400016',
                         capabilities=['GSM_only'],
                         ue_pc_address='10.5.60.40',
                         data_transfer=[_data_transfer_iperf_3,
                                        _data_transfer_ping_3,
                                        _data_transfer_ftp_3],
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
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_10470_1ASIA_3ABIA_2FXED_1FXED_3FRGU_2FXDB_1FRMF",
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[_android1,_android2,_android3]
)

__all__ = ["tl"]
