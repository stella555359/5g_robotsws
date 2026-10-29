__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

import os

from taf.config.testline import Connection
from taf.config.testline.adapters.ute_testline_adapter import (
    prepare_ute_testline_configuration_data,
)
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.ue import CUS

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu = FPFH(
    addr="10.255.17.11",
    port_numbers=[1, 2, 3, 4],
    login="admin",
    password="admin",
)

enb_1_capacity_unit = CapacityUnit(
    addr="",
    hardware_type="FBBC",
)
enb_1_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[enb_1_capacity_unit],
    pdu_port=_pdu.pdu_ports[1],
    hardware_type="FSMF",
)
_enb1 = RealEnb(
    system_module=Flexi([enb_1_common_unit]),
    instance_id=1071000541,
    trs_ip=NetworkAddress(v4="10.0.1.2"),
    top_ip=NetworkAddress(v4="10.83.224.201"),
    oam_ip="10.0.1.1",
)

cus_1_capacity_unit = CapacityUnit(addr="192.168.253.20")
cus_1_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.200.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[cus_1_capacity_unit],
    pdu_port=_pdu.pdu_ports[2],
    hardware_type="ASIA",
)
_cus1 = CUS(Airscale([cus_1_common_unit]))

enb_2_capacity_unit = CapacityUnit(
    addr="",
    hardware_type="FBBC",
)
enb_2_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[enb_2_capacity_unit],
    pdu_port=_pdu.pdu_ports[4],
    hardware_type="FSMF",
)
_enb2 = RealEnb(
    system_module=Flexi([enb_2_common_unit]),
    instance_id=1071000542,
    trs_ip=NetworkAddress(v4="10.0.1.4"),
    top_ip=NetworkAddress(v4="10.83.224.201"),
    oam_ip="10.0.1.3",
)

cus_2_capacity_unit = CapacityUnit(addr="192.168.253.20")
cus_2_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.200.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[cus_2_capacity_unit],
    pdu_port=_pdu.pdu_ports[3],
    hardware_type="ASIA",
)
_cus2 = CUS(Airscale([cus_2_common_unit]))

# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G10SK054.p10.ska-lab.nsn-rdnet.net",
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
    ],
)
# TestPC2
_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G10SK056.p10.ska-lab.nsn-rdnet.net",
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

tl = prepare_ute_testline_configuration_data(
    TestLine(
        test_pc=_test_pc1,
        test_pcs=[_test_pc1, _test_pc2],
        enbs=[_enb1, _enb2],
        ues=[_cus1, _cus2],
        tl_cloud_topology="CLOUD_2FCC_2CUS_A",
        pdus=[_pdu],
    )
)

__all__ = ["tl"]
