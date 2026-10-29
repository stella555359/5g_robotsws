#  *** Settings ***
#  Documentation    5GC000702_AAHF_AAHJ_General_SiSo_Cell_lock_and_unlock
#  Resource   ./Resource/702.robot
#  Resource   ./Resource/common.robot
#  Library   ../libraries/get_bts_info.py
#  Force Tags   SG_08   CA_5G_Siso         CRT   AUTHOR_johnny.1.jiang@nokia-sbell.com
#  ...    PY36
#  Suite Setup   Suite Setup Steps
#  Suite Teardown   Suite Teardown Steps
# 
#  *** Variables ***
#  ${cell_index}   2
#  ${dist_name}   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}
#  &{702_R_tags}   5G19B=495082   5G20A=531957   5G20B=525301   TRUNK=445828
# 
#  *** Test Cases ***
#  [1]5GC000702_AAHF_AAHJ_General_SiSo_Cell_lock_and_unlock
#      [Timeout]    5h
#      [Setup]   Case Setup
#  #    Set Common Test Tag   case_key=cell_lock_unlock
#      COAM Login   alias=cell_info
#      ${bts_info}   coam.get_bts_info   connection=cell_info   timeout=${30}
#      ${cell_num}   Get length   ${bts_info['cells']['nr']}
#      ${group_mapping}   get_cell_group_mapping   bts_info=${bts_info}
#      ${cell_grp_num}   Get length   ${group_mapping}
#      Log To Console   Cells Lock Unlock one by one
#      Cell Lock Unlock One by One   cell_num=${cell_num}
#      run keyword and continue on failure   Data Transfer Conducted    cell_index=${L3CALL_cellid}
#      Log To Console   All cells lock unlock together
#      All Cell locked and unlocked   cell_num=${cell_num}
#      run keyword and continue on failure   Data Transfer Conducted    cell_index=${L3CALL_cellid}
#  #    Log To Console   Cell Groups Lock Unlock one by one
#  #    Cell Group Lock Unlock One by One   cell_grp_num=${cell_grp_num}   group_mapping=${group_mapping}
#  #    run keyword and continue on failure   Wait Until Keyword Succeeds   3x   30s   Call Setup and check tput  tput=1000   tput_expect=100
#  #    Sleep   5m
#  #    Log To Console   All Cell Groups lock unlock together
#  #    All Cell Group Lock and Unlock   cell_grp_num=${cell_grp_num}   group_mapping=${group_mapping}
#  #    Wait Until Keyword Succeeds   3x   30s   Call Setup and check tput  tput=1000   tput_expect=100
#      [Teardown]   Run Keywords   All Cells Should Be Unlocked   cell_num=${cell_num}
#  #    ...   AND    check alarm on COAM    opration=fail    connection=cell_info
#      ...   AND   Run Keyword and Ignore Error   COAM Logout   connection=cell_info
#      ...   AND   Run Keyword and Ignore Error    Case Teardown
#  #
#  #
#  #[1]5GC000702_R_MixConfig1_003_L3_call_after_Cell_lock_unlock_for_AZQG
#  #    [Documentation]   This case for 702_R testing if previous case verified in 702_QA, please keep this case. Thanks
#  #    [Setup]   Case Setup
#  #    ${ru_type}   Read Current RU Type
#  #    ${release}   Get gnb release
#  #    ${cell_index}   Set Variable   5
#  #    Run Keyword If   '${ru_type}'=='AEQN'   Set Tags   QC_${702_R_tags['${release}']}
#  #    ...   ELSE   Pass Execution   No need for case verify
#  #    set test variable   ${ue_index}   1
#  #    Run Keyword If   '${ru_type}'=='AEQN' and '${PREV_TEST_STATUS}'=='FAIL'   Run Keywords
#  #    ...   Cell Operation   index=${cell_index}   operation=Lock
#  #    ...   AND   Cell Operation   index=${cell_index}   operation=Unlock
#  #    Run Keyword If   '${ru_type}'=='AEQN'   Call Setup and check tput  tput=1000   tput_expect=100   cell_index=${cell_index}
#  #    [Teardown]   Run Keywords   Case Teardown
#  ##    ...   AND    check alarm on COAM    opration=fail    connection=cell_info
#  #    ...   AND   Run Keyword and Ignore Error   COAM Logout   connection=cell_info
# 
#  *** Keywords ***
#  All Cells Should Be Unlocked
#      [Arguments]     ${cell_num}
#      :FOR    ${cell_id}    IN RANGE    ${cell_num}
#         ${cell_info}   selenium_coam.Get_Cell_Info    cell_idx=${cell_id+1}
#         Run Keyword If   '${cell_info['Status']['Administrative state'].lower()}'=='locked'
#         ...   Cell Operation   index=${cell_id+1}   operation=Unlocked
#      END
# 
#  Cell Status Confirm
#      [Arguments]   ${index}   ${status}
#      ${cell_info}   selenium_coam.Get_Cell_Info    cell_idx=${index}
#      Should Be Equal   ${cell_info['Status']['Administrative state'].lower()}   ${status.lower()}
# 
#  Cell Group Status Confirm
#      [Arguments]   ${index}   ${status}
#      ${cell_group_status_lock}   selenium_coam.get_cell_group_status   cell_group_idx=${index}
#      Should Be Equal   ${cell_group_status_lock.lower()}   ${status.lower()}
# 
#  Cell Operation
#      [Timeout]   10m
#      [Arguments]   ${index}   ${operation}   ${extra_sleep}=${false}
#      ${action_done}   Run Keyword and Return Status   Cell Status Confirm   index=${index}   status=${operation}
#      run keyword Unless   ${action_done}   wait until keyword succeeds   3 times   20s
#  #    ...   Perform cell ${operation} via rest api   cell_idx=${index}   connection=COAM
#  #    ...   WEBUI Cell and Group Operation   operation=${operation}  cell_idx=${index}
#      ...   Cell Operation State   INSID=${dist_name}   cell_index=${index}    state=${operation}
#      Cell Element Operation   index=${index}   operation=${operation}   element=Cell   extra_sleep=${extra_sleep}
#      ${wait_timer}    Run Keyword If   ${extra_sleep}   Set Variable   15m   ELSE   Set Variable   10m
#      run keyword if   '${operation.lower()}'=='unlock'   Wait for Cell Onair   wait_timer=${wait_timer}   cell_index=${index}
#      Log to Console   Cell ${index} Status reach to required.
# 
#  Wait for Cell Onair
#      [Arguments]   ${wait_timer}   ${cell_index}
#      ${status}   run keyword and return status   wait until keyword succeeds   ${wait_timer}   20s
#      ...   COAM WEBUI Check Cell Status   cell_index=${cell_index}
#      run keyword unless   ${status}   selenium_coam.refresh_page
#      run keyword unless   ${status}   COAM WEBUI Check Cell Status   cell_index=${cell_index}
#      run keyword unless   ${status}   Log to Console   Found cell ${cell_index} status not refresh automatically
# 
#  Cell Group Operation
#      [Timeout]   10m
#      [Arguments]   ${index}   ${operation}   ${group_mapping}   ${extra_sleep}=${false}
#      ${action_done}   Run Keyword and Return Status   Cell Group Status Confirm   index=${index}   status=${operation}
#      Run Keyword Unless   ${action_done}   wait until keyword succeeds   3 times   20s
#      ...   Perform cell group ${operation} via rest api   cellgrp_idx=${index}   connection=COAM
#  #    ...   WEBUI Cell and Group Operation   operation=${operation}   element=Cell Group   cell_group_idx=${index}
#      Cell Element Operation   index=${index}   operation=${operation}   element=Cell Group   extra_sleep=${extra_sleep}
#      ${wait_timer}    Run Keyword If   ${extra_sleep}   Set Variable   17m   ELSE   Set Variable   15m
#      :FOR   ${cell_index}   IN   @{group_mapping[${index}]}
#         Wait Until Keyword Succeeds   ${wait_timer}   20s   Cell Status Confirm   index=${cell_index}   status=${operation}
#      END
# 
#  WEBUI Cell and Group Operation
#      [Arguments]   ${operation}   ${cell_idx}=${EMPTY}   ${cell_group_idx}=${EMPTY}   ${element}=Cell
#      &{parameter}   Run Keyword If   '${element.lower()}'=='cell'   Create Dictionary   cell_idx=${cell_idx}
#      ...   ELSE   Create Dictionary   cell_group_idx=${cell_group_idx}
#      COAM WEBUI Whether Close Start Up View Window
#      ${operation_res}   Run Keyword and Return Status   selenium_coam.${operation} ${element}   &{parameter}
#      Run Keyword Unless   ${operation_res}   Run Keywords   selenium_coam.refresh_page
#      ...   AND   selenium_coam.disable_message_box
#      ...   AND   selenium_coam.${operation} ${element}   &{parameter}
#      Run Keyword Unless   ${operation_res}   Log to Console   Found ${operation} ${element} need to refresh page.
# 
#  Cell Element Operation
#      [Arguments]   ${index}   ${operation}   ${element}   ${extra_sleep}=${false}
#      ${wait_timer}    Run Keyword If   ${extra_sleep}   Set Variable   15m   ELSE   Set Variable   5m
#      ${check_status}   run keyword if   '${element.strip().lower()}'=='cell'   set variable   ${operation}
#      ...   ELSE   set variable   ${operation}
#      Log to Console   ${element} ${index} ${operation} action done.
#      wait until keyword succeeds   ${wait_timer}   10s   run keyword   ${element} Status Confirm   index=${index}   status=${check_status}
#      run keyword if   '${operation.lower()}'=='unlock'   wait until keyword succeeds   ${wait_timer}   10s
#      ...   COAM Check BTS OnAir   connection=cell_info
# 
#  Cell Lock Unlock One by One
#      [Arguments]     ${cell_num}
#      :FOR    ${cell_id}    IN RANGE    ${cell_num}
#         run keyword and continue on failure   Cell Operation   index=${cell_id+1}   operation=Locked
#         run keyword if   ${cell_id}==0   run keyword and continue on failure
#         ...   Wait Until Keyword Succeeds   3x   30s   Data Transfer Conducted    cell_index=${L3CALL_cellid}
#         Cell Operation   index=${cell_id+1}   operation=Unlocked
#      END
# 
#  All Cell locked and unlocked
#      [Arguments]     ${cell_num}
#      :FOR    ${cell_id}    IN RANGE    ${cell_num}
#         run keyword and continue on failure   Cell Operation   index=${cell_id+1}   operation=Locked
#      END
#      :FOR    ${cell_id}    IN RANGE    ${cell_num}
#         ${extra_wait}   Run Keyword If   ${cell_id}==0   set variable   ${true}   ELSE   set variable   ${false}
#         run keyword and continue on failure   Wait Until Keyword Succeeds   3x   10s
#         ...   Cell Operation   index=${cell_id+1}   operation=Unlocked   extra_sleep=${extra_wait}
#      END
# 
#  Cell Group Lock Unlock One by One
#      [Arguments]     ${cell_grp_num}   ${group_mapping}
#      :FOR    ${cell_group_id}    IN RANGE    ${cell_grp_num}
#         run keyword and continue on failure   Cell Group Operation   index=${cell_group_id}   operation=Locked   group_mapping=${group_mapping}
#  #       Check Other Group Cell Status
#         Cell Group Operation   index=${cell_group_id}   operation=Unlocked   group_mapping=${group_mapping}
#      END
# 
#  All Cell Group Lock and Unlock
#      [Arguments]     ${cell_grp_num}   ${group_mapping}
#      :FOR    ${cell_group_id}    IN RANGE    ${cell_grp_num}
#         run keyword and continue on failure   Cell Group Operation   index=${cell_group_id}   operation=Locked   group_mapping=${group_mapping}
#      END
#      Sleep   3m
#      :FOR    ${cell_group_id}    IN RANGE    ${cell_grp_num}
#         ${extra_wait}   Run Keyword If   ${cell_group_id}==0   set variable   ${true}   ELSE   set variable   ${false}
#         run keyword and continue on failure   Cell Group Operation   index=${cell_group_id}   operation=Unlocked
#         ...   group_mapping=${group_mapping}   extra_sleep=${extra_wait}
#      END
# 
#  Check Other Cell Status
#      [Arguments]     ${cell_id}   ${cell_num}
#      :FOR    ${id}    IN RANGE    ${cell_num}
#         run keyword if   '${id}'!='${cell_id}'   wait until keyword succeeds   5m   10s   COAM WEBUI Check Cell Status
#         ...   cell_index=${id+1}
#      END
# 
#  Check Other Group Cell Status
#      [Arguments]     ${cell_group_id}   ${cell_grp_num}   ${group_mapping}
#      :FOR    ${id}    IN RANGE    ${cell_grp_num}
#         run keyword if   '${id}'!='${cell_group_id}'   wait until keyword succeeds   5m   10s   COAM WEBUI Check Cell Status
#         ...   cell_index=${id+1}
#      END