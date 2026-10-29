__maintainer__ = "Barbier Jean-Michel"
__team__ = "MN 5G RAN I&V 1 Pz 1 SG"
__email__ = "I_UTE_NPS_5G@internal.nsn.com"


import os
import sys
import shutil
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
from taf.config.testline.ue import UE, Airphone
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline.core import EPCSim
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.legacy import SCF


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.34.41", username="ute", password="uteUTE!"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.5.114.5", username="admin", tenant="admin", password="uteadmin5G!"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.114.5", username="wrsroot", password="uteadmin5G!"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.5.114.2", username="admin", password="admin"
    ),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_17A")

_cbts_flavor = DeploymentFlavorStack(
    name="7_20_CLOUD5GPSIV051_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="cv51",
)

_cbts_net = DeploymentNetworkStack(
    name="7_20_CLOUD5GPSIV051_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_20_CLOUD5GPSIV051_BTS",
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
    backhaul_site_oam_ip="10.14.48.151",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.151", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.151", username="Nemuadmin", password="nemuuser"
    ),
)

_common_unit_lmp_connection1 = SshServiceDetails(
    addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lmp_connection2 = SshServiceDetails(
    addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
)


_pdu = ATEN(addr="10.14.55.126", port_numbers=[4, 5])

_common_unit_pdu_port1 = PduPort(pdu=_pdu, port_no=4)

_common_unit_pdu_port2 = PduPort(pdu=_pdu, port_no=5)

_capacity_unit1 = CapacityUnit(addr="192.168.253.20")

_capacity_unit2 = CapacityUnit(addr="192.168.253.20")

_common_unit1 = CommonUnit(
    lmp_connection=_common_unit_lmp_connection1,
    capacity_units=[_capacity_unit1],
    pdu_port=_common_unit_pdu_port1,
)

_common_unit2 = CommonUnit(
    lmp_connection=_common_unit_lmp_connection2,
    capacity_units=[_capacity_unit2],
    pdu_port=_common_unit_pdu_port2,
)

_airscale1 = Airscale([_common_unit1])
_airscale2 = Airscale([_common_unit2])

_du1 = DU(airscale=_airscale1)
_du2 = DU(airscale=_airscale2)

_cbts = CloudBts(
    cu=_cu, cloud_deployment=_cloud_deployment, dus=[_du1, _du2], vnf_name="cv51"
)

_epcsim = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.114.12", username="_rcpadmin", password="RCP_owner"
    ),
    dir_path="/opt/AirPhone/wts_4",
    cfg_filename="basic_cfg_LteEmu_4.cfg",
    mme_ip="10.192.4.230",
    mcc=-1,
    mnc=-1,
    tac=-1,
)
# AirPhone L2L3
_scf = SCF(project="5G19", name="SBTS5G19_5g_pid11_abil_l2rt.xml")
_ap = Airphone(
    egate=None,
    l3_ssh_connection_details=SshServiceDetails(
        addr="10.5.5.5", username="_rcpadmin", password="RCP_owner"
    ),
    l2_ssh_connection_details=None,
    l1=None,
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_MULTIDU_ASIKA101LR_ABILA101B1B4_AEUA",
    cloud_hostings=[_ncir],
    ues=[_ap],
    core=_epcsim,
    pdus=[_pdu],
)
# tl = TestlineWrapper(tl)
tl.scf = _scf


sys.path.insert(
    -1, "/mnt/titan/robotws5g/testsuite/Cloud/NPS_IV1/multi_du/resources/common"
)
__all__ = ["tl"]
# ustomization of TL                                    #

#                                                                                  #

# ################################################################################ #


tl_name = "IV_PS_051"


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
    "airmosaic_cfg_path": "/opt/Prisma/CV51-Prisma_Config_Antoine_v571_2019-01-10",
    "sid_filename": "Cephalonia_NSA_FullStack_pci1_v3_bande13_4G.sid",
    "Ul_gain": "0.0",
    "Dl_gain": "21.0",
    "LSU_Uu_lineup_filename": "LSU_Uu_lineup.txt",
    "LSU_S1_lineup_filename": "LSU_S1_lineup.txt",
}


# Variables from eCLAT

eclat = None

# ECLAT_STORAGE always set by eclat at excecution runtime...
if "ECLAT_STORAGE" in os.environ:

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
    "TL_Number": "051",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    "AP_WEBUI": "10.14.49.7",
    # Values linked to the gNB
    "GNB_Friendly_TL_Name": "CV051",
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
