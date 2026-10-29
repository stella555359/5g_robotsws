__maintainer__ = "Przemyslaw Golijasz"
__team__ = "MN 5G&SC Pz 5G I&V 7 WRO 2 SG"
__email__ = "przemyslaw.golijasz@nokia.com"
__owner_email__ = "przemyslaw.golijasz@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline import RealEnb
from taf.config.testline.core import EPCSim
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.pdu import ATEN, Gude

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc_ssh = SshServiceDetails(addr="10.42.158.177", username="ute", password="ute")

_test_pc = TestPc(default_ssh_connection_details=_test_pc_ssh)

_enb_pdu = Gude(addr="10.44.206.2", port_numbers=range(1, 13))

_ru_pdu = ATEN(addr="10.44.206.145", port_numbers=[6])

_ru = RU(
    ru_hw_group="5Ggen3_LowF_64T64R",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.53", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.5", username="root", password="umniedziala"
    ),
    pdu_port=_ru_pdu.pdu_ports[6],
)

_capacity_unit = CapacityUnit(addr="192.168.253.22")

_capacity_unit_1 = CapacityUnit(addr="192.168.253.26")

_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_enb_pdu.pdu_ports[1]
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_core = EPCSim(
    mme_ip="10.1.1.100",
    mcc=555,
    mnc=10,
    tac=61,
    default_ssh_connection_details=_test_pc_ssh,
    dir_path="/opt/core",
    cfg_filename="epcsim.cfg",
)

_lteenb = RealEnb(airscale=_du, x2_link_addr="10.1.1.7")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lteenb],
    ues=None,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKA101L_ABILA101B1_AEQA",
    core=_core,
    pdus=[_enb_pdu, _ru_pdu],
)

__all__ = ["tl"]
