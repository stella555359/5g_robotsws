*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi Chittoor
                 ...              :contact      : Keerthi
                 ...              :Description  : This script is to validate L3 call in
                 ...                               LO_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,04.08.2025,keerthi.chittoor@nokia.com
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CRT   RAN_5G_TDD   RAN_5G    SBTS00     CONFIGURED

Resource    resources/Keywords/CB008490_KW.robot

Suite Setup        Updated Suite Setup
#Suite Teardown    Common Suite Teardown

*** Variables  ***
${UE1}        1
${UE2}        2
${gnb_ID2}     2
${gnb_ID3}     3
${Log_Path}   /home/ute/logs

*** Test Cases ***
CB008490_Verify PSCELL ADDITION with MN SIMULATED
    Log to Console      Starting the test case\n
    [Setup]     Prepare for the MN Simulated case      CB008490_TC01
    UE Register and verify for SA    ${UE1}
    Prepare Sim gNB
    Set Scg DL Dist Percent     ${gnb_ID2}      50
    PDU Session setup      ${UE1}
    UE Sending Measurment     ${UE1}
    Trigger NR-NR dual connectivity    ${UE1}
    Sleep    30s
    Start and Validate Traffic For SA       UE_ID=${UE1}
    Stop Data Traffic for SA    ${UE1}
    sleep    30s
    UE Deregister should be Successful for SA    ${UE1}
    Log to Console     Starting log collection\n
    Collect Logs For The Test   ${Log_Path}
    Log to Console      \n Starting Tear Down for Test Case
    [Teardown]      Run Keyword And Ignore Error       Common test case tear down for MN Simulated
