*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

*** Variables ***

*** Keywords ***
General_KPI_Test_Case
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE]KPI Common case
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.07.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]   ${case_name}    ${times}=${1}    ${pass}=${1}
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           ${result} =    Run Keyword And Return Status    ${case_name}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
