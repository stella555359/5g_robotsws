# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Dominika Wojcik"
__email__ = "dominika.1.wojcik@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

_pdu_1 = Gude("10.44.200.26", [9, 10], "EPC", "8221-1")
_pdu_2 = Gude("10.44.200.32", [10], "EPC", "8220-1")
_pdu_3 = Gude("10.44.200.29", [1, 2, 3], "EPC", "8221-1")
_pdu_4 = Gude("10.44.200.33", [11, 12], "EPC", "8220-1")


_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_2T2R",
    radio_type="ANEGA",
    serial_number="L1190309345",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)  # ANEGA_1
_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_2T2R",
    radio_type="ANEGA",
    serial_number="L1193513970",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)  # ANEGA_2
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type="AHEGC",
    serial_number="EA192077335",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)  # AHEGC
_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_6T6R",
    radio_type="AHFIC",
    serial_number="K9190803233",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)  # AHFIC
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_6T6R",
    radio_type="ARDB",
    serial_number="L1194707349",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)  # ARDB
_rmod_6 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="LR233406929",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)  # AHPMDB

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="473096A.103",
    serial_number="L1234007305",
    pdu_port=_pdu_4.pdu_ports[11],
    rus=[_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173515922",
    pdu_port=_pdu_4.pdu_ports[11],
    rus=[_rmod_4, _rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602289",
    pdu_port=_pdu_4.pdu_ports[11],
    rus=[_rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602316",
    pdu_port=_pdu_4.pdu_ports[12],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    pdu_port=_pdu_4.pdu_ports[12],
    serial_number="L1173602326",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    pdu_port=_pdu_4.pdu_ports[12],
    serial_number="L1163606722",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_4.pdu_ports[11],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233106100",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_4.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1192405949",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.44.137.155"),
    instance_id=1321,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_1, _rmod_2], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.23", username="ute"),
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
    SshServiceDetails(addr="10.44.156.24", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_rnc = RNC(
    rnc_id=25,
    oms_ip=NetworkAddress("10.44.44.219"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.28.72", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_asBSC21",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.28.126", username="PZUSER", password="pzpassword"
    ),
)


_app_server_1 = TafUeAppServer(
    app_server_name="IPERF_WL",
    address="10.42.249.116",
    user="syslab",
    password="Pass4System!",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50,
    version=3,
)

_android1 = TafUeAndroid(
    serial_number="H2J9FI1G80380100033",
    ue_pc_address="10.42.224.188",
    data_transfer=[_data_transfer_iperf],
    capabilities=["H2J9FI1G80380100033"],
    ue_pc_port="9090",
    proxy_mngr_port=9955,
    network_mode_switch_method="ADB",
    is_rooted="no",
)

_android2 = TafUeAndroid(
    serial_number="H2J9FI1G80380100042",
    ue_pc_address="10.42.224.188",
    data_transfer=[_data_transfer_iperf],
    capabilities=["H2J9FI1G80380100042"],
    ue_pc_port="9090",
    proxy_mngr_port=9955,
    network_mode_switch_method="ADB",
    is_rooted="no",
)

_android3 = TafUeAndroid(
    serial_number="H2J9FI1G80380100113",
    ue_pc_address="10.42.224.188",
    data_transfer=[_data_transfer_iperf],
    capabilities=["H2J9FI1G80380100113"],
    ue_pc_port="9090",
    proxy_mngr_port=9955,
    network_mode_switch_method="ADB",
    is_rooted="no",
)

_android4 = TafUeAndroid(
    serial_number="A00000P660211300019",
    ue_pc_address="10.42.224.188",
    data_transfer=[_data_transfer_iperf],
    capabilities=["A00000P660211300019"],
    ue_pc_port="9090",
    proxy_mngr_port=9955,
    network_mode_switch_method="ADB",
    is_rooted="no",
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO079",
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[
        _android1,
        _android2,
        _android3,
        _android4,
    ],
)

__all__ = ["tl"]
