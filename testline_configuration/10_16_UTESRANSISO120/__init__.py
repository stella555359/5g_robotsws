__maintainer__ = "Maciej Grzeszczak"
__team__ = "siso"
__email__ = "maciej.grzeszczak@nokia.com"
__owner_email__ = "maciej.grzeszczak@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testpc import TestPc, Connection

_pdu_1 = Gude(
    "10.42.169.13", [9, 10, 11, 12], "EPC", "8220-1"
)  # AHEGA AHEGB AHPMDA AHPMDH
_pdu_2 = Gude("10.42.169.14", [1, 2, 6], "EPC", "8220-1")  # AHEGHA AHEB AHDB
_pdu_3 = Gude("10.42.169.5", [1, 11], "EPC", "8220-1")  # ASIB
_pdu_4 = Gude("10.42.168.105", [1, 2, 3], "EPC", "8220-1")  # fan_AHPMDH MDDA EAC
_pdu_5 = Gude("10.42.168.110", [8], "EPC", "8221-1")  # AHEGSA

_rmod_1 = RU(
    ru_hw_group="",
    radio_type="AHEGB",
    serial_number="K9180818557",
    pdu_port=_pdu_1.pdu_ports[10],
)  # AHEGB
_rmod_2 = RU(
    ru_hw_group="",
    radio_type="AHEGA",
    serial_number="K9181730142",
    pdu_port=_pdu_1.pdu_ports[9],
)  # AHEGA
_rmod_3 = RU(
    ru_hw_group="",
    radio_type="AHPMDA",
    serial_number="K9182817725",
    pdu_port=_pdu_1.pdu_ports[11],
)  # AHPMDA
_rmod_4 = RU(
    ru_hw_group="",
    radio_type="AHEB",
    serial_number="L1181107578",
    pdu_port=_pdu_2.pdu_ports[2],
)  # AHEB
_rmod_5 = RU(
    ru_hw_group="",
    radio_type="AHPMDH",
    serial_number="RW223301609",
    pdu_port=_pdu_1.pdu_ports[12],
)  # AHPMDH
_rmod_6 = RU(
    ru_hw_group="",
    radio_type="AHEGHA",
    serial_number="BL2311H604M",
    pdu_port=_pdu_2.pdu_ports[1],
)  # AHEGHA
_rmod_7 = RU(
    ru_hw_group="",
    radio_type="AHDB",
    serial_number="6Q184426360",
    pdu_port=_pdu_2.pdu_ports[6],
)  # AHDB
_rmod_8 = RU(
    ru_hw_group="",
    radio_type="AHEGSA",
    serial_number="1M250100005",
    pdu_port=_pdu_5.pdu_ports[8],
)  # AHEGSA

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223309819",
    pdu_port=_pdu_1.pdu_ports[10],
    rus=[_rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_7, _rmod_8],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1212901620",
    pdu_port=_pdu_1.pdu_ports[10],
    rus=[_rmod_1, _rmod_2, _rmod_6, _rmod_8],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162608292",
    pdu_port=_pdu_1.pdu_ports[10],
    rus=[_rmod_1, _rmod_4, _rmod_6, _rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[11],
    hardware_type="ASIB",
    serial_number="L1191304472",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
    oam_ip=NetworkAddress("10.42.174.146"),  # set U/C-plane
    instance_id=1443,
)

_rnc = RNC(
    rnc_id=25,
    oms_ip=NetworkAddress("10.44.44.218"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.171.138", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_asBSC21",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.28.126", username="PZUSER4", password="Ut3pa5s#1be1"
    ),
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.135", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_app_server_1 = TafUeAppServer(
    # IPERF MODULE - link to shared Iperf/FTP servers maintained by SRN you can find below this section
    app_server_name="wg-srn-iperf-728",  # set iperf server name
    address="10.44.184.246",  # set iperf IP address
    user="ranpz",  # set iperf username
    password="Pass4Testers!",  # set iperf password
    # bind_interface_ip="10.42.129.2",                                             # [OPTIONAL] if any server requires bind interface then set appropriate IP address
)

_data_transfer_iperf = TafUeDataTransferProtocol(  # DATA TRANSFER MODULE
    protocol_name="iperf",  # protocol - don't change
    app_server=_app_server_1,  # set server from previous module
    interval=1,  # iperf package interval - don't change
    server_close_delay=50,  # server close delay - don't change
    version=3,  # set iperf version
    # bind_interface_ip="10.42.129.2",                                            # [OPTIONAL] if any server requires bind interface then set appropriate IP address
)

_android1 = TafUeAndroid(  # FIRST UE MODULE
    serial_number="H2J9FI1G80380100046",  # set UE serial number
    ue_pc_address="10.42.172.143",  # set IP address your UE PC
    data_transfer=[
        _data_transfer_iperf
    ],  # choice of data transfer method - don't change
    capabilities=["H2J9FI1G80380100046"],  # choice UE -  set UE serial number
    ue_pc_port="9091",
    proxy_mngr_port="9955",  # set port number on which you run the proxy on UE PC
    network_mode_switch_method="adb",
    # UE control method - choose "adb" or "keyevents". The version using "keyevents" can be found below in SECOND UE MODULE
    is_rooted="no",  # whether UE is rooted - set "yes" or "no" depending on whether your UE is rooted
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO120",
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[_android1],
)

__all__ = ["tl"]
