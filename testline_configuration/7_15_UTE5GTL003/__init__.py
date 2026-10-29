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


# PDU  port=2 GNB  port=1 Airphone
# https://confluence.int.net.nokia.com/display/5GFTUlm/PDU+-+TestLine+allocation
_pdu = Gude(
    addr="10.46.151.51",
    port_numbers=[1, 2],
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

_capacity_unit = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:1101",
    hardware_type="ABIO",
)

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_pdu.pdu_ports[2],
    hardware_type="ASIL",
)

_airscale = Airscale(common_units=[_common_unit])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1403),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1403),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1403),
    ngu=NetworkAddress(v4="10.0.1.1", vlan_id=1403),
)

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715000031)


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
                [CapacityUnit(addr="192.168.253.84", hardware_type='ABIO')],
                pdu_port=_pdu.pdu_ports[1],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.17.3", username="ute", password="ute"
    ),
    connections=[
        Connection(
           interface="eth1",
           interface_type="lmp",
           device=_cbts.dus[0].airscale.common_units[0]
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_ue
        )
    ]
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_I_LO_AP_LO",
    ues=[_ue],
    pdus=[_pdu],
)

__all__ = ["tl"]
