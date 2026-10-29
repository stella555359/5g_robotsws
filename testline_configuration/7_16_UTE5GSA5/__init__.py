__maintainer__ = "Tomasz Mozola"
__team__ = "MN RAN RD VRF WRO2 1"
__email__ = "tomasz.mozola@nokia.com"
__owner_email__ = "tomasz.mozola@nokia.com"


import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.attenuator import JFW
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
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
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.lmi import SerialOverTcp, Remote
from taf.config.testline.pdn import PDNTafUeAndroidDetails

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
    interval=1,
    version=2,
    interface_name="internet",
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    binary_path="/data/data/com.nokia.android.application/",
    interval=1,
    version=2,
    server_close_delay=50,
    bind_ue_ip="10.45.168.53",
    interface_name="internet",
)

_samsung_1 = TafUeAndroid(
    serial_number="RFCX703KK4N",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "RFCX703KK4N", "OPERATORO"],
    ue_pc_address="10.42.224.123",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.123", username="wro5grrm", password="5gpass!1"
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

_MTK_UE_1 = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.123", username="wro5grrm", password="5gpass!1"
    ),
    ue_pc_address="10.42.224.123",
    serial_number="0123456789ABCDEF",
    imsi="310260560003128",
    capabilities=["REAL_ANDROID_MTK"],
    data_transfer=[_data_transfer_iperf_2],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[_pdn2],
)

_UE_1 = TafUeAndroid(
    serial_number="83499e5e",
    capabilities=["UE_QM", "UE_83499e5e"],
    ue_pc_address="10.42.224.123",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.123", username="wro5grrm", password="5gpass!1"
    ),
    network_mode_switch_method="keyevents",
    path_to_network_mode_type="SIMs/Preferred network type",
    pdns=[_pdn1],
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_real_android_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

_attenuator = TopYoung(
    ip_addr="10.42.66.197",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS12T12_51_90_1S_EJS",
)

_attenuator1 = TopYoung(
    ip_addr="10.42.221.217",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_pdu_1 = Gude(
    addr="10.44.206.13", port_numbers=[1, 3, 5, 9], model="EPC", version="8221-1"
)  # --> ASIM, AHLOB, ASIL
_pdu_2 = Gude(
    addr="10.44.205.104", port_numbers=[7, 10], model="EPC", version="8221-1"
)  # --> RU AHFII, AHLOB
_pdu_3 = Gude(
    addr="10.44.205.109", port_numbers=[1, 2], model="EPC", version="8221-1"
)  # --> RU AHFIIs
_pdu_4 = Gude(
    addr="10.44.177.96", port_numbers=[2, 3, 6], model="EPC", version="8221-1"
)  # --> RU AVHAs
_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

# RUs
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[5],
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="AH245000615",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.41"), port=5001)]
    ),
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_3.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="K9245113433",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.42"), port=5001)]
    ),
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_3.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="K9244701802",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.43"), port=5001)]
    ),
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[7],
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="K9245113387",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.44"), port=5001)]
    ),
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[10],
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="AH245000616",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.46"), port=5001)]
    ),
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="AH245000624",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.45"), port=5001)]
    ),
)

_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_4.pdu_ports[2],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251001321",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr=NetworkAddress(v4="10.255.38.47"), port=5001),
            Remote(addr=NetworkAddress(v4="10.255.38.47"), port=5002),
        ]
    ),
)

_ru_8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_4.pdu_ports[3],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251001322",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr=NetworkAddress(v4="10.255.38.48"), port=5001),
            Remote(addr=NetworkAddress(v4="10.255.38.48"), port=5002),
        ]
    ),
)

_ru_9 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_4.pdu_ports[6],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251001323",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr=NetworkAddress(v4="10.255.38.49"), port=5001),
            Remote(addr=NetworkAddress(v4="10.255.38.49"), port=5002),
        ]
    ),
)

# BBMODs
_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242207709",
    rus=[_ru_1, _ru_5, _ru_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242207708",
    rus=[_ru_7, _ru_8, _ru_9],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1243403592",
    rus=[_ru_2, _ru_3, _ru_4],
)

# SMODs
_smod_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233402464",
)

_smod_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1243204195",
)

_smods = Airscale([_smod_left, _smod_right])

_test_pc_Master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.252", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_Ext = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.151", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.139"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(_smods)

_gnb = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51778, instance_id=51778)

_test_pc_Master.connections.append(
    Connection(
        interface="eth1",
        device=_gnb.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_Ext.connections.append(
    Connection(
        interface="eth1",
        device=_gnb.dus[0].airscale.common_units[1],
        interface_type="lmp",
    )
)


_core = RealCore5G(mcc=310, mnc=260)

tl = TestLine(
    test_pc=_test_pc_Master,
    test_pcs=[_test_pc_Master, _test_pc_Ext],
    gnbs=[_gnb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2_2xAEQN_FRGY",
    ues=[_samsung_1, _MTK_UE_1, _UE_1],
    attenuator=_attenuator,
    attenuators=[_attenuator, _attenuator1],
    pdus=_pdus,
)

__all__ = ["tl"]
