__maintainer__ = "Krzysztof Urbaniak"
__team__ = "RRM team"
__email__ = "krzysztof.urbaniak@nokia.com"
__owner_email__ = "krzysztof.urbaniak@nokia.com"

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
    addr="10.44.177.206",
    port_numbers=[3, 4],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_1 = Gude(
    addr="10.44.177.139",
    port_numbers=[6, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.177.140",
    port_numbers=[2, 3, 4],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_3 = Gude(
    addr="10.44.206.149",
    port_numbers=[9],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_4 = ATEN(
    addr="10.44.206.106", 
    port_numbers=[1, 6]
)

_pdus = [_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2, _pdu_gnb_ru_3]

_attenuator_1 = TopYoung(
    ip_addr="10.42.75.216",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.231.200/26",
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
        v4="10.44.232.8/26",
        v6=None,
        vlan_id=708,
    ),
    x2u=NetworkAddress(
        v4="10.44.232.8/26",
        v6=None,
        vlan_id=708,
    ),
    s1u=NetworkAddress(
        v4="10.44.232.8/26",
        v6=None,
        vlan_id=708,
    ),
    xnc=NetworkAddress(
        v4="10.44.232.8/26",
        v6=None,
        vlan_id=708,
    ),
    xnu=NetworkAddress(
        v4="10.44.232.8/26",
        v6=None,
        vlan_id=708,
    ),
    ngc=NetworkAddress(
        v4="10.44.232.8/26",
        v6=None,
        vlan_id=708,
    ),
    ngu=NetworkAddress(
        v4="10.44.232.8/26",
        v6=None,
        vlan_id=708,
    ),
)

_cu_gnb.m = NetworkAddress(
    v4="https://10.44.231.200",
    v6=None,
    vlan_id=707,
)

_rmod_1 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2037V0LEJ",
    pdu_port=_pdu_gnb_ru_2.pdu_ports[2],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[13],
        _attenuator_1.attenuator_ports[14],
        _attenuator_1.attenuator_ports[15],
        _attenuator_1.attenuator_ports[16],
    ],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2215V011H",
    pdu_port=_pdu_gnb_ru_2.pdu_ports[3],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[17],
        _attenuator_1.attenuator_ports[18],
        _attenuator_1.attenuator_ports[19],
        _attenuator_1.attenuator_ports[20],
    ],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2215V0173",
    pdu_port=_pdu_gnb_ru_2.pdu_ports[4],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[21],
        _attenuator_1.attenuator_ports[22],
        _attenuator_1.attenuator_ports[23],
        _attenuator_1.attenuator_ports[24],
    ],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH220540012",
    pdu_port=_pdu_gnb_ru_1.pdu_ports[6],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
    ],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH220412258",
    pdu_port=_pdu_gnb_ru_1.pdu_ports[8],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[9],
        _attenuator_1.attenuator_ports[10],
        _attenuator_1.attenuator_ports[11],
        _attenuator_1.attenuator_ports[12],
    ],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH220540898",
    pdu_port=_pdu_gnb_ru_1.pdu_ports[9],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1934G10WD",
    pdu_port=_pdu_gnb_ru_1.pdu_ports[10],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
    ],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1934G10WZ",
    pdu_port=_pdu_gnb_ru_1.pdu_ports[11],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
    ],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1934G10W6",
    pdu_port=_pdu_gnb_ru_1.pdu_ports[12],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[9],
        _attenuator_1.attenuator_ports[10],
        _attenuator_1.attenuator_ports[11],
        _attenuator_1.attenuator_ports[12],
    ],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1192614814",
    rus=[_rmod_1, _rmod_2],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1192111864",
    rus=[_rmod_3, _rmod_4],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1192005445",
    rus=[_rmod_7],
)

_bbmod_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240602989",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_bbmod_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIL",
    hardware_version="474020A.101",
    serial_number="L1183000708",
    rus=[_rmod_8],
)

_bbmod_6 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1194704802",
    rus=[_rmod_9],
)

_smod_gnb_master = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1214010354",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2, _bbmod_3],
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_smod_gnb_slave = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.101U",
    serial_number="L1204505485",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_4, _bbmod_5, _bbmod_6],
    pdu_port=_pdu_gnb.pdu_ports[4],
)

_smod_1 = Airscale([_smod_gnb_master])

_smod_2 = Airscale([_smod_gnb_slave])

_du_1_gnb = DU(
    _smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_7, _rmod_8, _rmod_9],
)

_du_2_gnb = DU(
    _smod_2,
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=50893, global_bts_id=50893
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_2_gnb], instance_id=50893, global_bts_id=50893
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.155", username="ute", password="UTE.debian12"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.170", username="ute", password="UTE.debian12"
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASIL_ABIO_ABIA_3xAHLOA_4xAHFIB_3xAZHL_MRAT",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator_1,
    attenuators=[_attenuator_1, _attenuator_1],
)

__all__ = ["tl"]

############### ADDITIONAL PARAMS ###############
#
# 5G SWITCH DATA:
# 5G SWITCH MGMT:
#
# POD ID:
# RACK:
