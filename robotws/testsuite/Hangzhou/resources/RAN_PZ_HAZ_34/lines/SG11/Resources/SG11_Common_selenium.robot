*** Settings ***

*** Variables ***


*** Keywords ***
COAM Navigate to login page via webUI
    [Documentation]
    ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
    [Arguments]    ${download_dir}=${CASE_LOG_PATH}
    ...            ${timeout}=${60}
    ...            ${url}=https://${sbts_addr}
    ...            ${username}=${http_username}
    ...            ${password}=${http_password}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    selenium_coam.disable_message_box


SBTS Block cells and check status
    [Arguments]  ${block_list}    ${connection}=GNB_OAM
    COAM Navigate to login page via webUI    download_dir=${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console    \n***Block cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.block_cell    cell_idx=${idx}    technology=NR
        Wait Until Keyword Succeeds   3 min  10 sec   SBTS Cell Should Be Blocked    cell_idx=${idx}
        Wait Until Keyword Succeeds   1 min  10 sec   Expect Fault Should Present on WebUI    faultId=49
    END
    [Teardown]    Run Keyword And Ignore Error    selenium_coam.logout

UnBlock Cells and check status
    [Arguments]  ${block_list}  ${check_alarm}=${True}   ${technology}=NR   ${gnb_type}='NSA'  ${timeout}=60    ${connection}=GNB_OAM
    COAM Navigate to login page via webUI    download_dir=${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console    \n***unblock cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.block_cell    cell_idx=${idx}    technology=NR
        Wait Until Keyword Succeeds   3 min  10 sec   SBTS Cell Should Be UnBlocked    cell_idx=${idx}
    END
    [Teardown]    Run Keyword And Ignore Error    selenium_coam.logout

SBTS Cell Should Be Blocked
    [Arguments]    ${cell_idx}    ${cell_type}=nr    ${stream}=SBTS00    ${cell_index}=${None}
    ${cell_info_dict}   selenium_coam.get_cell_info    cell_idx=${cell_idx}    technology=${cell_type}    timeout=20
    Should Be Equal As Strings   ${cell_info_dict["Status"]["Operational state"]}    disabled
    Should Be Equal As Strings   ${cell_info_dict["Status"]["Administrative state"]}    Unlocked
    Should Be Equal As Strings   ${cell_info_dict["Status"]["Blocking state"]}    Blocked

SBTS Cell Should Be UnBlocked
    [Arguments]    ${cell_idx}    ${cell_type}=nr    ${stream}=SBTS00    ${cell_index}=${None}
    ${cell_info_dict}   selenium_coam.get_cell_info    cell_idx=${cell_idx}    technology=${cell_type}    timeout=20
    Should Be Equal As Strings   ${cell_info_dict["Status"]["Operational state"]}    disabled
    Should Be Equal As Strings   ${cell_info_dict["Status"]["Administrative state"]}    Unlocked
    Should Be Equal As Strings   ${cell_info_dict["Status"]["Blocking state"]}    Unblocked

Expect Fault Should Present on WebUI
    [Arguments]    ${faultId}    ${source}=${None}    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    selenium_coam.get_active_alarm_info
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    Fault ID    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['Severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['Alarm ID']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['Configuration alarming object']}    ${config_object_name}
       Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.


Perform BTS Site Reset
    [Arguments]   ${download_dir}=${TEST_LOG_DIRECTORY}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_site
    [Teardown]  COAM selenium logout

COAM selenium logout
    [Arguments]     ${virtual_disable}=${TRUE}
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window
    selenium_coam.logout
    run keyword if      ${virtual_disable}    selenium_coam.disable_virtual_display