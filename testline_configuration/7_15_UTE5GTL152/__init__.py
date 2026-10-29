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

# PDU
#     gNB1-153:    pdu1-2525  port A2 2
#     AirPh1-153:  pdu2-2525  port B3 9
#     AirPh2-153:  pdu1-2525  port B4 10
#     AirPh3-153:  pdu1-2525  port B1 7
# Testline Confluence: https://confluence.ext.net.nokia.com/display/5GFTUlm/TL152
_pdu = Gude(
    addr="10.46.134.15",
    port_numbers=[2,7,9,10],
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
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',username='toor4nsn',password='oZPS0POrRieRtu'
    ),
    hardware_type="ASOE",
    capacity_units=[],
    pdu_port=_pdu.pdu_ports[2],
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
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1452),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1452),
    s1u=NetworkAddress(v4="10.0.1.112", vlan_id=1452),
)

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715001521)

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
                [CapacityUnit(addr="192.168.253.84", hardware_type='ABIO'),
                CapacityUnit(addr='192.168.253.85', hardware_type='ABIO'),
                CapacityUnit(addr='192.168.253.86', hardware_type='ABIO'),],
                pdu_port=_pdu.pdu_ports[9],
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
                [CapacityUnit(addr="192.168.253.84", hardware_type='ABIO'),
                CapacityUnit(addr='192.168.253.85', hardware_type='ABIO'),
                CapacityUnit(addr='192.168.253.86', hardware_type='ABIO'),],
                pdu_port=_pdu.pdu_ports[10],
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
                [CapacityUnit(addr="192.168.253.84", hardware_type='ABIO'),
                CapacityUnit(addr='192.168.253.85', hardware_type='ABIO'),
                CapacityUnit(addr='192.168.253.86', hardware_type='ABIO'),],
                pdu_port=_pdu.pdu_ports[7],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.195.52", username="ute", password="UTE.debian12"
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
        addr="10.47.195.152", username="ute", password="UTE.debian12"
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
        addr="10.47.195.49", username="ute", password="UTE.debian12"
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
    test_pcs=[_test_pc1, _test_pc2, _test_pc3],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_O_E_AP_[LOOO][LOOO][LOOO]",
    ues=[_ap1, _ap2, _ap3],
    pdus=[_pdu],
)

__all__ = ["tl"]
