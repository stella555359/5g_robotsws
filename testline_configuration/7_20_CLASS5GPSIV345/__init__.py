__maintainer__ = "Dominique Bouriot"
__team__ = "MN 5G RAN I&V 2 Pz 9 SG"
__email__ = "dominique.bouriot@nokia.com"
__owner_email__ = "dominique.bouriot@nokia.com"

import subprocess
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
from taf.config.testline.gnb.du import RU, DU
from taf.config.testline.pdu import ATEN
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit

__all__ = ["tl"]


# ################################################################################ #
#                                                                                  #
#                          TL standard definition                                  #
#                                                                                  #
# ################################################################################ #

cfg_dir = os.path.dirname(os.path.abspath(__file__))

host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.28.0.134", username="ute", password="ute"
    )
)

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.39.247", username="localuser", password="10c@1user"
    )
)


ru_pdu = ATEN(addr="10.14.62.227", port_numbers=[5])

ru = RU(
    ru_hw_group="AAHF",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziola"
    ),
    lmp_connection=SshServiceDetails(
        addr="10.14.48.240", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=ru_pdu,
)

common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
)

airscale = Airscale(common_units=[common_unit])

du = DU(airscale=airscale, rus=[ru])


cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.240", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.240", username="Nemuadmin", password="nemuuser"
    ),
)

os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

cbts = ClassicalBts(dus=[du], cu=cu)

tl_classical_topology = "CLASS_5G_PRISMAPX2_ASIKXM01_ABILX21B1_AAHF_19"

tl = TestLine(test_pc=host, gnbs=[cbts], tl_cloud_topology=tl_classical_topology)


# ################################################################################ #
#                                                                                  #
#                           Customization of TL                                    #
#                                                                                  #
# ################################################################################ #

tl_name = "IV_PS_345"

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
    "TL_Number": "345",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    # Values linked to the gNB
    "BTS_ID": "345",
    "GNB_Friendly_TL_Name": "CV345",
    "GNB_Architecture": "CLASSICAL",
    "GNB_First_CellID": "1",
    "GNB_First_Cell_nrArfcn": "646656",
    "OAM_IP_ENB1": "10.14.48.219",
    "MRBTS_ID_ENB1": "4325",
    "LNBTS_ID_ENB1": "22125",
    # "LNADJGNB_ID_ENB1": "4",
    "LTEENB_ID_ENB1": "1",
    "X2_IP_ENB1": "10.5.118.13",
    "OAM_IP_ENB2": "10.14.49.94",
    "MRBTS_ID_ENB2": "22140",
    "LNBTS_ID_ENB2": "22140",
    "LNADJGNB_ID_ENB2": "1",
    # "LTEENB_ID_ENB2": "2",
    "X2_IP_ENB2": "10.28.6.221",
    "OAM_IP_GNB": "10.14.48.240",
    "MRBTS_ID_GNB": "345",
    "NRBTS_ID_GNB": "3",
    "NRCELL_ID_GNB": "1",
    "X2_IP_GNB": "10.5.118.186",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    "GNB_Cell1_PCI": "345",
    "NetAct_IP": "10.5.119.36",
    "NetAct_username": "omc",
    "NetAct_password": "Alcatel_1",
    # QCT
    # "YAML_UE_Config": "/home/localuser/TL_Config/TL345/ue_config_tl345.yml",
    # PC UE Hawai TL345
    "UE_PC_IP": "10.14.63.208",
    "UE_PC_Login": "cv5g2_7",
    "UE_PC_Pwd": "M@r!Ne27",
    # LOCATORS FOR SELENIUM WEBUI
    "BTS_USERNAME_FIELD": "xpath:*//input[@id='applicationLoginUsername']",
    "BTS_PASSWORD_FIELD": "xpath://input[@id='applicationLoginPassword']",
    "BTS_LOGIN_BTN": "xpath://button[@id='applicationLoginButton']",
    "MAIN_CONTAINER": "xpath:/html/body/main/div",
    "SOFTWARE_SECTION": "xpath://*[@id='softwareupdate']/div[1]",
    "Logout": "xpath://*[@id='n-banner-collapse']/div[1]/ul/li[5]",
    "RU_VIEW": "xpath://div[@id='rap-module-1']",
    "RU_LED_COLOR": "xpath://div[@id='frm-1']/div[1]/div[1]/div[2]",
    "RU_LOCK": "xpath://*[@id='frm-1-lock-container']/div/div/div[1]/label",
    "RU_LOCK_CONFIRM": "xpath:/html/body/div/div/div/div[3]/div/button[1]",
    "RU_RESET_BTN": "xpath://button[@id='frm-1-reset']",
    "RU_RESET_RADIO_INPUT_SERVICE_CONTINUE": "xpath://input[@id='force-reset-false']",
    "RU_RESET_FORCE_RESET": "xpath://input[@id='force-reset-true']",
    "RU_RESET_CONFIRMATION_BTN": "xpath://button[@id='confirmation-modal-confirm']",
    "LOCK_CONFIRM": "xpath://*[@id='react-modal']/div/div[3]/div/button",
    "unlock_confirm": "xpath://*[@id='react-modal']/div/div[3]/div/button",
    "CELL_VIEW": "xpath://*[@id='site-rack-cells-1']",
    "CELL_LOCK": "xpath://*[@id='subcellgroup-0']/div/div[2]/button[1]",
    "CELL_UNLOCK": "xpath://*[@id='subcellgroup-0']/div/div[2]/button[2]",
    "CELL_LOCK_CONFIRM": "xpath:/html/body/div/div/div/div[3]/div/button[1]",
    "SNAPSHOT_COLLECTION_TAB": "xpath://*[@id='snapshot-navigation']/a",
    "SNAPSHOT_SERVER_IP": "xpath://*[@id='snapshot-server-ip-address']",
    "SNAPSHOT_PORT": "xpath://*[@id='snapshot-server-port']",
    "SNAPSHOT_PASSWORD": "xpath://*[@id='snapshot-server-password']",
    "SNAPSHOT_TARGET_FOLDER": "xpath://*[@id='snapshot-server-target-folder']",
    "SNAPSHOT_SAVE_BTN": "xpath://*[@id='snapshot-save-button']",
    "SNAPSHOT_SAVE_SERVER": "xpath://*[@id='snapshot-save-button']",
    "software_section": "xpath://*[@id='softwareupdate']/div[1]",
    "Rollback_button": "xpath://*[@id='site-rollback-button']",
    "Rollback_confirm_button": "xpath://*[@id='modal-Rollback-button-confirm']",
    "parameters_tab": "xpath://*[@id='cmeditor-navigation']",
    "commisionning_parameters_holder": "xpath://*[@id='composer-app']",
    "parameters_filter": "xpath://*[@id='cm-editor']/header/div[3]/div/input",
    "parameters_filter_value": "xpath://*[@id='cm-editor']/section/table/tbody/tr[5]/td[4]/div/div/input",
    "parameters_error_table": "xpath://*[@id='pe-errors-data-table']",
}
