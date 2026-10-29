*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Library    testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.tcpdump_aic.tcpdump_aic_collector
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot

*** Keywords ***
Attach UE Aic
    [Arguments]    ${ue}    ${num_of_scells}=1    ${alias}=UE_1    ${vonr}=${FALSE}    ${scells_id}=${EMPTY}
    Start F1c And Ngc Tcpdump    filename=attach_${alias}.pcap
    ${reserved}    Is Ue Reserved    ${ue}
    Run Keyword If    not ${reserved}    ute_ue.Require Ue    ${ue}    capabilities=${ue}
    ute_ue.Attach UE    ${ue}    timeout=${120}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds  3x  5s  ute_ue.Log UE Info  ${ue}  IP
    Check Cell And Signal Strength For Ue    ${ue}
    ${pcap_file}=    Stop F1c And Ngc Tcpdump
    Ue Attached To Pcell And Scells    ${pcap_file}    ${num_of_scells}    ${scells_id}    vonr=${vonr}
    [Return]    ${pcap_file}
    [Teardown]    Run Keywords
    ...    Set Test Variable    ${${ue}_reserved}    ${True}    AND
    ...    Teardown Tcpdump Aic


Attach Ue Without Logging
    [Arguments]    ${ue}
    ${reserved}    Is Ue Reserved    ${ue}
    Run Keyword If    not ${reserved}    ute_ue.Require Ue    ${ue}    capabilities=${ue}
    ute_ue.Attach UE    ${ue}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds  3x  5s  ute_ue.Log UE Info  ${ue}  IP
    Check Cell And Signal Strength For Ue    ${ue}
    [Teardown]    Set Test Variable    ${${ue}_reserved}    ${True}
