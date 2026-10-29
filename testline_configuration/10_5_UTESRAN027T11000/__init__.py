__maintainer__ = "Liu AnAn"
__team__ = "NSB MN RAN RD VRF HAZ1 2"
__email__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_2@internal.nsn.com"
__owner_email__ = "anan.liu@nokia-sbell.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Airphone

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu = FPFH(
    port_numbers=[1, 2, 3],
    addr="10.56.202.83",
    login="admin",
    password="admin",
)

_pdus = [_pdu]

_cu1 = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=726),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=726),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=726),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=726),
)

_abip_du1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIP")

_asim_du1 = CommonUnit(
    pdu_port=_pdu.pdu_ports[1],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[_abip_du1],
)

_du1 = DU(airscale=Airscale(common_units=[_asim_du1]))

_cbts1 = ClassicalBts(cu=_cu1, dus=[_du1])

_cu2 = CU(
    backhaul_site_oam_ip="10.0.1.3",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.3", vlan_id=726),
    x2u=NetworkAddress(v4="10.0.1.3", vlan_id=726),
    s1u=NetworkAddress(v4="10.0.1.3", vlan_id=726),
    ngu=NetworkAddress(v4="10.0.1.3", vlan_id=726),
)

_abip_du2 = CapacityUnit(addr="192.168.253.36", hardware_type="ABIP")

_asim_du2 = CommonUnit(
    pdu_port=_pdu.pdu_ports[2],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[_abip_du2],
)

_du2 = DU(airscale=Airscale(common_units=[_asim_du2]))

_cbts2 = ClassicalBts(cu=_cu2, dus=[_du2])

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                pdu_port=_pdu.pdu_ports[3],
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
        addr="10.56.198.61",
        username="ute",
        password="uteUTE!",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
        _ue,
    ],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.62",
        username="ute",
        password="uteUTE!",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2ASIM_2ABIO_UE_ASIL_ABIO_ABIO",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]

