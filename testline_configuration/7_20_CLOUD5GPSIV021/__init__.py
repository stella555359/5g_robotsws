__maintainer__ = "Merwane Chemssi"
__team__ = "MN 5G&SC Pz 5G I&V 2 NPS 4 SG"
__email__ = "merwane.chemssi@nokia.com"
__owner_email__ = "merwane.chemssi@nokia.com"

import os

from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Prisma
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.du import RU, DU
from taf.config.testline.pdu import ATEN, PduPort
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.core import RealCore5G

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "custom.yaml"
)

_vm_ute = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.58.4", username="ute", password="uteUTE!"
    )
)

_du0_pdu = ATEN(addr="10.14.55.207", port_numbers=[1])

_common_unit_0_pdu_port = PduPort(pdu=_du0_pdu, port_no=_du0_pdu.pdu_ports[1])

_du0_capacity_unit_L_0 = CapacityUnit(addr="192.168.253.20")

_common_unit_0_L = CommonUnit(
    hardware_type="ASIB",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_du0_capacity_unit_L_0],
    pdu_port=_du0_pdu.pdu_ports[1],
)

_pdu1 = ATEN(addr="10.14.55.207", port_numbers=[1])


_pdus = [_pdu1]

_airscale = Airscale(common_units=[_common_unit_0_L])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.14.48.21",
        v6=None,
        vlan_id="1000",
        routing_v4=RoutingInformation(gateway="10.14.49.254", ip_prefix_length=23),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.21", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.21", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.200.0.150",
        vlan_id="3199",
        routing_v4=RoutingInformation(gateway="10.200.0.131", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.200.0.151",
        vlan_id="3199",
        routing_v4=RoutingInformation(gateway="10.200.0.131", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.200.0.151",
        vlan_id="3199",
        routing_v4=RoutingInformation(gateway="10.200.0.131", ip_prefix_length=24),
    ),
    tracing=None,
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.1", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AEQN",
)

_du = DU(_airscale, rus=[_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=21, global_bts_id=1)

_core = RealCore5G(mcc=208, mnc=64)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_ECPRI_AEQN"


_airmosaic_ssh = SshServiceDetails(
    addr="10.14.38.91", username="localuser", password="10c@1user"
)
_airmosaic_harness = HttpConnectionDetails(addr="10.14.38.91", port=8090)
_lsu_uu_ssh = SshServiceDetails(
    addr="10.14.63.95", username="user", password="user", proxy=_airmosaic_ssh
)
_tstm_uu_ssh = SshServiceDetails(
    addr="10.14.63.95", username="user", password="user", proxy=_airmosaic_ssh
)


_ue_prisma = Prisma(
    airmosaic_ssh_connection_details=_airmosaic_ssh,
    airmosaic_harness_connection_details=_airmosaic_harness,
    lsu_uu_ssh_connection_details=_lsu_uu_ssh,
    tstm_uu_ssh_connection_details=_tstm_uu_ssh,
)

tl = TestLine(
    test_pc=_vm_ute,
    gnbs=[_cbts],
    tl_cloud_topology=_tl_cloud_topology,
    core=_core,
    pdus=_pdus,
    ues=[_ue_prisma],
)

__all__ = ["tl"]
