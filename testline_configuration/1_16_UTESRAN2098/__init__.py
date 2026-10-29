__maintainer__ = "Wojciech Poeche"
__team__ = "UUF team"
__email__ = "wojciech.poeche@nokia.com"
__owner_email__ = "wojciech.poeche@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import NetworkAddress
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)

from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

import os

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.250.185", username="ute", password="ute"
    )
)


_pdu1 = EPC(
    addr="10.42.199.246",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu2 = EPC(
    addr="10.42.60.195",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_pdus = [_pdu1, _pdu2]

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu1.pdu_ports[8],
)

_ru_1 = RU(
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.129", port=2323
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru_2 = RU(
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.130", port=2323
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru_3 = RU(
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.128", port=2323
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHLOA",
)

_du1 = DU(Airscale(common_units=[_asik_du1]), rus=[_ru_1, _ru_2, _ru_3])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.83.182.9"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.83.182.9"),
    x2u=NetworkAddress(v4="10.83.182.9"),
    s1u=NetworkAddress(v4="10.83.182.9"),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du1], global_bts_id=50220, instance_id=50220)


_tl_cloud_topology = "CLOUD_5G_ASIKA101L_ABILA102B1_AEUA"


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology=_tl_cloud_topology,
    pdus=_pdus,
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]
