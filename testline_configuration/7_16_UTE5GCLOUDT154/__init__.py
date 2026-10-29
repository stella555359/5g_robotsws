__maintainer__ = "Sebastian Mikos"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "sebastian.mikos@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import MediaTek
from taf.config.testline.ue import Android
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
    os.path.dirname(os.path.abspath(__file__)), "askey_ue.yaml"
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.97", username="ute", password="ute"
    )
)

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_pdu_1 = Gude("10.44.206.31", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu_1.pdu_ports[11],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.181.25",
        routing=RoutingInformation(gateway="10.42.181.1", ip_prefix_length=26),
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
        v4="10.42.181.25",
        routing=RoutingInformation(
            gateway="10.42.181.1",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.42.181.25",
        routing=RoutingInformation(gateway="10.42.181.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.42.181.25",
        routing=RoutingInformation(gateway="10.42.181.1", ip_prefix_length=26),
    ),
)


_ru_default_ssh = SshServiceDetails(
    addr="192.168.254.34", username="root", password="umniedziala"
)

_ru_lmp_ssh = SshServiceDetails(addr="", username="")

_ru = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=None,
    ru_hw_group="",
    radio_type="AHLOA",
)

_du = DU(_airscale, rus=[_ru])

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51005, instance_id=51005)

_core = RealCore5G(mcc=555, mnc=10)

_core_ssh = SshServiceDetails(addr="10.42.53.71", username="ute", password="ute")

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

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
        v4="10.42.181.25",
        routing=RoutingInformation(gateway="10.42.181.1", ip_prefix_length=26),
    ),
    global_bts_id=40017,
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.96", username="ute", password="ute"
    ),
    connections=[_lteenb],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="192.168.60.200",
    iperf_path="/usr/bin/iperf",
)

_attenuator = JFW(
    ip_addr="10.42.61.163",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 21, 22],
    model="50PA-628",
)

_ue_pc_ssh = SshServiceDetails("10.42.22.76", "wro5grrm", password="5gpass!1")

_iperf_details_on_mtk = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="192.168.60.200",
    iperf_path="/usr/bin/iperf",
)


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB1_3xAHLOA_ENB",
    core=_core,
    enbs=[_lteenb],
    ues=[_qualcomm_ue],
    attenuators=[_attenuator],
)

__all__ = ["tl"]
