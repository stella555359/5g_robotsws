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


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.118", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_ue = SshServiceDetails(
        addr="10.5.53.40", username="ute", password="uteUTE!_1234"
    )

_pdu_1 = APC(
    addr="10.255.1.104",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    #model="APC",
)
_pdu_2 = Gude(
    addr="10.255.1.105",
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
    hardware_type="ABIC",
    hardware_version="A.102",
    serial_number="6Q192915823",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIC",
    hardware_version="A.102",
    serial_number="6Q193509679",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIC",
    hardware_version="A.102",
    serial_number="6Q193509667",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH204667822",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_1T1R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1213413670",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.146", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_1T1R",  # ???
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9214704628",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.146", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_1T1R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH232700003",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.146", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.247.172"),
    instance_id=10472,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.27.141.158"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.141.158", username="Nemuadmin", password="systeM123!"
    ),
)


_bsc = BSC(
    name="BSC_AVENSIS_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
    ),
)



# traffic 5G-NSA + LTE
_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.26",
                               user="ftp_5g",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.61.133")  #traffic IP

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

_android1 = TafUeAndroid(serial_number='AQ5003H048PA0800733',
                         capabilities=['NR_NSA'],
                         ue_pc_address='10.5.53.40',
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

_android2 = TafUeAndroid(serial_number='AQ5003H048PA0800733',
                         capabilities=['LTE_only'],
                         ue_pc_address='10.5.53.40',
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
                         
_android3 = TafUeAndroid(serial_number='H0J9DE1CN01C0900440',
                         capabilities=['GSM_only'],
                         ue_pc_address='10.5.53.40',
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
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_L_10472_1ASIB_3ABIC_3AEHC",
    ues=[_android1,_android2,_android3]
)

__all__ = ["tl"]
