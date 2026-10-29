*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
*** Variables ***

*** Keywords ***
General_SiSo_RAT_Block_Unblock
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check RAT_block_unblocked-reset can be successful and duration meet requirement.
    ...    should not be affected
    ...    WebUI interface.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.12.2023 - - Created
    ...    - 26.08.2024 - - Modified by Zeng Qunfang: Add MAX_LOOP parameter to control the number of iterations.
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${with_call}=${False}    ${with_peak}=${False}    ${duration}=${60}  ${ue_num_each_call}=1    ${MAX_LOOP}=${1}
    Selenium Login And Disable Screen Lock
    ${cell_list}    get all cell id
    FOR    ${TEST_LOOP}    IN RANGE    1    ${MAX_LOOP}+1
        Log To Console    \n RAT Block/Unblock Iteration:${TEST_LOOP}
        Block RAT and Check    cell_list=${cell_list}
        Unblock RAT and Check    cell_list=${cell_list}
        run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    END
    [Teardown]  Selenium Logout And Close Browser

Block RAT and Check
    [Arguments]  ${cell_list}    ${technology}=NR
    selenium_coam.block_rat    rat=${technology}
    Wait For Expect Fault Present    faultId=4614    timeout=120
    ${cell_list}    get all cell id
    FOR    ${cell_id}    IN    @{cell_list}
        check single cell should be blocked   cell_idx=${cell_id}   cell_type=${technology.lower()}
    END

Unblock RAT and Check
    [Arguments]  ${cell_list}    ${technology}=NR
    selenium_coam.unblock_rat    rat=${technology}
    Wait For Expect Fault To Disappear  faultId=4614   timeout=120
    FOR    ${cell_id}    IN    @{cell_list}
        wait until keyword succeeds   3 min  10 sec    check single cell should be unblocked   cell_idx=${cell_id}   cell_type=${technology.lower()}
    END
