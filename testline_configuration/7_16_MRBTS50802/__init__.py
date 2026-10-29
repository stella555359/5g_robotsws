__maintainer__ = "Pawel Wisniewski"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "pawel.1.wisniewski@nokia.com"
__owner_email__ = "pawel.1.wisniewski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import Gude

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.205.80",
    port_numbers=[7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(addr="10.44.205.104", port_numbers=[3], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu2.pdu_ports[3],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.70.13",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    tracing=None,
)


_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.34", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[7],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.35", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[8],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.35", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[9],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.35", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[10],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.35", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[11],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.35", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[12],
    ru_hw_group="",
    radio_type="AEQN",
)

_du = DU(_airscale, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50801, instance_id=50802)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.185", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_cbts],
)

_core = RealCore5G(mcc=450, mnc=6)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    pdus=_pdus,
)

__all__ = ["tl"]
