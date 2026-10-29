__maintainer__ = 'UTE team'
__team__ = 'UTE team'
__email__ = 'ute@nokia.com'
__owner_email__ = 'UTE Lab Team'

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (SshServiceDetails, HttpConnectionDetails)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_pdu = ATEN(addr="10.45.170.155", port_numbers=[2, 4, 1, 0])
_pdus = [_pdu]

### GNB1
_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',username='toor4nsn',password='oZPS0POrRieRtu'
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIO"),
    ],
    pdu_port=_pdus[0].pdu_ports[2],
    hardware_type="ASIL"
)

_cu1 = CU(
         backhaul_site_oam_ip='10.0.1.2',
         oam_ssh_connection_details=SshServiceDetails(
            addr='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'
         ),
         oam_http_connection_details=HttpConnectionDetails(
            addr='192.168.255.129', username='Nemuadmin', password='nemuuser'
         ),
         x2c=NetworkAddress(v4='10.0.1.2', vlan_id=1870),
         x2u=NetworkAddress(v4='10.0.1.2', vlan_id=1870),
         s1u=NetworkAddress(v4='10.0.1.2', vlan_id=1870),
         ngu=NetworkAddress(v4='10.0.1.2', vlan_id=1870),
)

_du1 = DU(airscale=Airscale(common_units=[_common_unit1]))

_cbts1 = ClassicalBts(cu=_cu1, dus=[_du1], instance_id=21645751)

### GNB2
_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',username='toor4nsn',password='oZPS0POrRieRtu'
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIO"),
    ],
    pdu_port=_pdus[0].pdu_ports[1],
    hardware_type="ASIL"
)

_cu2 = CU(
         backhaul_site_oam_ip='10.0.1.3',
         oam_ssh_connection_details=SshServiceDetails(
            addr='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'
         ),
         oam_http_connection_details=HttpConnectionDetails(
            addr='192.168.255.129', username='Nemuadmin', password='nemuuser'
         ),
         x2c=NetworkAddress(v4='10.0.1.3', vlan_id=1870),
         x2u=NetworkAddress(v4='10.0.1.3', vlan_id=1870),
         s1u=NetworkAddress(v4='10.0.1.3', vlan_id=1870),
         ngu=NetworkAddress(v4='10.0.1.3', vlan_id=1870),
)

_du2 = DU(airscale=Airscale(common_units=[_common_unit2]))

_cbts2 = ClassicalBts(cu=_cu2, dus=[_du2], instance_id=21645752)

### AP
_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.85", hardware_type="ABIO"),
                ],
                pdu_port=_pdus[0].pdu_ports[4],
            )
        ]
    ),
)

### TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.189.237",
        username="ute",
        password="ute",
    ),
    connections=[_cbts1.dus[0].airscale.common_units[0], _ue],
)

### TestPC2
_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.189.238",
        username="ute",
        password="ute",
    ),
    connections=[_cbts2.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_5G_I_[LO][LO]_AP_[LOO]",
    ues=[_ue],
    pdus=[_pdus],
)
__all__ = ["tl"]