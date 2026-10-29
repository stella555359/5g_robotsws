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

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.58.16", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.14.54.155", username="wrsroot", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.54.155", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_17A")

_cbts_flavor = DeploymentFlavorStack(
    name="7_20_CLOUD5GPSIV008_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="cv08",
)

_cbts_net = DeploymentNetworkStack(
    name="7_20_CLOUD5GPSIV008_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_20_CLOUD5GPSIV008_BTS",
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
    backhaul_site_oam_ip="10.14.48.8",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.8", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.8", username="Nemuadmin", password="nemuuser"
    ),
)

_common_unit_lmp_connection = SshServiceDetails(
    addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
)

_pdu = ATEN(addr="", port_numbers=list(range(1, 9)))

_common_unit_pdu_port = PduPort(pdu=_pdu, port_no=4)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_common_unit = CommonUnit(
    lmp_connection=_common_unit_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_common_unit_pdu_port,
)

_airscale = Airscale([_common_unit])

_du = DU(airscale=_airscale)

_cbts = CloudBts(cu=_cu, cloud_deployment=_cloud_deployment, dus=[_du], vnf_name="cv08")

_epcsim = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.10.10.10", username="ute", password="ute"
    ),
    dir_path="/opt/lteemu",
    cfg_filename="basic_cfg_LteEmu.cfg",
    mme_ip="192.168.4.134",
    mcc=-1,
    mnc=-1,
    tac=-1,
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_MIN_ASIKA101_ABILA102_18A",
    cloud_hostings=[_ncir],
    core=_epcsim,
    pdus=[_pdu],
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]
# ustomization of TL                                    #

#                                                                                  #

# ################################################################################ #


tl_name = "IV_PS_008"


# Values usefull with specific Prisma library outside of taff

prismaIV = {
    "lsu_uu": "10.14.55.37",
    "lsu_s1": "10.14.55.35",
    "tstm_uu": "10.14.55.37",
    "tstm_s1": "10.14.55.35",
    "lsu_uu_username": "user",
    "lsu_uu_passwd": "user",
    "lsu_s1_username": "user",
    "lsu_s1_passwd": "user",
    "tstm_uu_username": "user",
    "tstm_uu_passwd": "user",
    "tstm_s1_username": "user",
    "tstm_s1_passwd": "user",
    "airmosaic_host": "127.0.0.1",
    "airmosaic_port": "8090",
    "airmosaic_path": "/opt/Prisma/airmosaic_lteuu/bin/airmosaic_lteuu",
    "airmosaic_cfg_path": "/opt/Prisma/CV08-Prisma_Config_Antoine_v571_2019-01-10",
    "sid_filename": "Cephalonia_NSA_FullStack_pci1_v3_bande13_4G.sid",
    "Ul_gain": "0.0",
    "Dl_gain": "21.0",
    "LSU_Uu_lineup_filename": "LSU_Uu_lineup.txt",
    "LSU_S1_lineup_filename": "LSU_S1_lineup.txt",
}


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
    "TL_Number": "008",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    # Values linked to the gNB
    "GNB_Friendly_TL_Name": "CV008",
    "GNB_Architecture": "CLOUD",
    "GNB_First_CellID": "1",
    "GNB_First_Cell_nrArfcn": "2071591",
    # iPerf configuration on DL side: VM @10.14.60.72
    "iPerf_VM_DL_ipaddress": "10.14.60.72",
    "iPerf_VM_DL_login": "ftp",
    "iPerf_VM_DL_passwd": "ftp",
    "iPerf_VM_DL_launch_command": "iperf -c 41.0.0.1 -u -i 1 -l 350 -p 5100 -b 26M -t 100000000",
    "iPerf_VM_DL_Check_on_UL_Side": "iperf -s -u -i 1 -p 5100",
    # iPerf configuration on UL side: VM @10.14.60.73
    "iPerf_VM_UL_ipaddress": "10.14.60.73",
    "iPerf_VM_UL_login": "ftp",
    "iPerf_VM_UL_passwd": "ftp",
    "iPerf_VM_UL_launch_command": "iperf -c 192.168.4.3 -u -i 1 -l 350 -p 4100 -b 5M -t 3600",
    "iPerf_VM_UL_Check_on_DL_Side": "iperf -s -u -i 1 -p 4100",
}
