__owner__ = "IHT AUTOMATION"
__maintainer__ = "IHT AUTOMATION"
__email__ = "i_iht_automation@internal.nsn.com"
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

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_pdu_1 = FPFH(addr="10.255.26.85", port_numbers=[5, 6], protocol="http")


_bts1_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[CapacityUnit(addr="192.168.253.36", hardware_type="ABIP")],
    pdu_port=_pdu_1.pdu_ports[6],
)

_bts1_airscale1 = Airscale(common_units=[_bts1_common_unit1])

_bts1_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1995),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1995),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1995),
)

_bts1_du = DU(_bts1_airscale1)

_bts1 = ClassicalBts(cu=_bts1_cu, dus=[_bts1_du], instance_id=1070500495)

_sim_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIP")],
    pdu_port=_pdu_1.pdu_ports[5],
)
_sim_airscale1 = Airscale(common_units=[_sim_common_unit1])
_sim1 = CUS(l1=_sim_airscale1, trs_ip="10.0.2.2")

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK495.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_bts1.dus[0].airscale.common_units[0],
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_sim1,
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc1,
    gnbs=[_bts1],
    tl_cloud_topology="CLOUD_MP_CUS_MP",
    ues=[_sim1],
    pdus=[_pdu_1],
)
__all__ = ["tl"]
