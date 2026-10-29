*** Settings ***
Documentation   This is a Robot Test Suite for feature 'CB013392: Measurement Profiles Power Class criterion for CA UEs
...             sub feature -A SA Power Class determination for UL CA' testing,
...             for classic SA configuration with MTK UE
...             Team: 'MN RAN RD VRF ULM6'
...             Email: 'i_pz_ulm_sqd_64@internal.nsn.com'
#--------------------------------------------------------------------------------------------

Resource    resources/CB013392_AB_keywordsbook.robot

Suite Setup     Prepare TL for Testing
Suite Teardown  Testline Teardown for CCRT    gnb_id=${gnb_id}

*** Variables ***
${gnb_id}                                   0
${enb_id}                                   0


*** Test Cases ***
CB013392_A_ST_TC02_B4_Act_A1_A3_A5_after_A2_in_UL_CA
    [Documentation]
    ...    Author: Hua Li, eMail: Hua.Li@Nokia.com
    ...    This test case validates the gNB behavior of Activation of A1, Inter-Freq A3/A5 and
    ...    Inter-RAT B2 measurements using the selected measurement profile based on the effective power class
    ...    upon receipt of A2 Measurement Report for SA when UE is configured with UL Carrier Aggregation
    [Tags]    CB013392_A_TC02
    [Setup]   CB013392_A_TC02_Setup
    [Teardown]    Run Keywords
    ...           CB013392 A TC Teardown
    ...  AND      CCRT Test Cases Teardown

    Start Tracing
    taf.ue.Attach UE    UE_1  timeout=180
    Start Data Transfer UL DL     UE_1
    attenuator_scenario.Set Cell Attenuation     ${SCell_ID}  ${50}
    Sleep     5s
    Stop Tracing and Save As    file_name=UE1Attach_DlandUlCA_A1_A3_A5_MeasConfig
    Verify CA triggered by A1 and RRCReconfiguration with correct MeasConfigs
    ...    ${UE1Attach_DlandUlCA_A1_A3_A5_MeasConfig}

    Start Tracing
    sleep     2s
    attenuator_scenario.Set cell attenuation      ${PCell_ID}  ${45}
    sleep     5s
    Stop Tracing and Save As    file_name=A2_Act_A1_A3_A5_B2_MeasConfigs

    Stop all the traffic
    taf.ue.Detach UE    UE_1
    Verify A2 report and RRCReconfiguration with correct MeasConfigs activated after A2
    ...       ${A2_Act_A1_A3_A5_B2_MeasConfigs}


CB013392_B_ST_TC02_B4_Act_A1_A3_A5_after_A2_in_DL_CA
    [Documentation]
    ...    Author: Hua Li, eMail: Hua.Li@Nokia.com
    ...    This test case is running with TMO configuration, e.g. TL387
    ...    This test case validates the gNB behavior of Activation of A1, Inter-Freq A3/A5 and
    ...    Inter-RAT B2 measurements using the selected measurement profile based on the effective power class
    ...    upon receipt of A2 Measurement Report for SA when UE is configured with DL Carrier Aggregation
    [Tags]    CB013392_B_TC02
    [Setup]   CB013392_B_TC02_Setup
    [Teardown]    Run Keywords
    ...           CB013392 B TC Teardown
    ...  AND      CCRT Test Cases Teardown

    Start Tracing
    taf.ue.Attach UE    UE_2  timeout=180
    Start Data Transfer UL DL    UE_2
    attenuator_scenario.Set Cell Attenuation     ${SCell_ID}  ${50}
    sleep     2s
    Stop Tracing and Save As    file_name=UE1Attach_DlandUlCA_A1_A3_A5_MeasConfig
    Verify CA triggered by A1 and RRCReconfiguration with correct MeasConfigs
    ...    ${UE1Attach_DlandUlCA_A1_A3_A5_MeasConfig}

    Start Tracing
    sleep     2s
    attenuator_scenario.Set cell attenuation      ${PCell_ID}  ${45}
    sleep     5s
    Stop Tracing and Save As    file_name=A2_Act_A1_A3_A5_B2_MeasConfigs

    Stop all the traffic
    taf.ue.Detach UE    UE_2
    Verify A2 report and RRCReconfiguration with correct MeasConfigs activated after A2
    ...       ${A2_Act_A1_A3_A5_B2_MeasConfigs}
