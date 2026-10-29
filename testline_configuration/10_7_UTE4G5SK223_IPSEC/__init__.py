__maintainer__ = "I_CUS_CLOUD"
__email__ = "I_CUS_CLOUD@internal.nsn.com"
__owner__ = "I_CUS_CLOUD"

import os

from taf.config.testline import CUS, Connection
from taf.config.testline.adapters.ute_testline_adapter import (
    prepare_ute_testline_configuration_data,
)
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

# PDU1
_pdu1 = FPFH(addr="10.255.26.40", port_numbers=[4, 3])
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
vlans = [3501, 3502, 3503, 3504, 3505, 3506, 3507, 3508, 3509, 3510]
# ENB1
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIA",
)

_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb(
    system_module=_enb_airscale1,
    instance_id=1070500223,
    trs_ip=NetworkAddress(v4="10.0.1.2"),
    top_ip=NetworkAddress(v4="10.83.224.201"),
)

# CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIA"),
    ],
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="ASIA",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK223-IPSEC.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb1.system_module.common_units[0],
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_cus1,
        ),
    ],
)
tl = prepare_ute_testline_configuration_data(
    TestLine(
        test_pc=_test_pc1,
        enbs=[_enb1],
        tl_cloud_topology="CLOUD_R4A_CUS",
        ues=[_cus1],
        pdus=[_pdu1],
        vlan_ids=vlans,
    )
)
__all__ = ["tl"]
