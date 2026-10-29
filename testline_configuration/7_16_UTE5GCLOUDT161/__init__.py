__maintainer__ = "Pawel Wisniewski"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "pawel.1.wisniewski@nokia.com"
__owner_email__ = "pawel.1.wisniewski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.lmi import SerialOverTcp, Remote
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.flexi import Flexi
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.pdn import PDNTafUeAndroidDetails

#  *** UE Section ***
_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
    expected_prompt="dummy_prompt",
)

_app_server_2 = TafUeAppServer(
    app_server_name="APP_2",
    address="10.42.62.62",
    user="syslab",
    password="system",
    bind_interface_ip="10.42.197.171",
    expected_prompt="dummy_prompt",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2  # OPTIONAL
)  # OPTIONAL

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    version=2,
    interface_name="internet",
)

_pdn1 = PDNTafUeAndroidDetails(
    entryName="APN", apnName="internet", apnType=["DEFAULT"], protocol="IPV4"
)

_samsung_s20 = TafUeAndroid(
    serial_number="R5CRB1THG6F",
    capabilities=[
        "REAL_UE",
        "samsung",
        "R3CR60B4GAR",
        "770_UE",
        "REAL_UE_SA",
        "SamsungS21",
        "SamsungS22",
        "R3CR40QQH4F",
    ],
    ue_pc_address="10.42.22.157",
    data_transfer=[_data_transfer_iperf_2],
    pdns=[_pdn1],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.157", username="wro5grrm", password="5gpass!1"
    ),
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Off|On",
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

#  *** Hardware Section ***
_test_pc_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.116", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.117", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# * Attenuator *
_attenuator = JFW(
    ip_addr="10.42.61.201",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

# AHLOAs AHFIB
_pdu1 = Gude(
    addr="10.44.205.109", port_numbers=[4, 5, 6, 11], model="EPC", version="8221-1"
)
# SMODs
_pdu2 = Gude(addr="10.44.206.13", port_numbers=[11, 12], model="EPC", version="8221-1")
# AEHC
_pdu3 = Gude(addr="10.44.205.242", port_numbers=[12], model="EPC", version="8221-1")
# AZQJ
_pdu4 = Gude(addr="10.44.205.59", port_numbers=[11], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4]

# * RU *
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.34", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[11],
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2003G10Y9",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.22"), port=5001)]
    ),
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.35", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[5],
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1934G10UO",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.24"), port=5001)]
    ),
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.33", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[4],
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1930G11NT",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.25"), port=5001)]
    ),
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.33", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[6],
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2032V0HMF",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.23"), port=5001)]
    ),
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.33", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[12],
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1204708693",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.21"), port=5001)]
    ),
)

_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.50.14", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu4.pdu_ports[11],
    ru_hw_group="",
    radio_type="AZQJ",
    serial_number="1M222701815",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.27"), port=5001)]
    ),
)

# * BBMOD *
_abio_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1205002499",
    rus=[_ru_1],
)
_abio_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104926",
    rus=[_ru_2, _ru_3],
)
_abio_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211506453",
    rus=[_ru_6, _ru_7],
)
_abia_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183143179",
    rus=[_ru_4],
)
_abia_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1234309270",
    rus=None,
)
# * SMOD *
_asil_gnb = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1204202862",
    pdu_port=_pdu2.pdu_ports[12],
    capacity_units=[_abio_1, _abio_2, _abio_3],
)

_asia_enb = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1244303221",
    pdu_port=_pdu2.pdu_ports[11],
    capacity_units=[_abia_1, _abia_2],
)

_smod_gnb = Flexi([_asil_gnb])
_smod_enb = Flexi([_asia_enb])

_cu_smod_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.132"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du_smod_gnb = DU(
    airscale=Airscale([_asil_gnb]), rus=[_ru_1, _ru_2, _ru_3, _ru_6, _ru_7]
)

_gnb_nr_1 = ClassicalBts(
    cu=_cu_smod_gnb, dus=[_du_smod_gnb], instance_id=50069, global_bts_id=50069
)
_test_pc_gnb_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_enb_sbts = RealEnb(
    system_module=_smod_enb,
    rms=[_ru_4],
    oam_ip=NetworkAddress("10.44.79.4"),
    global_bts_id=40069,
    instance_id=40069,
)

_enb_sbts.m = NetworkAddress(v4="10.44.79.4")
_enb_sbts.x2_link_addr = NetworkAddress(v4="10.44.79.4")

_test_pc_enb.connections.append(_enb_sbts.system_module.common_units[0])

tl = TestLine(
    test_pc=_test_pc_gnb_1,
    test_pcs=[_test_pc_gnb_1, _test_pc_enb],
    enbs=[_enb_sbts],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ASIML_2xABIO_ABIP_AHFIB_3xAHLOA_2xAEHC",
    # ues=[_qualcomm_ue],  # ute_ue
    ues=[_samsung_s20],  # taf.ue
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
