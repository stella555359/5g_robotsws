*** Settings ***
Documentation    General_SiSo_Cell_lock_and_unlock
Resource   ../Resource/702.robot
Resource   ../Resource/common.robot
Resource   ../../5GC000376/Resource/common.robot

*** Variables ***


*** Keywords ***
Test_Case_General_SiSo_Cell_lock_and_unlock
    ${release}   Get gnb release
#    Run Keyword And Ignore Error   Set Common Test Tag   case_key=cell_lock_unlock
    Connect to gnb coam via ssl
    ${cell_list}   Get All Cell Id
    Set Test Variable   ${CELL_LIST}
    Run Keyword if  '${mrbts_id}' in ${nsa_btsid_list}
    ...   Add PCMD And Start Tcpdump
    General SiSo Cell Lock UnLock
    Log To Console   SiSo Cell Lock UnLock Finish ...
    Log To Console   Start L3Call  Data Transfer Conducted ...
    Run Keyword If   len(${CELL_LIST}) > ${1}   Cell Lock Unlock During L3CALL Beta
    Run Keyword if  '${mrbts_id}' in ${nsa_btsid_list}   Run keywords
    ...   Stop And Download Tcpdump   AND   Run keyword if   '${release}'!='SBTS22R1'
    ...   Check PCMD element ulRlcPduTxBytes_UL_RLCTraceRecord and CU_sgnbAdditionRecord

Case Setup: Cell_lock_and_unlock
    Case Setup

Case Teardown: Cell_lock_and_unlock
    FOR   ${cell_index}   IN   @{CELL_LIST}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
        ${status}   Run Keyword And Return Status   Cell Should Be Unlocked   cell_idx=${cell_index}   cell_group_idx=${cellgrp_id}
        run keyword if  not ${status}   Run Keywords
        ...   Perform cell unlock via rest api    cell_idx=${cell_index}   AND
        ...   Wait Until Keyword Succeeds   20m    30 sec   Cell Should Be Unlocked   cell_idx=${cell_index}   cell_group_idx=${cellgrp_id}
    END
    Wait Until Keyword Succeeds   600 sec   60 sec   COAM Check GNB cell on air
    Run Keyword And Ignore Error   COAM Teardown gnb connections
    Run Keyword And Ignore Error   Case Teardown

General SiSo Cell Lock UnLock
    FOR   ${cell_index}   IN   @{CELL_LIST}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
        Perform cell lock via rest api   cell_idx=${cell_index}
        Wait Until Keyword Succeeds   180 sec   30 sec   Cell Should Be Locked   cell_idx=${cell_index}  cell_group_idx=${cellgrp_id}
    END
    FOR   ${cell_index}   IN   @{CELL_LIST}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
        Perform cell unlock via rest api    cell_idx=${cell_index}
        Wait Until Keyword Succeeds   20m   30 sec   Cell Should Be Unlocked   cell_idx=${cell_index}   cell_group_idx=${cellgrp_id}
    END
    Wait Until Keyword Succeeds   600 sec   60 sec   COAM Check GNB cell on air
    Wait Until Keyword Succeeds   3x   10s   Data Transfer Conducted   tput_expect_DL=1   tput_expect_uL=1

Get Attached Cell Index
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    &{cell_index_mapping}   Create Dictionary
    FOR   ${cell_index}   IN   @{cell_mapping}
        ${nrCellIdentity}   Convert To String   ${cell_mapping[${cell_index}]["nrCellIdentity"]}
        Set To Dictionary   ${cell_index_mapping}   ${nrCellIdentity}=${cell_index}
    END
    ${nrCellId}   Get Attached Cell Indentity
    ${ATTACHED_CELL_INDEX}   Set Variable   ${cell_index_mapping['${nrCellId}']}
    Set Test Variable   ${nrCellId}
    Set Test Variable   ${ATTACHED_CELL_INDEX}
    Log To Console   Attached nrCellIdentity: ${nrCellId}
    Log To Console   Attached Cell Index: ${ATTACHED_CELL_INDEX}

Cell Lock Unlock During L3CALL Beta
#    Wait Until Keyword Succeeds   2x   1m   Call Setup and check tput
#    ...   tput_expect=10   traffic_stop=${false}   duration=1800
    Wait Until Keyword Succeeds   2x   1m   Data Transfer Conducted   traffic_stop=${false}   duration=1800   direction=DL
    ...   tput_expect_DL=50   tput_expect_uL=30
    Get Attached Cell Index
    Lock Unlock NoL3CALL Cells OnebyOne
    Lock Unlock NoL3CALL Cells ALL Onetime
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Lock Unlock NoL3CALL Cells OnebyOne
    LOG TO CONSOLE    Lock Unlock NoL3CALL Cells OnebyOne
    FOR   ${cell_index}   IN   @{CELL_LIST}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
        Run Keyword If   '${cell_index}'!='${ATTACHED_CELL_INDEX}'   Run Keywords
        ...   Perform cell lock via rest api   cell_idx=${cell_index}   AND
        ...   Wait Until Keyword Succeeds   180 sec   30 sec   Cell Should Be Locked   cell_idx=${cell_index}  cell_group_idx=${cellgrp_id}   AND
        ...   Perform cell unlock via rest api    cell_idx=${cell_index}   AND
        ...   Wait Until Keyword Succeeds   20m   30 sec   Cell Should Be Unlocked   cell_idx=${cell_index}  cell_group_idx=${cellgrp_id}   AND
        ...   Wait Until Keyword Succeeds   600 sec   60 sec   COAM Check GNB cell on air   AND
        ...   Wait Until Keyword Succeeds   1min   20s   Check Tput l3call
        ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=DL   cells=${nrCellId}   expect=10
    END

