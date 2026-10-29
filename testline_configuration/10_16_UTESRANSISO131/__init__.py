__maintainer__ = "Szymon Natanek"
__email__ = "szymon.natanek@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.connection_details import HttpConnectionDetails
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.flexi import Flexi
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote


_pdu_1 = Gude("10.44.167.146", [8, 9], "EPC", "8221-1")
_pdu_2 = Gude("10.44.167.127", [11], "EPC", "8221-1")
_pdu_3 = Gude("10.44.167.129", [3, 4], "EPC", "8221-1")
_pdu_4 = Gude("10.44.167.130", [7], "EPC", "8221-1")
_pdu_5 = Gude("10.44.167.131", [11], "EPC", "8221-1")
_pdu_6 = Gude("10.44.167.132", [4], "EPC", "8221-1")
_pdu_7 = Gude("10.44.167.147", [9], "EPC", "8221-1")
_pdu_8 = Gude("10.44.167.134", [2, 3, 4], "EPC", "8221-1")

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5, _pdu_6, _pdu_7, _pdu_8]

_mumin_eth_1 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.31.27", port=2003),]
    )
    
_mumin_eth_2 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.31.28", port=2003),]
    )
    
_mumin_eth_3 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.31.29", port=2003),]
    )
    
_mumin_eth_4 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.31.30", port=2003),]
    )
    
_mumin_eth_5 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.31.31", port=2003),]
    )
    
_mumin_eth_6 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.31.32", port=2003),]
    )    

_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="AH242902947",
    lmi=_mumin_eth_4,
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="AH242003075",
    lmi=_mumin_eth_5,
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="AH242902950",
    lmi=_mumin_eth_6,
    pdu_port=_pdu_6.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245001229",
    lmi=_mumin_eth_1,
    pdu_port=_pdu_4.pdu_ports[7],
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9244348165",
    lmi=_mumin_eth_2,
    pdu_port=_pdu_5.pdu_ports[11],
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245006288",
    lmi=_mumin_eth_3,
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251101936",
    pdu_port=_pdu_8.pdu_ports[2],
)
_rmod_8 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251101939",
    pdu_port=_pdu_8.pdu_ports[3],
)
_rmod_9 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251101934",
    pdu_port=_pdu_8.pdu_ports[4],
)

# ************************************eNB************************************************
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIL",
    serial_number="L1185105972",
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIL",
    serial_number="EA200850959",
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_4, _rmod_5],
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIL",
    serial_number="L1185109699",
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.128",
    hardware_type="ABIO",
    serial_number="L1220705703",
    pdu_port=_pdu_1.pdu_ports[9],
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    hardware_type="ASIL",
    serial_number="L1241009719",
    pdu_port=_pdu_1.pdu_ports[8],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    hardware_type="ASIL",
    serial_number="L1240801605",
    pdu_port=_pdu_1.pdu_ports[9],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.42.25.80"),
    instance_id=1217,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9],
    master=_enb_sbts_1,
)
# **************************************gNB*****************************************************************
_abia_1 = CapacityUnit(
    addr="172.16.40.1",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172805932",
    pdu_port=_pdu_7.pdu_ports[9],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_abia_2 = CapacityUnit(
    addr="172.16.40.1",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173706702",
    pdu_port=_pdu_7.pdu_ports[9],
    rus=[_rmod_4, _rmod_5],
)
_abia_3 = CapacityUnit(
    addr="172.16.40.1",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171216189",
    pdu_port=_pdu_7.pdu_ports[9],
    rus=[_rmod_6],
)

_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIB",
    capacity_units=[_abia_1, _abia_2, _abia_3],
    pdu_port=_pdu_7.pdu_ports[9],
    hardware_version="473764A.102",
    serial_number="DH223343363",
)

_airscale_asib = Airscale(common_units=[_asib])

_du_asib = DU(
    airscale=_airscale_asib,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_cu_asib = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.25.80", v6="", vlan_id=343),
    x2u=NetworkAddress(v4="10.42.25.80", v6="", vlan_id=343),
    s1u=NetworkAddress(v4="10.42.25.80", v6="", vlan_id=343),
)

_classical_asib = ClassicalBts(
    dus=[_du_asib], cu=_cu_asib, instance_id=1181, global_bts_id=1181
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.26", username="ute"),
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
    SshServiceDetails(addr="10.42.121.27", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_3 = TestPc(
    SshServiceDetails(addr="10.42.121.44", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_airscale_asib.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_enb_sbts_1.slave = _enb_sbts_2

_app_server_1 = TafUeAppServer(
    app_server_name="wg-srn-iperf-728",
    address="10.44.184.246",
    user="syslab",
    # bind_interface_ip="10.42.129.2",
    password="Pass4System!",
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
    serial_number="54c410bf",
    ue_pc_address="10.42.36.213",
    data_transfer=[_data_transfer_iperf],
    capabilities=["54c410bf"],
    ue_pc_port="9090",
    proxy_mngr_port="9955",
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Aeroplane mode",
    is_rooted="no",
)

_android2 = TafUeAndroid(
    serial_number="M9AIKN01N493HYA",
    ue_pc_address="10.42.36.213",
    data_transfer=[_data_transfer_iperf],
    capabilities=["M9AIKN01N493HYA"],
    ue_pc_port="9090",
    proxy_mngr_port="9955",
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Airplane mode",
    is_rooted="no",
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    gnbs=[_classical_asib],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO131",
    ues=[_android1, _android2],
)

__all__ = ["tl"]