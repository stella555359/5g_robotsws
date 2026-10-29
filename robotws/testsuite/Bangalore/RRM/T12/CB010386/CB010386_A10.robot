*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature  : to check TDD n90 band L3 Call with chBW 100 Mhz

Resource        resources/Keywords/CB10386_Keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Suite TearDown for CB010386

*** Variables ***
${UE_ID_SA}=        1
${UE_ID_NSA}=       101
${pattern1}=        supportedSubcarrierSpacingUL kHz30
${pattern2}=        supportedBandwidthUL fr1 : mhz100
${pattern3}=        supportedSubcarrierSpacingDL kHz30
${pattern4}=        supportedBandwidthDL fr1 : mhz100
${pattern5}=        freqBandIndicatorNR 90
${pattern6}=        bandNR 90

*** Test Cases ***
[1][2.0] CB010386_A_10_Verify_the_TDD_n90_band_Successful_cell_UE_Attach_ULDL_Traffic_setup_with_chBW_100Mhz_in_SA_and_NSA
    [Documentation]         [1]CB008187_B03_B10_1_Verify_RAN_UE_ID_Sent_by_gNB-CU-CP_and_gNB-DU_during_initial
    ...                     _access_due_to_successful_SA_call
#    [Tags]    QC_28297   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB0010386_A_10
    ${PDU_session_setup_output}     SA Call for Feature CB010386                    ${UE_ID_SA}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern1}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern2}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern3}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern4}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern5}
    ${ue_attach_output}             NSA Call for Feature CB010386                   ${UE_ID_NSA}
    Print Matching Lines from Output File           ${ue_attach_output}             ${pattern6}
    [Teardown]     Run Keyword And Ignore Error     Common test case tear down LO AP LO
