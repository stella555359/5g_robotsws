*** Settings ***
Documentation    This suite contains PM test cases
Force Tags    QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NLWG_1746_1ASIM_2ABIA_1ABIO_1FXED_1FRGU_2AHFIB  STATE_COMMISSIONED
Library       XML  use_lxml=True

Resource    ../../PM/test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot
Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.robot
Resource    ../../ONAP/test_resources/PANO__5GC001104_A_13_Suppression_of_zero_values.robot
Resource    ../../PM/test_resources/PM__NE3S_Interface_Setup_In_Startup.robot

Suite Teardown    Linux_mapping

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1746
${SKIP_RU_POWER_CHECK}    ${TRUE}
${VM_WITH_PANO_IP}       10.5.47.47
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   UTE.debian12
${VES_PORT}              30510
${ADDITIONAL_IGNORED_ALARMS}  [['faultId', '4639', ' alarmId ', '7115']]
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1676/commissioning

*** Test Cases ***

[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Tags]     QC_281621
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Teardown
    ...    AND    Restore Resource Search Order

PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Tags]     QC_281620
    [Setup]    Run Keywords
    ...    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Setup
    ...    AND    Modify Resource Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    ...    AND    Set Library Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Timeout]    21600
    TC__PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Teardown]    Run Keywords    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Tags]     QC_281622
    [Setup]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    ...    AND    Set Library Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    [Timeout]    14400
    TC__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Teardown]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Teardown
    ...    AND    Restore Resource Search Order

[1]PM__NE3S_Interface_Setup_In_Startup
    [Tags]     QC_281619
    [Setup]    Run Keywords    PM__NE3S_Interface_Setup_In_Startup.TC Setup
    ...    AND    Modify Resource Search Order    PM__NE3S_Interface_Setup_In_Startup
    ...    AND    Set Library Search Order    PM__NE3S_Interface_Setup_In_Startup
    TC__PM__NE3S_Interface_Setup_In_Startup
    [Teardown]    Run Keywords    PM__NE3S_Interface_Setup_In_Startup.TC Teardown
    ...    AND    Restore Resource Search Order



*** Keywords ***

Linux_mapping
    Run    curl -s -o linux_mapping.sh https://wrgitlab.int.net.nokia.com/adrosa/linux-mapping/-/raw/main/linux_mapping.sh?inline=false
    Run    chmod +x linux_mapping.sh
    Run    ./linux_mapping.sh

