*** Settings ***
Documentation    ...
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_13    CB013098   RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CB008927/Resources/CB008927_resource.robot

*** Variables ***
${SCF_PATH}          ${CURDIR}/Config
${FULL_SCF_15}       CB013098_15_ST_scfc.xml
${WTS_LOCAL}         ${CURDIR}/Config
${IPHY_FILE_15}      ${WTS_LOCAL}/iphy_2T_2F_CA04.xml
${WTS_CFG_15}        CB013098_15_ST_AP.cfg
${RD}                0x580839=1;0x580345=1;0x58090b=1;0x580954=1

*** Test Cases ***
CB013098-B-SR-02-Online_Act_Deact_Function_Verify_NSA
    [Setup]    Prepare TL w gNB_xml '${FULL_SCF_15}' AP_xml '${IPHY_FILE_15}' AP_cfg'${WTS_CFG_15}'
    Set egate rrc log 'on'
    Setup X2 Connection    1    2
    UE '101'-'101' Attach to LTE Cell
    UE '101'-'101' Attach to NR Cell '1'
    Start dl Trafficon on UE '101'-'101' BearerID '2'with '1'mbps
    Start ul Trafficon on UE '101'-'101' BearerID '2'with '1'mbps
    Trigger RLF by suing command        101
    Check PM Counter For RLF
    UE '102'-'102' Attach to LTE Cell
    UE '102'-'102' Attach to NR Cell '1'
    Start dl Trafficon on UE '102'-'102' BearerID '2'with '1'mbps
    Start ul Trafficon on UE '102'-'102' BearerID '2'with '1'mbps
    Online Change One Para With Admin    MRBTS-1/NRBTS-1    actGnbInitRlf    false
    Sleep    450s
    Trigger RLF by suing command        102
    Check PM Counter For RLF

*** Keywords ***
Trigger RLF by suing command
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate MAC HARQ DTX on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    Log To Console    start 5G MAC harq dtx...
    ${cmd1}    Set Variable    rlf_testmode_nr profile_id=4 num_stop_csi_report=2000 num_stop_dlharq_tx=3000
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd1}
    ${cmd2}    Set Variable    ue_testmode_set_nr id=${ue_id} scell=8 testmode=rlf profile_id=4 action=activate
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd2}
    Sleep    10s
Check PM Counter For RLF
    sleep    240s
    Wait Until PM Counter Update    5min
    sleep    180s
    ${M55113C02003_value}    Get Max PM Counter Value With Admin    M55113C02003
    ${M55116C00014_value}    Get Max PM Counter Value With Admin    M55116C00014
    Should Be True    ${M55113C02003_value} == 1
    Should Be True    ${M55116C00014_value} == 1