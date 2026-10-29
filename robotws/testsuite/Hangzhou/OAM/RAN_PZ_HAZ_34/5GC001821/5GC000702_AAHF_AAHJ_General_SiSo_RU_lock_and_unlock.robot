#  *** Settings ***
#  Documentation    5GC000702_AAHF_AAHJ_General_SiSo_RU_lock_and_unlock
#  Resource   ./Resource/702.robot
#  Resource   ./Resource/common.robot
#  Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#  Library   taf.transport.ssh   WITH NAME   csn
#  Force Tags   SG_08   CA_5G_Siso         CRT   AUTHOR_johnny.1.jiang@nokia-sbell.com
#  ...    PY36
#  Suite Setup   Suite Setup Steps
#  Suite Teardown   Suite Teardown Steps
# 
#  *** Variables ***
#  @{share_mode}   AAHF   AAHJ
#  ${coam_alias}   cell_info
# 
#  *** Test Cases ***
#  [1]5GC000702_AAHF_AAHJ_General_SiSo_RU_lock_and_unlock
#      [Timeout]    5h
#      [Setup]    Case Setup
#  #    Set Common Test Tag   case_key=ru_lock_unlock
#      run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
#      COAM Login   alias=${coam_alias}
#      General SiSo RU Lock Unlock   connection=${coam_alias}
#      [Teardown]   Run Keywords   Run Keyword and Ignore Error    Case Teardown
#      ...   AND   Run Keyword and Ignore Error   COAM Logout   connection=cell_info
#      ...   AND   run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
# 
#  *** Keywords ***
#  General SiSo RU Lock Unlock
#      [Arguments]    ${connection}=GNB_OAM
#      ${ru_num}    COAM Get GNB RU Number    connection=${connection}
#      @{ru_list}    Create List
#      : FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
#          Append To List    ${ru_list}    ${ru_index}
#      END
#      : FOR    ${ru_index}    IN    @{ru_list}
#          ${cell_group_idx}    Evaluate    ${ru_index}-1
#          Perform RU Lock  ru_index=${ru_index}
#          Wait Until Keyword Succeeds    180 sec    3 sec    RU Should Be Locked    ru_index=${ru_index}    connection=${connection}
#          Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Disabled    cell_idx=${ru_index}    cell_group_idx=${cell_group_idx}
#          ...    connection=${connection}
#      END
#      : FOR    ${ru_index}    IN    @{ru_list}
#          ${cell_group_idx}    Evaluate    ${ru_index}-1
#          Perform RU Unlock    ru_index=${ru_index}
#          Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Unlocked    ru_index=${ru_index}    connection=${connection}
#          Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Enabled    cell_idx=${ru_index}    cell_group_idx=${cell_group_idx}
#          ...   connection=${connection}
#          Wait Until Keyword Succeeds    600 sec   5 sec     COAM Check GNB cell on air    connection=${connection}
#      END
#      COAM WEBUI Login   display=${${DEBUG}}
#      ${start_view}   selenium_coam.start_up_view_window_exists
#      Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
#      run keyword and continue on failure     Data Transfer Conducted    cell_index=${L3CALL_cellid}
# 
# 
