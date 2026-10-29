__maintainer__ = "danhe"
__email__ = "dante.1.he@nokia-sbell.com"
__owner_email__ = "dante.1.he@nokia-sbell.com"

import sys
import os
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import  FACOM, PduPort, Pdu, EPC, RRB, APC, Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.ue import TafUeAndroid


_pdu_1 = FACOM(
    addr="10.68.170.188",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_2 = FACOM(
    addr="10.68.170.179",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]
)
_pdu_3 = FACOM(
    addr="10.68.179.196",
    port_numbers=[1, 2, 3, 4, 5, 6]
)

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFB.value,
    serial_number="AH220101096",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHQF.value,
    serial_number="EB2013R0227",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_3.pdu_ports[2],
    hardware_type="ASOF",
    hardware_version="A.101",
    serial_number="EA232850568",
    capacity_units=[],
)

_smod_1 = Flexi([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.68.179.205"),
    instance_id=812,
)


_ue_pc_ssh = SshServiceDetails('10.97.92.204', 'professor', password='Nokia@123')

_iperf_pc_ssh = SshServiceDetails('10.97.92.53', 'ute', password='N0kia@dmin56')
_android_iperf = IperfDataTransferDetails(_iperf_pc_ssh, '40.1.1.254', None)




_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.56.127.48", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)


_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.97.92.204",
                               user="professor",
                               password="dummy_password",
                               bind_interface_ip="2.2.2.2",
                               expected_prompt="dummy_prompt")

 

 
_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1)                                
 
_data_transfer_ping = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_1,
                                                interval=1)
 
_data_transfer_ftp = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_1,
                                               interval=1)


 
_android1 = TafUeAndroid(serial_number='Y2J7N17805001091',
                         capabilities=['Huawei_P10','REAL_UE','Android'],
                         ue_pc_address='10.97.92.204',
                         ssh_connection_details=SshServiceDetails(addr='10.97.92.204',
                                                                  username='professor',
                                                                  password='Nokia@123'),
                         data_transfer=[_data_transfer_iperf,
                                        _data_transfer_ping,
                                        _data_transfer_ftp],
                         phone_number='+13100009961',
                         ue_pc_port='80',
                         imei='866090038881896',
                         imsi='262033100009961',
                         is_rooted='no')
 


tl = TestLine(
    ues=[_android1],
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASOF_1AHFB_1AWHQF",
)

__all__ = ["tl"]
