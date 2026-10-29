__maintainer__ = "Tomasz Mozola"
__email__ = "tomasz.mozola@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.attenuator import JFW
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.lmi import SerialOverTcp, Remote
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import (
    NetworkAddress,
    RoutingInformation,
    TafUeDataTransferProtocol,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.pdn import PDNTafUeAndroidDetails

# from old init:
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "tmo_2.yaml"
)

# *** UEs ***
_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
    expected_prompt="dummy_prompt",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    binary_path="/data/data/com.nokia.android.application/",
    interval=1,
    version=2,
    server_close_delay=50,
    bind_ue_ip="10.45.168.53",
    interface_name="internet",
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    version=2,
    interface_name="internet",  # OPTIONAL
)

_ue1 = TafUeAndroid(
    serial_number="RFCX201F8VD",
    capabilities=[
        "REAL_UE",
        "REAL_UE_CA",
        "REAL_ANDROID_UE",
        "OPERATORO",
        "RFCX201F8VD",
        "UE_8954",
        "7090_UE",
    ],
    ue_pc_address="10.42.22.66",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.66", username="wro5grrm", password="5gpass!1"
    ),
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Off|On",
)

_pdn1 = PDNTafUeAndroidDetails(
    entryName="APN", apnName="internet", apnType=["DEFAULT"], protocol="IPV4"
)

_pdn2 = PDNTafUeAndroidDetails(
    entryName="internet",
    apnName="internet",
    apnType=["DEFAULT"],
    protocol="IPV4",
    carrierEnabled=True,
    operatorNumeric="54001",
)

_ue2 = TafUeAndroid(
    serial_number="RFCX51BXKLV",
    capabilities=[
        "REAL_UE",
        "REAL_UE_CA",
        "REAL_ANDROID_UE",
        "OPERATORO",
        "RFCX51BXKLV",
        "10683_UE",
    ],
    ue_pc_address="10.42.22.66",
    data_transfer=[_data_transfer_iperf_2],
    pdns=[_pdn1],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.66", username="wro5grrm", password="5gpass!1"
    ),
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Off|On",
)

_MTK_UE_3 = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.66", username="wro5grrm", password="5gpass!1"
    ),
    ue_pc_address="10.42.22.66",
    serial_number="0123456789ABCDEF",
    imsi="310260560003128",
    capabilities=["REAL_ANDROID_MTK"],
    data_transfer=[_data_transfer_iperf_1],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[_pdn2],
)

_attenuator = JFW(
    ip_addr="10.42.54.88",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

# PDUs definition
_pdu1 = Gude(
    addr="10.44.205.8", port_numbers=[1, 2, 3, 4], model="EPC", version="8221-1"
)  # --> RMODs
_pdu2 = Gude(
    addr="10.44.206.13", port_numbers=[8], model="EPC", version="8221-1"
)  # --> SMOD gNB
_pdu3 = Gude(
    addr="10.44.205.242", port_numbers=[8], model="EPC", version="8221-1"
)  # --> AEHC1
_pdu5 = Gude(
    addr="10.44.205.104", port_numbers=[9], model="EPC", version="8221-1"
)  # --> SMOD eNB
_pdus = [_pdu1, _pdu2, _pdu3, _pdu5]

# RUs definition
_rmod_5g_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1919G10HV",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.18"), port=5001)]
    ),
)
_rmod_5g_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G10OJ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.18"), port=5001)]
    ),
)
_rmod_5g_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1930G11Q3",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.16"), port=5001)]
    ),
)
_rmod_5g_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1210604423",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.50.2", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[8],
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.20"), port=5001)]
    ),
)
_rmod_lte_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1945V00IZ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.17"), port=5001)]
    ),
)

# BBMODs definition
_fsp_5g_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.101",
    serial_number="L1183112891",
    rus=[_rmod_5g_3],
)
_fsp_5g_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309813",
    rus=[_rmod_5g_1, _rmod_5g_2],
)
_fsp_5g_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206763",
    rus=[_rmod_5g_4],
)
_fsp_lte_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171903321",
    rus=[_rmod_lte_1],
)

# SMOD definition
_fct_5g = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5g_1, _fsp_5g_2, _fsp_5g_3],
    pdu_port=_pdu2.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1220403418",
)

_fct_lte = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_lte_1],
    pdu_port=_pdu5.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1162911797",
)

_smod_5g = Airscale([_fct_5g])
_smod_4g = Airscale([_fct_lte])

# IPs and network
_du_1 = DU(_smod_5g)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.135"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

# Real BTS definition
_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=50050, instance_id=50050)

_enb_sbts = RealEnb(
    system_module=_smod_4g,
    rms=[_rmod_lte_1],
    oam_ip=NetworkAddress("10.44.78.199"),  # 4G M-plane
    global_bts_id=40050,
    instance_id=40050,
)

_enb_sbts.m = NetworkAddress("10.44.78.199")

# VirtualMachines definition
_test_pc_5g = TestPc(
    SshServiceDetails(addr="10.44.156.30", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_lte = TestPc(
    SshServiceDetails(addr="10.44.156.31", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

# taf_ue prep:
#  TODO it's good to put here data related to taf.ue

# ALL Test Line
tl = TestLine(
    test_pc=_test_pc_5g,
    test_pcs=[_test_pc_5g, _test_pc_lte],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1_AHFIB_3xAHLOA_21A",
    ues=[_ue1, _ue2, _MTK_UE_3],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
