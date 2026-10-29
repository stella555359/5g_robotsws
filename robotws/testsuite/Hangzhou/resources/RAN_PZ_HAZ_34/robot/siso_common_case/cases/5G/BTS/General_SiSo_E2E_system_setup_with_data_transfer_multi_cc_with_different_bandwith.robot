*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] set multi cc with different band parameters and make L3 call
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 23.04.2021    - Created
    ...    *******************
    ...    Notice: input parameter bandlist may create by keyword 'create list', for example:[40,50]
    ...    *******************
    ...    OWNER_jiangjing.lin@nokia-sbell.com
    [Arguments]  ${bandlist}    ${cell_id}=${None}  ${ue_num_each_call}=1  ${random_access}=${False}    ${duration}=${300}
    ...    ${4G_check}=${False}    &{kwargs}
    log to console    This keyword will be deprecated, please use General_SiSo_Peak_with_Given_Information instead
    ${test_flag}  set variable  PASS
    ${bands}    set variable    ${EMPTY}
    FOR    ${item}    IN    @{bandlist}
        ${bands}    catenate    SEPARATOR=_    ${bands}    ${item}MHz
    END
    ${length}     Get length    ${frame_structure_list_${bands}}[0][frame]
    FOR    ${index}    IN RANGE    ${length}
        ${frame_info}    Get framestructinfo   framelistname=${frame_structure_list_${bands}}    frameindex=${index}
        ${status}  run keyword and ignore error  Modify_Band_Frame_Structure_And_Test_Throughput_multi_cc_with_different_bandwith
        ...    frames_info=${frame_info}    ue_num_each_call=${ue_num_each_call}  random_access=${random_access}
        ...    cell_id=${cell_id}    duration=${duration}    4G_check=${4G_check}    &{kwargs}
        ${test_flag}  set variable  ${status[0]}
    END
    run keyword if  '${test_flag}'=='FAIL'  fail   not all frame structure pass
