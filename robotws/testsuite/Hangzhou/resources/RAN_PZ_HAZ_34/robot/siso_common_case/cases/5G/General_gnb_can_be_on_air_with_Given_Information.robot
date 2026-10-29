*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
General_gnb_can_be_on_air_with_Given_Information
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to check gNB can air with given frame Structure
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 1.12.2020    - Created
    ...    *******************
    ...    OWNER_zhihao.shi@nokia-sbell.com
    [Arguments]  ${band}=${None}  ${frame_structure}=${None}  ${ru_index}=${None}
    ...    ${use_case_variable}=${false}    ${suite_name}=default    ${test_name}=default
    ...    &{kwargs}
    Modify_Band_Frame_Structure    band=${band}    frame_structure=${frame_structure}
    ...    ru_index=${ru_index}    use_case_variable=${use_case_variable}
    ...    suite_name=${suite_name}    test_name=${test_name}
    ...    &{kwargs}
