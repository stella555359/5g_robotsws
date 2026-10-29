__maintainer__ = "Leo Poniard"
__team__ = "MN 5G Market Execution"
__email__ = "leo.poniard@nokia.com"

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
control = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.14.38.237",
        username="localuser",
        tenant="localuser",
        password="10c@1user",
    ),
    default_ssh_connection_details=SshServiceDetails(addr="", username="", password=""),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

ncir = NCIR(compute_nodes=[], control_nodes=[control], version="ncir_17a")

host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.38.237", username="localuser", password="10c@1user"
    )
)

ru_pdu = ATEN(addr="", port_numbers=[])

ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.3", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=[],
    radio_type="AZQL",
)

common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(addr="", username="", password=""),
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
        addr="10.14.48.225", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.225", username="Nemuadmin", password="nemuuser"
    ),
)

os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config_cv326.yml"
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

tl_name = "IV_PS_326"

target_traffic_l3 = {
    "dl_udp": "400Mbits/sec",
    "ul_udp": "30Mbits/sec",
    "dl_tcp": "400Mbits/sec",
    "ul_tcp": "30Mbits/sec",
}

netact = {
    "vm_was1_address": "10.5.119.36",
    "vm_was2_address": "10.5.119.37",
    "vm_ne3s_address": "10.5.119.34",
    "omc_user": "omc",
    "omc_password": "Alcatel_1",
    "root_password": "Alcatel_1",
    "gui_url": "https://ivrrmlab.ivrrm.noklab.net",
    "gui_user": "omc",
    "gui_password": "Alcatel_1",
    "maintenance_region": "france",
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
    "TL_Number": "326",
    "PATH_Tools": PATH_Tools,
    "PATH_Storage": PATH_Storage,
    "eclat": eclat,
    # Values linked to the gNB
    "BTS_ID": "326",
    "GNB_Friendly_TL_Name": "CV326",
    "GNB_Architecture": "CLASSICAL",
    "GNB_First_CellID": "1",
    "GNB_First_Cell_nrArfcn": "646700",
    # IPERF CONF ON DL SIDE : SERVER SIDE
    "iPerf_VM_DL_ipaddress": "10.14.42.99",
    "iPerf_VM_DL_login": "ran5g",
    "iPerf_VM_DL_passwd": "nokia2018",
    "iPerf_VM_DL_launch_command": "iperf -c 172.10.1.41 -u -b 1000M -p 5410 -i 1 -t 999999 -l 1350",
    "iPerf_VM_DL_Check_on_UL_Side": "",
    # Power switch
    "PDU_IP": "10.28.1.100",
    "PDU_5G_PORT": "5",
    "PDU_4G_PORT": "2",
    # LOCATORS FOR SELENIUM WEBUI
    "BTS_USERNAME_FIELD": "xpath:*//input[@id='applicationLoginUsername']",
    "BTS_PASSWORD_FIELD": "xpath://input[@id='applicationLoginPassword']",
    "BTS_LOGIN_BTN": "xpath://button[@id='applicationLoginButton']",
    "BTS_Path": "MRBTS-320/NRBTS-23143",
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
# Custom variable TL_Number '321' in dictionary Custom = custom['TL_Number']
