__maintainer__ = "Muhammad_Stefan"
__team__ = "I_MN_RAN_L2_SW_ULM_SQD_68_GMS"
__email__ = "I_MN_RAN_L2_SW_ULM_SQD_68@internal.nsn.com"
__owner_email__ = "muhammad.h.zaman@nokia.com"


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


# Testline Confluence: https://confluence.ext.net.nokia.com/display/5GFTUlm/TL156

# PDU
#     gNB1-156:  pdu1-416  port A2
#     AirPh156:  pdu1-416  port A1
_pdu = Gude(
    addr="10.46.133.16",
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
    addr="192.168.253.20",
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
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1456),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1456),
    s1u=NetworkAddress(v4="10.0.1.112", vlan_id=1456),
)

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715001561)

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
                capacity_units=[_ABIO1, _ABIO2, _ABIO3],
                pdu_port=_pdu.pdu_ports[1],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.195.56", username="ute", password="UTE.debian12"
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
    tl_cloud_topology="CLOUD_5G_I_LO_AP_LOOO",
    ues=[_ue],
    pdus=[_pdu],
)

__all__ = ["tl"]
