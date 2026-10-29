__maintainer__ = "Patryk Podgórski"
__team__ = "RRM team"
__email__ = "patryk.podgorski@nokia.com"
__owner_email__ = "patryk.podgorski@nokia.com"

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

_pdu_gnb = ATEN(
    addr="10.44.205.204",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_pdu_gnb_ru_1 = ATEN(
    addr="10.44.206.25",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.177.140",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2]

_attenuator_1 = TopYoung(
    ip_addr="10.42.75.152",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.65.88/26",
        v6=None,
        vlan_id=459,
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
        v4="10.44.65.152/26",
        v6=None,
        vlan_id=460,
    ),
    x2u=NetworkAddress(
        v4="10.44.65.216/26",
        v6=None,
        vlan_id=461,
    ),
    s1u=NetworkAddress(
        v4="10.44.66.24/26",
        v6=None,
        vlan_id=462,
    ),
    xnc=NetworkAddress(
        v4="10.44.65.152/26",
        v6=None,
        vlan_id=460,
    ),
    xnu=NetworkAddress(
        v4="10.44.65.216/26",
        v6=None,
        vlan_id=461,
    ),
    ngc=NetworkAddress(
        v4="10.44.84.31/26",
        v6=None,
        vlan_id=463,
    ),
    ngu=NetworkAddress(
        v4="10.44.66.24/26",
        v6=None,
        vlan_id=462,
    ),
)

_enb_1 = RealEnb(
    system_module=None,
    rms=None,
    instance_id=55378,
    global_bts_id=8978,
    x2_link_addr=NetworkAddress(v4="10.44.90.83/26", v6=None, vlan_id=487),
)

_cu_gnb.m = NetworkAddress(v4="https://10.44.65.88", v6=None, vlan_id=459)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1213808578",
    pdu_port=_pdu_gnb_ru_1.pdu_ports[5],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
    ],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2217N401S",
    pdu_port=_pdu_gnb_ru_2.pdu_ports[7],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
    ],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50VQ",
    pdu_port=_pdu_gnb_ru_2.pdu_ports[8],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[9],
        _attenuator_1.attenuator_ports[10],
        _attenuator_1.attenuator_ports[11],
        _attenuator_1.attenuator_ports[12],
    ],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AVQQA",
    serial_number="L1251202476",
    pdu_port=_pdu_gnb.pdu_ports[3],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[13],
        _attenuator_1.attenuator_ports[14],
        _attenuator_1.attenuator_ports[15],
        _attenuator_1.attenuator_ports[16],
    ],
)

_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AXEGHA",
    serial_number="L1253802734",
    pdu_port=_pdu_gnb.pdu_ports[4],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[17],
        _attenuator_1.attenuator_ports[18],
        _attenuator_1.attenuator_ports[19],
        _attenuator_1.attenuator_ports[20],
    ],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AXEGHA",
    serial_number="L1253802736",
    pdu_port=_pdu_gnb.pdu_ports[5],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[21],
        _attenuator_1.attenuator_ports[22],
        _attenuator_1.attenuator_ports[23],
        _attenuator_1.attenuator_ports[24],
    ],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="	L1232004115",
    rus=[_gnb_ru_2, _gnb_ru_3],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233802986",
    rus=[_gnb_ru_1, _gnb_ru_4],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907574",
    rus=[_gnb_ru_5, _gnb_ru_6],
)

_smod_gnb = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2, _bbmod_3],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1213103087",
)

_smod_1 = Airscale([_smod_gnb])

_du_1_gnb = DU(
    _smod_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5, _gnb_ru_6]
)

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=55378, global_bts_id=55378
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.31", username="ute", password="UTE.debian12"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL78_ASIL_ABIP_AHFII_AEHC_AHLOB_AVQQA_2xAXEGHA",
    core=_core,
    enbs=[_enb_1],
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator_1,
)

__all__ = ["tl"]
