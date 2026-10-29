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

# PDU  port=A3 GNB  port=B5 AP1, B6 AP2, A2 AP3
# https://confluence.int.net.nokia.com/display/5GFTUlm/PDU+-+TestLine+allocation

# PDU1
#     gNB1-153:    pdu1-2525  port A3 3
#     AirPh1-153:  pdu1-2525  port B5 11
#     AirPh2-153:  pdu1-2525  port B6 12
#     AirPh3-153:  pdu2-2525  port A2 2

_pdu1 = Gude(
    addr="10.46.134.15",
    port_numbers=[3, 11, 12],
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

_pdu2 = Gude(
    addr="10.46.134.25",
    port_numbers=[2],
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
_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',username='toor4nsn',password='oZPS0POrRieRtu'
    ),
    hardware_type='ASOE',
    capacity_units=[],
    pdu_port=_pdu1.pdu_ports[3],
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
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1453),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1453),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1453)
)

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715001531)

_ABIO1 = CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
_ABIO2 = CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
_ABIO3 = CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")

_ap1 = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                capacity_units=[_ABIO1, _ABIO2, _ABIO3],
                pdu_port=_pdu1.pdu_ports[11],
                hardware_type="ASIL",
            )
        ]
    ),
)

_ap2 = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                capacity_units=[_ABIO1, _ABIO2, _ABIO3],
                pdu_port=_pdu1.pdu_ports[12],
                hardware_type="ASIL",
            )
        ]
    ),
)

_ap3 = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                capacity_units=[_ABIO1, _ABIO2, _ABIO3],
                pdu_port=_pdu2.pdu_ports[2],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.195.53", username="ute", password="UTE.debian12"
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
            device=_ap1
        )
    ]
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.195.153", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_ap2
        )
    ]
)

_test_pc3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.195.203", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_ap3
        )
    ]
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1],  # test_pcs=[_test_pc1, _test_pc2, _test_pc3],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_O_E_AP_LOOO",  # tl_cloud_topology="CLOUD_5G_O_E_AP_LOOO[LOOO][LOOO]",
    ues=[_ap1],  # ues=[_ap1, _ap2, _ap3],
    pdus=[_pdu1, _pdu2],
)

__all__ = ["tl"]
