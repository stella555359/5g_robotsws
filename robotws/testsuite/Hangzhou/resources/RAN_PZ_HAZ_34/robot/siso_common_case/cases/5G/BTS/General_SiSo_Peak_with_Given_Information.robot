*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
General_SiSo_Peak_with_Given_Information
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to frame structure
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.01.2020    - Created
    ...    *******************
    ...    Notice: confure cell_id if l3 call with assigned cell
    ...    *******************
    ...    OWNER_tingting.zhong@nokia-sbell.com
    [Arguments]  ${band}=${None}  ${frame_structure}=${None}  ${ru_index}=${None}  ${cell_id}=${None}  ${ue_num_each_call}=1
    ...    ${protocol}=udp    ${iperf_type}=${None}    ${duration}=${300}    ${loop_times}=${2}    ${use_case_variable}=${false}
    ...    ${random_access}=${False}    ${suite_name}=default    ${test_name}=default    ${4G_check}=${False}
    ...    &{kwargs}
    Modify_Band_Frame_Structure_And_Test_Throughput
    ...    ru_index=${ru_index}    band=${band}    frame_structure=${frame_structure}
    ...    ue_num_each_call=${ue_num_each_call}  random_access=${random_access}  cell_id=${cell_id}    protocol=${protocol}
    ...    iperf_type=${iperf_type}    duration=${duration}    loop_times=${loop_times}    use_case_variable=${use_case_variable}
    ...    suite_name=${suite_name}    test_name=${test_name}   4G_check=${4G_check}
    ...    &{kwargs}
