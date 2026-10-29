*** Settings ***
Documentation    The keyword for kill adb app
...              Author: Chen Jun
...              Contact: jun.8.chen@nokia-sbell.com


*** Keywords ***
Kill Adb App
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Wait Until Keyword Succeeds    1 min    2 sec    Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ${output}    csn.execute    command=ps -Wef|grep -i adb    connection=${cpc_alias}
    ${is_process_exists}    Run Keyword And Return Status    Should Contain    ${output}    adb.exe
    ${cmd_kill_adb_process}    Set Variable If    ${is_process_exists}    TASKKILL /F /IM adb.exe /T
    Run Keyword If    ${is_process_exists}    Run Keywords
    ...    Log to console    adb process exists, start to kill    AND
    ...    csn.execute    command=${cmd_kill_adb_process}    connection=${cpc_alias}    AND
    ...    Sleep    1s
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=${cpc_alias}
