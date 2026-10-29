__maintainer__ = "danhe"
__email__ = "dante.1.he@nokia-sbell.com"
__owner_email__ = "dante.1.he@nokia-sbell.com"
import sys
import os
sys.path.append('/opt/ute/remoteswinglibrary/remoteswinglibrary-2.2.3.jar')

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
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.ue import TafUeAndroid

_pdu_1 = Gude("10.108.151.127", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")
_pdu_2 = Gude("10.108.166.198", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")
_pdu_3 = Gude("10.108.166.195", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")

_pdu_4 = Gude("10.108.151.208", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")
_pdu_5 = Gude("10.108.166.203", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M170601743",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M170601990",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FZHM.value,
    serial_number="RY152301298",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183241603",
    rus=[_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183242216",
    rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184381521",
    rus=[_rmod_2],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1174201104",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q182640373",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1182603810",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_4.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.202",
    serial_number="L1170502875",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="K9173058492",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.97.124.3"),
    instance_id=5345,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_ue_pc_ssh = SshServiceDetails('10.97.92.204', 'professor', password='Nokia@123')

_iperf_pc_ssh = SshServiceDetails('10.97.92.53', 'ute', password='N0kia@dmin56')
_android_iperf = IperfDataTransferDetails(_iperf_pc_ssh, '40.1.1.254', None)




_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.229.2", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.108.229.3", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
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

 
#Y2J7N17805001091
#3d360d1e
 
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
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_2ASIA_6ABIA_2FXDB_1FZHM_1FZHJ",
)

__all__ = ["tl"]
