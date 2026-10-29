__maintainer__ = "nobody"
__team__ = "MN 5G&SC Pz 5G I&V 2 2 SG"
__email__ = "patrick.pm.moreau@nokia.com"
__owner_email__ = "patrick.pm.moreau@nokia.com"

import os
import shutil

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.du import RU, DU
from taf.config.testline.pdu import ATEN
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.gnb import CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

__all__ = ["tl"]

# ################################################################################ #
#                                                                                  #
#                          TL standard definition                                  #
#                                                                                  #
# ################################################################################ #

cfg_dir = os.path.dirname(os.path.abspath(__file__))


host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.28.0.89", username="ute", password="ute"
    )
)
# A mettre à jour
gNB_pdu = ATEN(addr="10.14.48.13", port_numbers=[1])
eNB_pdu = ATEN(addr="10.14.49.39", port_numbers=[2])
ru_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])
ues_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])

ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.1.5", username="root", password="umniedziela"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziela"
    ),
    pdu_port=ru_pdu.pdu_ports[1],
)

capacity_unit = CapacityUnit(addr="192.168.253.20")

common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.14.63.114", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[capacity_unit],
)

airscale = Airscale(common_units=[common_unit])

du = DU(airscale=airscale, rus=[ru])


cu = CU(
    backhaul_site_oam_ip="10.14.48.13",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.13", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.13", username="Nemuadmin", password="nemuuser"
    ),
)


cbts = ClassicalBts(
    dus=[du],
    cu=cu,
)

tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIKA101L_ABILA101B1B2_AEUA_ENB"

tl = TestLine(test_pc=host, gnbs=[cbts], tl_cloud_topology=tl_cloud_topology)


# ################################################################################ #
#                                                                                  #
#                           Customization of TL                                    #
#                                                                                  #
# ################################################################################ #

tl_name = "IV_PS_361"

# Values useful with specific Prisma library outside of taf
prismaIV = {
    "lsu_uu": "10.5.115.109",
    "tstm_uu": "10.5.115.109",
    "tstm_s1": "10.5.115.96",
    "lsu_s1": "10.5.115.96",
    "lsu_uu_username": "user",
    "lsu_uu_passwd": "user",
    "tstm_uu_username": "user",
    "tstm_uu_passwd": "user",
    "airmosaic_host": "127.0.0.1",
    "airmosaic_port": "8090",
    "airmosaic_path": "/home/ute/Prisma/airmosaic_lteuu/bin/airmosaic_lteuu",
    "airmosaic_cfg_path": "/home/ute/Prisma/cfg/",
    "sid_filename": "CV13_Santorin_v7.1.1_28GHz.sid",
    "scenario_prisma": "CV13.sce",
    "Ul_gain": "20.0",
    "Dl_gain": "41.0",
}

# Variables for iPerf

