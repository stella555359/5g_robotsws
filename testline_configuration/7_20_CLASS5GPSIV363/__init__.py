__maintainer__ = "nobody"
__team__ = "MN 5G&SC Pz 5G I&V 2 2 SG"
__email__ = "patrick.pm.moreau@nokia.com"
__owner_email__ = "patrick.pm.moreau@nokia.com"

import os
import shutil

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.du import RU, DU
from taf.config.testline.pdu import ATEN
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.gnb import CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

__all__ = ["tl"]

# ################################################################################ #
#          DRAFT DRAFT DRAFT                                                       #
#                          TL standard definition                                  #
#                                                                                  #
# ################################################################################ #

cfg_dir = os.path.dirname(os.path.abspath(__file__))


host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="ute", password="ute"
    )
)
# A mettre à jour
eNB_pdu = ATEN(addr="2.2.2.2", port_numbers=[2])
ru_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])
ues_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])

ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="3.3.3.3", username="root", password="umniedziela"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziela"
    ),
    pdu_port=ru_pdu.pdu_ports[1],
)

capacity_unit = CapacityUnit(addr="192.168.253.20")

common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="4.4.4.4", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[capacity_unit],
)

airscale = Airscale(common_units=[common_unit])

du = DU(airscale=airscale, rus=[ru])


cu = CU(
    backhaul_site_oam_ip="5.5.5.5",
    oam_ssh_connection_details=SshServiceDetails(
        addr="5.5.5.5", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="5.5.5.5", username="Nemuadmin", password="nemuuser"
    ),
)


cbts = ClassicalBts(
    dus=[du],
    cu=cu,
)

tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIKA101L_ABILA101B1B2_AEUA_ENB"

tl = TestLine(test_pc=host, gnbs=[cbts], tl_cloud_topology=tl_cloud_topology)


# ################################################################################ #
#                                                                                  #
#                           Customization of TL                                    #
#                                                                                  #
# ################################################################################ #

tl_name = "IV_PS_363"

# Values useful with specific Prisma library outside of taf

# Variables for iPerf

# Variables from eCLAT
