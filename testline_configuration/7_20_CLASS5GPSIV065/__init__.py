__maintainer__ = "Wong Annie"
__team__ = "MN 5G&SC Pz 5G I&V 2 5 SG"
__email__ = "annie.wong@nokia.com"
__owner_email__ = "annie.wong@nokia.com"

import os
import shutil
import sys

# communication services
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

# TL declaration
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline import RU, DU
from taf.config.testline.pdu import ATEN, PduPort, Pdu, EPC
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

# To be confirmed
from taf.config.testline.legacy import SCF

# from taf.config.testline.ue import *

__all__ = ["tl"]


# ################################################################################ #
#                                                                                  #
#                          TL standard definition                                  #
#                                                                                  #
# ################################################################################ #

cfg_dir = os.path.dirname(os.path.abspath(__file__))

# in case of testVM
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.38.179", username="localuser", password="10c@1user"
    )
)

# In case of UTE VM
# host = TestPc(
#    default_ssh_connection_details=SshServiceDetails(
#        addr='xx.xx.xx.xx',
#        username='ute',
#        password='ute'))

_gNB_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])

_eNB_pdu = ATEN(addr="TO_UPDATE", port_numbers=[2])

_ru_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])

_ues_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])

_lmp_connection = SshServiceDetails(
    addr="10.14.48.65", username="toor4nsn", password="oZPS0POrRieRtu"
)

# ABIL CPU A (from ASIK)
_capacity_unit = CapacityUnit(addr="192.168.253.20")

# RRH VM: 10.14.60.145
# RU mini-hub @ 192.168.100.5 / @ 192.168.100.1
_ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=_lmp_connection,
    pdu_port=_ru_pdu.pdu_ports[1],
)

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gNB_pdu.pdu_ports[1],
)

_airscale = Airscale(common_units=[_common_unit_0])

_du = DU(airscale=_airscale, rus=[_ru])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.65", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="10.14.48.65"),
)

# OAM_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr

# cbts = CloudBts(
#    dus=[_du],
#    cu=_cu,
#    cloud_deployment=cloud_deployment,
#    vnf_name='5gbts')

_ClassicalBts = ClassicalBts(cu=_cu, dus=[_du])

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIKM01L_ABILX21B1"

tl = TestLine(test_pc=_host, gnbs=[_ClassicalBts], tl_cloud_topology=_tl_cloud_topology)


# ################################################################################ #
#                                                                                  #
#                           Customization of TL                                    #
#                                                                                  #
# ################################################################################ #

tl_name = "IV_PS_065"

# Variables from eCLAT
eclat = None
if "WORKSPACE" in os.environ:
    eclat = {
        "launcher": "eCLAT",
        "storage": os.environ["ECLAT_STORAGE"],
        "tools": os.environ["ECLAT_TOOLS"],
        "exec_path": os.environ["WORKSPACE"],
        "robotws5g": os.environ["ROBOTWS5G_DIRECTORY"],
        "robotws5g_branch": os.environ["ROBOTWS5G_BRANCH"],
        "logCollector_TLcfg": os.environ["TLConfig"],
        "logCollector_CMDcfg": os.environ["TLCommandsAndFiles"],
        "LOGS_STORAGE": os.environ["LOGS_STORAGE"],
        "PM_STORAGE": os.environ["PM_STORAGE"],
        "TESTCASE_PATH": os.path.join(
            os.environ["WORKSPACE"], "test-cases", os.environ["testCaseId"]
        ),
    }
    PATH_Storage = os.environ["ECLAT_STORAGE"]
    PATH_Tools = os.environ["ECLAT_TOOLS"]
else:
    PATH_Storage = "%s/robot_temporary" % (os.environ["HOME"])
    PATH_RESOURCES = "%s/resources" % (os.environ["HOME"])
    PATH_Tools = "%s/resources/tools" % (os.environ["HOME"])
    # Creation of path in local on the VM
    for ipath in [PATH_Storage, PATH_RESOURCES, PATH_Tools]:
        if not os.path.isdir(ipath):
            if os.path.exists(ipath):
                shutil.rmtree(ipath)
            os.makedirs(ipath)
    eclat = {
        "launcher": "unknown",
        "storage": PATH_Storage,
        "tools": PATH_Tools,
        "exec_path": "",
        "robotws5g": "",
        "robotws5g_branch": "",
        "logCollector_TLcfg": "",
        "logCollector_CMDcfg": "",
        "LOGS_STORAGE": PATH_Storage,
        "PM_STORAGE": PATH_Storage,
        "TESTCASE_PATH": "",
    }


# Custom Values
custom = {
    "TL_Number": "65",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    "PATH_Tools_titan": "/mnt/titan/tools",
    # Values linked to the gNB
    "BTS_ID": "1900",
    "GNB_Friendly_TL_Name": "CV065",
    "GNB_Architecture": "CLASSICAL",
    "GNB_First_CellID": "1",
    "GNB_First_Cell_nrArfcn": "633356",
}
