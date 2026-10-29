__maintainer__ = "Krzysztof Brykman"
__team__ = "siso"
__email__ = "krzysztof.brykman@nokia.com"
__owner_email__ = "krzysztof.brykman@nokia.com"

import os
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline import Connection, CUS
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
#from taf.config.testline.testpc import TestPc
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testpc import TestPc, Connection

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

_pdu_1 = Gude("10.42.169.6", [1, 2], "EPC", "8220-1")
_pdu_2 = Gude("10.42.168.102", [1, 2, 3, 6], "EPC", "8220-1")
_pdu_3 = Gude("10.42.168.106", [1, 2, 3, 4, 5, 6, 7], "EPC", "8221-1")

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH242203822",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH242300461",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH242902872",
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245001205",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245001230",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245001208",
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251101948",
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_8 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251101913",
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_9 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251101947",
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_10 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH250400432",
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_11 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245128878",
    pdu_port=_pdu_3.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    serial_number="L1231800036",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_10],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    serial_number="L1244806844",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIP",
    serial_number="L1244806850",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_4, _rmod_5],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIP",
    serial_number="L1244806878",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_6, _rmod_11],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    hardware_type="ASIM",
    serial_number="L1234400871",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3, _fsp_4],
    hardware_type="ASIM",
    serial_number="L1233503521",
    pdu_port=_pdu_1.pdu_ports[2],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
    ],
    oam_ip=NetworkAddress("10.42.175.11"),
    instance_id=1312,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
    ],
#    oam_ip=NetworkAddress("10.44.137.152"),
    instance_id=1312,
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.7", username="ute"),
    connections=[NetworkAddress(v4='192.168.255.126'),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp")
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.184.8", username="ute"),
    connections=[NetworkAddress(v4='192.168.255.126'),
        Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp")
    ],
)

_app_server_1 = TafUeAppServer(                                                 # IPERF MODULE - link to shared Iperf/FTP servers maintained by SRN you can find below this section
    app_server_name="IPERF_WG",                                                   # set iperf server name
    address="10.44.184.246",                                                      # set iperf IP address
    user="syslab",                                                                # set iperf username
    password="Pass4System!",                                                      # set iperf password
    # bind_interface_ip="10.42.129.2",                                            # [OPTIONAL] if any server requires bind interface then set appropriate IP address
) 

_data_transfer_iperf = TafUeDataTransferProtocol(                               # DATA TRANSFER MODULE
    protocol_name="iperf",                                                        # protocol - don't change
    app_server=_app_server_1,                                                     # set server from previous module
    interval=1,                                                                   # iperf package interval - don't change
    server_close_delay=50,                                                        # server close delay - don't change
    version=3,                                                                    # set iperf version
    # bind_interface_ip="10.42.129.2",                                            # [OPTIONAL] if any server requires bind interface then set appropriate IP address
) 

_android1 = TafUeAndroid(                                                       # FIRST UE MODULE
    serial_number="R3CWC0AR95X",                                                # set UE serial number
    ue_pc_address="10.42.172.147",                                              # set IP address your UE PC
    data_transfer=[_data_transfer_iperf],                                       # choice of data transfer method - don't change
    capabilities=["R3CWC0AR95X"],                                               # choice UE -  set UE serial number
    proxy_mngr_port="9955",                                                        # set port number on which you run the proxy on UE PC
    network_mode_switch_method="adb",                                              # UE control method - choose "adb" or "keyevents". The version using "keyevents" can be found below in SECOND UE MODULE
    is_rooted="no",                                                               # whether UE is rooted - set "yes" or "no" depending on whether your UE is rooted
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    ues=[_android1],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO184",
)

__all__ = ["tl"]
