# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Adarsha
...             :contact  : adarsha.p_hegde@nokia.com
...             The TC shall help to validate SA Intra-gNB Inter-Freq handover between cells configured between different BW.

Resource        resources/Keywords/CB008278_Keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Suite TearDown for CB008278

*** Variables ***
${UE_ID}    1
${LOG_DIR}              /home/ute/logs
${IEFR_a2meas_id}   1
${IEFR_a3meas_id}   5

*** Test Cases ***
[1][1.0] CB008278-A-c_4 Intra-gNB Intra-frequency handover between cells configured with 10Mhz ChBw in SA Mode
    [Documentation]     Intra-gNB Inter-frequency handover between cells configured with 10Mhz ChBw in SA Mode
    [Tags]    QC_28273   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare for test Case - CB008278_AC4
    Make SA call        ${UE_ID}
    Log to Console      Starting HO
    Trigger A2 Measurement    ${UE_ID}    ${IEFR_a2meas_id}    50
    Trigger A3 Measurement    ${UE_ID}    ${IEFR_a3meas_id}    51
    Sleep   30s
    Stop Data Traffic for SA    ${UE_ID}
    [Teardown]     Run Keyword And Ignore Error          Common test case tear down LO AP LO



