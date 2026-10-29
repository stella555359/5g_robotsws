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

# PDU  port=3 GNB_1, port4=GNB_2  port=1 Airphone
# https://confluence.int.net.nokia.com/display/5GFTUlm/PDU+-+TestLine+allocation
_pdu = Gude(
    addr="10.46.151.50",
    port_numbers=[1, 3, 4],
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

##### gnb1 ######
_capacity_unit_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:1101",
    hardware_type="ABIP",
)
_common_unit_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit_1],
    pdu_port=_pdu.pdu_ports[3],
    hardware_type="ASIM",
)
_airscale_1 = Airscale(common_units=[_common_unit_1])
_du1 = DU(airscale=_airscale_1)
_cu1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1421),
    x2u=NetworkAddress(v4="10.1.1.2", vlan_id=1421),
    s1u=NetworkAddress(v4="10.1.1.2", vlan_id=1421),
    ngu=NetworkAddress(v4="10.1.1.2", vlan_id=1421),
)
_gnb1 = ClassicalBts(cu=_cu1, dus=[_du1], instance_id=715000211)

##### gnb2 ######
_capacity_unit_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:1101",
    hardware_type="ABIP",
)
_common_unit_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit_2],
    pdu_port=_pdu.pdu_ports[4],
    hardware_type="ASIM",
)
_airscale_2 = Airscale(common_units=[_common_unit_2])
_du2 = DU(airscale=_airscale_2)
_cu2 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1421),
    x2u=NetworkAddress(v4="10.1.1.2", vlan_id=1421),
    s1u=NetworkAddress(v4="10.1.1.2", vlan_id=1421),
    ngu=NetworkAddress(v4="10.1.1.2", vlan_id=1421),
)
_gnb2 = ClassicalBts(cu=_cu2, dus=[_du2], instance_id=715000212)

#### AP #####
_ABIO1 = CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
_ABIO2 = CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
_ABIO3 = CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")


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
                capacity_units=[_ABIO1,_ABIO2,_ABIO3],
                pdu_port=_pdu.pdu_ports[1],
                hardware_type="ASIL",
            )
        ]
    ),
)

###### VMs  ########
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.17.21", username="ute", password="ute"
    ),
    connections=[
        Connection(
           interface="eth1",
           interface_type="lmp",
           device=_gnb1.dus[0].airscale.common_units[0]
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
        addr="10.47.17.121", username="ute", password="ute"
    ),
    connections=[
        Connection(
           interface="eth1",
           interface_type="lmp",
           device=_gnb2.dus[0].airscale.common_units[0]
        )
    ]
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb1, _gnb2],
    tl_cloud_topology="CLOUD_5G_I_[MP][MP]_AP_[LOOO]",
    ues=[_ue],
    pdus=[_pdu],
)

__all__ = ["tl"]
