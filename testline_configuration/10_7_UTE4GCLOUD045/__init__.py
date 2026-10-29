__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Connection, CUS
from taf.config.testline.pdu import FPFH
from taf.config.testline.adapters.ute_testline_adapter import (
    prepare_ute_testline_configuration_data,
)

# PDU - 10.253.146.33 - FPFH-GO06-10.leg.krk-lab.nsn-rdnet.net port 6 = ENB  port 5 = CUS
_pdu = FPFH(
    addr="10.253.146.33",
    port_numbers=[5, 6],
    protocol="http",
    login="admin",
    password="admin",
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

### ENB
_enb_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIA"),
    ],
    pdu_port=_pdu.pdu_ports[6],
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
    pdu_port=_pdu.pdu_ports[5],
    hardware_type="ASIA",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-ute4gcloud045.vir.krk-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_enb.system_module.common_units[0]),
        Connection(interface="eth2", interface_type="lmp", device=_cus1),
    ],
)

tl = prepare_ute_testline_configuration_data(
    TestLine(
        test_pc=_test_pc,
        enbs=[_enb],
        tl_cloud_topology="CLOUD_R4A_CUS",
        ues=[_cus1],
        pdus=[_pdu],
    )
)

__all__ = ["tl"]
