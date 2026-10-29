__maintainer__ = "Cezary Szulc"
__team__ = "VRF_WRO2_T04"
__email__ = "cezary.szulc@nokia.com"
__owner_email__ = "cezary.szulc@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.ue import Android
from taf.config.testline.attenuator import TopYoung


_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue.yaml"
)

_pdu_gnb = Gude(addr="10.44.177.142", port_numbers=[8], model="EPC", version="8221-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.44.177.142",
    port_numbers=[3, 4, 5, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.206.147", port_numbers=[7, 8], model="EPC", version="8221-1"
)

_pdus = [_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2]

_attenuator = TopYoung(
    ip_addr="10.42.75.211",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.231.195/26", v6=None, vlan_id=707),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.232.3/26", v6=None, vlan_id=708),
    x2u=NetworkAddress(v4="10.44.232.3/26", v6=None, vlan_id=708),
    s1u=NetworkAddress(v4="10.44.232.3/26", v6=None, vlan_id=708),
    xnc=NetworkAddress(v4="10.44.232.3/26", v6=None, vlan_id=708),
    xnu=NetworkAddress(v4="10.44.232.3/26", v6=None, vlan_id=708),
    ngc=NetworkAddress(v4="10.44.232.3/26", v6=None, vlan_id=708),
    ngu=NetworkAddress(v4="10.44.232.3/26", v6=None, vlan_id=708),
    tracing=None,
)

_cu_gnb_1.m = NetworkAddress(v4="https://10.44.231.195", v6=None, vlan_id=707)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2045V0S8T",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[12],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2215V01G4",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[5],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2043V0PXB",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[8],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="AH234900467",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[3],
)

_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1205002779",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[4],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1213401830",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[11],
)

_gnb_ru_7 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1930G11Q6",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[10],
)

_gnb_ru_8 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1933G10Q3",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[9],
)

_gnb_ru_9 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1934G10V7",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[7],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240602921",
    rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1234309307",
    rus=[_gnb_ru_7, _gnb_ru_8, _gnb_ru_9],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214608177",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_smod_gnb_1 = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1233703636",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2, _bbmod_3],
    pdu_port=_pdu_gnb.pdu_ports[8],
)

_airscale_gnb_1 = Airscale([_smod_gnb_1])

_du_1_gnb_1 = DU(
    _airscale_gnb_1,
    rus=[
        _gnb_ru_1,
        _gnb_ru_2,
        _gnb_ru_3,
        _gnb_ru_4,
        _gnb_ru_5,
        _gnb_ru_6,
        _gnb_ru_7,
        _gnb_ru_8,
        _gnb_ru_9,
    ],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], instance_id=9246, global_bts_id=9246
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.39", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTMO127_ASIL_ABIP_ABIO_3xAHLOA_3xAHFIB_3xAEHC",
    core=_core,
    pdus=_pdus,
    ues=[_ue],
    attenuator=_attenuator,
    test_pcs=[_lmp_vm_gnb_1],
)

__all__ = ["tl"]


# ############## ADDITIONAL PARAMS ###############
#
# 5G SWITCH DATA:
# 5G SWITCH MGMT:
#
# POD ID:
# RACK:
