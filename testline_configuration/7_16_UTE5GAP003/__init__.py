__maintainer__ = 'Katarzyna Wisniewska'
__team__ = 'MN RAN RD VRF WRO2 5'
__email__ = 'I_MN_RAN_RD_VRF_WRO2_5@nokia.com'
__owner_email__ = 'katarzyna.wisniewska@nokia.com'

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
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline import Connection

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# PDU  port_3 = GNB_1,  port_4 = GNB_2, port_5 = Airphone
_pdu = Gude(
    addr="10.44.177.208",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_cu1 = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=1015),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1015),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1015),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=1015),
)

_abip_du1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIP")

_asim_du1 = CommonUnit(
    pdu_port=_pdu.pdu_ports[3],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[_abip_du1],
)

_du1 = DU(airscale=Airscale(common_units=[_asim_du1]))

_gnb1 = ClassicalBts(cu=_cu1, dus=[_du1], instance_id=716000021)

_cu2 = CU(
    backhaul_site_oam_ip="10.0.1.3",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.3", vlan_id=1015),
    x2u=NetworkAddress(v4="10.0.1.3", vlan_id=1015),
    s1u=NetworkAddress(v4="10.0.1.3", vlan_id=1015),
    ngu=NetworkAddress(v4="10.0.1.3", vlan_id=1015),
)

_abip_du2 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIP")

_asim_du2 = CommonUnit(
    pdu_port=_pdu.pdu_ports[4],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[_abip_du2],
)

_du2 = DU(airscale=Airscale(common_units=[_asim_du2]))

_gnb2 = ClassicalBts(cu=_cu2, dus=[_du2], instance_id=716000022)

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                pdu_port=_pdu.pdu_ports[5],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.85", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.86", hardware_type="ABIO")
                ],
            )
        ]
    ),
)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.231.54",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_gnb1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
        _ue,
    ],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.231.55",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_gnb2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_gnb1, _gnb2],
    tl_cloud_topology="CLOUD_5G_I_[MP][MP]_AP_[LOOO]",
    ues=[_ue],
    pdus=[_pdu],
)

__all__ = ["tl"]
