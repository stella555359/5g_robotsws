*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/loop_prach.robot
*** Variables ***

*** Keywords ***
General_SiSo_Modify_Prach_Online_with_Frame_Structure
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check if calibration of beamforming can be activated
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.11.2022 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell
    [Arguments]  ${prach_index_list}    ${band}=${None}    ${frame_structure}=${None}    ${ue_num_each_call}=1
    ...    ${suite_name}=default    ${test_name}=default
    ${commission_prach}     Evaluate   random.choice(${prach_index_list})    modules=random
    Modify Frame Structure via recommission    band=${band}    frame_structure=${frame_structure}    prach_index=${commission_prach}
    Modify Prach and Make L3 Call    prach_index_list=${prach_index_list}    ue_num_each_call=${ue_num_each_call}
    ...    suite_name=${suite_name}    test_name=${test_name}
