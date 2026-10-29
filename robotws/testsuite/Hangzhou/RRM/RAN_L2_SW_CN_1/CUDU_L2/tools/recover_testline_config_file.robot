*** Settings ***
Documentation
Resource         ./../common_setup_teardown.robot
*** Variables ***
${config_path}    /home/ute/.ute-ca/executions/1/configs/topology_configs/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ/
#${config_path}    /home/ute/CNI_2023/config/
*** Test Cases ***
Recover User Specific Config Files
    [Tags]    folder
    Set Suite Variable    ${gnb_swconfig_file}    ${config_path}/swconfig_gnb.txt
    Set Suite Variable    ${ap_swconfig_file}    ${config_path}/swconfig_ap.txt
    Set Suite Variable    ${ap_iphy_file}    ${config_path}/iphy.xml
    Set Suite Variable    ${gnb_scf_file}    ${config_path}/scfc.xml
    Set Suite Variable    ${wts_cfg_file}    ${config_path}/basic_setup.cfg
    Recover Testline
    Reboot TL And Check Configured

*** Keywords ***
Recover Testline
    Import Testline Variables
    Send Swconfig for GNB    ${gnb_swconfig_file}
    Send Swconfig for AP    ${ap_swconfig_file}
    Modify IPHY File And Send to Airphone    ${ap_iphy_file}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML    ${ap_iphy_file}
    Full Commission With SCF File    ${gnb_scf_file}    auto_update=False
    Run    cp ${wts_cfg_file} /opt/iphy/latest/basic_setup.cfg

