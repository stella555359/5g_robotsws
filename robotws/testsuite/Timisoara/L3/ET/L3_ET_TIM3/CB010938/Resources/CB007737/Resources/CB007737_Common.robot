*** Settings ***
Resource         ./../../../CUDU_L2/common_setup_teardown.robot


*** Variables ***
${PDU_ID}                    1

*** Keywords ***

CAL PDUID
    [Arguments]    ${ue_id}
    ${num}    set Variable    15
    ${pdu_id}    Evaluate    ${ue_id}%${num}
    ${pdu_id}    Run Keyword If    '${pdu_id}'=='0'    Evaluate    ${num}
    ...                        ELSE    Evaluate    ${pdu_id}+0
    [Return]    ${pdu_id}

SA 5G CA Attach With PDU
    [Arguments]    ${ue_id}    ${pdu_id}
    [Documentation]    This keyword is to 5G UE attach for SA CA.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | YES | id of ue |
    ...    | pdu_id | No | id of pdu ，the default value is 1 |
    ...    This keyword return the output of the egate command to use for other checking.
    ...
    ...    | Examples: |
    ...    | ${output} | SA CA 5G Attach | 1 | 1 |
    ...
    Set UEC Reordering Timer
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    ${output}    SA 5G CA PDU Sessions Setup    ${ue_id}    ${pdu_id}
    [Return]    ${output}

SA 5G CA PDU Sessions Setup
    [Arguments]    ${ue_id}    ${pdu_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | A1_add | No | ${true} |
    ...    | drx_on | No | ${true} |
    ...    This keyword return the output of the egate command to use for other checking.
    ...    Example:
    ...    | SA CA 5G PDU Session Setup | 1 |
    ...
    Log To Console    start 5G PDU Session Setup...
    ${pdu_id}    CAL PDUID    ${ue_id}
    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output_0}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3min
    ${output}    String.Get Lines Matching Regexp    ${output_0}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}
    [Return]    ${output_0}

Multi NonCA UE Attach With Blind
    [Arguments]    ${start_ue_num}    ${stop_ue_num}
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        ${pdu_id}    CAL PDUID    ${ue_id}
        SA 5G CA Attach With PDU    ${ue_id}    ${pdu_id}
    END

