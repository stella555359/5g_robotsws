__maintainer__ = "Michal Kowalski"
__team__ = "MN RAN L2 SW 1 KRK Vrf"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import FPFH
from taf.config.testline import Connection

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu = FPFH(port_numbers=[1, 2], addr="10.255.17.7", login="admin", password="admin")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASOE",
    capacity_units=[],
    pdu_port=_pdu.pdu_ports[1],
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1528),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1528),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1528),
)

_du = DU(Airscale([_common_unit]))

_cbts = ClassicalBts(cu=_cu, dus=[_du])


_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.85", hardware_type="ABIO"),
                ],
                pdu_port=_pdu.pdu_ports[2],
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE5G10SK028.p10.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_cbts.dus[0].airscale.common_units[0],
        ),
        Connection(interface="eth2", interface_type="lmp", device=_ue),
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_O_E_AP_LOO",
    ues=[_ue],
    pdus=[_pdu],
)

__all__ = ["tl"]
