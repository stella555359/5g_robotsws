*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_Number_of_failure_logs_reported_in_snapshot_for_one_RU_during_1h
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check the number of failure logs reported in snapshot
    ...     for one RU during 1h.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=1
    ${original_value}    Get SnapshotTimeoutS original value    ru_index=${ru_index}
    ${modify_file}  generate core assembly modify files
    Modify Core Assembly File On RU Unit    modify_file=${modify_file}    tobak=True    ru_index=${ru_index}
    Perform RF Module Reset from GUI    ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min     5s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    20s    Cell Should Not Be Online
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1923
    Modify RU SnapshotTimeoutS    SnapshotTimeoutS=${original_value}    new_timeout=240
    log to console    \n    sleep   6min
    sleep   6min
    Wait Until Keyword Succeeds    5min     5s    Connect to gnb coam via ssl
    ${log_on_snapshot}   Get File List On Snapshot  ru_index=${ru_index}
    ${rfsw_log_names}   Get Regexp Matches   ${log_on_snapshot}   BTS__RMOD.*
    Should Contain Match   ${rfsw_log_names}   regexp=.*faultLogs.*
    [Teardown]    Run keywords    Modify RU SnapshotTimeoutS    SnapshotTimeoutS=240    new_timeout=${original_value}
    ...    AND   recover env to clear fault 1923    modify_file=${modify_file}    tobak=False    ru_index=${ru_index}

recover env to clear fault 1923
     [Arguments]    ${modify_file}    ${tobak}=True    ${ru_index}=1
     Modify Core Assembly File On RU Unit    modify_file=${modify_file}    tobak=${tobak}    ru_index=${ru_index}
     Perform RF Module Reset from GUI    ru_index=${ru_index}
     Wait Until Keyword Succeeds    5min     5s    Connect to gnb coam via ssl
     Wait Until Keyword Succeeds    10min    20s    Cell Should Be Enabled
     Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1923
