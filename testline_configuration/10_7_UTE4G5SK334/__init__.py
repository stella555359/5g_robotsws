__owner__ = "IHT AUTOMATION"
__maintainer__ = "IHT AUTOMATION"
__email__ = "i_iht_automation@internal.nsn.com"
import os

from taf.config.testline import CUS, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import FPFH
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

# PDU1  port2=ENB port1=CUS1
_pdu1 = FPFH(addr="10.255.26.64", port_numbers=[1, 2], login="admin", password="admin")


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


### ENB
_enb_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.24", hardware_type="ABIN"),
        CapacityUnit(addr="192.168.253.22", hardware_type="ABIO"),
    ],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIB",
)
_enb_airscale = Airscale(common_units=[_enb_common_unit])
_enb = RealEnb("", system_module=_enb_airscale, instance_id=1070500334)

## CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.88", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.92", hardware_type="ABIA"),
    ],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIA",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK334.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb.system_module.common_units[0],
        ),
        Connection(interface="eth2", interface_type="lmp", device=_cus1),
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_*_CUS",
    ues=[_cus1],
    pdus=[_pdu1],
)

__all__ = ["tl"]
