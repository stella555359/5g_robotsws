*** Settings ***
Documentation    5GC001098_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call
Resource   ../Resource/common.robot
Resource   ../Resource/702.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library   taf.transport.ssh   WITH NAME   csn



*** Keywords ***
Test_Case_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call
    COAM Login
    ${SCF_FILE}   Get Current SCF File On COAM   IP_WEBUI=${asik_addr}
    Set Test Variable   ${SCF_FILE}
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    Commission_modify_1208_to_1116
    Sleep   1m
    ${before}   DateTime.Get Current Date
    Wait until keyword succeeds  10min   1min   COAM Login
    ${after}   DateTime.Get Current Date
    ${interval}   DateTime.Subtract Date From Date   ${after}   ${before}
    Wait Until Keyword Succeeds   20min   1min   COAM Check All Cells Onair
#    Should Be True   ${interval} > ${30}
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    Commission_modify_1116_to_1208
    Sleep   1m
    ${before}   DateTime.Get Current Date
    Wait until keyword succeeds  10min   1min   COAM Login
    ${after}   DateTime.Get Current Date
    ${interval}   DateTime.Subtract Date From Date   ${after}   ${before}
    Wait Until Keyword Succeeds   20min   1min   COAM Check All Cells Onair
#    Should Be True   ${interval} > ${30}
    Data Transfer Conducted    cell_index=${L3CALL_cellid}

Case Setup: Test_Case_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call
    Case Setup

Case Teardown: Test_Case_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call
    ${status}   run keyword and return status   robot_common_operations.Common Case Teardown
    run keyword if  ${status}    Comission Teardown   ${SCF_FILE}
    Case Teardown
    run keyword and ignore error   COAM Logout

Comission Teardown
    [Arguments]   ${SCF_FILE}
    Wait until keyword succeeds  10min   1min   Import SCF On COAM   IP_WEBUI=${asik_addr}   SCF_FILE=${SCF_FILE}
    Sleep   1m
    Wait until keyword succeeds  10min   1min   COAM Login
    Wait Until Keyword Succeeds   20min   1min   COAM Check All Cells Onair
    Wait until keyword succeeds  10min   1min   Expect Fault Should Absent   faultId=7300   connection=COAM
    COAM Logout

Commission_modify_1208_to_1116
    FOR   ${cell_id}    IN RANGE    ${cells_number}
        _modify_1208_to_1116    cell_id=${cell_id+1}
    END
    selenium_coam.validate_plan    timeout=40
    run keyword and ignore error   selenium_coam.activate_plan  download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
    ...   execute=${True}

_modify_1208_to_1116
    [Arguments]    ${cell_id}
    ${dist_name}    set variable   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_id}
    selenium_coam.set_parameter_value  dist_name=${dist_name}   filter_param=UL to DL logical data slot ratio   new_value=3/7


Commission_modify_1116_to_1208
    FOR   ${cell_id}    IN RANGE    ${cells_number}
        _modify_1116_to_1208    cell_id=${cell_id+1}
    END
    selenium_coam.validate_plan    timeout=40
    run keyword and ignore error   selenium_coam.activate_plan  download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
    ...   execute=${True}

_modify_1116_to_1208
    [Arguments]    ${cell_id}
    ${dist_name}    set variable   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_id}
    selenium_coam.set_parameter_value  dist_name=${dist_name}   filter_param=UL to DL logical data slot ratio   new_value=1/4