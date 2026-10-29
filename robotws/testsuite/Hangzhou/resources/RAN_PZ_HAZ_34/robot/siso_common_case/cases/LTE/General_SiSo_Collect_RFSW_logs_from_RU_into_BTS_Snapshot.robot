*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot

*** Keywords ***
General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to collect Snapshot logs in WebUI
    ...    and check if RFSW logs from Radio Unit are included in Snapshot.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2020 - - Created
    ...    *******************
    ...    Owner_aaron.deng@nokia-sbell.com
    [Arguments]    ${is_get_snapshot_via_selenium}=${False}
    log to console    Wait 10 mins before Collect Snapshot
    sleep    600
    csn.connect to   hostname=${sbts_addr}   username=${ssh_username}   password=${ssh_password}   alias=ASIK Master
    ${ru_index_list}  Get All RU Index
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${version}=    Set Variable If
    ...     '${stream}'=='SBTS24R3'        SBTS24R3
    ...     '${stream}'=='SBTS25R1'        SBTS25R1
    ...     '${stream}'=='SBTS25R3'        SBTS25R3
    ...     '${stream}'=='SBTS25R2'        SBTS25R2
    ...     SBTS00
    ${prefix_name}    Set Variable If   '${version}'=='SBTS24R3' or '${version}'=='SBTS25R1'    BTS    BTS${mrbtsID}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP LTE   ru_index=${ru_index}    asik_alias=ASIK Master    ru_alias=RU_${ru_index}
        Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SUITE_LOG_PATH}
        ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}    prefix_name=${prefix_name}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master
