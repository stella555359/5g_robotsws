__maintainer__ = "Grzegorz Slowinski, Krzysztof Urbaniak"
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
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.attenuator import TopYoung

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_pdu_gnb = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_1 = ATEN(
    addr="10.44.205.203", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.205.108",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_3 = Gude(
    addr="10.44.177.82",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_4 = Gude(
    addr="10.44.206.143",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_5 = Gude(
    addr="10.44.206.149",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2, _pdu_gnb_ru_3, _pdu_gnb_ru_4, _pdu_gnb_ru_5]

_attenuator_1 = TopYoung(
    ip_addr="10.42.54.171",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_attenuator_2 = TopYoung(
    ip_addr="10.42.221.201",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_pdu_gnb_att = Gude(
    addr="10.44.177.53",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)

_attenuator_2.pdu_port = _pdu_gnb_att.pdu_ports[10]

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.234.96",
        v6=None,
        vlan_id=50,
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
        v4="10.42.234.96",
        v6=None,
        vlan_id=50,
    ),
    x2u=NetworkAddress(
        v4="10.42.234.96",
        v6=None,
        vlan_id=50,
    ),
    s1u=NetworkAddress(
        v4="10.42.234.96",
        v6=None,
        vlan_id=50,
    ),
    xnc=NetworkAddress(
        v4="110.42.234.96",
        v6=None,
        vlan_id=50,
    ),
    xnu=NetworkAddress(
        v4="10.42.234.96",
        v6=None,
        vlan_id=50,
    ),
    ngc=NetworkAddress(
        v4="10.42.234.96",
        v6=None,
        vlan_id=50,
    ),
    ngu=NetworkAddress(
        v4="10.42.234.96",
        v6=None,
        vlan_id=50,
    ),
)

_cu_gnb.m = NetworkAddress(v4="https://10.42.234.96", v6=None, vlan_id=50)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2221N405W",
    pdu_port=_pdu_gnb_ru_4.pdu_ports[10],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
    ],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2212N400G",
    pdu_port=_pdu_gnb_ru_3.pdu_ports[2],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[9],
        _attenuator_1.attenuator_ports[10],
    ],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    serial_number="1M211820165",
    pdu_port=_pdu_gnb_ru_2.pdu_ports[12],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
    ],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    serial_number="1M211820198",
    pdu_port=_pdu_gnb_ru_3.pdu_ports[3],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[4],
    ],
)

_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2229D503L",
    pdu_port=_pdu_gnb_ru_2.pdu_ports[10],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[11],
        _attenuator_1.attenuator_ports[12],
    ],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH220540031",
    pdu_port=_pdu_gnb_ru_1.pdu_ports[6],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
    ],
)

_gnb_ru_7 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2221N4060",
    pdu_port=_pdu_gnb_ru_5.pdu_ports[1],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
    ],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204902771",
    rus=[_gnb_ru_2],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204209894",
    rus=[_gnb_ru_6],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="4474020A.102",
    serial_number="L1183413606",
    rus=[_gnb_ru_5],
)

_bbmod_4 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400397",
    rus=[_gnb_ru_5],
)

_bbmod_5 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204505534",
    rus=[_gnb_ru_3,_gnb_ru_4, _gnb_ru_5],
)

_bbmod_6 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1183301736",
    rus=[_gnb_ru_7],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2,_bbmod_3],
    pdu_port=_pdu_gnb.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1223402812",
)

_smod_gnb_slave_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_4, _bbmod_5, _bbmod_6],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1222905891",
)


_smod_1 = Airscale([_smod_gnb_master_left])

_smod_2 = Airscale([_smod_gnb_slave_right])



_du_1_gnb = DU(_smod_1,rus=[_gnb_ru_2, _gnb_ru_5, _gnb_ru_6])

_du_2_gnb = DU(_smod_2,rus=[_gnb_ru_1, _gnb_ru_3, _gnb_ru_4, _gnb_ru_7])

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=51995, global_bts_id=51995
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.84", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_2_gnb], instance_id=51995, global_bts_id=51995
)

_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.72", username="ute", password="ute"
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASIL_ABIO_ABIL_2xAHFII_2xAEQK_AZHL_AHLOB",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator_2,
)
__all__ = ["tl"]
