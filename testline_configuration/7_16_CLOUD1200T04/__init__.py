__maintainer__ = "Hubert Wisniewski"
__team__ = "MN 5G RAN I&V 3 Prodzn 04 RF & SiSo"
__email__ = "hubert.wisniewski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.pdu import ATEN
from taf.config.testline.gnb.networkaddress import NetworkAddress


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc_ssh = SshServiceDetails(addr="10.42.53.57", username="ute", password="ute")

_test_pc = TestPc(default_ssh_connection_details=_test_pc_ssh)

_enb_pdu = ATEN(addr="10.44.206.5", port_numbers=[3], model="ATEN")

_ru_pdu = ATEN(addr="10.44.206.7", port_numbers=[1], model="ATEN")

_capacity_unit = CapacityUnit(addr="192.168.253.22")

_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit = CommonUnit(
    lmp_connection=_common_unit_ssh,
    capacity_units=[_capacity_unit],
    pdu_port=_enb_pdu.pdu_ports[3],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_ru = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AEUA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_ru_pdu.pdu_ports[1],
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

_lteenb = RealEnb(airscale=_du, x2_link_addr=NetworkAddress(v4="10.1.1.7"))


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lteenb],
    ues=None,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKA101L_ABILA102B1_AEUA",
    core=_core,
    pdus=[_enb_pdu, _ru_pdu],
)

__all__ = ["tl"]
