__maintainer__ = "Filip Jozefczak"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "filip.jozefczak@nokia.com"
__owner_email__ = ""

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, NetworkAddress, Connection


cfg_dir = os.path.dirname(os.path.abspath(__file__))


_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[]
)


_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)


_du = DU(Airscale([_common_unit]))


_cbts = ClassicalBts(cu=_cu, dus=[_du])


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="Szybowcowa 2", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_cbts.dus[0].airscale.common_units[0]
        )
    ]
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
)


__all__ = ["tl"]
