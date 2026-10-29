__owner__ = "I_CUS_CLOUD"
__maintainer__ = "I_CUS_CLOUD"
__email__ = "I_CUS_CLOUD@internal.nsn.com"
import os

from taf.config.testline import CUS, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.gnb import CU, DU, ClassicalBts
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_pdu_1 = FPFH(addr="10.253.166.180", port_numbers=[1, 2, 3], protocol="http")

_ru1 = RU(
    ru_hw_group="cmw",
    pdu_port=_pdu_1.pdu_ports[3],
    radio_type="AVQL",
)


_bts1_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[CapacityUnit(addr="192.168.253.36", hardware_type="ABIP")],
    pdu_port=_pdu_1.pdu_ports[1],
)

_bts1_airscale1 = Airscale(common_units=[_bts1_common_unit1])

_bts1_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1504),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1504),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1504),
)

_bts1_du = DU(_bts1_airscale1, rus=[_ru1])

_bts1 = ClassicalBts(cu=_bts1_cu, dus=[_bts1_du])

_sim_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIP")],
    pdu_port=_pdu_1.pdu_ports[2],
)
_sim_airscale1 = Airscale(common_units=[_sim_common_unit1])
_sim1 = CUS(l1=_sim_airscale1, trs_ip="10.0.2.2")


_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4GM004.macro.krk-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_bts1.dus[0].airscale.common_units[0],
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_sim1,
        ),
    ],
)

_egen1_ul_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="eGen-gk02s30-1.macro.krk-lab.nsn-rdnet.net ",
        username="egenuser",
        password="Nokia5g!",
    ),
)
_egen2_dl_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="eGen-gk02s30-2.macro.krk-lab.nsn-rdnet.net ",
        username="egenuser",
        password="Nokia5g!",
    ),
)
tl = TestLine(
    test_pc=_test_pc1,
    gnbs=[_bts1],
    tl_cloud_topology="CLOUD_MP1_CUS_MP",
    ues=[_sim1],
    pdus=[_pdu_1],
    test_pcs=[_test_pc1, _egen1_ul_pc, _egen2_dl_pc],
)
__all__ = ["tl"]
