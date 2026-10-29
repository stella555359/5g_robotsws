__maintainer__ = "ET_PSI"
__team__ = "VRF_WRO2_1"
__email__ = "I_L3_WRO_PSI_ET"
__owner_email__ = "I_L3_WRO_PSI_ET@nokia.com"

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

# PDU1  port_11 = Airphone
# PDU2  port_1 = GNB_1, port_4 = GNB_2
_pdu = Gude(
    addr="10.44.177.186",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.177.188",
    port_numbers=[1, 4],
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
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=1811),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1811),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1811),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=1811),
)

_abio_du1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_asil_du1 = CommonUnit(
    pdu_port=_pdu2.pdu_ports[1],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_abio_du1],
)

_du1 = DU(airscale=Airscale(common_units=[_asil_du1]))

_gnb1 = ClassicalBts(cu=_cu1, dus=[_du1], instance_id=716000991)

_cu2 = CU(
    backhaul_site_oam_ip="10.0.1.3",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.3", vlan_id=1811),
    x2u=NetworkAddress(v4="10.0.1.3", vlan_id=1811),
    s1u=NetworkAddress(v4="10.0.1.3", vlan_id=1811),
    ngu=NetworkAddress(v4="10.0.1.3", vlan_id=1811),
)

_abio_du2 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_asil_du2 = CommonUnit(
    pdu_port=_pdu2.pdu_ports[4],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_abio_du2],
)

_du2 = DU(airscale=Airscale(common_units=[_asil_du2]))

_gnb2 = ClassicalBts(cu=_cu2, dus=[_du2], instance_id=716000992)

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                pdu_port=_pdu.pdu_ports[11],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.85", hardware_type="ABIO"),
		            CapacityUnit(addr="192.168.253.86", hardware_type="ABIO"),
                ],
            )
        ]
    ),
)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.231.149",
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
        addr="10.42.231.150",
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
    tl_cloud_topology="CLOUD_5G_I_[LO][LO]_AP_[LOO]",
    ues=[_ue],
    pdus=[_pdu, _pdu2],
)

__all__ = ["tl"]

