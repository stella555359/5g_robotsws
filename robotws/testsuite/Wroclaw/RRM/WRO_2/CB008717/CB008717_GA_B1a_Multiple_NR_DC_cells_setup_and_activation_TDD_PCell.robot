*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Library     taf.ul.ettf.retry_context

Suite Setup       Run Keywords
...               Enable C-Plane Debug Logs       with_reboot=${false}
...    AND        Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND        Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND        With Gnb Configuration          commissioning=${scfc}
...    AND        Wait Until Keyword Succeeds    3x    1s    Check Radios Availability
...    AND        Prepare Test Setup for -GA_B1a Scenario

Test Teardown     Stop Default Logging
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${egate_cfg}=           ${CURDIR}/config/CB008717_FK/cfg_FK_n78A_n257M.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_K/iphy_n78_n257_8CC_BOO_LOO.xml
${scfc}=                    scfc_GA_B1a_n78_n257_8CC_BOO_LOO.xml

*** Test Cases ***
CB008717_GA_B1a_NR_DC_SN_cell_s_setup_and_activation_in_pure_NR_DC_SN_cell_deployment_with_TDD_PCell
    Check If F1 E1 Setup and gNBDUConfigurationUpdates Occured
    Expect NGAP Setup
    Reach Onair    lua_cfg=${egate_cfg}
    Verify NGAP Setup After Reached OnAir
    Verify If Cells To Be Activated List Contains 8 FR2 Cells And PCell
    Verify If All Cells Are In Service State
    Verify Mibs and Sib after Reached Onair
    Verify If SIBs Are Not Present On FR2 Cells
