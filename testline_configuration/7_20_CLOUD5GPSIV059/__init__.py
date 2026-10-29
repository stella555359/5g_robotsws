__maintainer__ = "Barbier Jean-Michel"
__team__ = "MN 5G RAN I&V 1 Pz 1 SG"
__email__ = "I_UTE_NPS_5G@internal.nsn.com"


import os
import sys
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline.core import EPCSim
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper

# os.environ["PYTHONPATH"] += os.pathsep + "/mnt/titan/robotws5g/testsuite/Cloud/NPS_IV1/multi_du/resources/common"
# print os.environ["PYTHONPATH"]
# os.export["PYTHONPATH"]
sys.path.insert(
    -1, "/mnt/titan/robotws5g/testsuite/Cloud/NPS_IV1/multi_du/resources/common"
)

__all__ = ["tl"]


# ################################################################################ #
#                                                                                  #
#                          TL standard definition                                  #
#                                                                                  #
# ################################################################################ #

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.38.59", username="localuser", password="10c@1user"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.14.55.142", username="wrsroot", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.55.142", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_17A")

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_20_CLOUD5GPSIV059_FLAVOR_AP",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="TL59-",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_20_CLOUD5GPSIV059_EXT_NET_AP",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_20_CLOUD5GPSIV059_BTS",
    env_files=[os.path.join(_CFG_DIR, "config_bts.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_bts.yaml"),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip="10.14.48.59",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.59", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.59", username="Nemuadmin", password="nemuuser"
    ),
)

_common_unit_lmp_connection = SshServiceDetails(
    addr="10.14.55.141", username="toor4nsn", password="oZPS0POrRieRtu"
)

_pdu = ATEN(addr="", port_numbers=list(range(1, 9)))

_common_unit_pdu_port = PduPort(pdu=_pdu, port_no=4)

_capacity_unit = CapacityUnit(addr="")

_common_unit = CommonUnit(
    lmp_connection=_common_unit_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_common_unit_pdu_port,
)

_airscale = Airscale([_common_unit])

_du = DU(airscale=_airscale)

_epcsim = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.38.219", username="ute", password="ute"
    ),
    dir_path="/opt/lteemu",
    cfg_filename="basic_cfg_LteEmu.cfg",
    mme_ip="192.168.4.134",
    mcc=-1,
    mnc=-1,
    tac=-1,
)


_cbts = CloudBts(
    cu=_cu, cloud_deployment=_cloud_deployment, dus=[_du], vnf_name="tl59-5gbts"
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_MIN_ASIKA101_ABILA102_18A",
    cloud_hostings=[_ncir],
    pdus=[_pdu],
    core=_epcsim,
)
tl = TestlineWrapper(tl)


# ################################################################################ #
#                                                                                  #
#                           Customization of TL                                    #
#                                                                                  #
# ################################################################################ #

tl_name = "IV_PS_059"

# Variables from eCLAT
eclat = None
if "WORKSPACE" in os.environ:
    eclat = {
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

# Custom Values
custom = {
    "TL_Number": "059",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    # Values linked to the gNB
    "GNB_Friendly_TL_Name": "CV059",
    "GNB_Architecture": "CLOUD",
    "GNB_First_CellID": "50",
    "GNB_First_Cell_nrArfcn": "2056661",
    "GNB_Antiproduct": "Aiphone_L1Bypass",
    # Airphone L1 Bypass
    "APL1BP_ASIK_Addr": "10.14.55.154",
    "APL1BP_ASIK_Username": "toor4nsn",
    "APL1BP_ASIK_Password": "oZPS0POrRieRtu",
    "APL1BP_OAM_AP_Addr": "10.14.55.143",
    "APL1BP_OAM_AP_Username": "wrsroot",
    "APL1BP_OAM_AP_Password": "uteadmin",
    "APL1BP_OAM_WTS_Addr": "10.14.55.151",
    "APL1BP_OAM_WTS_Username": "ute",
    "APL1BP_OAM_WTS_Password": "ute",
    "APL1BP_cfg_filename": "basic_wts_step2.cfg",
    "APL1BP_edaemon_port": "22222",
    "APL1BP_egate_port": "10000",
}
