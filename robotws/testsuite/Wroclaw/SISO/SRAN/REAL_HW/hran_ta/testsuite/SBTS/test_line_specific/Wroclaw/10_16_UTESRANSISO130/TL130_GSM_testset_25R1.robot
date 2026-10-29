*** Settings ***
Documentation
...   Test Suite Author: Tomasz Pawlaczyk
...   Test Suite Owner: Tomasz Pawlaczyk

#Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CONF_130_3xWCDMA   SBTS00
Library           XML    use_lxml=True

Resource          ../../../test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Data_Transfer.robot
Resource          ../../../test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Voice_Call.robot
Resource          ../../../test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Data_Transfer.robot
Resource          ../../../test_resources/4G_RRM/Automated_SiSo_CALL_LTE_Data_Transfer.robot
Resource          ../../../test_resources/BS-RF/BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3.robot
Resource          ../../../test_resources/BS-RF/BS-RF__SBTS_GSM_BB_hopping__RP002611__Automated_L3.robot
Resource          ../../../test_resources/BS-RF/BS-RF__SBTS_GSM_RF_hopping__RP002611__Automated_L3.robot
Resource          ../../../test_resources/STATE/STATE__Site_reset.robot
Resource          ../../../test_resources/BS-SM/BS-SM__GSM_RAT_reset_from_ADMIN.robot
#Resource    ${PATH}/test_resources/STATE/STATE__Radio_module_reset_from_admin.robot
#Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Data_Transfer.robot
#Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Voice_Call.robot
#Resource    ${PATH}/test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Data_Transfer.robot
#Resource    ${PATH}/test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Voice_Call.robot

*** Variables ***

${ADDITIONAL_IGNORED_ALARMS}  61675      # For trunk

${HW_LOCATION_CODE}    Wroclaw
#${SCF_ID}              01
${TESTLINE_NAME}      10_16_UTESRANSISO130
${ENABLE_TRUCK_ROLL_FLAG}    ${False}
${COLLECT_SNAPSHOT_FLAG}  never      # failed_verdict ->    only when TC failed    always    never
${PATH}    testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS   #DO NOT CHANGE
${COMMISSIONING_PATH}
...  /home/ute/testline_configuration/10_16_UTESRANSISO130/node1/SBTS25R1/GSM_cells2_wo_LTE.xml
${COMMISSIONING_PATH_1}
...  /home/ute/testline_configuration/10_16_UTESRANSISO130/node1/SBTS25R1/CONF_130_3xWCDMA.xml
${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO130/130cells.yaml


*** Test Cases ***

[GSM_RAT_reset][3.0] Automated__BS-SM GSM RAT reset from ADMIN                            #OK    #25R1
    [Setup]    Run Keywords  Set Test Variable   ${COMMISSIONING_PATH}
    ...    AND    Set Test Variable   ${COMMISSIONING_PATH}
    ...    AND    BS-SM__GSM_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Set Library Search Order    BS-SM__GSM_RAT_reset_from_ADMIN
    [Timeout]    14400
    TC__BS-SM__GSM_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    BS-SM__GSM_RAT_reset_from_ADMIN.TC Teardown

[Rf_hopping2][1.0] BS-RF__SBTS_GSM_RF_hopping__RP002611__Automated #206=36ca2644=4               #OK     #25R1
    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    1592=37    #1592=37 1591=612 #<GCELLID>=<MALL_ID
    ...    AND    Set Test Variable    ${CELLS_YAML_PATH}
	...    AND    BS-RF__SBTS_GSM_RF_hopping__RP002611__Automated_L3.TC Setup
    ...    AND    Set Library Search Order    BS-RF__SBTS_GSM_RF_hopping__RP002611__Automated_L3
    [Timeout]    14400
    TC__BS-RF__SBTS_GSM_RF_hopping__RP002611__Automated_L3
    [Teardown]  Run Keywords  BS-RF__SBTS_GSM_RF_hopping__RP002611__Automated_L3.TC Teardown
    ...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action

[Antenna_hopping][1.0] BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated #206=36ca2644                 #OK
    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    1592
    ...    AND    Set Test Variable    ${CELLS_YAML_PATH}
	...    AND    BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3.TC Setup
    ...    AND    Set Library Search Order    BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3
    [Timeout]    14400
    TC__BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3
    [Teardown]  Run Keywords  BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3.TC Teardown
    ...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action

[BB_hopping][1.0] BS-RF__SBTS_GSM_BB_hopping__RP002611__Automated              #OK
    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}   1592     #1592 - GSM sector cellID
    ...    AND    Set Test Variable    ${CELLS_YAML_PATH}
	...    AND    BS-RF__SBTS_GSM_BB_hopping__RP002611__Automated_L3.TC Setup
    ...    AND    Set Library Search Order    BS-RF__SBTS_GSM_BB_hopping__RP002611__Automated_L3
    [Timeout]    14400
    TC__BS-RF__SBTS_GSM_BB_hopping__RP002611__Automated_L3
    [Teardown]  Run Keywords  BS-RF__SBTS_GSM_BB_hopping__RP002611__Automated_L3.TC Teardown
    ...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action

###################

#[1][1.0] Automated_SiSo_CALL_GSM_Data_Transfer
#    [Setup]    Run Keywords    Set Test Variable    @{SELECTED_CELLS}    1591
#    ...    AND    Automated_SiSo_CALL_GSM_Data_Transfer.TC Setup
#    ...    AND    Set Library Search Order    Automated_SiSo_CALL_GSM_Data_Transfer
#    [Timeout]    14400
#    TC__Automated_SiSo_CALL_GSM_Data_Transfer
#    [Teardown]  Automated_SiSo_CALL_GSM_Data_Transfer.TC Teardown

#[1592][1.0] Automated_SiSo_CALL_GSM_Data_Transfer
#    [Setup]    Run Keywords    Set Test Variable    @{SELECTED_CELLS}    1592
#    ...    AND    Automated_SiSo_CALL_GSM_Data_Transfer.TC Setup
#    ...    AND    Set Library Search Order    Automated_SiSo_CALL_GSM_Data_Transfer
#    [Timeout]    14400
#    TC__Automated_SiSo_CALL_GSM_Data_Transfer
#    [Teardown]  Automated_SiSo_CALL_GSM_Data_Transfer.TC Teardown
#
#[WCDMA1][1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
#    [Setup]    Run Keywords    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}     180
#    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
#    ...    AND    Set Library Search Order    STATE__WCDMA_RAT_reset_from_ADMIN
#    ...    AND    STATE__WCDMA_RAT_reset_from_ADMIN.TC Setup
#    [Timeout]    14400
#    TC__STATE__WCDMA_RAT_reset_from_ADMIN
#    [Teardown]    Run Keywords    STATE__WCDMA_RAT_reset_from_ADMIN.TC Teardown
#	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action
