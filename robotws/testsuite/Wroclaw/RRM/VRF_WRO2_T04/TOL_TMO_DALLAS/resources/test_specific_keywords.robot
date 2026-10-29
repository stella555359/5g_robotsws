*** Settings ***
Documentation
...    author: Adam Kropiwnicki
...    contact: adam.kropiwnicki@nokia.com

Library        ute_ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008954/resources/keywords_8954.py
Variables      ./test_constants.py

*** Keywords ***
Attach UE With Data Transfer
    [Arguments]  ${duration}   ${ue_alias}   ${direction}=DL    ${filename_postfix}=${EMPTY}
    Log To Console    Attaching ${ue_alias}...
    Tcpdump.Start Tcpdump On Smod    filename=attach_${ue_alias}${filename_postfix}.pcap
    Attach UE    ${ue_alias}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds  3x  5s  Log UE Info  ${ue_alias}  IP
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
    ${bwp}    find_bwp_values    ${pcap_file}
    Log To Console    BWP: ${bwp}
    Check Cell And Signal Strength For Ue    ${ue_alias}
    Log to Console    Starting ${direction} data transfer on ${ue_alias}...
    Start Data Transfer
    ...   dt_name=${ue_alias}_DT_${direction}
    ...   ue_alias=${ue_alias}
    ...   throughput=200 Mbits/sec
    ...   direction=${direction}
    ...   duration=${duration}
    ...   protocol=tcp
    [Teardown]    Tcpdump.Teardown Tcpdump On Smod

Finish Data Transfer Call
    [Arguments]   ${ue_alias}   ${direction}=DL    ${tput_check}=${FALSE}
    Await Data Transfer Finish   ${ue_alias}_DT_${direction}
    Log To Console    ${\n}Checking DL tput for UE: ${ue_alias}...
    Run Keyword If    ${tput_check} is ${TRUE}
    ...    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation  ${ue_alias}_DT_${direction}
    ...    200 Mbits/sec     5%
    Log To Console    Detaching ${ue_alias}
    Wait Until Keyword Succeeds  2x  2s    Detach UE   ${ue_alias}


Verify Cell Id
    [Arguments]    ${ue_alias}    ${expected_cell_id}    ${cell_type}=NR
    ${CELL_INFO}   Get UE Info   ${ue_alias}  CELL_INFO
    ${cell_key}    Set variable if    '${cell_type}' == 'GSM'    cid    pci
    Log To Console    ${CELL_INFO}
    Should be true   ${CELL_INFO}[${cell_key}] == ${expected_cell_id}


Change APN On Ue
    [Arguments]    ${ue}    ${apn}    ${path_to_apn}=Connections,Mobile networks,Access Point Names
    Attach UE    ${ue}
    Wait Until Keyword Succeeds  2x  2s    ute_ue.Change APN   ${ue}    apn_name=${apn}    labels_to_apn_settings=${path_to_apn}
    Detach Ue    ${ue}


Perform L3 Call On Cells
    [Arguments]    ${cells}
    Require UE   ${UE_ALIAS_2}   capabilities=${UE_ALIAS_2}
    FOR    ${cell}    IN    @{cells}
        Set Attach Cell DN   ${ATTACH_CELL_N41_${cell}}
        Deattenuate Attach Cell   ${tl.attenuators}
        Log To Console    Attach cell: ${cell}
        Set Preferred Cell    ${cell}    preffered_value=${-45}
        Attach UE With Data Transfer   60s   ${UE_ALIAS_2}    filename_postfix=_${TEST_NAME}${cell}
        Finish Data Transfer Call    ${UE_ALIAS_2}    tput_check=${TRUE}
    END
    [Teardown]    Wait Until Keyword Succeeds  2x  2s  Detach Ue    ${UE_ALIAS_2}
