*** Settings ***
Documentation    This suite contains PM test cases
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NLG_1657_2ASIL_5ABIO_1ABIA_3AHLOA_6AHFII_3AEHC

Library           OperatingSystem

Resource    ../../PM/test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot
Resource    ../../PM/test_resources/PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.robot

Suite Teardown    Linux_mapping

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
#${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
#daca se ruleaza din Single run, ENB_BUILD nu mai trebuie setat aici in suita.
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1657
${SKIP_RU_POWER_CHECK}    ${TRUE}


${COMMISSIONING_PATH}=  SEPARATOR=
    ...  /home/ute/testline_configuration/10_18_UTESRANCLOUD1657/node1/
    ...  BTS_CLOUD_SRAN_NLG_1657_2ASIL_5ABIO_1ABIA_3AHLOA_6AHFII_3AEHC_SBTS00.xml


*** Test Cases ***


PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Tags]     QC_300268
    [Setup]    Run Keywords
    ...    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Setup
    ...    AND    Modify Resource Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    ...    AND    Set Library Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    TC__PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Teardown]    Run Keywords    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PM_check_counters_after_delete_block_lock_LTE_cell
    [Tags]     QC_300269
    [Setup]    Run Keywords    Set Test Variable    ${CELL_OPERATIONS}    delete, block, lock
    ...    AND    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.TC Setup
    ...    AND    Modify Resource Search Order    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    ...    AND    Set Library Search Order    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    [Timeout]    18000
    TC__PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    [Teardown]    Run Keywords    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.TC Teardown
    ...    AND    Restore Resource Search Order



*** Keywords ***

Linux_mapping
    Run    curl -s -o linux_mapping.sh https://wrgitlab.int.net.nokia.com/adrosa/linux-mapping/-/raw/main/linux_mapping.sh?inline=false
    Run    chmod +x linux_mapping.sh
    Run    ./linux_mapping.sh
