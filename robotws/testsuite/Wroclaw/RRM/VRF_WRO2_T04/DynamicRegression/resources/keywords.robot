*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Library       ute_ue
Library       SSHLibrary
Library       ../../../resources/rrm_fixture.py
Library       ../../../resources/webui/interface.py
Library      ./dynamic_regression.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
*** Variables ***
${CA_UE}=     UE_1


*** Keywords ***
Attach UE To Pcell
    [Arguments]    ${ue}    ${alias}=attach
    Set Test Variable    ${log_index}    ${alias}
    Start Tracing On Smod
    ${reserved}    Is Ue Reserved    ${ue}
    Run Keyword If    not ${reserved}    Require Ue    ${ue}    capabilities=${ue}
    Attach UE    ${ue}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds  3x  5s  Log UE Info  ${ue}  IP
    ${pcap_file}=    Stop tracing and download logs from SMOD
    Check Cell And Signal Strength For Ue    ${ue}
    [Return]    ${pcap_file}
    [Teardown]    Run Keywords    Stop Tracing On Smod    AND
    ...    Set Test Variable    ${log_index}    ${EMPTY}   AND
    ...    Set Test Variable    ${${ue}_reserved}    ${True}


Update Parameter
    [Arguments]    ${param}    ${value}    ${distname}=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    Log To Console    Updating param ${param} value to: ${value}
    Perform Parameter Commissioning     parameter=${param}    value=${value}    dist_name=${distname}
    ...    skip_parameter_relation_errors=${FALSE}


Start DL Traffic For Ue
    [Arguments]    ${ue}=UE_1    ${dl_tput}=${MAX_DL_TPUT_1CELL}    ${duration}=60s    ${protocol}=udp    ${dt}=default
    Start Data Transfer  DT_${ue}_${dt}  ${ue}  dl  duration=${duration}  packet_size=1400  throughput=${dl_tput}
    ...    protocol=${protocol}
    Set Test Variable   ${expected_dl_tput_${ue}}    ${dl_tput}
    BuiltIn.Sleep    15    Wait for tput
    Log To Console    ${\n}Tput started: DT_${ue}_${dt}  ${dl_tput}  duration: ${duration}${\n}

Start UL Traffic For Ue
    [Arguments]    ${ue}=UE_1    ${ul_tput}=${MAX_UL_TPUT}    ${duration}=60s    ${protocol}=udp    ${dt}=defaultul
    Start Data Transfer  DT_${ue}_${dt}  ${ue}  ul  duration=${duration}  packet_size=1400  throughput=${ul_tput}
    ...    protocol=${protocol}
    Set Test Variable   ${expected_ul_tput_${ue}}    ${ul_tput}
    BuiltIn.Sleep    15    Wait for tput
    Log To Console    ${\n}Tput started: DT_${ue}_${dt}  ${ul_tput}  duration: ${duration}${\n}

Verify DL Tput For Ue
    [Arguments]    ${ue}=UE_1    ${expected_tput}=${None}    ${threshold}=10%    ${dt}=default
    Log To Console    ${\n}Checking DL tput for UE: ${ue}...
    ${tput}=    Set Variable If    '${expected_tput}' is '${None}'
    ...    ${expected_dl_tput_${ue}}
    ...    ${expected_tput}
    Run Keyword And Continue On Failure    Await Data Transfer Finish  DT_${ue}_${dt}
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation  DT_${ue}_${dt}  ${tput}  ${threshold}

Verify UL Tput For Ue
    [Arguments]    ${ue}=UE_1    ${expected_tput}=${None}    ${threshold}=10%    ${dt}=defaultul
    Log To Console    ${\n}Checking UL tput for UE: ${ue}...
    ${tput}=    Set Variable If    '${expected_tput}' is '${None}'
    ...    ${expected_ul_tput_${ue}}
    ...    ${expected_tput}
    Run Keyword And Continue On Failure    Await Data Transfer Finish  DT_${ue}_${dt}
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation  DT_${ue}_${dt}  ${tput}  ${threshold}


