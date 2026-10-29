*** Settings ***
Documentation    This suite contains PM test cases
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NLWG_10423_2ASIL_2ABIA_1ABIO_1ABIQ_1ABIN_1ABIP_2FXDB_1FRGU_1FRME_2FXED_3AHEGB
Library           OperatingSystem


Resource    ../../PM/test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot

Suite Teardown    Linux_mapping

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
#${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
#daca se ruleaza din Single run, ENB_BUILD nu mai trebuie setat aici in suita.
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1423
${SKIP_RU_POWER_CHECK}    ${TRUE}


${COMMISSIONING_PATH}=  SEPARATOR=
    ...  /home/ute/testline_configuration/10_18_UTESRANCLOUD1423/node1/
    ...  BTS_CLOUD_SRAN_NLWG_10423_2ASIL_2ABIA_1ABIO_1ABIQ_1ABIN_1ABIP_2FXDB_1FRGU_1FRME_2FXED_3AHEGB_SBTS00.xml


*** Test Cases ***

PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Tags]     QC_133687
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