*** Settings ***
Documentation
    ...    Author: zhe.1.lin@nokia-sbell.com
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library   OperatingSystem
Library   XML    True
Variables   ../../libraries/global_vars.py
Variables   ../Library/config_vars.py
Resource   ../../common/taf_env.robot
Resource   ./coam.robot
Resource   ./CPRI.robot
Library   taf.pdu   WITH NAME   pdu
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Library    taf.analyzer.pcap     WITH NAME    cap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${cell_id}    1
${cell_index}    1
${L3CALL_cellid}    1
${iperf_port}      ${tl.ues[0].iperf_details.port}
${lua_script_path}   /home/ute/luashark_script/generated_luashark/luashark.lua

*** Keywords ***
All Cells Should Be Unlocked
    [Arguments]     ${cell_num}
    FOR    ${cell_id}    IN RANGE    ${cell_num}
       ${cell_info}   selenium_coam.Get_Cell_Info    cell_idx=${cell_id+1}
       Run Keyword If   '${cell_info['Status']['Blocking state'].lower()}'=='blocked'
       ...   Cell Operation   index=${cell_id+1}   operation=Unblock
    END

Cell Status Confirm
    [Arguments]   ${index}   ${status}
    ${cell_info}   selenium_coam.Get_Cell_Info    cell_idx=${index}
    Should Be Equal   ${cell_info['Status']['Blocking state'].lower()}   ${status.lower()}

Cell Group Status Confirm
    [Arguments]   ${index}   ${status}
    ${cell_group_status_lock}   selenium_coam.get_cell_group_status   cell_group_idx=${index}
    Should Be Equal   ${cell_group_status_lock.lower()}   ${status.lower()}

Cell Operation
    [Timeout]   10m
    [Arguments]   ${index}   ${operation}   ${extra_sleep}=${false}
    ${action_done}   Run Keyword and Return Status   Cell Status Confirm   index=${index}   status=${operation}ed
    run keyword if  not ${action_done}   wait until keyword succeeds   3 times   20s
    ...   WEBUI Cell and Group Operation   operation=${operation}  cell_idx=${index}
    Cell Element Operation   index=${index}   operation=${operation}   element=Cell   extra_sleep=${extra_sleep}
    ${wait_timer}    Run Keyword If   ${extra_sleep}   Set Variable   15m   ELSE   Set Variable   10m
    run keyword if   '${operation.lower()}'=='unblock'   Wait for Cell Onair   wait_timer=${wait_timer}   cell_index=${index}
    Log to Console   Cell ${index} Status reach to required.

Wait for Cell Onair
    [Arguments]   ${wait_timer}   ${cell_index}
    ${status}   run keyword and return status   wait until keyword succeeds   ${wait_timer}   20s
    ...   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   selenium_coam.refresh_page
    run keyword if  not ${status}   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   Log to Console   Found cell ${cell_index} status not refresh automatically

Cell Group Operation
    [Timeout]   10m
    [Arguments]   ${index}   ${operation}   ${group_mapping}   ${extra_sleep}=${false}
    ${action_done}   Run Keyword and Return Status   Cell Group Status Confirm   index=${index}   status=${operation}ed
    run keyword if  not ${action_done}   wait until keyword succeeds   3 times   20s
    ...   WEBUI Cell and Group Operation   operation=${operation}   element=Cell Group   cell_group_idx=${index}
    Cell Element Operation   index=${index}   operation=${operation}   element=Cell Group   extra_sleep=${extra_sleep}
    ${wait_timer}    Run Keyword If   ${extra_sleep}   Set Variable   15m   ELSE   Set Variable   10m
    FOR   ${cell_index}   IN   @{group_mapping[${index}]}
       Wait Until Keyword Succeeds   ${wait_timer}   20s   Cell Status Confirm   index=${cell_index}   status=${operation}ed
    END

WEBUI Cell and Group Operation
    [Arguments]   ${operation}   ${cell_idx}=${EMPTY}   ${cell_group_idx}=${EMPTY}   ${element}=Cell
    &{parameter}   Run Keyword If   '${element.lower()}'=='cell'   Create Dictionary   cell_idx=${cell_idx}
    ...   ELSE   Create Dictionary   cell_group_idx=${cell_group_idx}
    ${operation_res}   Run Keyword and Return Status   selenium_coam.${operation} ${element}   &{parameter}
    run keyword if  not ${operation_res}   Run Keywords   selenium_coam.refresh_page
    ...   AND   selenium_coam.disable_message_box
    ...   AND   selenium_coam.${operation} ${element}   &{parameter}
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
#    run keyword and ignore error   Save or Remove logs
    run keyword if  not ${operation_res}   Log to Console   Found ${operation} ${element} need to refresh page.

Cell Element Operation
    [Arguments]   ${index}   ${operation}   ${element}   ${extra_sleep}=${false}
    ${wait_timer}    Run Keyword If   ${extra_sleep}   Set Variable   15m   ELSE   Set Variable   5m
    ${check_status}   run keyword if   '${element.strip().lower()}'=='cell'   set variable   ${operation}ed
    ...   ELSE   set variable   ${operation}
    Log to Console   ${element} ${index} ${operation} action done.
    wait until keyword succeeds   ${wait_timer}   10s   run keyword   ${element} Status Confirm   index=${index}   status=${check_status}
    run keyword if   '${operation.lower()}'=='unblock'   wait until keyword succeeds   ${wait_timer}   10s
    ...   COAM Check BTS OnAir   connection=cell_info

