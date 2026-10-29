*** Settings ***
Resource         ./../../CUDU_L2/common_setup_teardown.robot
Resource         ./../../CUDU_L2/common_CA_DSS.robot


*** Variables ***
${PDU_ID}
${REORDERING_WINDOW_SIZE}           500
${REORDERING_TIMER}                 300                    1

*** Keywords ***
Configure 3CELL DSS
    [Arguments]    ${prb_list}    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
    Setup XP LINK    ${ENBID}    ${GNBID}
    Enable DSS DMS3 Feature On    ${ENBID}
    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL1_ID}    ${ANTP_NUM}
    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL2_ID}    ${ANTP_NUM}
    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL3_ID}    ${ANTP_NUM}
    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}
    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL2_ID}
    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL3_ID}
    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL1_ID}
    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL2_ID}
    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL3_ID}
    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}    DL
    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL2_ID}    DL
    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL3_ID}    DL
    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL1_ID}
    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL2_ID}
    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL3_ID}
    Cell Allocation    ${ALLOC_SUBFRAME1}    ${prb_list}    ${ENBID}    ${GNBID}    ${CELL1_ID}
    Cell Allocation    ${ALLOC_SUBFRAME1}    ${prb_list}    ${ENBID}    ${GNBID}    ${CELL2_ID}
    Cell Allocation    ${ALLOC_SUBFRAME2}    ${prb_list}    ${ENBID}    ${GNBID}    ${CELL3_ID}

Check All UE Scell On EGate Console Log
    [Arguments]    ${egate_path}
    ${content}    OperatingSystem.Get File    ${egate_path}
    ${patt}    Set Variable    sCellIndex\\s+(?P<index>\\w+),
    ${matches}    String.Get Regexp Matches    ${content}    ${patt}
    ${index}    Create List    sCellIndex 1,    sCellIndex 2
    #Collections.Lists Should Be Equal    ${matches}    ${index}

Start SA UE Big Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    mbps=175    trf_id=${t_time}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    mbps=${last_mbps}    trf_id=${dl_times+1}

Multi 2CC UE Check TPUT
    [Arguments]    ${ca_ue_list}    ${pdu_id}    ${pcell_ul_tput}    ${pcell_dl_tput}    ${scell1_dl_tput}
    FOR    ${ue_id}    IN    @{ca_ue_list}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${pcell_dl_tput}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=1    target_tp=${scell1_dl_tput}
        ${ul_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ul
        ${tp_delta}    Evaluate    ${ul_tp}-${pcell_ul_tput}
        Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
        Log To Console    UE${ue_id} pcell ultput is on target: ${pcell_ul_tput}Mb \n
    END

Multi 3CC UE Check TPUT
    [Arguments]    ${ca_ue_list}    ${pdu_id}    ${pcell_ul_tput}    ${pcell_dl_tput}    ${scell1_dl_tput}    ${scell2_dl_tput}
    FOR    ${ue_id}    IN    @{ca_ue_list}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${pcell_dl_tput}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=1    target_tp=${scell1_dl_tput}
        Check UE Pcell Scell TP On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=2    target_tp=${scell2_dl_tput}
        ${ul_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ul
        ${tp_delta}    Evaluate    ${ul_tp}-${pcell_ul_tput}
        Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
        Log To Console    UE${ue_id} pcell ultput is on target: ${pcell_ul_tput}Mb \n
    END

Stop Multi SA UE Traffic
    [Arguments]    ${ca_ue_list}    ${pdu_id}
    FOR    ${ue_id}    IN    @{ca_ue_list}
    SA Stop DL Traffic EGate    ${ue_id}    ${pdu_id}
    SA Stop DL Traffic EGate    ${ue_id}    ${pdu_id}    2
    SA Stop UL Traffic EGate    ${ue_id}    ${pdu_id}
    END

Check UE Pcell Scell TP On Target
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}    ${target_tp}
    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    ${tp_delta}    Evaluate    ${tput}-${target_tp}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    UE${ue_id} ${cell_type} ${scell_index} The tput is on target: ${target_tp}Mb \n


Multi 3CC UE Attach With Blind
    [Arguments]    ${ca_ue_list}    ${scell_physicalid_list}
    FOR    ${ue_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${scell_physicalid_list}
        SA 5G CA Attach    ${ue_id}
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[0]    1
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[1]    2
    END

Multi 2CC UE Attach With Blind
    [Arguments]    ${ca_ue_list}    ${scell_physicalid_list}
    FOR    ${ue_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${scell_physicalid_list}
        SA 5G CA Attach    ${ue_id}
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}[0]    1
    END

Start Multi SA UE Big Traffic
    [Arguments]    ${ca_ue_list}    ${pdu_id}    ${mbps}
    FOR    ${ue_id}    IN    @{ca_ue_list}
        Start SA UE Big Traffic    ${ue_id}    ${pdu_id}    ${mbps}
    END

Start Multi SA UE Traffic
    [Arguments]    ${ca_ue_list}    ${pdu_id}    ${trf_type}    ${mbps}
    FOR    ${ue_id}    IN    @{ca_ue_list}
        Run Keyword If    "${trf_type}"=="dl"    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}
        Run Keyword If    "${trf_type}"=="ul"    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}
    END

SA Stop DL Traffic EGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | SA Stop DL Traffic EGate| 1 | 2 |
    Log To Console    stop DL traffic...\n
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=dl trf_id\=${trf_id}

SA Stop UL Traffic EGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | SA Stop UL Traffic EGate| 1 | 2 |
    Log To Console    stop UL traffic...\n
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=ul trf_id\=${trf_id}

Change GNB From Fullstack To L1bypass ASOE
    ute_fsmaccess.Setup Enb Fsm Access
    ${set_l1bypass_cmd}    Set Variable    echo "tag -3w app.btsom.nts.L1BypassMap 0x104D:0x574A" | nc 0 15007
    ute_fsmaccess.Execute Command On Enb    ${set_l1bypass_cmd}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access

