*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
Snapshot_includes_RU_log_related_to_critical_failures_raise_any_time_early
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check Snapshot includes RU log related to critical failures
    ...     raise any time early.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.06.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${Tdanger_trriger}=30.0   ${ru_index}=1
    ${Tdanger_init}    Get Tdanger Value from Json File    ru_index=${ru_index}
    ${Old_SW_version}    get old sw version    SW=${Active_SW_version}
    log to console  OLD_SW_PKG:${Old_SW_version}, NEW_SW_PKG:${Active_SW_version}
    ${OLD_SW_PKG}  Download SW  SW=${Old_SW_version}
    ${NEW_SW_PKG}  Download SW  SW=${Active_SW_version}
    log to console  start deploy to OLD_SW_PKG:${OLD_SW_PKG}
    Perform SW Update  ${SAVE LOG DIRECTORY}${OLD_SW_PKG}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    Trigger Fault 1937    Tdanger_target=${Tdanger_trriger}  ru_index=${ru_index}
    sleep    65min
    ${snapshot_file_path_old_version}    COAM Save snapshot via rest api    timeout=1500
    ${snapshot_alarms_string_old_version}    Extract fault logs from snapshot
    ...    snapshot_file=${snapshot_file_path_old_version}    fault_id=1168
    recovery Fault 1937   Tdanger_target=${Tdanger_init}   ru_index=${ru_index}
    Perform SW Update  ${SAVE LOG DIRECTORY}${NEW_SW_PKG}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    ${snapshot_file_path_new_version}    COAM Save snapshot via rest api    timeout=1500
    ${snapshot_alarms_string_new_version}    Extract fault logs from snapshot
    ...    snapshot_file=${snapshot_file_path_old_version}    fault_id=1168
    [Teardown]  Remove Downloaded Content  ${NEW_SW_PKG}  ${OLD_SW_PKG}
