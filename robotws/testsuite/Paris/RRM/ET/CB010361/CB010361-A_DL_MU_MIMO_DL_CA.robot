*** Settings ***
Documentation     [SUITE PURPOSE]   Common keyword of CB010361 feature
...               PCMD additional radio resource usage and quality of service metrics
...               Scope : 10361-A   DLUL MU MIMO PCMD Reports
...               Focus : DL MU MIMO
...
...               Creation Date               : 01-10-2024
...               Version History  Date           Authors                                Notes
...               0.2              01-10-2024     martial.hummel@nokia.com              Creation
...               0.2              01-10-2024     marie-laurence.le_borgne@nokia.com    Creation
...               0.1              25-09-2024     richard.duthu@nokia.com               Produce Scout Data through "Test Teardown" + some RF50 fixes


Library           OperatingSystem
Library           Collections
Library           ArchiveLibrary

Resource          ./resources/robot/CB010361_Tests_Keywords.robot


Suite Setup                 Suite Setup for CB010361
Suite Teardown              Suite Teardown

Test Setup                  CB010361 Test Setup
Test Teardown               CB010361 Test Teardown


*** Variables ***
${TestSharkTool}            MC_SHARK

# PCMD activation
#${Delta_SCF_PCMD}           ${CURDIR}/config/CB010361-A_pcmd_activation_like_WRO.json
${Delta_SCF_PCMD}            ${CURDIR}/config/Act_PCMD_CB010361.json

#Test setting


## ue's settings
&{dict_ue1}                  sa_or_nsa=sa
...                          ueid=1

&{dict_ue2}                  sa_or_nsa=sa
...                          ueid=2

@{dict_ue_all}               ${dict_ue1}
...                          ${dict_ue2}

*** Test Cases ***

[1]CB010361-A_B201_1_PCMD_Monitoring_UE_scheduling_time_DL_MU_MIMO_SA
    Set Suite Variable    ${userneed_Btslog}     ${False}
    Set Suite Variable    ${userneed_TTI}        ${False}
    Set Suite Variable    ${DodIsSet}            ${True}
    Set Suite Variable    ${userneed_PCAP}       ${False}
    Set Suite Variable    ${userneed_PM}         ${False}
    TC_CB010361-SA-DL-MIMO     dict_ues=${dict_ue_all}     ${Delta_SCF_PCMD}
    [Teardown]        Setup.Test Teardown