Lock Unlock NoL3CALL Cells ALL Onetime
    LOG TO CONSOLE    Lock Unlock NoL3CALL Cells ALL Onetime
    FOR   ${cell_index}   IN   @{CELL_LIST}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
        Run Keyword If   '${cell_index}'!='${ATTACHED_CELL_INDEX}'   Run Keywords
        ...    Perform cell lock via rest api   cell_idx=${cell_index}   AND
        ...    Wait Until Keyword Succeeds   180 sec   30 sec   Cell Should Be Locked   cell_idx=${cell_index}  cell_group_idx=${cellgrp_id}
    END
    Wait Until Keyword Succeeds   1min   20s   Check Tput l3call
    ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=DL   cells=${nrCellId}   expect=10
    FOR   ${cell_index}   IN   @{CELL_LIST}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
        Run Keyword If   '${cell_index}'!='${ATTACHED_CELL_INDEX}'   Run Keywords
        ...   Perform cell unlock via rest api    cell_idx=${cell_index}   AND
        ...   Wait Until Keyword Succeeds   20m   30 sec   Cell Should Be Unlocked   cell_idx=${cell_index}   cell_group_idx=${cellgrp_id}
    END
    Wait Until Keyword Succeeds   600 sec   60 sec   COAM Check GNB cell on air

Add PCMD And Start Tcpdump
    log to console    Remove PCMD Object
    set test variable   ${INSID}    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    run keyword and ignore error   Remove PCMD Object
    log to console    Add PCMD Object
    Add PCMD Object
    Set Environment Variable              https_proxy                 ${empty}
    asik_handler.connect                i_ipAddr=${ASIK_IP}
    log to console    start tcpdump
    ${SMOD_name}   Get SMOD Product Name
    log to console   SMOD_name=${SMOD_name}
    Run Keyword If     '${SMOD_name}'=='ASIB'
    ...           asik_handler.general_tcpdump_ASIB   i_dir_path=${remote_dir_path}   i_filename=${filename5}
    ...   ELSE IF  '${SMOD_name}'=='ASIK'  asik_handler.general_tcpdump_ASIK   i_dir_path=${remote_dir_path}   i_filename=${filename5}
    ...   ELSE   asik_handler.general_tcpdump_ASOE   i_dir_path=${remote_dir_path}   i_filename=${filename5}

Stop And Download Tcpdump
    asik_handler.kill_tcpdump
    Sleep   5s
    Run keyword and Ignore error  asik_handler.close
    Create Directory     ${Log_directory}
    asik_handler.connect                i_ipAddr=${ASIK_IP}
    asik_handler.download_file_from_Asik	i_filename=${remote_dir_path}/${filename5} 	i_local_path=${Log_directory}/${filename5}

Check PCMD element ulRlcPduTxBytes_UL_RLCTraceRecord and CU_sgnbAdditionRecord
    ${filtered_ulRbRlcMeasRecord_packets}    Load Pcap File with Filter
    ...                        pcap_file=${Log_directory}/${filename5}
    ...                        record_type=Du
    ...                        input_type=5
    ...                        filter=tcp.dstport==48151
    ${ulRbRlcMeasRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.ulRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.UlRadioBearerRlcMeasData_element/nsetapx.endMarker
    ${ulRlcPduTxBytes_value_list}=    wireshark.get_field_value_by_xpath
    ...  xpath=.//nsetapx.ulRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.UlRadioBearerRlcMeasData_element/nsetapx.sumOfRlcPduRxBytes
    Run Keyword If    0 < ${ulRlcPduTxBytes_value_list}[0] < 2533693758 or ${ulRlcPduTxBytes_value_list}[0]==0
    ...    Log To Console   first value is OK
    ${ulRlcPduTxBytes_length}=     Get Length   ${ulRlcPduTxBytes_value_list}
    FOR   ${idx}    IN RANGE    1    ${ulRlcPduTxBytes_length}
        Run Keyword If     2473310208 < ${ulRlcPduTxBytes_value_list}[${idx}] < 2533693758
        ...   Should Be True   ${ulRbRlcMeasRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${ulRlcPduTxBytes_value_list}[${idx}] < 2473310208 or ${ulRlcPduTxBytes_value_list}[${idx}]==0
    END
    Log To Console   check ulRlcPduTxBytes_UL_RLCTraceRecord value is OK

    ${filtered_sgnbAdditionRecord_packets}    Load Pcap File with Filter
    ...                        pcap_file=${Log_directory}/${filename5}
    ...                        record_type=Cu
    ...                        input_type=1
    ...                        filter=tcp.dstport==48151
    ${sgnbAdditionRecord_result_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.sgnbAdditionRecord/nsetapx.data_element/nsetapx.result
    ${sgnbAdditionRecord_result_length}=     Get Length   ${sgnbAdditionRecord_result_list}
    FOR   ${idx}    IN RANGE    1    ${sgnbAdditionRecord_result_length}
        Should Be True      ${sgnbAdditionRecord_result_list}[${idx}] ==0
    END
    Log To Console   check CU_sgnbAdditionRecord value is OK
