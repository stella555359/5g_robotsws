__maintainer__ = "Kamil Galus"
__team__ = "VRF_WRO2_T04"
__email__ = "kamil.galus@nokia.com"
__owner_email__ = "kamil.galus@nokia.com"

import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.attenuator import TopYoung


_pdu_gnb = Gude(
    addr="10.44.177.192",
    port_numbers=[7, 8],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru = Gude(
    addr="10.44.177.251",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru]

_attenuator = TopYoung(
    ip_addr="10.42.54.131",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_bbmod_1_master = CapacityUnit(addr="192.168.253.20")
_bbmod_1_slave = CapacityUnit(addr="192.168.253.21")
_bbmod_1_loner = CapacityUnit(addr="192.168.253.22")

_bbmod_2_master = CapacityUnit(addr="192.168.253.24")
_bbmod_2_slave = CapacityUnit(addr="192.168.253.25")
_bbmod_2_loner = CapacityUnit(addr="192.168.253.26")

_bbmod_3_master = CapacityUnit(addr="192.168.253.28")
_bbmod_3_slave = CapacityUnit(addr="192.168.253.29")
_bbmod_3_loner = CapacityUnit(addr="192.168.253.30")

_bbmod_4_master = CapacityUnit(addr="192.168.253.36")
_bbmod_4_slave = CapacityUnit(addr="192.168.253.37")
_bbmod_4_loner = CapacityUnit(addr="192.168.253.38")

_smod_gnb_1_master = CommonUnit(
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1223402820",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _bbmod_1_master,
        _bbmod_1_slave,
        _bbmod_1_loner,
        _bbmod_2_master,
        _bbmod_2_slave,
        _bbmod_2_loner,
        _bbmod_3_master,
        _bbmod_3_slave,
        _bbmod_3_loner,
    ],
    pdu_port=_pdu_gnb.pdu_ports[7],
)

_smod_gnb_1_slave = CommonUnit(
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH22L12234028170345079",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _bbmod_4_master,
        _bbmod_4_slave,
        _bbmod_4_loner,
    ],
    pdu_port=_pdu_gnb.pdu_ports[8],
)

_airscale_1_gnb = Airscale([_smod_gnb_1_master])

_airscale_2_gnb = Airscale([_smod_gnb_1_slave])

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.231.206/26",
        v6=None,
        vlan_id=707,
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.231.206/26",
        v6=None,
        vlan_id=707,
    ),
    x2u=NetworkAddress(
        v4="10.44.231.206/26",
        v6=None,
        vlan_id=707,
    ),
    s1u=NetworkAddress(
        v4="10.44.231.206/26",
        v6=None,
        vlan_id=707,
    ),
    xnc=NetworkAddress(
        v4="10.44.231.206/26",
        v6=None,
        vlan_id=707,
    ),
    xnu=NetworkAddress(
        v4="10.44.231.206/26",
        v6=None,
        vlan_id=707,
    ),
    ngc=NetworkAddress(
        v4="10.44.231.206/26",
        v6=None,
        vlan_id=707,
    ),
    ngu=NetworkAddress(
        v4="10.44.231.206/26",
        v6=None,
        vlan_id=707,
    ),
)

_cu_gnb.m = NetworkAddress(
    v4="https://10.44.231.206",
    v6=None,
    vlan_id=707,
)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1930G11QD",
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2004G100O",
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2003G10Y0",
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AHFIG",
    serial_number="BL2048W2HWJ",
    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)
_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AHFIG",
    serial_number="K9205212655",
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AHFIG",
    serial_number="K9203119592",
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_gnb_ru_7 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9223130054",
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_gnb_ru_8 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9223130047",
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_gnb_ru_9 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9223130053",
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_du_1_gnb = DU(
    _airscale_1_gnb,
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_du_2_gnb = DU(
    _airscale_2_gnb,
    rus=[_gnb_ru_7, _gnb_ru_8, _gnb_ru_9],
)

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=50888, global_bts_id=50888
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_2_gnb], instance_id=50888, global_bts_id=50888
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.195.161", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.195.162", username="ute", password="ute"  # non UTE VM
    ),
    connections=[_cbts_2.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master, _lmp_vm_gnb_1_slave],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASIL_ABILB1B2B3_ABI0B4_3xAHLOA_3xAHFIG_3xAEHC",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator,
)

__all__ = ["tl"]
