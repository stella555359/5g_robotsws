*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/site_prepare.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
*** Variables ***

*** Keywords ***
General_SiSo_Peak_with_Given_Information
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to frame structure
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.09.2022    - Created
    ...    *******************
    ...    Notice: confure cell_id if l3 call with assigned cell
    ...    *******************
    ...    OWNER_tingting.zhong@nokia-sbell.com
    [Arguments]  ${ru_index}=${None}  ${cell_id}=${None}
    ...    ${mimo_mode}=TM3  ${frame_structure}=2/7    ${prach_index}=4
    ...    ${timing_shifter}=OFF    ${scheme_dl}=256QAM
    ...    ${ue_num_for_call_per_cell}=1    ${dl_tp}=100  ${ul_tp}=10
    ...    ${duration}=${200}    ${protocol}=udp    ${check_wait_time}=60
    ...    ${target_avg_percent}=0.5    ${min_percent}=0.1
    ...    ${with_peak}=${False}    ${suite_name}=default    ${test_name}=default
    Site General Modify via Webem    ru_index=${ru_index}
    ...                              mimo_mode=${mimo_mode}
    ...                              frame_structure=${frame_structure}
    ...                              prach_index=${prach_index}
    ...                              timing_shifter=${timing_shifter}
    ...                              scheme_dl=${scheme_dl}
    Wait Until Keyword Succeeds    2min     10s     verify all cells should be onair    cell_type=${cell_type}
    UE L3 Call for Designated cell    ru_index=${ru_index}
    ...                               cell_id=${cell_id}
    ...                               ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
    ...                               dl_tp=${dl_tp}
    ...                               ul_tp=${ul_tp}
    ...                               duration=${duration}
    ...                               protocol=${protocol}
    ...                               check_wait_time=${check_wait_time}
    ...                               target_avg_percent=${target_avg_percent}
    ...                               min_percent=${min_percent}
    ...                               scf_path=${Golden_SCF_Path}
    ...                               with_peak=${with_peak}
    ...                               suite_name=${suite_name}
    ...                               test_name=${test_name}
