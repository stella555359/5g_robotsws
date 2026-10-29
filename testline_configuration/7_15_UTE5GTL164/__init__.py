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

# PDU  port=6 GNB  port=4 Airphone2  port=12 Airphone1
# https://confluence.int.net.nokia.com/display/5GFTUlm/PDU+-+TestLine+allocation
_pdu = Gude(
    addr="10.46.133.15",
    port_numbers=[4, 12, 6],
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
    hardware_type='ASOE',
    capacity_units=[],
    pdu_port=_pdu.pdu_ports[6],
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
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1464),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1464),
    s1u=NetworkAddress(v4="10.0.1.112", vlan_id=1464),
)

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715001641)

_ue1 = Airphone(
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
                pdu_port=_pdu.pdu_ports[12],
                hardware_type="ASIL",
            )
        ]
    ),
)

_ue2 = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.2", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                [CapacityUnit(addr="192.168.253.84", hardware_type='ABIO'),
                CapacityUnit(addr='192.168.253.85', hardware_type='ABIO'),
                CapacityUnit(addr='192.168.253.86', hardware_type='ABIO'),],
                pdu_port=_pdu.pdu_ports[4],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.195.164", username="ute", password="ute"
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
            device=_ue1
        ),
        Connection(
            interface="eth5",
            interface_type="lmp",
            device=_ue2
        )
    ]
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_O_E_AP_2LOOO",
    ues=[_ue1, _ue2],
    pdus=[_pdu],
)

__all__ = ["tl"]
