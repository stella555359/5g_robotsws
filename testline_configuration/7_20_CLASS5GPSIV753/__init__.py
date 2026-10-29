__maintainer__ = "NPS_IV2.5"
__team__ = "MN 5G RAN I&V 2 5"
__email__ = "I_MN_5G_RAN_PRODZN_PROD_CI_ICEBREAKERNPS@internal.nsn.com"

import os
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.du import RU, DU
from taf.config.testline.pdu import ATEN
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.ue import Prisma

__all__ = ["tl"]


# ################################################################################ #
#                                                                                  #
#                          TL standard definition                                  #
#                                                                                  #
# ################################################################################ #

cfg_dir = os.path.dirname(os.path.abspath(__file__))

# VM UTE address
host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.28.0.60", username="ute", password="ute"
    )
)


AEQD = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziola"
    ),
    lmp_connection=SshServiceDetails(
        addr="10.14.33.54", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=[0],
    radio_type="AEQD",
)

AEQN = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="10.14.33.54", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=[0],
    radio_type="AEQD",
)
gnb_pdu = ATEN(addr="10.14.33.47", port_numbers=[1])


UE_pdu = ATEN(addr="10.14.33.47", port_numbers=[3])

ru_pdu = ATEN(addr="10.14.33.47", port_numbers=[])

common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.14.48.42", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
)

airscale = Airscale(common_units=[common_unit])

du = DU(airscale=airscale, rus=[AEQD, AEQN])


cu = CU(
    backhaul_site_oam_ip="",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.33.54", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="10.14.33.54"),
)

cbts = ClassicalBts(dus=[du], cu=cu)

tl_classical_topology = "CLASSICAL_5G_QC_ASIKXM01_ABILX22_AEQN"

tl = TestLine(
    test_pc=host,
    gnbs=[cbts],
    tl_cloud_topology=tl_classical_topology,
    pdus=[gnb_pdu, ru_pdu, UE_pdu],
)
