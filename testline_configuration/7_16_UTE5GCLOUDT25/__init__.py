__maintainer__ = "Sebastian Mikos"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "sebastian.mikos@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdu import Gude
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

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "mtk.yaml"
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.78", username="ute", password="ute"
    ),
    connections=[]

)

_abil_master = CapacityUnit(addr="192.168.253.20")  # ?
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_pdu_1 = Gude("10.44.206.236", [1, 2, 3, 4, 5, 6], "EPC", "8221-1")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu_1.pdu_ports[1],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.76.61",
        routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
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
        v4="10.44.76.61",
        routing=RoutingInformation(
            gateway="10.44.76.1",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.76.61",
        routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.76.61",
        routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
    ),
)

_ru_default_ssh = SshServiceDetails(
    addr="192.168.254.34", username="root", password="umniedziala"
)

_ru_lmp_ssh = SshServiceDetails(addr="", username="")

_ru1 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdu_1.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHCA",
)

_ru2 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdu_1.pdu_ports[5],
    ru_hw_group="",
    radio_type="AHCA",
)

_ru3 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdu_1.pdu_ports[6],
    ru_hw_group="",
    radio_type="AHCA",
)

_ru4 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdu_1.pdu_ports[4],
    ru_hw_group="",
    radio_type="AHFIA",
)

_du = DU(_airscale, rus=[_ru1, _ru2, _ru3, _ru4])

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51009, instance_id=51009)

_core = RealCore5G(mcc=310, mnc=260)

_core_ssh = SshServiceDetails(addr="10.42.61.65", username="5g", password="2019H@slo")

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh,
    capacity_units=[_capacity_unit],
    pdu_port=_pdu_1.pdu_ports[3],
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
        v4="10.44.76.115",
        routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
    ),
    global_bts_id=40088,
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.57", username="ute", password="ute"
    ),
    connections=[_lteenb],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="10.42.197.170",
    iperf_path="/usr/bin/iperf",
)

_ue_pc_ssh = SshServiceDetails("10.44.72.6", "wro5grrm", password="5gpass!1")

_attenuator = JFW(
    ip_addr="10.42.61.252",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="50PA-767",
)

_appserver = AppServer(_iperf_ue)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_classical_bts],
    test_pcs=[_test_pc, _test_pc_enb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASILL_ABIOB1_3xAHCA_1xAHFIA_ENB",
    core=_core,
    enbs=[_lteenb],
    ues=[_qualcomm_ue],
    attenuators=[_attenuator],
    appserver=_appserver,
)

__all__ = ["tl"]
