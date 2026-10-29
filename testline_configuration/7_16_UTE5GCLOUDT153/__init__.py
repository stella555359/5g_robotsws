__maintainer__ = "Kornel Dluzniewski"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "kornel.dluzniewski@nokia.com"

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

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "askey_ue.yml"
)

_pdu_1 = Gude("10.44.200.34", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.26", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")


_ru_default_ssh = SshServiceDetails(
    addr="192.168.254.34", username="root", password="umniedziala"
)

_ru_lmp_ssh = SshServiceDetails(addr="", username="")

_ru1 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdu_2.pdu_ports[8],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru2 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdu_2.pdu_ports[9],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru3 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdu_2.pdu_ports[7],
    ru_hw_group="",
    radio_type="FRIJ",
)
_ru4 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdu_2.pdu_ports[6],
    ru_hw_group="",
    radio_type="AZHL",
)

_abil_master = CapacityUnit(addr="192.168.253.20",hardware_type="ABIL", rus=[_ru1, _ru2, _ru3, _ru4])

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master],
    hardware_type="ASIK",
    pdu_port=_pdu_1.pdu_ports[3],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.137.20",
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
        v4="10.42.181.27",
        routing=RoutingInformation(
            gateway="10.42.181.1",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.137.20",
        routing=RoutingInformation(gateway="10.44.137.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.137.20",
        routing=RoutingInformation(gateway="10.44.137.1", ip_prefix_length=26),
    ),
)

_du = DU(_airscale)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51006, instance_id=51006)

_core = RealCore5G(mcc=555, mnc=10)

_core_ssh = SshServiceDetails(addr="10.44.156.98", username="ute", password="ute")

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
        v4="10.44.137.21",
        routing=RoutingInformation(gateway="10.44.137.1", ip_prefix_length=26),
    ),
    global_bts_id=40016,
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.99", username="ute", password="ute"
    ),
    connections=[_lteenb],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.98", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]]
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="192.168.60.200",
    iperf_path="/usr/bin/iperf",
)

_ue_pc_ssh = SshServiceDetails("10.42.22.76", "wro5grrm", password="5gpass!1")

_attenuator = JFW(
    ip_addr="10.42.83.7",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="TAS12T12",
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_classical_bts],
    test_pcs=[_test_pc, _test_pc_enb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB1_3xAHLOA_ENB",
    core=_core,
    enbs=[_lteenb],
    ues=[_qualcomm_ue],
    attenuators=[_attenuator],
)

__all__ = ["tl"]
