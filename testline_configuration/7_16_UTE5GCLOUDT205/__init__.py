__maintainer__ = "Sebastian Mikos"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "sebastian.mikos@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue.yaml"
)

_pdu_1 = Gude("10.44.200.21", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.22", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3 = Gude("10.44.200.23", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")


_pdus = [_pdu_1, _pdu_2, _pdu_3]

_ru_default_ssh = SshServiceDetails(
    addr="192.168.254.34", username="root", password="umniedziala"
)

_ru_lmp_ssh = SshServiceDetails(addr="", username="")

_ru1 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdus[2].pdu_ports[8],
    ru_hw_group="",
    radio_type="AHFIB",
)

_ru2 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdus[1].pdu_ports[1],
    ru_hw_group="",
    radio_type="AHFII",
)

_ru3 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdus[1].pdu_ports[10],
    ru_hw_group="",
    radio_type="AHFII",
)

_ru4 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdus[1].pdu_ports[9],
    ru_hw_group="",
    radio_type="AZQU",
)

_ru5 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdus[1].pdu_ports[2],
    ru_hw_group="",
    radio_type="AHLOA",
)
_abip_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    rus=[_ru1, _ru2, _ru3, _ru4, _ru5]
)
_abip_slave = CapacityUnit(addr="192.168.253.21", hardware_type="ABIP")
_abip_loner = CapacityUnit(addr="192.168.253.22", hardware_type="ABIP")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_master],
    hardware_type="ASIM",
    pdu_port=_pdus[0].pdu_ports[3],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.137.28",
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
        v4="10.44.137.83",
        routing=RoutingInformation(
            gateway="10.44.137.65",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.137.147",
        routing=RoutingInformation(gateway="10.44.137.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.137.223",
        routing=RoutingInformation(gateway="10.44.137.193", ip_prefix_length=26),
    ),
)

_du = DU(_airscale)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50017, instance_id=50017)

_core = RealCore5G(mcc=555, mnc=10)

_core_ssh = SshServiceDetails(addr="10.45.168.53", username="5g", password="2019H@slo")

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20", hardware_type="ABIP")

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_capacity_unit], pdu_port=None
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lteenb = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.92.80",
        routing=RoutingInformation(gateway="10.44.92.65", ip_prefix_length=26),
    ),
    global_bts_id=40137,
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.86", username="ute", password="ute"
    ),
    connections=[_lteenb],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="192.168.60.200",
    iperf_path="/usr/bin/iperf",
)

_attenuator = TopYoung(
    ip_addr="10.42.61.10",
    port=3001,
    attenuation_port_numbers=range(1, 25),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.133", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]]
)

_ue_pc_ssh = SshServiceDetails("10.44.72.98", "wro5grrm", password="5gpass!1")

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIML_ABIPB1_1xAHFIB_ENB",
    core=_core,
    ues=[_qualcomm_ue],
    attenuator=_attenuator,
    attenuators=[_attenuator],
)

__all__ = ["tl"]