Multi 2CC UE Attach With Blind
    [Arguments]    ${ca_ue_list}    ${scell_physicalid_list}
    FOR    ${ue_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${scell_physicalid_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        SA 5G CA Attach With PDU    ${ue_id}    ${pdu_id}
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[0]    1
    END

Multi 3CC UE Attach With Blind
    [Arguments]    ${ca_ue_list}    ${scell_physicalid_list}
    FOR    ${ue_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${scell_physicalid_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        SA 5G CA Attach With PDU    ${ue_id}    ${pdu_id}
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[0]    1
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[1]    2
    END

Multi 4CC UE Attach With Blind
    [Arguments]    ${ca_ue_list}    ${scell_physicalid_list}
    FOR    ${ue_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${scell_physicalid_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        SA 5G CA Attach With PDU    ${ue_id}    ${pdu_id}
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[0]    1
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[1]    2
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[2]    3
    END

Multi 2CC UE Attach With A1
    [Arguments]    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}    ${a1Threshold}=105
    FOR    ${ue_id}    ${pcell_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        SA 5G CA Attach With PDU    ${ue_id}    ${pdu_id}
        Trigger A1 Scell Addition    ${ue_id}    ${a1Threshold}    ${pcell_id}
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[0]    1
    END

Multi 3CC UE Attach With A1
    [Arguments]    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}    ${a1Threshold}=105
    FOR    ${ue_id}    ${pcell_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        SA 5G CA Attach With PDU    ${ue_id}    ${pdu_id}
        Trigger A1 Scell Addition    ${ue_id}    ${a1Threshold}    ${pcell_id}
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[0]    1
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[1]    2
    END

Multi 4CC UE Attach With A1
    [Arguments]    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}    ${a1Threshold}=105
    FOR    ${ue_id}    ${pcell_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        SA 5G CA Attach With PDU    ${ue_id}    ${pdu_id}
        Trigger A1 Scell Addition    ${ue_id}    ${a1Threshold}    ${pcell_id}
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[0]    1
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[1]    2
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[2]    3
    END

Start NonCA Multi SA UE Traffic
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${trf_type}    ${mbps}
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        ${pdu_id}    CAL PDUID    ${ue_id}
        Run Keyword If    "${trf_type}"=="dl"    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}
        Run Keyword If    "${trf_type}"=="ul"    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}
    END

Start Multi SA UE Traffic
    [Arguments]    ${ca_ue_list}    ${trf_type}    ${mbps}
    FOR    ${ue_id}    IN    @{ca_ue_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        Run Keyword If    "${trf_type}"=="dl"    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}
        Run Keyword If    "${trf_type}"=="ul"    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}
    END

Start SA UE Big Traffic
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    ${pdu_id}    CAL PDUID    ${ue_id}
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    mbps=175    trf_id=${t_time}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    mbps=${last_mbps}    trf_id=${dl_times+1}

Start Multi SA UE Big Traffic
    [Arguments]    ${ca_ue_list}    ${mbps}
    FOR    ${ue_id}    IN    @{ca_ue_list}
        Start SA UE Big Traffic    ${ue_id}    ${mbps}
    END

Multi NonCA UE Check TPUT
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${pcell_ul_tput}    ${pcell_dl_tput}
     FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        ${pdu_id}    CAL PDUID    ${ue_id}
        ${dl_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    dl
        ${dtp_delta}    Evaluate    ${dl_tp}-${pcell_dl_tput}
        Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
        ${ul_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ul
        ${utp_delta}    Evaluate    ${ul_tp}-${pcell_ul_tput}
        Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
        Log To Console    UE${ue_id} pcell ultput is on target: ${pcell_ul_tput}Mb \n
    END

Multi 2CC UE Check TPUT
    [Arguments]    ${ca_ue_list}    ${pcell_ul_tput}    ${pcell_dl_tput}    ${scell1_dl_tput}
    FOR    ${ue_id}    IN    @{ca_ue_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${pcell_dl_tput}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=1    target_tp=${scell1_dl_tput}
        ${ul_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ul
        ${tp_delta}    Evaluate    ${ul_tp}-${pcell_ul_tput}
        Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
        Log To Console    UE${ue_id} pcell ultput is on target: ${pcell_ul_tput}Mb \n
    END

Multi 3CC UE Check TPUT
    [Arguments]    ${ca_ue_list}    ${pcell_ul_tput}    ${pcell_dl_tput}    ${scell1_dl_tput}    ${scell2_dl_tput}
    FOR    ${ue_id}    IN    @{ca_ue_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${pcell_dl_tput}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=1    target_tp=${scell1_dl_tput}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=2    target_tp=${scell2_dl_tput}
        ${ul_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ul
        ${tp_delta}    Evaluate    ${ul_tp}-${pcell_ul_tput}
        Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
        Log To Console    UE${ue_id} pcell ultput is on target: ${pcell_ul_tput}Mb \n
    END

Multi 4CC UE Check TPUT
    [Arguments]    ${ca_ue_list}    ${pcell_ul_tput}    ${pcell_dl_tput}    ${scell1_dl_tput}    ${scell2_dl_tput}    ${scell3_dl_tput}
    FOR    ${ue_id}    IN    @{ca_ue_list}
        ${pdu_id}    CAL PDUID    ${ue_id}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${pcell_dl_tput}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=1    target_tp=${scell1_dl_tput}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=2    target_tp=${scell2_dl_tput}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=3    target_tp=${scell3_dl_tput}
        ${ul_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ul
        ${tp_delta}    Evaluate    ${ul_tp}-${pcell_ul_tput}
        Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
        Log To Console    UE${ue_id} pcell ultput is on target: ${pcell_ul_tput}Mb \n
    END

Check UE Pcell Scell TP On Target
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}    ${target_tp}
    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    ${tp_delta}    Evaluate    ${tput}-${target_tp}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    UE${ue_id} ${cell_type} ${scell_index} The tput is on target: ${target_tp}Mb \n

Set L1 RD Parameter
    [Arguments]    ${domain}    ${key}    ${value}
    Write L1 RD Param    1    ${domain}    ${key}    ${value}
    Check L1 RD Param Change    1    ${domain}    ${key}
    ${value}    Read L1 RD Param    1    ${domain}    ${key}

Lock Cell
    [Arguments]    ${cell_name}
    Log To Console    Cell ${cell_name} Locked
    Setup Admin
    Block Cell    dist_name=${cell_name}
    Sleep    30s    reason=wait for gnb ok
    Teardown Admin

Unlock Cell
    [Arguments]    ${cell_name}
    Log To Console    Cell ${cell_name} Unlocked
    Setup Admin
    UnBlock Cell    dist_name=${cell_name}
    Teardown Admin

Delta Commission
    [Arguments]    ${delta_scf}
    ${scf_file_type}    Get File Type    ${delta_scf}
    Run Keyword If    '${scf_file_type}'=='json'    Delta Commission With SCF File    ${delta_scf}

Read L1 RD Param
    [Arguments]    ${board_num}    ${domain}    ${key}
    ${read_cmd}    Catenate    SEPARATOR=${SPACE}    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip}
    ...    bsh ${board_num}:1 confmgmtbrowser read ${domain} ${key}
    ${ret}    ${output}    OperatingSystem.Run And Return Rc And Output    ${read_cmd}
    ${value}    Get Regexp Matches    ${output}    VALUE:\\s(?P<param_value>\\d+)    param_value
    [Return]    ${value}[0]

Write L1 RD Param
    [Arguments]    ${board_num}    ${domain}    ${key}    ${value}
    ${write_cmd}    Catenate    SEPARATOR=${SPACE}    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip}
    ...    bsh ${board_num}:1 confmgmtbrowser write ${domain} ${key} ${value}
    ${ret}    ${output}    OperatingSystem.Run And Return Rc And Output    ${write_cmd}

Check L1 RD Param Change
    [Arguments]    ${board_num}    ${domain}    ${key}
    ${change_cmd}    Catenate    SEPARATOR=${SPACE}    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip}
    ...    bsh ${board_num}:1 journalctl -b | grep processRadParametersChange
    ${ret}    ${output}    OperatingSystem.Run And Return Rc And Output    ${change_cmd}
    Should Contain    ${output}    ${key}

Suite Setup Start WTS L1RD And Check OnAir
    [Arguments]        ${log}=${True}    ${enb_id}=2    ${gnb_id}=1
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Set L1 RD Parameter    NrUlPhy    ulRdAdvancedTimingWindow    1
    Set L1 RD Parameter    NrDlPhy    rdAdvancedTimingWindow    1
    Start UTE WTS
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection    ${enb_id}    ${gnb_id}
    Run Keyword If    '${GNBCUTYPE}'=='SANSA' or '${GNBCUTYPE}'=='SA'    Check All Cells Received SIB2
    Verify Cell Setup
    [Teardown]    Run Keyword If    "${log}"=="${True}"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
