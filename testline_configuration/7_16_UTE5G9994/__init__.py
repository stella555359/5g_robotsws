__maintainer__ = "FTW2 FTW7"
__team__ = "SRAN 5G CP WRO TEAM"
__email__ = "I_EXT_SRAN_5G_CP_WRO_TEAM_GMS"
__owner_email__ = "I_EXT_SRAN_5G_CP_WRO_TEAM@internal.nsn.com"


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
from taf.config.testline.pdu import APC


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_pdu1 = APC(addr="10.42.168.179", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu2 = APC(addr="10.42.169.128", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdus = [_pdu1, _pdu2]

_cu1 = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=207),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=207),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=207),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=207),
)

_abip_du1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIP")

_asim_du1 = CommonUnit(
    pdu_port=_pdu2.pdu_ports[2],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
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
    x2c=NetworkAddress(v4="10.0.1.3", vlan_id=207),
    x2u=NetworkAddress(v4="10.0.1.3", vlan_id=207),
    s1u=NetworkAddress(v4="10.0.1.3", vlan_id=207),
    ngu=NetworkAddress(v4="10.0.1.3", vlan_id=207),
)

_abio_du2 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_asib_du2 = CommonUnit(
    pdu_port=_pdu2.pdu_ports[3],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIB",
    capacity_units=[_abio_du2],
)

_du2 = DU(airscale=Airscale(common_units=[_asib_du2]))

_cbts2 = ClassicalBts(cu=_cu2, dus=[_du2])

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                pdu_port=_pdu2.pdu_ports[4],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.88", hardware_type="ABIO"),
                ],
            )
        ]
    ),
)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.185.14",
        username="ute",
        password="ute",
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
        addr="10.42.185.18",
        username="ute",
        password="ute",
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
    tl_cloud_topology="CLOUD_5G_I_[MP][BO]_AP_[LOO]",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
