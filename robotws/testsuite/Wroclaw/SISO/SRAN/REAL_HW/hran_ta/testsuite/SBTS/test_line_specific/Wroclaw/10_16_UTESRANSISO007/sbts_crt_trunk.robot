*** Settings ***
Documentation
...  Test Suite Author: Dominika Wojcik
...  Test Suite Owner: Dominika Wojcik
...  Team: T01

Resource          ../../../test_resources/3G_RRM/Automated_SiSo_CALL_WCDMA_Data_Transfer.robot
Resource          ../../../test_resources/4G_RRM/Automated_SiSo_CALL_LTE_Data_Transfer.robot
Resource          ../../../test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Data_Transfer.robot
Resource          ../../../test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Voice_Call.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_1__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_6__RP001548__Automated.robot
Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_Temperature_Fault_1927_1936_1938.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_Temperature_Fault_1937.robot
Resource          ../../../test_resources/BS-RF/SiSo_REC_RU_Deep_Sleep_Mode_Power_State.robot
Resource          ../../../test_resources/BS-SM/BS-SM__GSM_RAT_reset_from_ADMIN.robot


*** Variables ***


${HW_LOCATION_CODE}      Wroclaw

${COMMISSIONING_PATH}  SEPARATOR=  /home/ute/branch_archive/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/
...  test_line_specific/Wroclaw/10_16_UTESRANSISO007/commissioning/scf01.xml
${TESTLINE_NAME}  10_16_UTESRANSISO007
${COLLECT_SNAPSHOT_FLAG}    Never

*** Test Cases ***


