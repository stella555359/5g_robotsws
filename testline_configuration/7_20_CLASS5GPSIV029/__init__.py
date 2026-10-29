__maintainer__ = "Jourdain Remi"
__team__ = "MN 5G&SC Pz 5G I&V 2 2 SG"
__email__ = "remi.jourdain@nokia.com"
__owner_email__ = "remi.jourdain@nokia.com"

import os
import shutil

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
        ip_addr="10.14.54.176", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.29", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.14.54.172", username="admin", password="uteadmin"
    ),
)

ncir = NCIR(compute_nodes=[], control_nodes=[control], version="ncir_17a")

host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.54.188", username="localuser", password="10c@1user"
    )
)

ru_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])

ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.1.5", username="root", password="umniedziela"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=ru_pdu.pdu_ports[1],
)

common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
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
    backhaul_site_oam_ip="10.14.48.29",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.29", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="10.14.48.29"),
)

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

tl_name = "IV_PS_029"

# Values useful with specific Prisma library outside of taf
prismaIV = {
    "lsu_uu": "10.5.114.188",
    "tstm_uu": "10.5.114.188",
    "tstm_s1": "None",
    "lsu_s1": "None",
    "lsu_uu_username": "user",
    "lsu_uu_passwd": "user",
    "tstm_uu_username": "user",
    "tstm_uu_passwd": "user",
    "airmosaic_host": "127.0.0.1",
    "airmosaic_port": "8090",
    "airmosaic_path": "/opt/Prisma/airmosaic_lteuu/bin/airmosaic_lteuu",
    "airmosaic_cfg_path": "/opt/Prisma/CV29_Prisma_Config/config_files",
    "sid_filename": "CV29.sid",
    "scenario_prisma": "CV29.sce",
    "Ul_gain": "20.0",
    "Dl_gain": "41.0",
}

# Variables for iPerf

iPerf_Config = {
    "PublicIPTrafficServerDL": "10.14.58.83",
    "CoreIPTrafficServerDL": "10.201.0.3",
    "userDL": "ute",
    "pwDL": "uteadmin",
    "userUL": "ftp",
    "pwUL": "ftp",
    "TrafficServerUL": "10.14.57.193",
    "UEList": [
        {
            "UL_addr": "192.168.29.2",
            "UL_port": "51006",
            "DL_addr": "41.0.0.1",
            "DL_port": "51140",
        },
        {
            "UL_addr": "192.168.29.3",
            "UL_port": "52006",
            "DL_addr": "41.0.0.2",
            "DL_port": "51240",
        },
        {
            "UL_addr": "192.168.29.4",
            "UL_port": "53006",
            "DL_addr": "41.0.0.3",
            "DL_port": "51340",
        },
        {
            "UL_addr": "192.168.29.5",
            "UL_port": "54006",
            "DL_addr": "41.0.0.4",
            "DL_port": "51441",
        },
        {
            "UL_addr": "192.168.29.6",
            "UL_port": "55006",
            "DL_addr": "41.0.0.5",
            "DL_port": "51542",
        },
        {
            "UL_addr": "192.168.29.7",
            "UL_port": "56006",
            "DL_addr": "41.0.0.6",
            "DL_port": "51641",
        },
        {
            "UL_addr": "192.168.29.8",
            "UL_port": "57006",
            "DL_addr": "41.0.0.7",
            "DL_port": "51740",
        },
        {
            "UL_addr": "192.168.29.9",
            "UL_port": "58006",
            "DL_addr": "41.0.0.8",
            "DL_port": "51840",
        },
    ],
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
    "TL_Number": "029",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    # Values linked to the gNB
    "BTS_ID": "1900",
    "GNB_Friendly_TL_Name": "CV029",
    "GNB_Architecture": "CLASSICAL",
    "GNB_First_CellID": "1",
    "GNB_First_Cell_nrArfcn": "2071592",
}
