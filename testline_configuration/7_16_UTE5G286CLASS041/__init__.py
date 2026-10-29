# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Adam Tokarski"
__email__ = "adam.tokarski@nokia.com"
__owner_email__ = "adam.tokarski@nokia.com"


import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.attenuator import JFW
from taf.config.testline.enb import RealEnb
from taf.config.testline.lmi import SerialOverTcp, Remote
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
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
from taf.config.testline.ue import TafUeIphone
from taf.config.testline.appserver import TafUeAppServer

# from old init:
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

_attenuator = JFW(
    ip_addr="10.42.61.128",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

# PDU definition
_pdu_1 = Gude("10.44.206.13", [10], "EPC", "8221-1")  # smod_gNB
_pdu_2 = Gude("10.44.205.104", [2], "EPC", "8221-1")  # smod_eNB
_pdu_3 = Gude("10.44.177.63", [1, 2, 3, 4], "EPC", "8221-1")  # RMODs

_pdus = [_pdu_1, _pdu_2, _pdu_3]

# RUs definition
# AHFIB
_rmod_lte_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9181806850",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.40"), port=5001)]
    ),
)
# AHLOA 1
_rmod_g5_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G1028",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.39"), port=5001)]
    ),
)
# AHLOA 2
_rmod_5g_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G1008",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.37"), port=5001)]
    ),
)
# AHLOA 3
_rmod_5g_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1934G10UR",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.38"), port=5001)]
    ),
)

# BBMOD definition
_fsp_5g_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1210904001",
    rus=[],
)
_fsp_5g_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211200982",
    rus=[_rmod_5g_3, _rmod_5g_4],
)
_fsp_5g_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201205182",
    rus=[_rmod_g5_2],
)
_fsp_lte_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA194854204",
    rus=[_rmod_lte_1],
)

# SMOD definition
_fct_5g = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5g_1, _fsp_5g_2, _fsp_5g_3],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1202606176",
)

_fct_lte = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_lte_1],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173117639",
)

#_smod_5g = Airscale([_fct_5g])
#_smod_4g = Airscale([_fct_lte])

_smod_5g = Flexi([_fct_5g])
_smod_4g = Flexi([_fct_lte])

# IP and network
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.145"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du_1 = DU(airscale=Airscale([_fct_5g]), rus=[_rmod_g5_2, _rmod_5g_3, _rmod_5g_4])

# Real BTS definition
_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=50041, instance_id=50041)

_enb_sbts = RealEnb(
    system_module=_smod_4g,
    rms=[
        _rmod_lte_1,
    ],
    oam_ip=NetworkAddress("10.44.78.208"),  # 4G M-plane
    global_bts_id=40041,
    instance_id=40041,
)

_enb_sbts.m = NetworkAddress("10.44.78.208")

# VirtualMachines definition
_test_pc_5g = TestPc(
    SshServiceDetails(addr="10.44.156.61", username="ute"),
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
    SshServiceDetails(addr="10.44.156.60", username="ute"),
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
_app_server = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
    expected_prompt=':~\$',
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server, interval=1, version=2
)

_samsung_s21_1 = TafUeAndroid(
    serial_number="R5CR600T98N",
    capabilities=["770_UE", "REAL_UE", "REAL_UE_CA", "OPERATORO", "R5CR600T98N", "REAL_UE_NSA", "REAL_UE_SA","SamsungS22"],
    ue_pc_address="10.42.22.64",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.64", username="wro5grrm", password="5gpass!1"
    ),
    qualcomm_prototype=True,
    service_call_attach="16",
    service_call_detach="16",
)

_samsung_s21_2 = TafUeAndroid(
    serial_number="R3CR60HQP6N",
    capabilities=["770_UE", "REAL_UE", "REAL_UE_CA", "OPERATORO", "R3CR60HQP6N", "REAL_UE_NSA", "REAL_UE_SA","SamsungS22"],
    ue_pc_address="10.42.22.64",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.64", username="wro5grrm", password="5gpass!1"
    ),
    qualcomm_prototype=True,
    service_call_attach="16",
    service_call_detach="16",
)

_iphone = TafUeIphone(
    serial_number='JVX4Q1909M',
    ue_pc_address='10.42.215.26',
    capabilities=['IPHONE','JVX4Q1909M'],
    data_transfer=[_data_transfer_iperf]
)

# ALL Test Line
tl = TestLine(
    test_pc=_test_pc_5g,
    test_pcs=[_test_pc_5g, _test_pc_lte],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1_AHFIB_3xAHLOA_20B",
    ues=[_iphone,_samsung_s21_1, _samsung_s21_2],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
