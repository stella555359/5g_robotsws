__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

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

# PDU - FPFH-HF04-46-P10.p10-leg.ska-lab.nsn-rdnet.net - 10.255.17.1 port 2 = ENB  port 1 = CUS
_pdu1 = FPFH(
    addr="10.255.17.1",
    port_numbers=[1, 2],
    protocol="http",
    login="admin",
    password="admin",
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

### ENB
_enb_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIA"),
    ],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIA",
)
_enb_airscale = Airscale(common_units=[_enb_common_unit])
_enb = RealEnb(
    system_module=_enb_airscale,
    trs_ip=NetworkAddress(v4="10.0.1.2"),
    top_ip=NetworkAddress(v4="10.83.224.201"),
)

## CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIA")],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIA",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G10SK008.p10.ska-lab.nsn-rdnet.net",
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

tl = prepare_ute_testline_configuration_data(
    TestLine(
        test_pc=_test_pc,
        enbs=[_enb],
        tl_cloud_topology="CLOUD_R4A_CUS",
        ues=[_cus1],
        pdus=[_pdu1],
    )
)

__all__ = ["tl"]
