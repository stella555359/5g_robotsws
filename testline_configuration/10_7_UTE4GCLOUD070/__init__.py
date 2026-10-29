__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"
import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Connection
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.ue import CUS

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu_1 = FPFH(addr="10.253.146.25", port_numbers=[1, 2], protocol="http")
vlans = None
airscale_1_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.18", hardware_type="FBBC", pdu_port=_pdu_1.pdu_ports[1]
        ),
        CapacityUnit(
            addr="192.168.253.19", hardware_type="FBBC", pdu_port=_pdu_1.pdu_ports[1]
        ),
    ],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
)
enb_airscale_1 = Airscale([airscale_1_common_unit])
enb_1 = RealEnb(
    system_module=enb_airscale_1,
    trs_ip=NetworkAddress(v4="10.0.1.2"),
    top_ip=NetworkAddress(v4="10.44.136.254"),
    oam_ip="10.0.1.1",
)
cus_capacity_unit_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
)
cus_common_unit_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[cus_capacity_unit_1],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
)
cus_airscale_1 = Airscale([cus_common_unit_1])
cus_ue_1 = CUS(l1=cus_airscale_1, trs_ip="10.0.2.2")
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-ute4gcloud070.vir.krk-lab.nsn-rdnet.net",
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
    tl_cloud_topology="CLOUD_FCC_CUS_A",
    ues=[cus_ue_1],
    vlan_ids=vlans,
)
__all__ = ["tl"]
