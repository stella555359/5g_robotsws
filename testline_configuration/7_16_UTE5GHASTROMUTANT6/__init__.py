__maintainer__ = "Lukasz Topa"
__team__ = "RRM team"
__email__ = "lukasz.topa@nokia.com"
__owner_email__ = "lukasz.topa@nokia.com"

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


_pdu_1 = Gude(
    addr="10.44.177.224",
    port_numbers=[1, 3, 5, 6],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.42.61.242",
    port_numbers=[1, 4],
    model="EPC",
    version="8221-1",
)


_pdus = [_pdu_1, _pdu_2]

_attenuator_1 = TopYoung(
    ip_addr="10.42.221.108",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_04G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.65.122/26",
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
        v4=None,
        v6=None,
        vlan_id=None,
    ),
    x2u=NetworkAddress(
        v4=None,
        v6=None,
        vlan_id=None,
    ),
    s1u=NetworkAddress(
        v4=None,
        v6=None,
        vlan_id=None,
    ),
    xnc=NetworkAddress(
        v4="10.44.65.185/26",
        v6=None,
        vlan_id=460,
    ),
    xnu=NetworkAddress(
        v4="10.44.65.185/26",
        v6=None,
        vlan_id=460,
    ),
    ngc=NetworkAddress(
        v4="10.44.65.185/26",
        v6=None,
        vlan_id=460,
    ),
    ngu=NetworkAddress(
        v4="10.44.65.185/26",
        v6=None,
        vlan_id=460,
    ),
)

_cu_gnb.m = NetworkAddress(
    v4="https://10.44.88.145",
    v6=None,
    vlan_id=480,
)

_rmod_1 = RU(
    ru_hw_group="",
    radio_type="AQQJ",
    serial_number="NQ234990326",
    pdu_port=_pdu_1.pdu_ports[1],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
    ],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type="AQQJ",
    serial_number="NQ234990327",
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
    ],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type="AQQJ",
    serial_number="NQ234990325",
    pdu_port=_pdu_1.pdu_ports[5],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[17],
        _attenuator_1.attenuator_ports[18],
        _attenuator_1.attenuator_ports[19],
        _attenuator_1.attenuator_ports[20],
    ],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type="AHPB",
    serial_number="DH244316383",
    pdu_port=_pdu_2.pdu_ports[4],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[9],
        _attenuator_1.attenuator_ports[10],
        _attenuator_1.attenuator_ports[11],
        _attenuator_1.attenuator_ports[12],
    ],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type="AHPB",
    serial_number="DH244715513",
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[
        _attenuator_1.attenuator_ports[13],
        _attenuator_1.attenuator_ports[14],
        _attenuator_1.attenuator_ports[15],
        _attenuator_1.attenuator_ports[16],
    ],
)

_fsp_1  = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ASOE",
    hardware_version="475587A.103",
    serial_number="DH224606015",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_fct_1 = CommonUnit(
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASOE",
    hardware_version="475587A.103",
    serial_number="DH224606015",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
)

_smod_1 = Airscale([_fct_1])

_du_1_gnb = DU(
    _smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=9279, global_bts_id=9279
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.23", username="ute", password="UTE.debian12"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master],
    gnbs=[_cbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROMUTANT6_FULLRACK_ASOE_3xAQQJ_2xAHPB",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator_1,
    attenuators=[_attenuator_1],
)

__all__ = ["tl"]