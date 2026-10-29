__maintainer__ = "Sylwia Swiatkiewicz"
__team__ = "I_MN_5GSC_PZ_5G_IV7_WRO_5"
__email__ = "I_MN_5GSC_PZ_5G_IV7_WRO_5@internal.nsn.com"
__owner_email__ = "sylwia.swiatkiewicz@nokia.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore4G

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.4", username="ute", password="ute"
    )
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.19.33",
        vlan_id="286",
        routing=RoutingInformation(gateway="10.42.19.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.19.33", v6="2a00:8a00:6000:603a:0:21ff:fe11:11d7", vlan_id=286
    ),
    x2u=NetworkAddress(
        v4="10.42.18.33", v6="2a00:8a00:6000:6039:0:21ff:fe11:11d7", vlan_id=285
    ),
    s1u=NetworkAddress(
        v4="10.42.21.33", v6="2a00:8a00:6000:603c:0:21ff:fe11:11d7", vlan_id=288
    ),
)

_pdu_gnb = Gude(addr="10.42.80.108", port_numbers=[1], model="EPC", version="8220-1")
_pdu_gnb_ru1 = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_gnb_ru2 = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_gnb_ru3 = ATEN(addr="0.0.0.0", port_numbers=[0])

_pdus = [_pdu_gnb, _pdu_gnb_ru1, _pdu_gnb_ru2, _pdu_gnb_ru3]

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AHPMDA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=None,
)
#  _pdu_gnb_ru1.pdu_ports[0])

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AHPMDA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.53", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=None,
)
#  _pdu_gnb_ru1.pdu_ports[0])

_gnb_ru3 = RU(
    ru_hw_group="Unknown",
    radio_type="AHPMDA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.54", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=None,
)
#  _pdu_gnb_ru1.pdu_ports[0])

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3])

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.47", username="ute", password="ute"
    )
)

_pdu_enb = Gude(addr="10.42.80.108", port_numbers=[1], model="EPC", version="8220-1")

_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_enb.pdu_ports[1],
)

_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=1837,
    instance_id=1837,
    x2_link_addr=NetworkAddress(v4="10.42.19.33"),
)

_enb_1.m_plane = NetworkAddress(v4="0.0.0.0", vlan_id=287)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=3605, instance_id=3605
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIK_ABIL_3xAHPMDA_RFS_UUF"

_core = RealCore4G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_enb_1],
    pdus=_pdus,
)

tl_config_dir = os.path.dirname(os.path.abspath(__file__))
__all__ = ["tl"]
