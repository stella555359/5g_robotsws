*** Settings ***
Documentation
...   Test Suite Author: Tomasz Pawlaczyk
...   Test Suite Owner: Tomasz Pawlaczyk

Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CONF_130_3xWCDMA   SBTS00    SBTS25R1
Library           XML    use_lxml=True

Resource          ../../../test_resources/STATE/STATE__WCDMA_RAT_reset_from_ADMIN.robot
#Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Data_Transfer.robot
#Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Voice_Call.robot
Resource    ../../../test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Data_Transfer.robot
Resource    ../../../test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Voice_Call.robot


*** Variables ***
${ADDITIONAL_IGNORED_ALARMS}  61675
@{additional_common_fault_list}=
...  faultId=61675

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}


${HW_LOCATION_CODE}    Wroclaw

${TESTLINE_NAME}      10_16_UTESRANSISO130
${ENABLE_TRUCK_ROLL_FLAG}    ${False}
${PATH}    testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS   #DO NOT CHANGE

${SCF_ID}              01
${COMMISSIONING_PATH}  SEPARATOR=
...  /home/ute/testline_configuration/10_16_UTESRANSISO130/node1/SBTS25R1/CONF_130_3xWCDMA.xml

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


############
#[1][1.0] Automated__SiSo_CALL_WCDMA_Data_Transfer
#    [Setup]    Run Keywords  Set Test Variable    @{SELECTED_CELLS}    5464
#    ...    AND    Automated_SiSo_CALL_WCDMA_Data_Transfer.TC Setup
#    ...    AND    Set Library Search Order    Automated_SiSo_CALL_WCDMA_Data_Transfer
#    [Timeout]    14400
#    TC__Automated_SiSo_CALL_WCDMA_Data_Transfer
#    [Teardown]  Automated_SiSo_CALL_WCDMA_Data_Transfer.TC Teardown


