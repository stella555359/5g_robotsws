__maintainer__ = "Barbier Jean-Michel"
__team__ = "MN 5G RAN I&V 1 Pz 1 SG"
__email__ = "I_UTE_NPS_5G@internal.nsn.com"

import os
import shutil

# from taf.config.testline.cloud_hosting import ControlNode, NCIR, CloudDeployment, DeploymentFlavorStack, DeploymentNetworkStack, DeploymentVnfStack

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

from taf.config.testline.testpc import TestPc
from taf.config.testline import RU, DU
from taf.config.testline.pdu import ATEN, PduPort, Pdu, EPC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.core import EPCSim
from taf.config.testline.core import LTEEmuCore
from taf.compatibility.configuration import TestlineWrapper

# To be confirmed
from taf.config.testline.legacy import SCF
from taf.config.testline.ue import *


__all__ = ["tl"]


# ################################################################################ #
#                                                                                  #
#                          TL standard definition                                  #
#                                                                                  #
# ################################################################################ #

cfg_dir = os.path.dirname(os.path.abspath(__file__))
ue_cfg_file_name = os.path.join(cfg_dir, "ue_config_cv80.yml")


# In case of UTE VM
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.28.0.17", username="ute", password="ute"
    )
)
_default_ssh_connection_details = SshServiceDetails(
    addr="192.168.100.5", username="root", password="umniedziola"
)
_lmp_connection = SshServiceDetails(
    addr="10.57.231.136", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20")
_gnb_pdu = ATEN(addr="10.14.62.234", port_numbers=[4])
_enb_pdu = ATEN(addr="10.14.63.234", port_numbers=[5])
_ues_pdu = ATEN(addr="10.14.62.219", port_numbers=[3])
_ru_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])


_ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=_default_ssh_connection_details,
    lmp_connection=_lmp_connection,
    pdu_port=_ru_pdu.pdu_ports[1],
)

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[4],
)

_airscale = Airscale(common_units=[_common_unit_0])

_du = DU(airscale=_airscale, rus=[_ru])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="192.168.255.129"),
)

_ClassicalBts = ClassicalBts(cu=_cu, dus=[_du])

# with open(ue_cfg_file_name) as f:
#    import yaml
#    _ue_conf = yaml.load(f)
os.environ["ABSTRACT_LIB_CONFIG"] = ue_cfg_file_name

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIKM01L_ABILX21B1"

tl = TestLine(
    test_pc=_host,
    gnbs=[_ClassicalBts],
    # ues=_ue_conf,
    tl_cloud_topology=_tl_cloud_topology,
)


# ################################################################################ #
#                                                                                  #
#                           Customization of TL                                    #
#                                                                                  #
# ################################################################################ #

tl_name = "IV_PS_080"

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
    if not os.path.isdir(PATH_Storage):
        if os.path.exists(PATH_Storage):
            shutil.rmtree(PATH_Storage)
        os.makedirs(PATH_Storage)
    PATH_RESOURCES = "%s/resources" % (os.environ["HOME"])
    if not os.path.isdir(PATH_RESOURCES):
        if os.path.exists(PATH_RESOURCES):
            shutil.rmtree(PATH_RESOURCES)
        os.makedirs(PATH_RESOURCES)
    PATH_Tools = "%s/resources/tools" % (os.environ["HOME"])
    if not os.path.isdir(PATH_Tools):
        if os.path.exists(PATH_Tools):
            shutil.rmtree(PATH_Tools)
        os.makedirs(PATH_Tools)
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
    "TL_Number": "080",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    "PATH_Tools_titan": "/mnt/titan/tools",
    # Values linked to the gNB
    "GNB_Friendly_TL_Name": "CV080",
    "GNB_Architecture": "CLASSICAL",
    "GNB_First_CellID": "1",
    "GNB_First_Cell_nrArfcn": "630000",
    "UES_PDU_ADDR": "10.14.63.219",
    "UE_1_PDU_PORT": "3",
}
