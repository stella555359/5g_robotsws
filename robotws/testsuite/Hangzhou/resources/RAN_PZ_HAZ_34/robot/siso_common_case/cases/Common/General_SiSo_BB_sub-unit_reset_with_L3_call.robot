*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
*** Variables ***

*** Keywords ***
General_SiSo_BB_sub-unit_reset_with_L3_call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify correctness of BB sub-unit (ABIL) reset procedure
    ...    (by using provisioning plan), triggered by an operator in WebEM. Verification with L3 call.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.21.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${bbmod_index_list}  Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        selenium_coam.reset_abil    abil_index=${bbmod_index}
    END
    sleep  120
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