iPerf_Config = {
    "PublicIPTrafficServerDL": "10.14.42.113",
    "CoreIPTrafficServerDL": "192.168.2.114",  # tbd
    "userDL": "ftp",
    "pwDL": "ftp",
    "userUL": "ftp",
    "pwUL": "ftp",
    "TrafficServerUL": "192.168.5.2",  # tbd
    "PublicIPTrafficServerUL": "10.14.42.114",
    "UEList": [
        {
            "UL_addr": "192.168.5.3",
            "UL_port": "5161",
            "DL_addr": "42.0.0.1",
            "DL_port": "5261",
        },
        {
            "UL_addr": "192.168.5.4",
            "UL_port": "5162",
            "DL_addr": "42.0.0.2",
            "DL_port": "5262",
        },
        {
            "UL_addr": "192.168.5.5",
            "UL_port": "5163",
            "DL_addr": "42.0.0.3",
            "DL_port": "5263",
        },
        {
            "UL_addr": "192.168.5.6",
            "UL_port": "5164",
            "DL_addr": "42.0.0.4",
            "DL_port": "5264",
        },
        {
            "UL_addr": "192.168.5.7",
            "UL_port": "5165",
            "DL_addr": "42.0.0.5",
            "DL_port": "5265",
        },
        {
            "UL_addr": "192.168.5.8",
            "UL_port": "5166",
            "DL_addr": "42.0.0.6",
            "DL_port": "5266",
        },
        {
            "UL_addr": "192.168.5.9",
            "UL_port": "5167",
            "DL_addr": "42.0.0.7",
            "DL_port": "5267",
        },
        {
            "UL_addr": "192.168.5.10",
            "UL_port": "5168",
            "DL_addr": "42.0.0.8",
            "DL_port": "5268",
        },
        {
            "UL_addr": "192.168.5.11",
            "UL_port": "5169",
            "DL_addr": "42.0.0.9",
            "DL_port": "5269",
        },
        {
            "UL_addr": "192.168.5.12",
            "UL_port": "5170",
            "DL_addr": "42.0.0.10",
            "DL_port": "5270",
        },
        {
            "UL_addr": "192.168.5.13",
            "UL_port": "5171",
            "DL_addr": "42.0.0.11",
            "DL_port": "5271",
        },
        {
            "UL_addr": "192.168.5.14",
            "UL_port": "5172",
            "DL_addr": "42.0.0.12",
            "DL_port": "5272",
        },
        {
            "UL_addr": "192.168.5.15",
            "UL_port": "5173",
            "DL_addr": "42.0.0.13",
            "DL_port": "5273",
        },
        {
            "UL_addr": "192.168.5.16",
            "UL_port": "5174",
            "DL_addr": "42.0.0.14",
            "DL_port": "5274",
        },
        {
            "UL_addr": "192.168.5.17",
            "UL_port": "5175",
            "DL_addr": "42.0.0.15",
            "DL_port": "5275",
        },
        {
            "UL_addr": "192.168.5.18",
            "UL_port": "5176",
            "DL_addr": "42.0.0.16",
            "DL_port": "5276",
        },
        {
            "UL_addr": "192.168.5.19",
            "UL_port": "5177",
            "DL_addr": "42.0.0.17",
            "DL_port": "5277",
        },
        {
            "UL_addr": "192.168.5.20",
            "UL_port": "5178",
            "DL_addr": "42.0.0.18",
            "DL_port": "5278",
        },
        {
            "UL_addr": "192.168.5.21",
            "UL_port": "5179",
            "DL_addr": "42.0.0.19",
            "DL_port": "5279",
        },
        {
            "UL_addr": "192.168.5.22",
            "UL_port": "5180",
            "DL_addr": "42.0.0.20",
            "DL_port": "5280",
        },
        {
            "UL_addr": "192.168.5.23",
            "UL_port": "5181",
            "DL_addr": "42.0.0.21",
            "DL_port": "5281",
        },
        {
            "UL_addr": "192.168.5.24",
            "UL_port": "5182",
            "DL_addr": "42.0.0.22",
            "DL_port": "5282",
        },
        {
            "UL_addr": "192.168.5.25",
            "UL_port": "5183",
            "DL_addr": "42.0.0.23",
            "DL_port": "5283",
        },
        {
            "UL_addr": "192.168.5.26",
            "UL_port": "5184",
            "DL_addr": "42.0.0.24",
            "DL_port": "5284",
        },
        {
            "UL_addr": "192.168.5.27",
            "UL_port": "5185",
            "DL_addr": "42.0.0.25",
            "DL_port": "5285",
        },
        {
            "UL_addr": "192.168.5.28",
            "UL_port": "5186",
            "DL_addr": "42.0.0.26",
            "DL_port": "5286",
        },
        {
            "UL_addr": "192.168.5.29",
            "UL_port": "5187",
            "DL_addr": "42.0.0.27",
            "DL_port": "5287",
        },
        {
            "UL_addr": "192.168.5.30",
            "UL_port": "5188",
            "DL_addr": "42.0.0.28",
            "DL_port": "5288",
        },
        {
            "UL_addr": "192.168.5.31",
            "UL_port": "5189",
            "DL_addr": "42.0.0.29",
            "DL_port": "5289",
        },
        {
            "UL_addr": "192.168.5.32",
            "UL_port": "5190",
            "DL_addr": "42.0.0.30",
            "DL_port": "5290",
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
    "TL_Number": "361",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    # Values linked to the gNB
    "BTS_ID": "1900",
    "GNB_Friendly_TL_Name": "CV361",
    "GNB_Architecture": "CLASSICAL",
    "GNB_First_CellID": "1",
    "GNB_First_Cell_nrArfcn": "2071592",
}
