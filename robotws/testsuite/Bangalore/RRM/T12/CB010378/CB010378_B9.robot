*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  : The aim of the feature is to validate Idle Mode Mobility steering to 5G n77 band

Resource    resources/Keywords/10378_KW.robot

Suite Setup     Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${UE1}        1
${UE2}        2
${pattern1}      SIB1 FrequencyInfoDL additionalSpectrumEmission: 2
${pattern2}      SIB2 intraFreqCellReselectionInfo additionalSpectrumEmission: 2
${pattern3}      carrierFreq 650016
${pattern4}      carrierFreq 694334
${pattern5}      cellReselectionPriority 7

*** Test Cases ***
[1][1.0] CB010378_B9_1_SA_Idle_Mode_Mobility_steering_to_5G_n77_band_(3650_to_3980_MHz)
        [Documentation]     This user scenario describes the gNB behavior for Idle Mode Mobility
         ...    steering including UE Capability check for n77 band with non CA aware algorithm and
         ...    without mobility profiles
        [Tags]    QC_28274  QCD_MN_RAN    QCP_RAN_VRF
        Log to Console      \n Starting the test case\n
        [Setup]     Prepare for test Case - CB0010378_B9
        Log to Console      \nChecking for SI   B1
        Run Keyword And Ignore Error        Check Pattern in Egate Console Log      ${pattern1}
        Log to Console      \nChecking for SIB2
        Run Keyword And Ignore Error     Check Pattern in Egate Console Log      ${pattern2}
        Log to Console      \nRegistering UE 1
        UE Register should be Successful for SA     ${UE1}
        Log to Console      \nDeregistering UE 1
        UE Deregister     ${UE1}
        sleep      10s
        Log to Console      \nVerifying carrierFreq 650016  msg for UE1
        Run Keyword And Ignore Error    Read WTS Output Until Pattern Matches      ${pattern3}     timeout=100
        Run Keyword And Ignore Error     Read WTS Output Until Pattern Matches      ${pattern5}     timeout=100
        Log to Console      \nRegistering UE 2
        UE Register should be Successful for SA     ${UE2}
        Log to Console      \nDeregistering UE 2
        UE Deregister     ${UE2}
        Log to Console      \nVerifying carrierFreq 694334  msg for UE1
        Run Keyword And Ignore Error    Read WTS Output Until Pattern Matches      ${pattern4}     timeout=100
        Log to console    \n CarrierFreq shold not be present
        Run Keyword And Expect Error    timeout: read timed out.    Pattern should not contain
        [Teardown]      Run Keyword And Ignore Error       Common test case tear down LO AP LO


*** Keywords ***
Pattern should not contain
    Read WTS Output Until Pattern Matches      ${pattern3}     timeout=100
