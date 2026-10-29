__maintainer__ = "Airphone QT"
__team__ = "I_MN_5G_AIRPHONE_QT_BLR_GMS"
__email__ = "I_MN_5G_AIRPHONE_QT_BLR@internal.nsn.com"
__owner_email__ = "I_MN_5G_AIRPHONE_QT_BLR@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import RRB


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.95.145", username="ute", password="ute"
    ),
)

tl = TestLine(
    test_pc=_test_pc,
    tl_cloud_topology="L3COH",
)

__all__ = ["tl"]
