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
        addr="", username="ute", password="ute"
    )
)

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.39.107", username="localuser", password="10c@1user"
    )
)


ru_pdu = ATEN(addr="10.14.62.227", port_numbers=[1])

ru = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziola"
    ),
    lmp_connection=SshServiceDetails(
        addr="10.14.49.130", username="toor4nsn", password="oZPS0POrRieRtu"
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
        addr="10.14.49.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.49.130", username="Nemuadmin", password="nemuuser"
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

tl_name = "IV_PS_346"

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
    PATH_TL_Config = os.environ["TL_PATH_CONFIG"]
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
    PATH_TL_Config = "%s/TL_Config" % (os.environ["HOME"])
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
        "TL_PATH_CONFIG": PATH_TL_Config,
        "TESTCASE_PATH": "",
    }

# Custom Values
custom = {
    "TL_Number": "346",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "PATH_TL_Config": PATH_TL_Config,
    "eclat": eclat,
    # Values linked to the gNB
    "BTS_Path": "MRBTS-346/NRBTS-346",
    "BTS_ID": "346",
    "GNB_Friendly_TL_Name": "TL346",
    "GNB_Architecture": "CLASSICAL",
    "UE_Architecture": "QCT",
    "eNB_Architecture": "REAL",
    "Core_Architecture": "REAL",
    "GNB_First_CellID": "1",
    "GNB_First_Cell_nrArfcn": "643296",
    "GNB_X2_IP": "10.28.14.249",
    # Values specific to PCMD Feature 5GC001804-B
    "CA4MN_IP": "10.75.189.39",
    "CA4MN_Port": "48151",
    "NetAct_IP": "10.5.119.36",  # NetAct server, VM16
    "NetAct_username": "omc",
    "NetAct_password": "Alcatel_1",
    "PLMN": "PLMN-PLMN",
    "cellIdentity": "00:05:68:00:10",  # HEX ( 16  * ( 16384 * 23165 + 16383 ) )
    "plmn_Identity": "45:f0:10",  # MCC 540 - MNC 01
    "gnb_id": "00:05:68",  # HEX( 4 * 23165 )
    # Values linked to the LTE
    "OAM_IP_LTE": "10.14.49.66",
    "interface_telecom": "br1.3002",
    # IPERF CONF ON DL SIDE : SERVER SIDE
    "iPerf_VM_DL_ipaddress": "10.14.42.228",
    "iPerf_VM_DL_login": "ran5g",
    "iPerf_VM_DL_passwd": "nokia2018",
    "iPerf_VM_DL_launch_command": "iperf -c 172.70.4.0 -u -i1 -t 60 -p5050 -l 1350 -b 200M",
    "iPerf_VM_DL_Check_on_UL_Side": "",
    # DIRS for scf
    "scf_dir": "scf",
    # Power switch
    "PDU_IP": "10.14.62.227",
    "PDU_5G_PORT": "5",
    "PDU_4G_PORT": "5",
    # QCT
    # "YAML_AT_UE_Config": "/home/localuser/Jenkins/workspace/7_20_CLASS5GPSIV346/testline_configuration_5G/7_20_CLASS5GPSIV346/ue_config.yaml",
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
    "RU_TYPE": "AAHF",
    "RU_1_PDU_IP": "10.28.1.94",
    "RU_1_PDU_PORT": "1",
    "RU_1_PDU_ID": "1",
    "sw_build_name_upgrade": "5G19A_FSMK_0006_008451_000756",
    "ABIL1_slot": "1",
    "UE_CAPABILITY": "REAL_QUALCOMM_UE",
}
# Custom variable TL_Number "346" in dictionary Custom = custom["TL_Number"]
