*** Settings ***
Documentation
...   Test suite for regression testing of feature CB012196
...   author: Marek Szłapa
...   contact: marek.szlapa@nokia.com

Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/CB012196_keywords.robot
Resource     ./resources/Manual_SISO_CM_Recommissioning.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               increase_timeout_for_update_sw=${1800}
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords    Common Preconditions With Watching Alarms    AND     Require Ue for L3 Call
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}
${SITE_RESET_TEST_ITERATION}            3


*** Test Cases ***
CB012196_A_C2_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Timeout]    20h
    Perform NSA L3 Call on all cells    deviation=10%

CB012196_A_C2_General_SiSo_block_unblock_pRRHs_via_ASiR_WebEM
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Failure detected on assigned antennas
    ...         AND            Common Preconditions With Watching Alarms    AND     Require Ue for L3 Call
    [Timeout]    20h
    Block Unblock all pRRHs via ASIRWebEM
    Perform NSA L3 Call on all cells

CB012196_A_C2_General_SiSo_reset_pRRH_via_ASiR_WebEM
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Failure detected on assigned antennas
    ...         AND            Common Preconditions With Watching Alarms    AND     Require Ue for L3 Call
    [Timeout]    20h
    Reset all pRRHs via ASIRWebEM
    Perform NSA L3 Call on all cells

CB012196_A_C2_Manual_SiSo_SM_BTS_Site_Reset
    [Setup]     Run Keywords   Set Test Variable   @{CUSTOM_ALLOWED_ALARMS}   No X2 link available for a specific LTEENB
    ...         No X2 link available
    ...         AND
    ...         Common Preconditions With Watching Alarms    AND     Require Ue for L3 Call
    [Timeout]    20h
    Repeat Keyword    ${SITE_RESET_TEST_ITERATION}
    ...    Run Keyword And Continue On Failure    CB012196 Manual SiSo SM BTS Site Reset with L3call

CB012196_A_C2_Manual_SiSo_CM_Recommissioning
    [Timeout]    20h
    CB012196_Manual_SiSo_CM_Recommissioning


*** Keywords ***
CB012196 Manual SiSo SM BTS Site Reset with L3call
    Run Keyword And Continue On Failure    General_SiSo_Auto_BTS_Site_Reset
    Perform NSA L3 Call on all cells    deviation=20%
