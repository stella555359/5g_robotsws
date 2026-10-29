__maintainer__ = "Joseph Soques"
__team__ = "MN 5G&SC Pz 5G I&V 2 NPS 4 SG"
__email__ = "joseph.soques@nokia.com"
__owner_email__ = "joseph.soques@nokia.com"

import os

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

from taf.config.testline.gnb.du import RU, DU
from taf.config.testline.pdu import ATEN, PduPort
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import Prisma
from taf.config.testline.testline import TestLine

# from taf.compatibility.configuration import TestlineWrapper

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_vm_ute = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.28.0.41", username="ute", password="ute"
    )
)

_du0_pdu = ATEN(addr="10.5.115.114", port_numbers=[3])

_common_unit_0_pdu_port = PduPort(pdu=_du0_pdu, port_no=_du0_pdu.pdu_ports[3])

_du0_capacity_unit_R_0 = CapacityUnit(addr="192.168.253.20")

_common_unit_0_R = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.14.49.150", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_du0_capacity_unit_R_0],
    pdu_port=_common_unit_0_pdu_port,
)

_airscale = Airscale(common_units=[_common_unit_0_R])

_du = DU(airscale=_airscale)

_cu = CU(
    backhaul_site_oam_ip="10.14.49.150",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.49.150", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.49.150", username="Nemuadmin", password="nemuuser"
    ),
)

_cbts = ClassicalBts(dus=[_du], cu=_cu)

_airmosaic_ssh = SshServiceDetails(addr="10.14.58.10", username="ute", password="ute")
_airmosaic_harness = HttpConnectionDetails(addr="10.14.58.10", port=8090)
_lsu_uu_ssh = SshServiceDetails(addr="10.14.54.184", username="user", password="user")
_tstm_uu_ssh = SshServiceDetails(addr="10.14.54.184", username="user", password="user")
_prisma_ue = Prisma(
    airmosaic_ssh_connection_details=_airmosaic_ssh,
    airmosaic_harness_connection_details=_airmosaic_harness,
    lsu_uu_ssh_connection_details=_lsu_uu_ssh,
    tstm_uu_ssh_connection_details=_tstm_uu_ssh,
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_PRISMARX2_ASIKA101L_ABILA102B1_AEQD"

tl = TestLine(
    test_pc=_vm_ute,
    gnbs=[_cbts],
    tl_cloud_topology=_tl_cloud_topology,
    ues=[_prisma_ue],
)

# tl = TestlineWrapper(tl)

__all__ = ["tl"]
