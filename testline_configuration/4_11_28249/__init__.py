###############################
#  4_11_28249 Classical SBTS  #
###############################
__maintainer__ = "RSP PET Oulu"
__team__ = "Vrf_RSP_TA CA4"
__email__ = "I_RSP_TA_CA4@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline import DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="localhost", username="ute", password="ute"
    )
)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu", port="22"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20")
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
)
_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(airscale=_airscale, rus=[])

# CU
_cu = CU(
    backhaul_site_oam_ip="",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
)
# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=28249, global_bts_id=28249)
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_classical_bts],
)

__all__ = ["tl"]
