*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check Snapshot full level showing reason for a failure after
    ...     radio has been re-started.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.06.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${Tdanger_trriger}=30.0   ${ru_index}=1
    ${Tdanger_init}    Get Tdanger Value from Json File    ru_index=${ru_index}
    Trigger Fault 1937    Tdanger_target=${Tdanger_trriger}  ru_index=${ru_index}
    Perform RU Reset
    sleep    65min
    Check fault Exist in RU and snapshot
    [Teardown]  recovery Fault 1937   Tdanger_target=${Tdanger_init}   ru_index=${ru_index}
