__maintainer__ = "Bartlomiej Gabrys"
__team__ = "VRF_WRO2_T04"
__email__ = "bartlomiej.gabrys@nokia.com"
__owner_email__ = "bartlomiej.gabrys@nokia.com"

import os
from taf.config.testline.attenuator import TopYoung, HBTE
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.ue import MediaTek
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.appserver import AppServer
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.core import RealCore
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb


_pdu_gnb = ATEN(addr="10.44.200.240", port_numbers=[5, 6, 7, 8])

_pdu_2_gnb = ATEN(addr="10.44.200.240", port_numbers=[1])

_pdu_gnb_ru = Gude(
    addr="10.44.177.207",
    port_numbers=[2, 4, 5, 6, 7, 8, 9],
    model="EPC",
    version="8221-1",
)

_pdu_2_gnb_ru = Gude(
    addr="10.44.206.143",
    port_numbers=[2, 9, 11],
    model="EPC",
    version="8221-1",
)

_pdu_3_gnb_ru = Gude(
    addr="10.44.206.171",
    port_numbers=[1, 2],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_2_gnb, _pdu_gnb_ru, _pdu_2_gnb_ru, _pdu_3_gnb_ru]

_attenuator_1 = TopYoung(
    ip_addr="10.42.54.244",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_attenuator_2 = TopYoung(
    ip_addr="10.42.75.14",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_attenuator_3 = HBTE(
    ip_addr="10.42.54.237",
    port=5000,
    attenuation_port_numbers=range(1, 17),
    model="PA-16-16-6-127-0.5-B-S",
)

_attenuator_3.pdu_port = _pdu_2_gnb.pdu_ports[1]

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.231.218", v6=None, vlan_id=707),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.232.11/26", v6=None, vlan_id=708),
    x2u=NetworkAddress(v4="10.44.232.73/26", v6=None, vlan_id=709),
    s1u=NetworkAddress(v4="10.44.232.138/26", v6=None, vlan_id=710),
    xnc=NetworkAddress(v4="10.44.232.11/26", v6=None, vlan_id=708),
    xnu=NetworkAddress(v4="10.44.232.73/26", v6=None, vlan_id=709),
    ngc=NetworkAddress(v4="10.44.233.10/26", v6=None, vlan_id=712),
    ngu=NetworkAddress(v4="10.44.232.138/26", v6=None, vlan_id=710),
)

_cu_gnb.m = NetworkAddress(v4="https://10.44.231.218", v6=None, vlan_id=707)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2234N41HK",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2314N44L3",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2340N4A1M",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50VS",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50VR",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="AH242203623",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)

_gnb_ru_7 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251101915",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_3_gnb_ru.pdu_ports[1],
)

_gnb_ru_8 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251510246",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_3_gnb_ru.pdu_ports[2],
)

_gnb_ru_9 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251101916",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_gnb_ru_10 = RU(
    ru_hw_group="",
    radio_type="AVQQA",
    serial_number="L1244206854",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_2_gnb_ru.pdu_ports[2],
)

_gnb_ru_11 = RU(
    ru_hw_group="",
    radio_type="AVQQA",
    serial_number="L1244002015",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_2_gnb_ru.pdu_ports[11],
)

_gnb_ru_12 = RU(
    ru_hw_group="",
    radio_type="AVQQA",
    serial_number="L1244002016",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_2_gnb_ru.pdu_ports[9],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004116",
    rus=[_gnb_ru_7, _gnb_ru_8, _gnb_ru_9],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240602917",
    rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="	475792A.102",
    serial_number="L1240602900",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_bbmod_4 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="	475792A.101",
    serial_number="L1232004115",
    rus=[_gnb_ru_10, _gnb_ru_11, _gnb_ru_12],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1],
    pdu_port=_pdu_gnb.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240406564",
)

_smod_gnb_slave_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_2, _bbmod_3, _bbmod_4],
    pdu_port=_pdu_gnb.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234311071",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_smod_2 = Airscale([_smod_gnb_slave_right])

_du_1_gnb = DU(_smod_1, rus=[_gnb_ru_7, _gnb_ru_8, _gnb_ru_9])

_du_2_gnb = DU(
    _smod_2,
    rus=[
        _gnb_ru_1,
        _gnb_ru_2,
        _gnb_ru_3,
        _gnb_ru_4,
        _gnb_ru_5,
        _gnb_ru_6,
        _gnb_ru_10,
        _gnb_ru_11,
        _gnb_ru_12,
    ],
)

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=50899, global_bts_id=50899
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.19", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_2_gnb], instance_id=50899, global_bts_id=50899
)

_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.56", username="ute", password="ute"
    ),
    connections=[_cbts_2.dus[0].airscale.common_units[0]],
)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_core = RealCore5G(mcc=310, mnc=260)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master, _lmp_vm_gnb_1_slave],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL77_FULLRACK_ASIM_ABIP_3xAHFII_3xAVHA_3xAHLOB_3xAVQQA_MRAT",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator_1,
    attenuators=[_attenuator_1, _attenuator_2, _attenuator_2],
)

__all__ = ["tl"]
