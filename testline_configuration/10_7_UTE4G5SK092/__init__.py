__owner__ = "IHT AUTOMATION"
__maintainer__ = "IHT AUTOMATION"
__email__ = "i_iht_automation@internal.nsn.com"
import os

from taf.config.testline import Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import FPFH
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.ue import CUS

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_pdu_1 = FPFH(addr="10.255.26.12", port_numbers=[5, 6], protocol="http")
airscale_1_capacity_unit_fbip1 = CapacityUnit(addr="127.0.0.2", hardware_type="ABIA")
airscale_1_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[airscale_1_capacity_unit_fbip1],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIA",
)

enb_airscale_1 = Airscale([airscale_1_common_unit])

enb_1 = RealEnb(
    "",
    system_module=enb_airscale_1,
    instance_id=1070500092,
)

cus_capacity_unit_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
)

cus_capacity_unit_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
)

cus_capacity_unit_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
)

cus_common_unit_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[cus_capacity_unit_1, cus_capacity_unit_2, cus_capacity_unit_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
)

cus_airscale_1 = Airscale([cus_common_unit_1])

cus_ue_1 = CUS(l1=cus_airscale_1, trs_ip="10.0.2.2")

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK092.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=enb_1.system_module.common_units[0],
        ),
        Connection(interface="eth2", interface_type="lmp", device=cus_ue_1),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[enb_1],
    tl_cloud_topology="CLOUD_R4A_CUS_B",
    ues=[cus_ue_1],
)

__all__ = ["tl"]
