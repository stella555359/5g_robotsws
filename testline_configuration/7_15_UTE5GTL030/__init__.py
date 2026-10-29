__maintainer__ = "I_UTE_ULM_5G_MAINTAINER_GMS"
__team__ = "I_UTE_ULM_5G_MAINTAINER_GMS"
__email__ = "I_UTE_ULM_5G_MAINTAINER@internal.nsn.com"
__owner_email__ = "I_UTE_ULM_5G_MAINTAINER@internal.nsn.com"


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
from taf.config.testline.pdu import Gude
from taf.config.testline import Connection

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# PDU  port=9 GNB-1  port=10 GNB-2  port=7 Airphone
# https://confluence.int.net.nokia.com/display/5GFTUlm/PDU+-+TestLine+allocation
_pdu = Gude(
    addr="10.46.151.151",
    port_numbers=[7, 9, 10],
    model="EPC",
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_capacity_unit_1 = CapacityUnit(addr="192.168.253.20", hardware_type='ABIO')

_common_unit_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit_1],
    pdu_port=_pdu.pdu_ports[9],
    hardware_type="ASIL",
)

_airscale_1 = Airscale(common_units=[_common_unit_1])

_cu_1 = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1430),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1430),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1430),
    ngu=NetworkAddress(v4="10.0.1.1", vlan_id=1430),
)

_du_1 = DU(airscale=_airscale_1)

_cbts_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], instance_id=715000301)

_capacity_unit_2 = CapacityUnit(addr="192.168.253.36", hardware_type='ABIO')

_common_unit_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit_2],
    pdu_port=_pdu.pdu_ports[10],
    hardware_type="ASIL",
)

_airscale_2 = Airscale(common_units=[_common_unit_2])

_cu_2 = CU(
    backhaul_site_oam_ip="10.0.1.3",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1430),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1430),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1430),
    ngu=NetworkAddress(v4="10.0.1.1", vlan_id=1430),
)

_du_2 = DU(airscale=_airscale_2)

_cbts_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], instance_id=715000302)

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                [CapacityUnit(addr="192.168.253.84", hardware_type='ABIO'),
                 CapacityUnit(addr="192.168.253.85", hardware_type='ABIO'),
                 CapacityUnit(addr='192.168.253.86', hardware_type='ABIO'),],
                pdu_port=_pdu.pdu_ports[7],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.17.30", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
           interface="eth1",
           interface_type="lmp",
           device=_cbts_1.dus[0].airscale.common_units[0]
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_ue
        )
    ]
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.17.130", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
           interface="eth1",
           interface_type="lmp",
           device=_cbts_2.dus[0].airscale.common_units[0]
        ),
    ]

)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_5G_I_[LO][LO]_AP_[LOOO]",
    ues=[_ue],
    pdus=[_pdu],
)

__all__ = ["tl"]
