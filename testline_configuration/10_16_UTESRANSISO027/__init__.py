# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Grzegorz Oklinski"
__email__ = "grzegorz.oklinski@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt, PluginAtClassType
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.testpc import TestPc
from taf.config.testline.testpc import TestPc, Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude("10.44.167.124", [1, 2], "EPC", "8220-1")  # port_1 AWHQN / port_2 ASIM

_rmod_1 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type="AWHQN",
    serial_number="AH242903796",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234004860",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1242410019",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.25.36"),
    instance_id=1173,
)

#_rnc = RNC(
#    rnc_id=25,
#    oms_ip=NetworkAddress("10.44.44.219"),
#    logging_ssh_connection_details=SshServiceDetails(
#        addr="10.42.28.72", username="SYSTEM", password="SYSTEM"
#    ),
#)

#_bsc = BSC(
#    name="BSC_mcBSC32",
#    logging_telnet_connection_details=TelnetConnectionDetails(
#        addr="10.42.28.126", username="PZUSER4", password="Ut3pa5s#1be1"
#    ),
#)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.115", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_app_server_1 = TafUeAppServer(                                                   # IPERF MODULE - link to shared Iperf/FTP servers maintained by SRN you can find below this section
    app_server_name="wg-srn-iperf-728",                                           # set iperf server name
    address="10.44.184.246",                                                      # set iperf IP address
    user="ranpz",                                                                 # set iperf username
    password="Pass4Testers!",                                                     # set iperf password
    # bind_interface_ip="10.42.129.2",                                            # [OPTIONAL] if any server requires bind interface then set appropriate IP address
)

_data_transfer_iperf = TafUeDataTransferProtocol(                                 # DATA TRANSFER MODULE
    protocol_name="iperf",                                                        # protocol - don't change
    app_server=_app_server_1,                                                     # set server from previous module
    interval=1,                                                                   # iperf package interval - don't change
    server_close_delay=50,                                                        # server close delay - don't change
    version=3,                                                                    # set iperf version
    # bind_interface_ip="10.42.129.2",                                            # [OPTIONAL] if any server requires bind interface then set appropriate IP address
)

_android1 = TafUeAndroid(                                                         # FIRST UE MODULE
    serial_number="M9AIKN01N575W5V",                                              # set UE serial number
    ue_pc_address="10.42.36.215",                                                 # set IP address your UE PC
    data_transfer=[_data_transfer_iperf],                                         # choice of data transfer method - don't change
    capabilities=["M9AIKN01N575W5V"],                                             # choice UE -  set UE serial number
#    ue_pc_port="6998",                                                           # set port number on which you run the proxy on UE PC
    proxy_mngr_port="9955",                                                       # set port number on which you run the proxy on UE PC
    network_mode_switch_method="adb",                                             # UE control method - choose "adb" or "keyevents". The version using "keyevents" can be found below in SECOND UE MODULE
    is_rooted="no",                                                               # whether UE is rooted - set "yes" or "no" depending on whether your UE is rooted
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO027",
#    bscs=[_bsc],
#    rncs=[_rnc],
ues=[_android1],
)

__all__ = ["tl"]