Cell Lock Unlock One by One
    [Arguments]     ${cell_num}
    FOR    ${cell_id}    IN RANGE    ${cell_num}
       run keyword and continue on failure   Cell Operation   index=${cell_id+1}   operation=block
       run keyword if   '${cell_id}'!='${${L3CALL_cellid}-${1}}'   run keyword and continue on failure   Data Transfer Conducted    cell_index=1
       Cell Operation   index=${cell_id+1}   operation=Unblock
    END

Cell Lock Unlock During L3CALL
   [Arguments]    ${cell_num}   ${cell_id}=1
   ${L3CALL_duration}    set variable    ${${cell_num}* 240}s
   Wait Until Keyword Succeeds   3x   1m
   ...    Data Transfer Conducted    cell_index=${L3CALL_cellid}   bip_enable=${false}
   ...    traffic_stop=${false}    duration=${L3CALL_duration}
   _lock_unlock_noL3CALL_cells_onebyone    cell_num=${cell_num}
   _lock_unlock_all_noL3CALL_onetime    cell_num=${cell_num}

_lock_unlock_noL3CALL_cells_onebyone
    [Arguments]    ${cell_num}
    LOG TO CONSOLE    lock_unlock_noL3CALL_cells_onebyone
    FOR    ${cell_id}    IN RANGE    ${cell_num}
        run keyword if   '${cell_id}'!='${${L3CALL_cellid}-${1}}'    run keywords
       ...   Cell Operation   index=${cell_id+1}   operation=block
       ...   AND    wait until keyword succeeds    1min   20s   l3call.Check Throughput
       ...     ue_type=${ue_${ue_index}_type}   direction=DL   throughput=10
       ...   AND    Cell Operation   index=${cell_id+1}   operation=Unblock
    END

_lock_unlock_all_noL3CALL_onetime
    [Arguments]    ${cell_num}
    LOG TO CONSOLE    lock_unlock_all_noL3CALL_onetime
    FOR    ${cell_id}    IN RANGE    ${cell_num}
        run keyword if   '${cell_id}'!='${${L3CALL_cellid}-${1}}'
       ...   run keyword and continue on failure   Cell Operation   index=${cell_id+1}   operation=block
    END
    wait until keyword succeeds    1min   20s   l3call.Check Throughput
     ...     ue_type=${ue_${ue_index}_type}   direction=DL   throughput=10
    FOR    ${cell_id}    IN RANGE    ${cell_num}
       run keyword and continue on failure   Wait Until Keyword Succeeds   3x   10s
       ...   Cell Operation   index=${cell_id+1}   operation=Unblock
    END

All Cell locked and unlocked
    [Arguments]     ${cell_num}
    FOR    ${cell_id}    IN RANGE    ${cell_num}
       run keyword and continue on failure   Cell Operation   index=${cell_id+1}   operation=block
    END
    FOR    ${cell_id}    IN RANGE    ${cell_num}
       ${extra_wait}   Run Keyword If   ${cell_id}==0   set variable   ${true}   ELSE   set variable   ${false}
       run keyword and continue on failure   Wait Until Keyword Succeeds   3x   10s
       ...   Cell Operation   index=${cell_id+1}   operation=Unblock   extra_sleep=${extra_wait}
    END

Cell Group Lock Unlock One by One
    [Arguments]     ${cell_grp_num}   ${group_mapping}
    FOR    ${cell_group_id}    IN RANGE    ${cell_grp_num}
       run keyword and continue on failure   Cell Group Operation   index=${cell_group_id}   operation=block   group_mapping=${group_mapping}
#       Check Other Group Cell Status
       Cell Group Operation   index=${cell_group_id}   operation=Unblock   group_mapping=${group_mapping}
    END

All Cell Group Lock and Unlock
    [Arguments]     ${cell_grp_num}   ${group_mapping}
    FOR    ${cell_group_id}    IN RANGE    ${cell_grp_num}
       run keyword and continue on failure   Cell Group Operation   index=${cell_group_id}   operation=block   group_mapping=${group_mapping}
    END
    Sleep   3m
    FOR    ${cell_group_id}    IN RANGE    ${cell_grp_num}
       ${extra_wait}   Run Keyword If   ${cell_group_id}==0   set variable   ${true}   ELSE   set variable   ${false}
       run keyword and continue on failure   Cell Group Operation   index=${cell_group_id}   operation=Unblock
       ...   group_mapping=${group_mapping}   extra_sleep=${extra_wait}
    END

General SiSo RU Module Reset From GUI
    [Arguments]    ${connection}=GNB_OAM
    ${ru_num}    COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        ${cell_group_idx}    Evaluate    ${ru_index}-1
        Perform RU Reset    ru_index=${ru_index}
        Wait Until Keyword Succeeds    90 sec    5 sec    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
#        Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Disabled    cell_idx=${ru_index}    cell_group_idx=${cell_group_idx}
#        ...    connection=${connection}
    END
    wait until keyword succeeds   20m   30s   COAM Check All Cells Onair   connection=${connection}
