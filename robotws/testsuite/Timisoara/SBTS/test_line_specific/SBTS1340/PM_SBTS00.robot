*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NL_10340_1ASOE_2FRHC  STATE_COMMISSIONED
Library           XML  use_lxml=True
Documentation    Robot Test Suite
Resource    ../../PM/test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot
Resource    ../../PM/test_resources/PM__NE3S_Interface_Setup_In_Startup.robot
Resource    ../../PM/test_resources/PM__SFP_Dynamic_Data.robot
Resource    ../../PM/test_resources/PM__Result_File_Retrieval_Failure.robot
Resource    ../../PM/test_resources/PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min.robot
Resource    ../../PM/test_resources/PM__Measurements_Interval_Change_From_Longer_To_Shorter.robot
Resource    ../../PM/test_resources/PM__Check_Temperature_Counters.robot
Resource    ../../PM/test_resources/PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used.robot
Resource    ../../PM/test_resources/PM__Check_Counters_Number_On_NetAct_Reports.robot
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1340
${SKIP_RU_POWER_CHECK}    ${TRUE}
${COLLECT_SNAPSHOT_FLAG}    ${FALSE}


${PM__LTE_counters_ABBREVIATION_DICT_PATH}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       LTE_Abbreviations.csv

${PM__LTE_M804x_MEASUREMENT_PATH}             SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       M8046_M8047_M8048_2021-02-05.csv

${PM__WBTS19_counters_MEASUREMENT_PATH}       SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       SBTS_WBTS19_selected_groups_0207.csv

${PM__SBTS19A_LTE_MEASUREMENT_PATH}           SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       SBTS19A__LTE_Counters_2019-07-01.csv

${PM__SBTS19A_counters_MEASUREMENT_PATH}      SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       SBTS19A_Counters_2019-07-01_limited.csv

${PM__TNL_counters_ABBREVIATION_DICT_PATH}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       TNL_Abbreviations.csv

${PM__TNL_counters_MEASUREMENT_PATH}          SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       TNL_NIDD_target_TRUNK.csv

${PM__TRS_counters_MEASUREMENT_PATH}          SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       TRS_NIDD_2019-03-28.csv

${PM__WBTS_M5015_counters_MEASUREMENT_PATH}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                      WBTS_M5015_CountersWithoutMetaData_2020-08-07.csv

${PM__WCDMA_counters_ABBREVIATION_DICT_PATH}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       WCDMA_Abbreviations.csv

${PM__NR_MEASUREMENT_PATH}                   SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       SBTS24R3_NR_Counters_10340.csv

${PM__NR_counters_ABBREVIATION_DICT_PATH}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       NR_Abbreviations.csv





*** Test Cases ***
PM__Check_Counters_Number_On_NetAct_Reports
    [Tags]     QC_274892
    [Setup]    Run Keywords
    ...    Set Test Variable    ${WEB_URL}    srnclab2010lbwas.srnblr.nsn-rdnet.net
    ...    AND    Set Test Variable    ${CMWAS_SERVICE_IP}    10.82.47.125
    ...    AND    PM__Check_Counters_Number_On_NetAct_Reports.TC Setup
    ...    AND    Modify Resource Search Order    PM__Check_Counters_Number_On_NetAct_Reports
    ...    AND    Set Library Search Order    PM__Check_Counters_Number_On_NetAct_Reports
    TC__PM__Check_Counters_Number_On_NetAct_Reports
    [Teardown]    Run Keywords    PM__Check_Counters_Number_On_NetAct_Reports.TC Teardown
    ...    AND    Restore Resource Search Order



[1]PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Tags]     QC_133653
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Setup
    ...    AND    Modify Resource Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    TC__PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Teardown]    Run Keywords    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Teardown
    ...    AND    Restore Resource Search Order



[1]PM__Check_Temperature_Counters
    [Tags]    QC_216813
    [Setup]    Run Keywords    PM__Check_Temperature_Counters.TC Setup
    ...    AND    Modify Resource Search Order    PM__Check_Temperature_Counters
    ...    AND    Set Library Search Order    PM__Check_Temperature_Counters
    [Timeout]    14400
    TC__PM__Check_Temperature_Counters
    [Teardown]    Run Keywords    PM__Check_Temperature_Counters.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min
    [Tags]     QC_216810
    [Setup]    Run Keywords    Set Test Variable     ${NEW_ReportingInterval}    30min
    ...    AND    PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min.TC Setup
    ...    AND    Modify Resource Search Order    PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min
    ...    AND    Set Library Search Order    PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min
    [Timeout]    14400
    TC__PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min
    [Teardown]    Run Keywords    PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min.TC Teardown
    ...    AND    Restore Resource Search Order



[1]PM__Result_File_Retrieval_Failure
    [Tags]     QC_177256
    [Setup]    Run Keywords    PM__Result_File_Retrieval_Failure.TC Setup
    ...    AND    Modify Resource Search Order    PM__Result_File_Retrieval_Failure
    ...    AND    Set Library Search Order    PM__Result_File_Retrieval_Failure
    TC__PM__Result_File_Retrieval_Failure
    [Teardown]    Run Keywords    PM__Result_File_Retrieval_Failure.TC Teardown
    ...    AND    Restore Resource Search Order