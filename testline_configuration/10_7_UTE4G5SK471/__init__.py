__maintainer__ = "I_CUS_CLOUD"
__email__ = "I_CUS_CLOUD@internal.nsn.com"
__owner__ = "I_CUS_CLOUD"

import os

from taf.config.testline import (
    CU,
    CUS,
    DU,
    FPFH,
    Airscale,
    CapacityUnit,
    ClassicalBts,
    CommonUnit,
    Connection,
    HttpConnectionDetails,
    NetworkAddress,
    SshServiceDetails,
    TestLine,
    TestPc,
)

# PDU
_pdu1 = FPFH(
    addr="10.255.26.76",
    port_numbers=[5, 6],
    login="admin",
    password="admin",
)

_pdu2 = FPFH(
    addr="10.255.26.77",
    port_numbers=[1, 2],
    login="admin",
    password="admin",
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB1
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.24", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.28", hardware_type="ABIP"),
    ],
    pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIM",
)

_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb_cu1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1971),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1971),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1971),
)

_du1 = DU(_enb_airscale1)
_cbts1 = ClassicalBts(cu=_enb_cu1, dus=[_du1])


# ENB2
_enb_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.36", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.40", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.44", hardware_type="ABIP"),
    ],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIM",
)

_enb_airscale2 = Airscale(common_units=[_enb_common_unit2])
_enb_cu2 = CU(
    backhaul_site_oam_ip="192.168.255.119",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.119", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1971),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1971),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1971),
)

_du2 = DU(_enb_airscale2)
_cbts2 = ClassicalBts(cu=_enb_cu2, dus=[_du2])

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
    pdu_port=_pdu2.pdu_ports[1],
    hardware_type="ASIM",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)


# CUS2
_cus_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.88", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.92", hardware_type="ABIP"),
    ],
    pdu_port=_pdu2.pdu_ports[2],
    hardware_type="ASIM",
)
_cus_airscale2 = Airscale(common_units=[_cus_common_unit2])
_cus2 = CUS(l1=_cus_airscale2)


# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK471-1.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_cbts1.dus[0].airscale.common_units[0],
        ),
        Connection(interface="eth2", interface_type="lmp", device=_cus1),
        Connection(interface="eth5", interface_type="lmp", device=_cus2),
    ],
)
# TestPC2
_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK471-2.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_cbts2.dus[0].airscale.common_units[0],
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_2MPPP_2CUS_MPPP",
    ues=[_cus1, _cus2],
    pdus=[_pdu1, _pdu2],
)

__all__ = ["tl"]
