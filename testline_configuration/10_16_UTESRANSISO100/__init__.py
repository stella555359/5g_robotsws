__maintainer__ = "Tomasz Pawlaczyk  "
__email__ = "tomasz.pawlaczyk@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude("10.42.168.168", [7], "EPC", "8220-1")      #ASOG
_pdu_2 = Gude("10.42.169.109", [1, 2, 3, 4, 5, 6, 9, 10], "EPC", "8220-1")  # 9 AHEGB_974  10_AHEGB_079    
# 1 AHPMDG_374   2 AHPMDG_334     3 AHEGG_345    4 AHPMDG_861     5 AHEGG_409   6 AHEGG_394  

_rmod_1 = RU(
    ru_hw_group="FRMr6.2_2T4R",
    radio_type="AHPMDG",
    serial_number="LR244901374",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.2_2T4R",
    radio_type="AHPMDG",
    serial_number="LR244901334",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr6.2_2T4R",
    radio_type="AHPMDG",
    serial_number="LR244709861",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGG",
    serial_number="K9243201345",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGG",
    serial_number="K9243202409",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGG",
    serial_number="K9243201394",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="EA203761974",
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEGB",
    serial_number="K9183633079",
    pdu_port=_pdu_2.pdu_ports[10],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
#    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASOG",
    serial_number="L1243405102",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
    ],
    oam_ip=NetworkAddress("10.42.175.24"),
    instance_id=1369,
)

#_enb_sbts_1 = RealEnb(
#    system_module=_smod_1,
#    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
#    oam_ip=NetworkAddress("10.42.175.24"),
#    instance_id=1369,
#)

_rnc = RNC(
    rnc_id=25,
    oms_ip=NetworkAddress("10.44.44.219"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.28.72", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC25",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.196.183", username="VRFUSER", password="VRFPASSWORD"
    ),
)

_app_server_1 = TafUeAppServer(
    app_server_name="wg-srn-iperf-728",
    address="10.44.184.246",
    user="ranpz",
    password="Pass4Testers!",
)
# _app_server_1 = TafUeAppServer(app_server_name="IPERF_TMP_GT",
#                                address="10.42.249.116",
#                                bind_interface_ip="10.42.249.116",
#                                user="syslab",
#                                password="Pass4System!")

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50,
    bind_ue_ip="10.44.184.246",
    version=3,
)

_android1 = TafUeAndroid(
    serial_number="4a7490bf",
    ue_pc_address="10.42.172.142",
    data_transfer=[_data_transfer_iperf],
    capabilities=["4a7490bf"],
    ue_pc_port="9091",
    proxy_mngr_port=9955,
    network_mode_switch_method="ADB",
    is_rooted="no",
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.113", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
#    tl_cloud_topology="CLOUD_10_16_UTESRANSISO100",
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[_android1],
)

__all__ = ["tl"]
