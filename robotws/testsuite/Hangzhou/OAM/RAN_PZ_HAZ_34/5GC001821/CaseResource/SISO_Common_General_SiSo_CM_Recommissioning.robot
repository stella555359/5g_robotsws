*** Settings ***
Documentation
...   author: ruiyu.han
...   contact: ruiyu.han@nokia-sbell.com
Resource   ../Resource/702.robot
Resource   ../Resource/common.robot


*** Keywords ***
Manual_SiSo_CM_Recommissioning
    Commission Modify tiltOffset
    Commission Modify manualFrameTimingAdjustment

Case Setup Steps: Manual_SiSo_CM_Recommissioning
    Case Setup
    COAM Backup SCF
    ${cell_numbers}    Siso Get Cell Number
    set suite variable   ${cell_numbers}

Case Teardown Steps: Manual_SiSo_CM_Recommissioning
    ${status}   run keyword and return status   robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   20m   1m   COAM Login   bts_host=192.168.255.129
    run keyword if   ${status}    COAM SCF Commission
    Case Teardown

Commission Modify manualFrameTimingAdjustment
    ${return_value}    COAM WEBUI Get Parameter Value    dist_name=MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ...   filter_param=Manual frame timing adjustment
    ...   abbr=manualFrameTimingAdjustment
    run keyword if   '${return_value}'=='0'   COAM WEBUI Set Parameter Value
    ...    dist_name=MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ...    filter_param=Manual frame timing adjustment
    ...    abbr=manualFrameTimingAdjustment
    ...    new_value=990
    ...    ELSE     Commission Modify manualFrameTimingAdjustment after Recover
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    Wait until keyword succeeds  10min   1min   COAM Check All Cells Onair

Commission Modify tiltOffset
#    run keyword and ignore error    _remove_param_for_all_cell    filter_param=Tilt Offset
    ${return_value}    COAM WEBUI Get Parameter Value    dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${GLOBAL_BTS_ID}/NRCELL-1
    ...   filter_param=Tilt Offset
    ...   abbr=tiltOffset
    run keyword if  '${return_value}'=='${EMPTY}'    _set_param_for_all_cell
    ...    filter_param=Tilt Offset
    ...    abbr=tiltOffset
    ...    new_value=1
    ...    ELSE     Commission Modify tiltOffset after Recover
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True
    Wait until keyword succeeds  10min   1min   COAM Check All Cells Onair

Siso Get Cell Number
    ${cell_list}   COAM Get Cell List
    ${cell_numbers}    get length    ${cell_list}
    [Return]    ${cell_numbers}

_remove_param_for_all_cell
    [Arguments]   ${filter_param}
    FOR   ${index}    IN RANGE    ${cell_numbers}
         selenium_coam.remove_element
         ...   dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${GLOBAL_BTS_ID}/NRCELL-${index+1}
         ...   filter_param=${filter_param}
    END
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True
    Wait until keyword succeeds  10min   1min   COAM Check All Cells Onair

_set_param_for_all_cell
    [Arguments]   ${filter_param}    ${abbr}   ${new_value}
#     :FOR   ${index}    IN RANGE    ${cell_numbers}
#     \     selenium_coam.add_element
#    ...    dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${GLOBAL_BTS_ID}/NRCELL-${index+1}
#    ...    filter_param=${filter_param}
    FOR   ${index}    IN RANGE    ${cell_numbers}
          COAM WEBUI Set Parameter Value
    ...    dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${GLOBAL_BTS_ID}/NRCELL-${index+1}
    ...    filter_param=${filter_param}
    ...    abbr= ${abbr}
    ...    new_value=${new_value}
    END


Commission Modify tiltOffset after Recover
#    _remove_param_for_all_cell    filter_param=Tilt Offset
    _set_param_for_all_cell
    ...    filter_param=Tilt Offset
    ...    abbr=tiltOffset
    ...    new_value=2

Recover manualFrameTimingAdjustment
    COAM WEBUI Set Parameter Value
    ...    dist_name=MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ...    filter_param=Manual frame timing adjustment
    ...    abbr=manualFrameTimingAdjustment
    ...    new_value=0
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    Wait until keyword succeeds  10min   1min   COAM Check All Cells Onair

Commission Modify manualFrameTimingAdjustment after Recover
    Recover manualFrameTimingAdjustment
     COAM WEBUI Set Parameter Value
    ...    dist_name=MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ...    filter_param=Manual frame timing adjustment
    ...    abbr=manualFrameTimingAdjustment
    ...    new_value=990