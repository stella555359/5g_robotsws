__maintainer__ = "Przemyslaw Sas"
__team__ = "siso"
__email__ = "przemyslaw.sas@nokia.com"

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
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

_pdu_1 = Gude("10.44.167.17", [12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.167.53", [1, 2], "EPC", "8220-1")
_pdu_3 = Gude("10.44.167.54", [5, 9, 12], "EPC", "8220-1")
_pdu_4 = Gude("10.44.167.56", [4], "EPC", "8220-1")
# _pdu_5 = Gude("10.44.167.51", [1], "EPC", "8220-1")
# _pdu_6 = Gude("10.44.167.59", [7], "EPC", "8220-1")

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2015G1AM6",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2116G1CF7",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2015G1AL2",
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9182400422",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL1919V00S4",
    pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9182400397",
    pdu_port=_pdu_3.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204304804",
    pdu_port=_pdu_1.pdu_ports[12],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206706",
    pdu_port=_pdu_1.pdu_ports[12],
)

_fsp_3 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173008436",
    pdu_port=_pdu_1.pdu_ports[12],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    hardware_type="ASIL",
    serial_number="DH220844980",
    hardware_version="474767A.101",
    pdu_port=_pdu_1.pdu_ports[12],
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],  # set all RMODs used
    oam_ip=NetworkAddress("10.42.24.46"),  # set U/C-plane
    instance_id=1183,  # set MRBTS-ID
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.250", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
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
    # bind_interface_ip="10.42.129.2",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50,
    version=3,
    # bind_ue_ip='10.42.129.2',
)

_android1 = TafUeAndroid(
    serial_number="5a0f5f84",
    ue_pc_address="10.42.36.101",
    data_transfer=[_data_transfer_iperf],
    capabilities=["5a0f5f84"],
    ue_pc_port="9090",
    proxy_mngr_port="9955",
    network_mode_switch_method="adb",
    airplane_mode_switcher_text="Airplane mode",
    is_rooted="no",
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    bscs=[_bsc],
    ues=[_android1],
)

__all__ = ["tl"]
