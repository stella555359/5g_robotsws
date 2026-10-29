__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.flexi import Flexi
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection, CUS
from taf.config.testline.pdu import FPFH
from taf.config.testline.ue import CUS
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.adapters.ute_testline_adapter import (
    prepare_ute_testline_configuration_data,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
# ASIB087 pdu=Pdu(addr="10.253.146.25", port=3, device="FPFH", protocol="http", login="admin", password="admin")
# FSMF058 pdu=Pdu(addr="10.253.146.25", port=4, device="FPFH", protocol="http", login="admin", password="admin")
_pdu = FPFH(
    addr="10.253.146.25",
    port_numbers=[3, 4],
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
    pdu_port=_pdu.pdu_ports[4],
    hardware_type="FSMF",
)
_enb1 = RealEnb(
    system_module=Flexi([enb_1_common_unit]),
    trs_ip=NetworkAddress(v4="10.0.1.2"),
    top_ip=NetworkAddress(v4="10.83.224.201"),
    oam_ip="10.0.1.1",
)

cus_1_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.200.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.20")],
    pdu_port=_pdu.pdu_ports[3],
    hardware_type="ASIB",
)
_cus1 = CUS(Airscale([cus_1_common_unit]))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-ute4gcloud058.vir.krk-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_enb1.system_module.common_units[0]),
        Connection(interface="eth2", interface_type="lmp", device=_cus1),
    ],
)

tl = prepare_ute_testline_configuration_data(
    TestLine(
        test_pc=_test_pc,
        enbs=[_enb1],
        ues=[_cus1],
        tl_cloud_topology="CLOUD_FCC_CUS_A",
        pdus=[_pdu],
    )
)

__all__ = ["tl"]