#
#
#[TEMP_1937][1.0] Automated__SiSo_FM_Temperature_Fault_1937
#    [Setup]   Run Keywords    Set Test Variable   ${COMMISSIONING_PATH}
#    ...    AND    Set Test Variable    ${RMOD_SN}    LR233406929
#    ...    AND    SiSo_FM_Temperature_Fault_1937.TC Setup
#    ...    AND    Set Library Search Order    admin  SiSo_FM_Temperature_Fault_1937
#    [Timeout]   14400
#    TC__SiSo_FM_Temperature_Fault_1937
#    [Teardown]   SiSo_FM_Temperature_Fault_1937.TC Teardown
#
#[DS-ARDB][1.0] Automated_SiSo_REC_RU_Deep_Sleep_Mode_Power_State
#    [Setup]  Run Keywords  Set Test Variable  ${RMOD_SN}   L1194707349
#    ...  AND  Set Test Variable  ${REPETITIONS_AMOUNT}  5
#    ...  AND  Set Test Variable  ${SISO_L3_CALL}  False
#    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}
#    ...  AND  SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Setup
#    ...  AND  Set Library Search Order  admin  SiSo_REC_RU_Deep_Sleep_Mode_Power_State
#    [Timeout]   14400
#    TC__SiSo_REC_RU_Deep_Sleep_Mode_Power_State
#    [Teardown]   SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Teardown
#
#[WCDMA_Transf_2211][1.0] Automated_SiSo_CALL_WCDMA_Data_Transfer
#    [Setup]    Run Keywords    Set Test Variable    ${CELLS_YAML_PATH}    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    @{SELECTED_CELLS}         35805
#    ...    AND    Set Library Search Order    admin  Automated_SiSo_CALL_WCDMA_Data_Transfer
#    ...    AND    Automated_SiSo_CALL_WCDMA_Data_Transfer.TC Setup
#    [Timeout]    14400
#    TC__Automated_SiSo_CALL_WCDMA_Data_Transfer
#    [Teardown]  Automated_SiSo_CALL_WCDMA_Data_Transfer.TC Teardown
##  HSPA RP002211
#
#[LTE_Transf_2211][1.0] Automated_SiSo_CALL_LTE_Data_Transfer
#    [Setup]    Run Keywords    Set Test Variable    ${CELLS_YAML_PATH}    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    @{SELECTED_CELLS}      338180
#    ...    AND    Set Library Search Order    admin  Automated_SiSo_CALL_LTE_Data_Transfer
#    ...    AND    Automated_SiSo_CALL_LTE_Data_Transfer.TC Setup
#    [Timeout]    14400
#    TC__Automated_SiSo_CALL_LTE_Data_Transfer
#    [Teardown]  Automated_SiSo_CALL_LTE_Data_Transfer.TC Teardown
##  RP002211_3MHz
#
#[GSM_Transf_2369][3.0] Automated_SiSo_CALL_GSM_Data_Transfer
#    [Setup]    Run Keywords    Set Test Variable    ${CELLS_YAML_PATH}
#    ...    AND    Set Test Variable    @{SELECTED_CELLS}    324
#    ...    AND    Automated_SiSo_CALL_GSM_Data_Transfer.TC Setup
#    ...    AND    Set Library Search Order    admin  Automated_SiSo_CALL_GSM_Data_Transfer
#    [Timeout]    14400
#    TC__Automated_SiSo_CALL_GSM_Data_Transfer
#    [Teardown]  Automated_SiSo_CALL_GSM_Data_Transfer.TC Teardown
##  ERGPS_RP002369
#
#[GSM_Voice_2369][1.0] Automated_SiSo_CALL_GSM_Voice_call
#    [Setup]    Run Keywords    Set Test Variable    ${CELLS_YAML_PATH}
#    ...    AND    Set Test Variable    @{SELECTED_CELLS}     324     325     327
#    ...    AND    Automated_SiSo_CALL_GSM_Voice_Call.TC Setup
#    ...    AND    Set Library Search Order    admin  Automated_SiSo_CALL_GSM_Voice_Call
#    [Timeout]    14400
#    TC__Automated_SiSo_CALL_GSM_Voice_Call
#    [Teardown]    Automated_SiSo_CALL_GSM_Voice_Call.TC Teardown
##  RP002369
#
#[Enter][1] BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Tags]    STOPONFAIL
#    [Setup]    Run Keywords    BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    admin  BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Teardown]    BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Teardown
#
#[Simult][1.0] BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_DL_TM}
#    ...    AND    Set Test Variable    ${USER_LTE_UL_TM}    A1_2
#    ...    AND    Set Test Variable    ${USER_LTE_CELL}    31103
#    ...    AND    Set Test Variable    ${USER_WCDMA_DL_TM}
#    ...    AND    Set Test Variable    ${USER_WCDMA_CELL}    35807
#    ...    AND    BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    admin  BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.TC Teardown
#
#[Exit][1] BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Setup]    Run Keywords    BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    admin  BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Teardown]    BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Teardown
#
[Simult][1.0] BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_DL_TM}
    ...    AND    Set Test Variable    ${USER_LTE_UL_TM}    A1_3
    ...    AND    Set Test Variable    ${USER_LTE_CELL}    34000
    ...    AND    Set Test Variable    ${USER_WCDMA_DL_TM}
    ...    AND    Set Test Variable    ${USER_WCDMA_CELL}    35205
    ...    AND    BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.TC Setup
    ...    AND    Set Library Search Order    admin  BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
    [Timeout]    14400
    TC__BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
    [Teardown]    BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.TC Teardown

#[1]BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Setup]    Run Keywords
#    ...    BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Teardown]    BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Teardown

[TM][1.0] Automated_Start_Stop_LTE_Downlink_TestModels
    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    34000
    ...    AND    Set Test Variable    ${USER_PHY_CELL_ID}
    ...    AND    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated
    [Timeout]    14400
    TC__BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated
    [Teardown]   BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated.TC Teardown

[TM][2.0] Automated_Start_Stop_LTE_Uplink_TestModels
    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    34000
    ...    AND    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated
    [Timeout]    14400
    TC__BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated
    [Teardown]    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated.TC Teardown

#[1]BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Setup]    Run Keywords
#    ...    BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Teardown]    BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Teardown
