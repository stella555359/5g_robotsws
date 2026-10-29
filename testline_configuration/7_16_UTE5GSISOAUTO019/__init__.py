__maintainer__ = "Piotr Dudek"
__team__ = "MN 5G RAN I&V 1 Pz 4 SiSo"
__email__ = "piotr.dudek@nokia.com"
__owner_email__ = "piotr.dudek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, KeysightN9935A
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress


__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.42.181.85", vlan_id=1392),
    x2u=NetworkAddress(v4="10.42.181.85", vlan_id=1392),
    s1u=NetworkAddress(v4="10.42.181.85", vlan_id=1392),
)

_pdu_gnb = ATEN(addr="10.44.206.188", port_numbers=[5])

_pdu_gnb_ru = ATEN(addr="10.44.206.189", port_numbers=[4])

_pdu_enb = Gude(addr="10.44.206.3", port_numbers=[2], model="EPC", version="8221-1")

_attenuator = JFW(
    ip_addr="10.42.54.112",
    port=23,
    attenuation_port_numbers=[7, 8],
    model="TAS16T16-0.2G6-90-1S-DEJS",
    version="1.0.0",
    serial_number="30020011363",
)

_gnb_ru = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHGA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.5", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
    signal_analyzer=KeysightN9935A(ip="10.42.54.183"),
    attenuation_ports=[_attenuator.attenuator_ports[8]],
)

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_abia_enb_1 = CapacityUnit(addr="192.168.253.20")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[5],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.163", username="ute", password="ute"
    ),
    connections=[_asik_gnb_1],
)

_airscale_gnb_1 = Airscale([_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru])

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    global_bts_id=1,
    instance_id=40155,
    x2_link_addr=NetworkAddress(v4="10.42.181.151"),
    oam_ip=NetworkAddress(v4="10.42.55.219"),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.164", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_enb_1.u_plane = NetworkAddress(v6="2a00:8a00:6000:607c::1:a217")

_enb_1.c_plane = NetworkAddress(v6="2a00:8a00:6000:607c::1:a217")

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50115
)

_core = RealCore5G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHGA_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb],
    attenuators=[_attenuator],
)
