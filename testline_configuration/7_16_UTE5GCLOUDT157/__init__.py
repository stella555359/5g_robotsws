__maintainer__ = "Sebastian Mikos"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "kornel.dluzniewski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import MediaTek
from taf.config.testline.ue import Android
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import JFW
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.appserver import AppServer

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_mediatek_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "mtk_ues.yaml"
)

_pdu_1 = Gude("10.44.200.33", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.25", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")


_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.19.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHCA",
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.19.33", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[5],
    ru_hw_group="",
    radio_type="AHCA",
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.19.35", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[3],
    ru_hw_group="",
    radio_type="AQQL",
)

_abil_master = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1101", hardware_type="ABIL", rus=[_ru1, _ru2, _ru3])

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master],
    hardware_type="ASIB",
    pdu_port=_pdu_1.pdu_ports[10],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.137.22",
        routing=RoutingInformation(gateway="10.44.137.1", ip_prefix_length=26),
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
        v4="10.44.137.80",
        routing=RoutingInformation(
            gateway="10.44.137.65",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.137.144",
        routing=RoutingInformation(gateway="10.44.137.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.137.217",
        routing=RoutingInformation(gateway="10.44.137.193", ip_prefix_length=26),
    ),
)

_du = DU(_airscale)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51020, instance_id=51020)

_core = RealCore5G(mcc=555, mnc=10)

_core_ssh = SshServiceDetails(addr="10.45.168.53", username="5g", password="2019H@slo")

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.36")

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_capacity_unit], pdu_port=None
)

_abia = CapacityUnit(addr="192.168.253.36")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lteenb = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.137.23",
        routing=RoutingInformation(gateway="10.44.137.1", ip_prefix_length=26),
    ),
    global_bts_id=40020,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.110", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]]
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.111", username="ute", password="ute"
    ),
    connections=[_lteenb],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="10.45.168.53",
    iperf_path="",
)

_attenuator = JFW(
    # ip_addr="10.42.61.117",
    ip_addr="10.42.61.252",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 21, 22],
    model="TAS24T24-0.4G6-90-1S-EJS",
)

_appserver = AppServer(_iperf_ue)

_ue_pc_ssh = SshServiceDetails("10.42.61.155", "wro5grrm", password="5gpass!1")

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIBL_ABILB1_3xAHCA_ENB",
    core=_core,
    enbs=[_lteenb],
    ues=[_mediatek_ue],
    appserver=_appserver,
    attenuators=[_attenuator],
)

__all__ = ["tl"]
