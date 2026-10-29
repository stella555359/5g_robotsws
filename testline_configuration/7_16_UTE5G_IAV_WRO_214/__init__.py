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
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline.core import RealCore4G
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G


__all__ = ["tl"]

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.168", username="ute", password="ute"
    )
)

_lmp_vm_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.169", username="ute", password="ute"
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
    x2c=NetworkAddress(v4="10.1.1.3", v6=None, vlan_id=2441),
    x2u=NetworkAddress(v4="10.1.1.3", v6=None, vlan_id=2441),
    s1u=NetworkAddress(v4="10.1.1.7", v6=None, vlan_id=2441),
)

_pdu_gnb = ATEN(addr="10.44.206.156", port_numbers=[1])

_pdu_enb = ATEN(addr="10.44.206.156", port_numbers=[3])

_pdu_gnb_ru = Gude(
    addr="10.44.206.218", port_numbers=[3], model="EPC", version="8220-1"
)

_gnb_ru = RU(
    ru_hw_group="5Ggen3_LowF_2T2R",
    radio_type="AZQS",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.1", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    # lmp_connection=SshServiceDetails(addr='192.168.100.1', username='root', password='root'),
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[1],
    test_pc=_lmp_vm_gnb_primary,
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru])


_abia_enb_1 = CapacityUnit(addr="192.168.253.20")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[3],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50123, instance_id=1
)

_core = RealCore4G()

_enb_1 = RealEnb(
    x2_link_addr=NetworkAddress(v4="10.1.1.7", vlan_id=1332),
    global_bts_id=40123,
    instance_id=1,
)

_enb_1.m_plane = NetworkAddress(v4="10.1.1.7", vlan_id=1332)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_enb],
    gnbs=[_cbts],
    # enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABI0B1_AZQS_ECPRI",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb],
)
