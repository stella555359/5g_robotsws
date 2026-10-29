__maintainer__ = "TAF"
__team__ = "MN 5G RAN I&V 3 Pz Autom 1 SG"
__email__ = "I_CV_WRO_AUTOTEAM@internal.nsn.com"
__owner_email__ = "I_CV_WRO_AUTOTEAM@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.gnb.networkaddress import NetworkAddress


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.136", username="ute", password="ute"
    )
)

_capacity_unit = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129", vlan_id=459),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.127", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.1.1.1", vlan_id=459),
    x2u=NetworkAddress(v4="10.1.1.2", vlan_id=459),
    s1c=NetworkAddress(v4="10.1.1.1", vlan_id=459),
    s1u=NetworkAddress(v4="10.1.1.2", vlan_id=459),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du])

# _lteemu = LTEEmuCore(default_ssh_connection_details=SshServiceDetails(addr='10.42.53.14',
#                                                                       username='ute',
#                                                                       password='ute'),
#                      dir_path='/opt/core',
#                      cfg_filename='basic_cfg_LteEmu.cfg',
#                      mme_ip='192.168.4.134',
#                      mcc=311, mnc=489, tac=333,
#                      edaemon_port=22222,
#                      egate_port=10000)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKA101L_ABILA101B1",
)

__all__ = ["tl"]
