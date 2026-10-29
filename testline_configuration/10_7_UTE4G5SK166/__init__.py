__maintainer__ = "I_CUS_CLOUD"
__email__ = "I_CUS_CLOUD@internal.nsn.com"
__owner__ = "I_CUS_CLOUD"

import os

from taf.config.testline import (
    CU,
    DU,
    FPFH,
    Airscale,
    CapacityUnit,
    ClassicalBts,
    CommonUnit,
    Connection,
    HttpConnectionDetails,
    NetworkAddress,
    Simulator,
    SshServiceDetails,
    TestLine,
    TestPc,
)

# PDU1
_pdu1 = FPFH(addr="10.255.26.55", port_numbers=[2, 1])
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# bts1
_bts_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIL",
)

_bts_airscale1 = Airscale(common_units=[_bts_common_unit1])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1666),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1666),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1666),
)

_du = DU(_bts_airscale1)

_bts = ClassicalBts(cu=_cu, dus=[_du], instance_id=1070500166)

# SIM1
_sim_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
    ],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIL",
)
_sim_airscale1 = Airscale(common_units=[_sim_common_unit1])
_sim1 = Simulator(l1=_sim_airscale1)

# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK166.p05.ska-lab.nsn-rdnet.net",
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
            device=_sim1,
        ),
    ],
)
tl = TestLine(
    test_pc=_test_pc1,
    gnbs=[_bts],
    tl_cloud_topology="CLOUD_LO_CUS_LO",
    ues=[_sim1],
    pdus=[_pdu1],
)
__all__ = ["tl"]
