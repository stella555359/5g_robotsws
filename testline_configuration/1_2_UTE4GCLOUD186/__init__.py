__maintainer__ = "Bharat Morad"
__team__ = "MN_RAN_PZ_BLR_SG5"
__email__ = "I_MN_RAN_PZ_BLR_SG5_ATHULYA_SQD_GMS <I_MN_RAN_PZ_BLR_SG5_ATHULYA_SQD@internal.nsn.com>"
__owner_email__ = "bharat.morad@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, RRB
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.attenuator import AttenuationPort, TopYoung


_attenuator1 = TopYoung(
    ip_addr="10.53.188.8",
    port=3001,
    attenuation_port_numbers=[1, 2],
    model="TAS12T12-51-90-1S-EJS",
)

_attenuator2 = TopYoung(
    ip_addr="10.53.188.8",
    port=3001,
    attenuation_port_numbers=[3, 4],
    model="TAS12T12-51-90-1S-EJS",
)


_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.111.67.29",
                               user="ftpuser",
                               password="ftpuser",
                               #bind_interface_ip="2.2.2.2",
                               #expected_prompt="dummy_prompt"
)

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1                                 #OPTIONAL
                                                 #binary_path='some/path',                    #OPTIONAL
                                                 #interface_name='some_interface_name',       #OPTIONAL
                                                 #server_close_delay=50,                      #OPTIONAL
                                                 # bind_ue_ip='1.1.1.1',                     #DEPRICATED instead of this "bind_interface_ip" is used for,
                                                                                             # but usage of "bind_ue_ip" causes obligatory add "-B <ue_addr>" to ue command
                                                 #version=3                                  #OPTIONAL
)
 
_data_transfer_ping = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_1,
                                                interval=1)
 
_data_transfer_ftp = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_1,
                                               interval=1)



_REAL_QUALCOMM_UE = TafUeAndroid(serial_number='38dfb053',
                         capabilities=['REAL_QUALCOMM_UE'],
                         ue_pc_address='10.43.13.214',
                         ue_pc_port=5000,
                         data_transfer=[_data_transfer_iperf,
                                        _data_transfer_ping,
                                        _data_transfer_ftp],
                         ssh_connection_details=SshServiceDetails(addr='192.168.255.1',
                                                                  username='toor4nsn',
                                                                  password='oZPS0POrRieRtu'),
                         qualcomm_prototype=True,
)
 
_REAL_UE= TafUeAndroid(serial_number='38f7b44f',
                         capabilities=['REAL_UE'],
                         ue_pc_address='10.43.13.214',
                         ue_pc_port=5000,
                         data_transfer=[_data_transfer_iperf,
                                        _data_transfer_ping,
                                        _data_transfer_ftp],
                         ssh_connection_details=SshServiceDetails(addr='192.168.255.1',
                                                                  username='toor4nsn',
                                                                  password='oZPS0POrRieRtu'),
                         qualcomm_prototype=True,
)





_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.54.83", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)


_IP_PDU_1 = RRB("10.41.155.55", [1, 2, 3, 4, 5, 6, 7, 8])
_IP_PDU_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[6].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[7].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[8].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    serial_number="AS175108978",
    pdu_port=_IP_PDU_1.pdu_ports[7],
    product_code="472930A.102",
    radio_type="FRHC",
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="L1150509214",
    pdu_port=_IP_PDU_1.pdu_ports[6],
    product_code="472924A.101",
    radio_type="FXED",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="ABIA",
    serial_number="K9174334173",
	product_code="473096A.103",
    pdu_port=_IP_PDU_1.pdu_ports[4],  
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_IP_PDU_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1191004186",
    rus=[_rmod_1,_rmod_2,],
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])




_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1,_rmod_2,], oam_ip=[NetworkAddress(v4="10.43.197.245")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIB_1ABIA_1FRHC_1FXED_CPA_CRT",
    ues=[_REAL_QUALCOMM_UE, _REAL_UE],
    attenuator=[_attenuator1,_attenuator2],
)

__all__ = ["tl"]
