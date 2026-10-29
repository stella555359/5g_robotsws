__maintainer__ = "Michal Pogodzinski"
__team__ = "I_EXT_5G_SISO7"
__email__ = "I_EXT_5G_SISO7@internal.nsn.com"
__owner_email__ = "michal.pogodzinski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline import RealEnb
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import Android
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

__all__ = ["tl"]

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.19", username="ute", password="ute"
    )
)

_lmp_vm_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.30", username="ute", password="ute"
    )
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2d6", vlan_id=370),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2d6", vlan_id=370),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2d6", vlan_id=370),
)


_pdu_gnb = ATEN(addr="10.44.206.188", port_numbers=[4])

_pdu_gnb_ru = Gude(addr="10.44.205.63", port_numbers=[4], model="EPC", version="8221-1")

_pdu_enb = ATEN(addr="10.44.206.188", port_numbers=[1])

_ru = RU(
    ru_hw_group="TDD",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.162", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.101.1", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_abil1_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="B101",
    serial_number="L1192307427",
    rus=[_ru],
)

_asik_gnb_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    test_pc=_lmp_vm_gnb_primary,
    pdu_port=_pdu_gnb.pdu_ports[4],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru])


_abia_enb_1 = CapacityUnit(addr="192.168.253.20")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    test_pc=_lmp_vm_enb,
    pdu_port=_pdu_enb.pdu_ports[1],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50114, instance_id=1
)

_core = RealCore5G()

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    oam_ip=NetworkAddress(v4="10.42.181.149", vlan_id=370),
    global_bts_id=40114,
    instance_id=1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2d7"),
)

_enb_1.m_plane = NetworkAddress(v4="10.42.181.149")

_enb_1.u_plane = NetworkAddress(v6="2a00:8a00:6000:607c::1:a2d7")

_enb_1.c_plane = NetworkAddress(v6="2a00:8a00:6000:607c::1:a2d7")

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50114, instance_id=1
)


_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "askey.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_enb],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_qualcomm_ue],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QUALCOMM_ASIKL_ABILB1_AZQO_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb],
)
