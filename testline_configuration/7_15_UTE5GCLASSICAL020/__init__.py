######################################
#  TestLine 31 Ulm                   #
######################################
__maintainer__ = "MN 5G&SC SW Eng ULM L2RT 05 SG SQD66"
__team__ = "MN 5G&SC SW Eng ULM L2RT 05 SG SQD66"
__email__ = "I_ECE_RD_ULM_SQD_66@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.ue import Airphone, AirphoneCloud
from taf.config.testline.pdu import APC, PduPort
from taf.config.testline import RU, DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit


# PDU  port7= GNB  port8= Airphone
_pdu = APC(addr="10.46.139.53", port_numbers=[7, 8])

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="kiwi320.delab3.nsn", username="dpdktests", password="qwer2009!"
    )
)

# LteEmu
_lteemu = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="kiwi320.delab3.nsn", username="dpdktests", password="qwer2009!"
    ),
    dir_path="/opt/WTS",
    cfg_filename="basic_wts_step2_above.cfg",
    mme_ip="192.168.4.1",
    mcc="311",
    mnc="489",
    tac=333,
    edaemon_port="22222",
    egate_port="10000",
)


# GNB

_cu = CU(
    backhaul_site_oam_ip="192.168.255.11",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.11", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.11", username="Nemuadmin", password="nemuuser"
    ),
)

# ABIL
_capacity_unit = CapacityUnit(addr="192.168.253.20")

# ASIK
_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.11", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_pdu.pdu_ports[7],
)

_airscale = Airscale(common_units=[_common_unit])

_du = DU(airscale=_airscale, rus=[])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=715000201)

# AirPhone

_airphone_cloud = AirphoneCloud(
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.2", username="Nemuadmin", password="nemuuser"
    ),
)

_l3 = SshServiceDetails(
    addr="192.168.255.2", username="toor4nsn", password="oZPS0POrRieRtu"
)

_l2 = SshServiceDetails(
    addr="192.168.255.2", username="toor4nsn", password="oZPS0POrRieRtu"
)

_airphone_capacity_unit_1 = CapacityUnit(addr="192.168.253.84")

_airphone_common_unit_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_airphone_capacity_unit_1],
    pdu_port=_pdu.pdu_ports[8],
)

_airphone_airscale = Airscale(common_units=[_airphone_common_unit_1])

_airphone = Airphone(
    egate=_lteemu.default_ssh_connection_details,
    airphone_cloud=_airphone_cloud,
    l1=_airphone_airscale,
    l3_ssh_connection_details=_l3,
    l2_ssh_connection_details=_l2,
)

# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=_lteemu,
    tl_cloud_topology="classical-tl20",
    pdus=[_pdu],
    ues=[_airphone],
)

__all__ = ["tl"]
