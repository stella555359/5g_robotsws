*** Settings ***
Documentation   This is a Robot Test Suite for feature 'CB013392: Measurement Profiles Power Class criterion for CA UEs
...             sub feature -A SA Power Class determination for UL CA' testing,
...             for classic SA configuration with MTK UE
...             Team: 'MN RAN RD VRF ULM6'
...             Email: 'i_pz_ulm_sqd_64@internal.nsn.com'
#--------------------------------------------------------------------------------------------

Resource    resources/CB013392_C_keywordsbook.robot

Suite Setup     Prepare TL for Testing
Suite Teardown  Run Keywords
...             Testline Teardown for CCRT    gnb_id=${gnb_id}
...             AND     Load initial enb scf for CCRT    enb_id=${enb_id}

*** Variables ***
${enb_id}                                   0
${gnb_id}                                   0
${PCell_ID}                                14
${PCell_frequenceNR}                       78
${SCell_ID}                                 9
${EnbCell_ID}                               10


*** Test Cases ***
CB013392_C_ST_TC04_B9_Act_A1_A3_A5_after_A2
    [Documentation]
    ...    Author: Hua Li, eMail: Hua.Li@Nokia.com
    ...    This test case validates the gNB behavior of Activation of A1, Inter-Freq A3/A5 and
    ...    measurements using the selected measurement profile with MeNB power coordination consideration
    ...    based on the effective power class upon receipt of A2 Measurement Report for NSA
    [Tags]    CB013392_C_TC04
    [Setup]   CB013392_C_TC04_Setup
    [Teardown]    Run Keywords
    ...           CB013392 C TC Teardown
    ...  AND      CCRT Test Cases Teardown

    Start Tracing
    taf.ue.Attach UE    UE  timeout=180
    attenuator_scenario.Set cell attenuation     ${PCell_ID}    ${20}  node_id=${gnb_id}  node_type=gnb
    Start Data Transfer UL DL
    sleep     2s
    Stop Tracing and Save As    file_name=UE2Attach_SgNbAddition_A2_A3_A5_MeasConfig
    Verify SgNbAddtion RRCReconfiguration with correct MeasConfigs
    ...    ${UE2Attach_SgNbAddition_A2_A3_A5_MeasConfig}

    Start Tracing
    sleep     2s
    attenuator_scenario.Set cell attenuation      ${PCell_ID}  ${40}
    sleep     2s
    Stop Tracing and Save As    file_name=A2_Reports

    Start Tracing
    online change IAF-2 a2ThresholdhoSsbRsrq to 68
    sleep     2s
    Stop Tracing and Save As    file_name=A2_Act_A1_A3_A5_MeasConfigs

    Stop all the traffic
    taf.ue.Detach UE    UE
    Verify A2 report and RRCReconfiguration with correct MeasConfigs activated after A2
    ...       ${A2_Act_A1_A3_A5_MeasConfigs}


