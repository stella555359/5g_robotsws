*** Settings ***
Documentation    This suite contains PM test cases
Force Tags    QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NLWG_1746_1ASIM_2ABIA_1ABIO_1FXED_1FRGU_2AHFIB  STATE_COMMISSIONED
Library       XML  use_lxml=True

Resource    ../../PM/test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot
Resource    ../../PM/test_resources/PM__NE3S_Interface_Setup_In_Startup.robot


Suite Teardown    Linux_mapping

*** Variables ***
${SCF_ID}                01
${HW_LOCATION_CODE}      Timisoara
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1746/commissioning
${REQUEST_SCF_SCOUT}     ${TRUE}
${SCOUT_TL_NAME}         10_18_UTESRANCLOUD1746


*** Test Cases ***

[1]PM__NE3S_Interface_Setup_In_Startup
    [Tags]     QC_281634
    [Setup]    Run Keywords    PM__NE3S_Interface_Setup_In_Startup.TC Setup
    ...    AND    Modify Resource Search Order    PM__NE3S_Interface_Setup_In_Startup
    ...    AND    Set Library Search Order    PM__NE3S_Interface_Setup_In_Startup
    TC__PM__NE3S_Interface_Setup_In_Startup
    [Teardown]    Run Keywords    PM__NE3S_Interface_Setup_In_Startup.TC Teardown
    ...    AND    Restore Resource Search Order


PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Tags]     QC_281633
    [Setup]    Run Keywords
    ...    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Setup
    ...    AND    Modify Resource Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    ...    AND    Set Library Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Timeout]    21600
    TC__PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Teardown]    Run Keywords    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Teardown
    ...    AND    Restore Resource Search Order
*** Keywords ***

Linux_mapping
    Run    curl -s -o linux_mapping.sh https://wrgitlab.int.net.nokia.com/adrosa/linux-mapping/-/raw/main/linux_mapping.sh?inline=false
    Run    chmod +x linux_mapping.sh
    Run    ./linux_mapping.sh

