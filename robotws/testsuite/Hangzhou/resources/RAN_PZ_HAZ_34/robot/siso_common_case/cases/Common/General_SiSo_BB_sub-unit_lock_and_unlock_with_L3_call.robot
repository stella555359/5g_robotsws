*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Variables ***

*** Keywords ***
General_SiSo_BB_sub-unit_lock_and_unlock_with_L3_call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify correctness of BB sub-unit (ABIL) lock/unlock
    ...     procedure,triggered by an operator in WebEM. Verification with L3 call
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.10.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${stream}    get stream from version    ${Active_SW_version}
    ${boundary}    get the boundary of stream    stream=${stream}
    ${bbmod_index_list}  Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        selenium_coam.lock_baseband    baseband_idx=${bbmod_index}
    END
    sleep  120
    Check All BBMOD status   as=Locked
    RU Should Be Online
    Cell Status Info Should Be Disabled    cell_type=${cell_type}    boundary=${boundary}    bs_blocked=Unblocked
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        selenium_coam.unlock_baseband    baseband_idx=${bbmod_index}    timeout=120
    END
    sleep  120
    Check All BBMOD status    as=Unlocked
    RU Should Be Online
    Cell Status Info Should Be Enable   cell_type=${cell_type}    boundary=${boundary}
