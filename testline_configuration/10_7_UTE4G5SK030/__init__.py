__owner__ = "I_CUS_CLOUD"
__maintainer__ = "I_CUS_CLOUD"
__email__ = "I_CUS_CLOUD@internal.nsn.com"

import os

from taf.config.testline import CUS, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.gnb import CU, DU, ClassicalBts
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

# PDU1
_pdu1 = FPFH(addr="10.255.26.2", port_numbers=[2, 1])
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB1
_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.36", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.40", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.44", hardware_type="ABIP"),
    ],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIM",
)

_airscale = Airscale(common_units=[_common_unit])
_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1530),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1530),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1530),
)

_du = DU(_airscale)

_bts = ClassicalBts(cu=_cu, dus=[_du], instance_id=1070500030)

# CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.88", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.92", hardware_type="ABIP"),
    ],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIM",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK030.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_bts.dus[0].airscale.common_units[0],
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_cus1,
        ),
    ],
)
tl = TestLine(
    test_pc=_test_pc1,
    gnbs=[_bts],
    tl_cloud_topology="CLOUD_MPPP_CUS_MPPP",
    ues=[_cus1],
    pdus=[_pdu1],
)
__all__ = ["tl"]
