*** Settings ***
Documentation
...   author: XXX                                      # set your Name
...   contact: XXX                                     # set your email
...   Test suite for XXX                               # short description/purpose of test suite

Force Tags        QCD_MN_RAN    QCP_RAN_ST


Resource    ${PATH}/test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.robot
Resource    ${PATH}/test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.robot
Resource    ${PATH}/test_resources/BS-RF/BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.robot
Resource    ${PATH}/test_resources/STATE/STATE__Radio_module_reset_from_admin.robot
Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Data_Transfer.robot
Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Voice_Call.robot
Resource    ${PATH}/test_resources/4G_RRM/Automated_SiSo_CALL_LTE_Data_Transfer.robot
Resource    ${PATH}/test_resources/5G_RRM/Automated_SiSo_CALL_NR_Data_Transfer.robot
Resource    ${PATH}/test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Data_Transfer.robot
Resource    ${PATH}/test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Voice_Call.robot



*** Variables ***
${PATH}    testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS   #DO NOT CHANGE
${COMMISSIONING_PATH}  XXX        # path to your SCF
${TESTLINE_NAME}  10_16_XXX       # testline name in format 10_16_XXX, the same as folder name for your config in testline_configuration repository
${HW_LOCATION_CODE}  Wroclaw      # location name - DO NOT CHANGE
${COLLECT_SNAPSHOT_FLAG}  XXX     # possible values: failed_verdict -> snapshot will be collected only when TC is failed
                                  #                  always -> snapshot will be collected after every execution
                                  #                  never -> snapshot won't be collected
${CELLS_YAML_PATH}  XXX           # ${PATH}/test_line_specific/Wroclaw/Integration/<paste_missing_path_to_yaml_file>
                                  # define cells yaml file path; If You don't execute calls TCes, delete this variable

*** Test Cases ***

[1]BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Setup]    Run Keywords    Set Test Variable    ${INTERVAL}    XXX
    ...    AND    Set Test Variable    ${RMODS}    XXX
    ...    AND    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Timeout]    14400
    TC__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Teardown]    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Teardown


[1]BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SN}    XXX
    ...    AND    Set Test Variable    ${RMODS}    XXX
    ...    AND    Set Test Variable    ${TIME_TO_WAIT}    XXX
    ...    AND    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Timeout]    14400
    TC__BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Teardown]   BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Teardown

[1][1.0] BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
    [Setup]    Run Keywords    Set Test Variable    ${USER_RAT_TO_LAUNCH}  XXX
    ...    AND    Set Test Variable    ${USER_NR_DL_TM}  XXX
    ...    AND    Set Test Variable    ${USER_NR_UL_TM}  XXX
    ...    AND    Set Test Variable    ${USER_NR_CELL}  XXX
    ...    AND    Set Test Variable    ${USER_LTE_DL_TM}  XXX
    ...    AND    Set Test Variable    ${USER_LTE_UL_TM}  XXX
    ...    AND    Set Test Variable    ${USER_LTE_CELL}  XXX
    ...    AND    Set Test Variable    ${USER_WCDMA_DL_TM}   XXX
    ...    AND    Set Test Variable    ${USER_WCDMA_CELL}    XXX
    ...    AND    BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
    [Timeout]    14400
    TC__BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
    [Teardown]     BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.TC Teardown

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SERIAL_NUMBER}    XXX
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    XXX
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    XXX
    ...    AND    Set Library Search Order    STATE__Radio_module_reset_from_admin
    ...    AND    STATE__Radio_module_reset_from_admin.TC Setup
    [Timeout]    14400
    TC__STATE__Radio_module_reset_from_admin
    [Teardown]    STATE__Radio_module_reset_from_admin.TC Teardown


[1][1.0] Automated_SiSo_CALL_GSM_Data_Transfer
    [Setup]    Run Keywords    Set Test Variable    @{SELECTED_CELLS}    XXX
    ...    AND    Automated_SiSo_CALL_GSM_Data_Transfer.TC Setup
    ...    AND    Set Library Search Order    Automated_SiSo_CALL_GSM_Data_Transfer
    [Timeout]    14400
    TC__Automated_SiSo_CALL_GSM_Data_Transfer
    [Teardown]  Automated_SiSo_CALL_GSM_Data_Transfer.TC Teardown


[1][1.0] Automated_SiSo_CALL_GSM_Voice_Call
    [Setup]    Run Keywords    Set Test Variable    @{SELECTED_CELLS}    XXX
    ...    AND    Automated_SiSo_CALL_GSM_Voice_Call.TC Setup
    ...    AND    Set Library Search Order    Automated_SiSo_CALL_GSM_Voice_Call
    [Timeout]    14400
    TC__Automated_SiSo_CALL_GSM_Voice_Call
    [Teardown]    Automated_SiSo_CALL_GSM_Voice_Call.TC Teardown


[1][1.0] Automated_SiSo_CALL_LTE_Data_Transfer
    [Setup]    Run Keywords    Set Test Variable    @{SELECTED_CELLS}    XXX
    ...    AND    Automated_SiSo_CALL_LTE_Data_Transfer.TC Setup
    ...    AND    Set Library Search Order    Automated_SiSo_CALL_LTE_Data_Transfer
    [Timeout]    14400
    TC__Automated_SiSo_CALL_LTE_Data_Transfer
    [Teardown]  Automated_SiSo_CALL_LTE_Data_Transfer.TC Teardown


[1][1.0] Automated_SiSo_CALL_NR_Data_Transfer
    [Setup]    Run Keywords    Set Test Variable    @{SELECTED_CELLS}    XXX
    ...    AND    Automated_SiSo_CALL_NR_Data_Transfer.TC Setup
    ...    AND    Set Library Search Order    Automated_SiSo_CALL_NR_Data_Transfer
    [Timeout]    14400
    TC__Automated_SiSo_CALL_NR_Data_Transfer
    [Teardown]  Automated_SiSo_CALL_NR_Data_Transfer.TC Teardown


[1][1.0] Automated__SiSo_CALL_WCDMA_Data_Transfer
    [Setup]    Run Keywords  Set Test Variable    @{SELECTED_CELLS}    XXX
    ...    AND    Automated_SiSo_CALL_WCDMA_Data_Transfer.TC Setup
    ...    AND    Set Library Search Order    Automated_SiSo_CALL_WCDMA_Data_Transfer
    [Timeout]    14400
    TC__Automated_SiSo_CALL_WCDMA_Data_Transfer
    [Teardown]  Automated_SiSo_CALL_WCDMA_Data_Transfer.TC Teardown


[1][1.0] Automated_SiSo_CALL_WCDMA_Voice_Call
    [Setup]    Run Keywords    Set Test Variable    @{SELECTED_CELLS}    XXX
    ...    AND    Automated_SiSo_CALL_WCDMA_Voice_Call.TC Setup
    ...    AND    Set Library Search Order    Automated_SiSo_CALL_WCDMA_Voice_Call
    [Timeout]    14400
    TC__Automated_SiSo_CALL_WCDMA_Voice_Call
    [Teardown]    Automated_SiSo_CALL_WCDMA_Voice_Call.TC Teardown


