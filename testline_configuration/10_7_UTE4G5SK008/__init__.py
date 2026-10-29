__owner__ = "I_CUS_CLOUD"
__maintainer__ = "I_CUS_CLOUD"
__email__ = "I_CUS_CLOUD@internal.nsn.com"

import os

from taf.config.testline import CUS, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import FPFH
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

# PDU
_pdu1 = FPFH(
    addr="10.255.26.96",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)
_pdu2 = FPFH(addr="10.255.26.95", port_numbers=[1, 2], login="admin", password="admin")

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


### ENB1
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.21", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.22", hardware_type="ABIP"),
    ],
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="ASIM",
)
_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb("", system_module=_enb_airscale1, instance_id=1070500081)

### ENB2
_enb_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.21", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.22", hardware_type="ABIP"),
    ],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIM",
)
_enb_airscale2 = Airscale(common_units=[_enb_common_unit2])
_enb2 = RealEnb("", system_module=_enb_airscale2, instance_id=1070500082)

## CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIL",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

## CUS2
_cus_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIL",
)
_cus_airscale2 = Airscale(common_units=[_cus_common_unit2])
_cus2 = CUS(l1=_cus_airscale2)

## CUS3
_cus_common_unit3 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")],
    pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIL",
)
_cus_airscale3 = Airscale(common_units=[_cus_common_unit3])
_cus3 = CUS(l1=_cus_airscale3)

## CUS4
_cus_common_unit4 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.4", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIL",
)
_cus_airscale4 = Airscale(common_units=[_cus_common_unit4])
_cus4 = CUS(l1=_cus_airscale4)

## CUS5
_cus_common_unit5 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.5", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")],
    pdu_port=_pdu2.pdu_ports[1],
    hardware_type="ASIL",
)
_cus_airscale5 = Airscale(common_units=[_cus_common_unit5])
_cus5 = CUS(l1=_cus_airscale5)

## CUS6
_cus_common_unit6 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.6", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")],
    pdu_port=_pdu2.pdu_ports[2],
    hardware_type="ASIL",
)
_cus_airscale6 = Airscale(common_units=[_cus_common_unit6])
_cus6 = CUS(l1=_cus_airscale6)

# TestPC
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK008-1.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb1.system_module.common_units[0],
        ),
        Connection(interface="eth2", interface_type="lmp", device=_cus1),
        Connection(interface="eth5", interface_type="lmp", device=_cus2),
        Connection(interface="eth7", interface_type="lmp", device=_cus3),
        Connection(interface="eth9", interface_type="lmp", device=_cus4),
        Connection(interface="eth11", interface_type="lmp", device=_cus5),
        Connection(interface="eth13", interface_type="lmp", device=_cus6),
    ],
)

# TestPC2
_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK008-2.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb2.system_module.common_units[0],
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    enbs=[_enb1, _enb2],
    tl_cloud_topology="CLOUD_2MPPP_6CUS_LOOO",
    ues=[_cus1, _cus2, _cus3, _cus4, _cus5, _cus6],
    pdus=[_pdu1, _pdu2],
)

__all__ = ["tl"]
