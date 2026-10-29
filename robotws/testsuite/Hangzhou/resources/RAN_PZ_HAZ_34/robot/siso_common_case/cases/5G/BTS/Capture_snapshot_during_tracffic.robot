*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
Capture_snapshot_during_tracffic
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This test scenario is used to verify the RF memory stability by capturing the snapshot during L3call.
    ...    A5G-TD-1S-2CC-8DL4UL should be config with finnal regression
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.01.2023 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${suite_name}=default    ${test_name}=default    ${loop_times}=2
    FOR    ${time}    IN RANGE    ${loop_times}
        Snapshot and Peak    suite_name=${suite_name}    test_name=${test_name}
    END

Snapshot and Peak
    [Arguments]  ${suite_name}=default    ${test_name}=default
    ${check_cell}    Get Ues Attached Cell    ue_num_each_call=1
    ${cell_list}    create list    ${check_cell}
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=1
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}    duration=3600
    ...    suite_name=${suite_name}    test_name=${test_name}
    ${ue_and_cell}    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}    cell_and_peak_info=${cell_and_peak_info}
    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    Gnb should be onair with cell up
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ${check_cell}    convert to string    ${check_cell}
    ${cell_info}    get from dictionary    ${cell_and_peak_info}    ${check_cell}
    set to dictionary    ${cell_info}    duration=30
    set to dictionary    ${cell_and_peak_info}    ${check_cell}=${cell_info}
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}    cell_and_peak_info=${cell_and_peak_info}
    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}
