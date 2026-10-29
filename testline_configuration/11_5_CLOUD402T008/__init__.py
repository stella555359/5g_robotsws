__maintainer__ = "Fu, Hongye"
__team__ = "CRAN_IV_1_HZ_5_SG"
__email__ = "hongye.fu@nokia-sbell.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC
from taf.config.testline import RU, DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

from taf.config.testline.legacy import SCF
from taf.config.testline.ue import *


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

asik_addr_webui = "10.57.230.4"
asik_addr = "10.57.230.4"
asik_username = "toor4nsn"
asik_password = "oZPS0POrRieRtu"


_cu = CU(
    backhaul_site_oam_ip="10.57.230.4",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.57.230.4", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.57.230.4", username="Nemuadmin", password="nemuuser"
    ),
)


# _du = DU(airscale = Airscale([]))

_gnb_pdu = FACOM(addr="10.57.230.4", port_numbers=[5])

_common_unit_0 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.57.230.4", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_gnb_pdu.pdu_ports[5],
)

_airscale = Airscale(common_units=[_common_unit_0])

_du = DU(airscale=_airscale, rus=None)

_cbts = ClassicalBts(cu=_cu, dus=[_du])

#########Testpc##########
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.57.167.107", username="ute", password="ute"
    )
)

#########LteEmu##########
_lteemu = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.57.238.7", username="nokia", password="nokia123"
    ),
    dir_path="/home/nokia/LTEemu_core2_64_3252",
    cfg_filename="basic_wts_step1.cfg",
    mme_ip="",
    edaemon_port="22222",
    egate_port="9880",
)

# #Airphone
_airphone_cloud = AirphoneCloud(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.57.201.21", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="10.57.201.21"),
)

_egate = SshServiceDetails(addr="0.0.0.0", username="user2", password="password2")

_l3 = SshServiceDetails(addr="3.3.3.3", username="user3", password="password3")

_l2 = SshServiceDetails(addr="10.57.209.21", username="_rcpadmin", password="RCP_owner")

_airphone_pdu = FACOM(addr="10.57.242.34", port_numbers=[5])

_common_unit_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.57.233.21", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_airphone_pdu.pdu_ports[5],
)

_l1 = Airscale(common_units=[_common_unit_1])

_airphone = Airphone(
    egate=_egate,
    l3_ssh_connection_details=_l3,
    l2_ssh_connection_details=_l2,
    l1=_l1,
    l3_port=1234,
    edaemon_port=33333,
    egate_port=22222,
    airphone_cloud=_airphone_cloud,
)


# Testline
tl = TestLine(
    test_pc=_test_pc, gnbs=[_cbts], core=_lteemu, tl_cloud_topology="", ues=[_airphone]
)

__all__ = ["tl"]
