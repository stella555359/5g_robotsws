*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_Stability_Test_Case
    [Arguments]   ${case_name}    ${times}=${1}    ${pass}=${1}    ${common_setup_each_time}=${False}    ${gnb_index}=0
    ...    ${run_total_times}=${False}    ${with_recovery}=${True}    &{kwargs}
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           run keyword if    ${common_setup_each_time}    SISO Coam Test Setup    gnb_index=${gnb_index}
           ${result} =    Run Keyword And Return Status    ${case_name}    &{kwargs}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${teardown_result}    run keyword if    ${common_setup_each_time}
           ...    run keyword and return status    SISO Coam Test Teardown    gnb_index=${gnb_index}    is_case_teardown=${False}
           ...    ELSE    set variable    ${True}
           Run Keyword If    (not ${result} or not ${teardown_result}) and ${with_recovery}
           ...    run keyword and ignore error    Action After Stability Case Failed
           ...    target_dir=${SAVE LOG DIRECTORY}    time=${itime}    common_setup_each_time=${common_setup_each_time}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop} and not ${run_total_times}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
