######################################
#  TestLine 42 Ulm                   #
######################################
__maintainer__ = "MN 5G&SC SW Eng ULM L3NRT 05 SG SQD65"
__team__ = "MN 5G&SC SW Eng ULM L3NRT 05 SG SQD65"
__email__ = "I_MN_5GSC_SW_ENG_ULM_SQD_65@internal.nsn.com"

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
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Connection

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# PDU  port6= GNB  port5= Airphone

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)
_pdu = Gude(
    addr="10.46.139.8",
    port_numbers=[5, 6],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


# GNB

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=1442),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1442),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1442),
)

##ABIL
_capacity_unit_1 = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1101", hardware_type="ABIL")
_capacity_unit_2 = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1201", hardware_type="ABIL")
_capacity_unit_3 = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1301", hardware_type="ABIL")


##ASIK
_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit_1, _capacity_unit_2, _capacity_unit_3],
    pdu_port=_pdu.pdu_ports[6],
    hardware_type="ASIB",
)

_airscale = Airscale(common_units=[_common_unit])

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715000421)

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
                [
                    CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:4101", hardware_type="ABIL"),
                    CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:4201", hardware_type="ABIL"),
                    CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:4301", hardware_type="ABIL"),
                ],
                pdu_port=_pdu.pdu_ports[5],
                hardware_type="ASIK",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.24.242", username="ute", password="ute"
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
