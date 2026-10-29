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
from taf.config.testline.pdu import APC
from taf.config.testline import Connection

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# PDU  port8= gNB  port7= Airphone
_pdu = APC(addr="10.46.139.55", port_numbers=[7, 8])


_capacity_unit = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
)

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_pdu.pdu_ports[8],
    hardware_type="ASIB",
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
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1415),
    x2u=NetworkAddress(v4="10.1.1.2", vlan_id=1415),
    s1u=NetworkAddress(v4="10.1.1.2", vlan_id=1415),
    ngu=NetworkAddress(v4="10.1.1.2", vlan_id=1415),
)

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715000151)

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
                [CapacityUnit(addr="192.168.253.84", hardware_type="ABIL")],
                pdu_port=_pdu.pdu_ports[7],
                hardware_type="ASIK",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.18.215", username="ute", password="ute"
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
    tl_cloud_topology="CLOUD_5G_I_BL_AP_KL",
    ues=[_ue],
    pdus=[_pdu],
)

__all__ = ["tl"]
