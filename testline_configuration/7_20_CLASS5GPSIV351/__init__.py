__maintainer__ = "Heurtault Amaury"
__team__ = "MN 5G&SC Pz 5G I&V 2 7 SG"
__email__ = "amaury.heurtault@nokia.com"
__owner_email__ = "amaury.heurtault@nokia.com"

import os
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline import RU, DU
from taf.config.testline.pdu import ATEN
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit

__all__ = ["tl"]


# ################################################################################ #
#                                                                                  #
#                          TL standard definition                                  #
#                                                                                  #
# ################################################################################ #

cfg_dir = os.path.dirname(os.path.abspath(__file__))
control = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.14.55.26", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.55.26", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

ncir = NCIR(compute_nodes=[], control_nodes=[control], version="ncir_17a")

host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.38.203", username="localuser", password="10c@1user"
    )
)

ru_pdu = ATEN(addr="10.14.62.192", port_numbers=[7, 6])

ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziola"
    ),
    lmp_connection=SshServiceDetails(
        addr="10.14.48.213", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=7,
    radio_type="AAHF",
)

common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.14.48.42", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
)

airscale = Airscale(common_units=[common_unit])

du = DU(airscale=airscale, rus=[ru])

cbts_flavor = DeploymentFlavorStack(
    name="cbtsflavor",
    env_files=[os.path.join(cfg_dir, "config_flavor.env")],
    yaml_file=os.path.join(cfg_dir, "config_flavor.yaml"),
    default_vnf_prefix="cbts_prefix",
)

cbts_net = DeploymentNetworkStack(
    name="ext_net",
    env_files=[os.path.join(cfg_dir, "config_ext_net.env")],
    yaml_file=os.path.join(cfg_dir, "config_ext_net.yaml"),
)

cbts_vnf = DeploymentVnfStack(
    name="cbts_deploy",
    env_files=[os.path.join(cfg_dir, "config_bts.env")],
    yaml_file=os.path.join(cfg_dir, "config_bts.yaml"),
)

cu = CU(
    backhaul_site_oam_ip="",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.213", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="10.14.48.213"),
)
# OAM_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr

cloud_deployment = CloudDeployment(
    default_cfg_dir=cfg_dir,
    flavors=[cbts_flavor],
    networks=[cbts_net],
    vnfs=[cbts_vnf],
    cloud_hosting=ncir,
)

cbts = CloudBts(dus=[du], cu=cu, cloud_deployment=cloud_deployment, vnf_name="5gbts")

tl_cloud_topology = "CLOUD_5G_PRISMAPX2_ASIKX42L_ABILX21B1_AEUA_18A"

tl = TestLine(
    test_pc=host,
    gnbs=[cbts],
    cloud_hostings=[ncir],
    tl_cloud_topology=tl_cloud_topology,
)


# ################################################################################ #
#                                                                                  #
#                           Customization of TL                                    #
#                                                                                  #
# ################################################################################ #

tl_name = "IV_PS_351"

# Values usefull with specific Prisma library outside of taff
prismaIV = {
    "lsu_uu": "10.14.63.118",
    #'lsu_s1': '10.14.34.205', # pas utiliser
    "tstm_uu": "10.14.63.78",
    #'tstm_s1': '10.14.34.205', #pas utiliser
    "lsu_uu_username": "user",
    "lsu_uu_passwd": "user",
    "lsu_s1_username": "user",
    "lsu_s1_passwd": "user",
    "tstm_uu_username": "user",
    "tstm_uu_passwd": "user",
    "tstm_s1_username": "user",
    "tstm_s1_passwd": "user",
    "airmosaic_host": "10.14.38.218",
    "airmosaic_port": "22",
    "airmosaic_path": "/home/localuser/prisma/airmosaic_lteuu",
    "airmosaic_cfg_path": "/home/localuser/prisma/conf/Sid&Scenarios",
    "sid_filename": "TL323_Alonisos_fullstack.sid",
    "scenario_prisma": "2.5MS_ue_attach_fullstack_ippass_OLD.sce",
    "Ul_gain": "5.00",
    "Dl_gain": "26.00",
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
    "TL_Number": "351",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    # Values linked to the gNB
    "BTS_ID": "1900",
    "GNB_Friendly_TL_Name": "CV351",
    "GNB_Architecture": "CLASSICAL",
    "GNB_First_CellID": "1",
    "GNB_First_Cell_nrArfcn": "517980",
    # IPERF CONF ON DL SIDE : SERVER SIDE
    "iPerf_VM_DL_ipaddress": "10.14.42.99",
    "iPerf_VM_DL_login": "ran5g",
    "iPerf_VM_DL_passwd": "nokia2018",
    "iPerf_VM_DL_launch_command": "iperf -c 172.10.1.41 -u -b 1000M -p 5410 -i 1 -t 999999 -l 1350",
    "iPerf_VM_DL_Check_on_UL_Side": "",
}
# Custom variable TL_Number '321' in dictionary Custom = custom['TL_Number']
