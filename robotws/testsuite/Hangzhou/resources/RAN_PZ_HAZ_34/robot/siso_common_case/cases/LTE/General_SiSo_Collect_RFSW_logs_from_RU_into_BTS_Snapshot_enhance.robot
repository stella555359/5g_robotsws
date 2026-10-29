*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/snapshot_check.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot

*** Variables ***

*** Keywords ***
General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_enhance
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to collect Snapshot logs in WebUI
    ...    and check if RFSW logs from Radio Unit are included in Snapshot.
    ...    ******************
    ...    History of changes
    ...    ******************s
    ...    - 10.14.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${is_get_snapshot_via_selenium}=${False}
    log to console    Wait 10 mins before Collect Snapshot
    sleep    600
    ssh.Connect to    ${sbts_addr}    ${ssh_username}    ${ssh_password}    alias=ASIK Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}
        ...    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
        Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${CASE_LOG_PATH}
        ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
        Check startup runtime and soap file in ru log    ru_log=${rfsw_log_path_on_testPC}    ru_index=${ru_index}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master
