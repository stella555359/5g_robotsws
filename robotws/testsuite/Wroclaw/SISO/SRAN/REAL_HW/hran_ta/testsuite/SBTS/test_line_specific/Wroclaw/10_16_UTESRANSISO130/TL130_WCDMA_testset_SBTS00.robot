*** Settings ***
Documentation
...   Test Suite Author: Tomasz Pawlaczyk
...   Test Suite Owner: Tomasz Pawlaczyk

Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CONF_130_3xWCDMA   SBTS00    SBTS25R1
Library           XML    use_lxml=True

Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource          ../../../test_resources/STATE/STATE__Radio_module_reset_from_admin.robot
Resource          ../../../test_resources/STATE/STATE__Site_power_reset.robot
Resource          ../../../test_resources/STATE/STATE__Site_reset.robot
Resource          ../../../test_resources/STATE/STATE__WCDMA_RAT_reset_from_ADMIN.robot


Resource    ${PATH}/test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.robot
Resource    ${PATH}/test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.robot
Resource    ${PATH}/test_resources/STATE/STATE__Radio_module_reset_from_admin.robot
Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Data_Transfer.robot
Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Voice_Call.robot
Resource    ${PATH}/test_resources/4G_RRM/Automated_SiSo_CALL_LTE_Data_Transfer.robot
Resource    ${PATH}/test_resources/5G_RRM/Automated_SiSo_CALL_NR_Data_Transfer.robot
Resource    ${PATH}/test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Data_Transfer.robot
Resource    ${PATH}/test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Voice_Call.robot


*** Variables ***

${HW_LOCATION_CODE}    Wroclaw
#${SCF_ID}              01
${TESTLINE_NAME}      10_16_UTESRANSISO130
${ENABLE_TRUCK_ROLL_FLAG}    ${False}
${PATH}    testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS   #DO NOT CHANGE

${ADDITIONAL_IGNORED_ALARMS}  61675

${COMMISSIONING_PATH}  SEPARATOR=
...  /home/ute/testline_init_results/execution/configs/topology_configs/node_1/CONF_130_3xWCDMA.xml
${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO130/130cells.yaml

*** Test Cases ***

[WCDMA][1.0] Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Setup]    Run Keywords    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Library Search Order    STATE__WCDMA_RAT_reset_from_ADMIN
    ...    AND    STATE__WCDMA_RAT_reset_from_ADMIN.TC Setup
    [Timeout]    14400
    TC__STATE__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__WCDMA_RAT_reset_from_ADMIN.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action



[WCDMA][1.0] Automated__SiSo_CALL_WCDMA_Data_Transfer
    [Setup]    Run Keywords  Set Test Variable    @{SELECTED_CELLS}    5464
    ...    AND    Automated_SiSo_CALL_WCDMA_Data_Transfer.TC Setup
    ...    AND    Set Library Search Order    Automated_SiSo_CALL_WCDMA_Data_Transfer
    [Timeout]    14400
    TC__Automated_SiSo_CALL_WCDMA_Data_Transfer
    [Teardown]  Automated_SiSo_CALL_WCDMA_Data_Transfer.TC Teardown

