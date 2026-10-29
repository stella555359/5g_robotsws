######################################
#  TestLine 11 Ulm                   #
######################################
__maintainer__ = "MN 5G&SC SW Eng ULM L3NRT 07 SG SQD60"
__team__ = "MN 5G&SC SW Eng ULM L2PS 04 SG SQD60"
__email__ = "I_ECE_RD_ULM_SQD_60@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import Airphone
from taf.config.testline.pdu import APC, PduPort
from taf.config.testline import DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Connection

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# PDU  port 5 = Airphone  port 6 = gNB
_pdu = APC(addr="10.46.139.50", port_numbers=[5, 6])


# GNB

##ABIL
_capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type='ABIL'),
        CapacityUnit(addr="192.168.253.24", hardware_type='ABIL'),
        CapacityUnit(addr="192.168.253.28", hardware_type='ABIL')
    ],

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1411),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1411),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1411),
    ngu=NetworkAddress(v4="10.0.1.1", vlan_id=1411),
)

##ASIB
_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_units],
    pdu_port=_pdu.pdu_ports[6],
)

_airscale = Airscale(common_units=[_common_unit])

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715000111)

# AirPhone

_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                pdu_port=_pdu.pdu_ports[5],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                capacity_units=[
                    CapacityUnit(addr='192.168.253.84', hardware_type='ABIL'),
                    CapacityUnit(addr='192.168.253.85', hardware_type='ABIL'),
                    CapacityUnit(addr='192.168.253.86', hardware_type='ABIL')
                ],
                hardware_type="ASIK",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.18.198", username="ute", password="ute"
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

# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_I_BLLL_AP_KLLL",
    pdus=[_pdu],
    ues=[_ue],
)

__all__ = ["tl"]
