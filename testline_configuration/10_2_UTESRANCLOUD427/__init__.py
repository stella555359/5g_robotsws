__maintainer__ = "Prajwali Milind Joshi"
__owner_email__ = "prajwali.milind_joshi@nokia.com"
__team__ = "MN_RAN_Pz_BLR_5_SG"
__email__ = "I_MN_RAN_PZ_BLR_SG5_VAJRA_SQD@internal.nsn.com"

import os
import sys
import socket
sys.path.append(os.path.join(os.path.dirname(__file__), '../../..'))
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
from taf.config.testline.attenuator import AttenuationPort, TopYoung

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, Pdu # added by sandesh 
from taf.config.testline.appserver import TafUeAppServer 
from taf.config.testline import TafUeDataTransferProtocol 
from taf.config.testline.pdn import PDNTafUeAndroidDetails 
from taf.config.testline.ue import TafUeAndroid 
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)


_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.54.198", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_attenuator1 = TopYoung( 
    ip_addr="10.53.203.73", 
    port=3001, 
    attenuation_port_numbers=[9, 10, 12, 13, 14], 
    model="TAS_16T16_0_2G6_90_1S_DEJS") 

_attenuator2 = TopYoung( 
    ip_addr="10.53.164.203", 
    port=3001, 
    attenuation_port_numbers=[5, 6], 
    model="TAS12T12_51_90_1S_EJS")

_app_server = TafUeAppServer(app_server_name="APP1",
                               address="10.58.241.84",
                               user="ftpuser",
                               password="ftpuser",
                               bind_interface_ip="10.58.241.84",
                               expected_prompt="dummy_prompt")

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server,)
                                                 # interval=1,  # OPTIONAL
                                                 # binary_path='some/path',  # OPTIONAL
                                                 # server_close_delay=50,  # OPTIONAL
                                                 # bind_ue_ip='1.1.1.1',  # OPTIONAL
                                                 # version=3)  # OPTIONAL

_data_transfer_ping = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server,
                                                interval=1)

_data_transfer_ftp = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server,
                                               interval=1)
                                                
_REAL_QUALCOMM_UE = TafUeAndroid( 
                         serial_number='ae52e817', 
                         capabilities=['REAL_QUALCOMM_UE'], 
                         ue_pc_address='10.53.164.247', 
                         ue_pc_port=5000,
                         data_transfer=[_data_transfer_iperf,
                                        _data_transfer_ping,
                                        _data_transfer_ftp],  
                         ssh_connection_details=SshServiceDetails(addr='10.53.164.247', 
                                                                  username='inbabtslabuser', 
                                                                  password='BT5l@bus3rl0g1n'),)    

_IP_PDU_1 = RRB("10.41.155.145", [2])
_IP_PDU_2 = RRB("10.41.155.144", [4, 3])
_IP_PDU_3 = RRB("10.41.155.146", [8, 5])
_IP_PDU_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_IP_PDU_3.pdu_ports[8].contactor = "NORMALLY_OPENED"
_IP_PDU_3.pdu_ports[5].contactor = "NORMALLY_OPENED"

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1170407044",
	product_code="473096A.102",
    pdu_port=_IP_PDU_1.pdu_ports[2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    serial_number="EA184481524",
	product_code="473096A.103",
    pdu_port=_IP_PDU_1.pdu_ports[2],
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    serial_number="L1153803749",
    pdu_port=_IP_PDU_2.pdu_ports[4],
    product_code="473439A.X11",
    radio_type="FXEF",
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="AS175102206",
    pdu_port=_IP_PDU_2.pdu_ports[3],
    product_code="472930A.102 ",
    radio_type="FRMF",
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="AS211620571",
    pdu_port=_IP_PDU_3.pdu_ports[8],
    product_code="473966A.101",
    radio_type="AHCA",
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    serial_number="F7143519960",
    pdu_port=_IP_PDU_3.pdu_ports[5],
    product_code="472501A.104",
    radio_type="FXEB",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_IP_PDU_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="473095A.202",
    serial_number="K9171153216",
    test_pc=_test_pc_master,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4], oam_ip=[NetworkAddress(v4="10.43.197.139")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )

tl = TestLine(
    test_pc=_test_pc_master,
    enbs=[_enb_sbts_1],
    attenuator=[_attenuator1,_attenuator2],
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIA_2ABIA_1FXEF_1FRMF_1AHCA_1FXEB",
	ues=[_REAL_QUALCOMM_UE]
)

__all__ = ["tl"]
