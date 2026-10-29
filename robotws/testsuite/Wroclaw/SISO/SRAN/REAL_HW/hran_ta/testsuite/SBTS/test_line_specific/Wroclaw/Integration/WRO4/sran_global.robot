*** Settings ***
Documentation
...    Test Suite Author: Mateusz Kawka
...    Test Suite Owner: Roksana Spychala

Resource          ../../../../test_resources/BS-RF/SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked.robot
Resource          ../../../../test_resources/BS-RF/SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair.robot
Resource          ../../../../test_resources/BS-RF/SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.robot
Library           ../../../../../../resources/ca_BSRF_excel_operation.py  WITH NAME  excel

Suite Setup
...  excel.Create Excel File  ${REPORT_NAME}   ${PATH_TO_REPORT_FILE}  sheet_name=${MAIN_SHEET_NAME}  headers=MRAT

*** Variables ***
${COMMISSIONING_PATH}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/
...  hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/Manual_team/WRO4/SCF/SRAN_Global_SIMPLIFIED_features_23R2_ON.xml
${PATH_TO_REPORT_FILE}     /home/ute/logi_EEM/Sran_Global
${REPORT_NAME}             EEM_REPORT_SRAN_GLOBAL
${MAIN_SHEET_NAME}         SRAN_GLOBAL
${BTS_MPLANE_IP}           10.42.24.98
${BTS_ID}                  1235

*** Test Cases ***

[1]SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair_MRAT
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    onAir_MRAT
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair.TC Teardown


Append Next Row To Excel File
    ${data_list}  Create List  Simplified
    Append Next Row To Excel File  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  list_of_data=${data_list}

[1] Perform Recommissioning For Simplified
     [Setup]  admin.Setup Admin  bts_host=${BTS_MPLANE_IP}  admin_api_log_dir=${OUTPUT_DIR}/AdminAPI_logs
     admin.Perform Commissioning
     ...  bts_id=${BTS_ID}
     ...  scf_file=${COMMISSIONING_PATH}
     ...  skip_parameter_relation_errors=True
     ...  timeout=600
     ${bts_onair_status}  Run Keyword And Return Status
     ...  Wait Until Keyword Succeeds  10 min  20 s  Check Required Mrbts State  OnAir
     ${cells_onair_status}  Run Keyword And Return Status
     ...  Wait Until Keyword Succeeds  5 min  20 s  Check If All Cells Are onAir
     Run Keyword If  '${bts_onair_status}'=='True' and '${cells_onair_status}'=='True'
    ...  Log to console  ${\n}BTS is onAir after Site Recommissioning !${\n}
    ...  ELSE
    ...  Run Keywords  Log to console  BTS is NOT onAir after Site Recommissioning, set test failed !${\n}
    ...  AND  Fail  BTS is NOT onAir after Site Recommissioning, set test fail !
    [Teardown]  admin.Teardown Admin


[1]SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    Idle with cells locked
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked.TC Teardown


[1]SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    onAir
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair.TC Teardown


[1]SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset_5_1dB
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${TM_OFFSET}  51
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    TM1_1-Offset_51dB
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Teardown


[1]SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset_2_9dB
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${TM_OFFSET}  29
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    TM1_1-Offset_29dB
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Teardown


[1]SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset_0dB
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${TM_OFFSET}  0
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    TM1_1-Offset_0dB
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Teardown


[1] Calculate ETSI avg (wighted)
    Calculate ETSI  ETSI avg (wighted)

[1] Calculate ETSI Avg Target(W)-wighted
    Calculate ETSI  ETSI Avg Target(W)-wighted
