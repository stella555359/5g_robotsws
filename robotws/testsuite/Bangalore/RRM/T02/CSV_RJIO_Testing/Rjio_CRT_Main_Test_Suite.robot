*** Settings ***
Documentation    Main Test suite for RJIO
Resource        ../resources/robot/Common_keywords.resource
Resource        ../resources/robot/ANR_keywords.resource
# Resource    ./Resources_Rjio/robot/Simcom_taf_ue_keywords.robot
Resource           ../resources/robot/Rjio_Suite_Setup_Teardown.resource
# Resource    ./Resources_Rjio/robot/Power_saving_configuration.resource
Resource           ../resources/robot/Features/CB012601/CB012601_keyword.resource
Resource           ../resources/robot/UUF_Mantaray/UUF_Mantaray.resource
Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown
Test Setup         Common Test Setup
Test Teardown      Common Test Teardown


*** Test Cases ***
Test for Simcom
    [Tags]    Test_simcom
    UE_keywords.Simcom Attach DT Detach

SW Upgrade Rollback Via MantaRay
    [Documentation]    Test For UUF through the Mantaray
    [Tags]    Mantaray
    UUF_Mantaray.SW Upgrade Rollback Via MantaRay Keyword

Rjio_E2E_63_Mobility_UE_based_ANR
    [Documentation]  Contains Test scenarios for NR-ANR and Reporting port update
    [Tags]   CDRT_SBTS25R1  CDRT_SBTS25R2  CDRT_SBTS00    test_anr_1
    ANR_keywords.Rjio E2E 63 Mobility UE based ANR

Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor
    [Documentation]  Contains Test scenarios for EUTRA-ANR and Reporting port update
    [Tags]   CDRT_SBTS25R1  CDRT_SBTS25R2  CDRT_SBTS00  ANR_EUTRA
    ANR_keywords.Rjio E2E 63 Mobility UE based ANR

UE_redirected_to_a_intergNB_TDD_frequency_layer_due_to_bad_uplink_radio_conditions_after_an_Incoming_Ng_handover
    [Documentation]  Contains Test scenarios for redirection due to bler and Reporting port update
    [Tags]    CRT_SBTS24R2  CRT_SBTS24R3  CRT_SBTS00   bad_ul_nr    CB012601
    CB012601_keyword.BadULRadio Condition After ICS

UE_redirected_to_a_eutra RAT_frequency_layer_due_to_bad_uplink_radio_conditions_after_an_Initial_Context_Setup
    [Documentation]  Contains Test scenarios for redirection due to bler and Reporting port update
    ...   Need to be perform with NR TDD --> LTE FDD
    [Tags]    CB012601    bad_ul_etura
    CB012601_keyword.Bad Uplink Radio Conditions After An Incoming Ng Handover Keyword

CB007511 Deepsleep mode for energy efficiency based on CB007511
    [Documentation]    Test case in implementation phase.
    [Tags]   24R2  24R1      test_deep_sleep
    # Power_saving_configuration.Power Saving Algorithm
    Pass Execution  message=Empty test case

Robustness Deepsleep mode for energy efficiency based on CB007511
    [Documentation]    Test Case in implementation phase
    [Tags]   24R2  24R1  23R4    DeepSleep
    # Power_saving_configuration.Power Saving Algorithm
    Pass Execution  message=Empty test case

Regression Scenario for Sleeping Cell Detection when GPS signal is recovered after longer interruption
    [Tags]   24R2  24R1
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case

RJIO_KPI & counter verification for VoNR traffic
    [Tags]   24R2  24R1  23R4
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case

RJIO_KPI & counter verification with multiple slices
    [Tags]   24R2  24R1  23R4
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case
RJIO_RACH success rate verification on multiple slices
    [Tags]   24R2  24R1  23R4
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case
RJIO_Throughput verification on slicing configuration
    [Tags]   24R2  24R1  23R4
    Configure_QC_ID_for_Reportng_portal
    Pass Execution  message=Empty test case