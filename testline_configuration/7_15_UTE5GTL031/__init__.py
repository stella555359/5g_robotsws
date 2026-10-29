######################################
#  TestLine 31 Ulm                   #
######################################
__maintainer__ = "MN 5G&SC SW Eng ULM L3NRT 07 SG SQD61"
__team__ = "MN 5G&SC SW Eng ULM L3NRT 07 SG SQD61"
__email__ = "I_MN_5GSC_SW_ENG_ULM_SQD_61@internal.nsn.com"

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


# PDU  port8= GNB  port7= Airphone
_pdu = APC(addr="10.46.139.50", port_numbers=[7, 8])

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.20.201", username="ute", password="ute"
    )
)

# GNB

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="192.168.255.129",
        routing_v4="192.168.255.126",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(
        v4="10.0.1.111",
        routing_v4="10.0.1.1",
        vlan_id=1431,
    ),
    x2u=NetworkAddress(
        v4="10.0.1.112",
        routing_v4="10.0.1.1",
        vlan_id=1431,
    ),
    s1u=NetworkAddress(
        v4="10.0.1.112",
        routing_v4="10.0.1.1",
        vlan_id=1431,
    ),
)

##ABIL
_capacity_unit = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIL", hardware_version="M02"
)

##ASIK
_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_pdu.pdu_ports[8],
)

_airscale = Airscale(common_units=[_common_unit])

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715000311, global_bts_id=2003)

# AirPhone

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
                [CapacityUnit(addr="192.168.253.84")],
                pdu_port=_pdu.pdu_ports[7],
            )
        ]
    ),
)


# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_AP",
    pdus=[_pdu],
    ues=[_ue],
)

__all__ = ["tl"]
