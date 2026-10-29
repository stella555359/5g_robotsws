*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  BTS_CLOUD_SRAN_L_10757_1ASIB_2ABIC_3AEHC  STATE_COMMISSIONED
Library           XML  use_lxml=True


Resource    ../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG05/PM/PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot

Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1339
${SKIP_RU_POWER_CHECK}    ${TRUE}


${COMMISSIONING_PATH}=    SEPARATOR=
...  /home/ute/testline_configuration/10_18_UTESRANCLOUD1757/node1/BTS_CLOUD_SRAN_L_10757_1ASIB_2ABIC_3AEHC_SBTS24R2.xml

${LTE_MEASUREMENT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5021_Libra/counters/
    ...  SBTS19A__LTE_Counters_2019-07-01.csv

${LTE_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5021_Libra/counters/LTE_Abbreviations.csv



*** Test Cases ***
[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]     QC_99622
    [Setup]    Run Keywords    Set Test Variable    ${MEASUREMENT_PATH}    ${LTE_MEASUREMENT_PATH}
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}    ${LTE_ABBREVIATION_DICT_PATH}
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    AirScale_SBTS,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    Set Library Search Order    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4291', ' alarmId ', '7651']]
    [Timeout]    14400
    TC__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order


