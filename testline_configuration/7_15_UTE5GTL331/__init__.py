__maintainer__ = "I_UTE_ULM_5G_MAINTAINER_GMS"
__team__ = "I_UTE_ULM_5G_MAINTAINER_GMS"
__email__ = "I_UTE_ULM_5G_MAINTAINER@internal.nsn.com"
__owner_email__ = "I_UTE_ULM_5G_MAINTAINER@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Airphone
from taf.config.testline import Connection

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


# PDU  port=11 GNB  port=9 Airphone
# https://confluence.int.net.nokia.com/display/5GFTUlm/PDU+-+TestLine+allocation
_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_pdu = Gude(
    addr="10.46.152.137",
    port_numbers=[9, 11],
    version="8226-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


_asoe_du1 = CommonUnit(
    pdu_port=_pdu.pdu_ports[11],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    hardware_type="ASOE",
)

_du1 = DU(airscale=Airscale(common_units=[_asoe_du1]))

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1431),
    x2u=NetworkAddress(v4="10.0.2.1", vlan_id=1431),
    s1u=NetworkAddress(v4="10.0.2.1", vlan_id=1431),
    ngu=NetworkAddress(v4="10.0.2.1", vlan_id=1431),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du1], instance_id=715003311)

_ABIO1 = CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
_ABIO2 = CapacityUnit(addr="192.168.253.85", hardware_type="ABIO")
_ABIO3 = CapacityUnit(addr="192.168.253.86", hardware_type="ABIO")

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                pdu_port=_pdu.pdu_ports[9],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                capacity_units=[_ABIO1,_ABIO2,_ABIO3],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.12.61", username="ute", password="UTE.debian12"
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
    tl_cloud_topology="CLOUD_5G_O_E_AP_LOOO",
    ues=[_ue],
    pdus=[_pdu],
)

__all__ = ["tl"]
