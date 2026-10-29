*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nrarfcn_and_gscn.robot
*** Variables ***

*** Keywords ***
Baseband_module_lock_unlock_via_WEBUI
    [Documentation]   Author:lanwen.cai@nokia-sbell.com
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify lock unlock bbmod via WEBUI.
    ...    ******************
    ${bbmod_index_list}  Get All BBmod Index
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    close start up view    timeout=60
    log to console    start lock bbmod via WEBUI
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        selenium_coam.lock_baseband    baseband_idx=${bbmod_index}    timeout=240
        Wait Until Keyword Succeeds    5min    10s    bbmod Should Be Locked    bbmod_index=${bbmod_index}
    END
    sleep    ${X2_link_shutdown_time}min
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    2min    10s    Expect Fault Should Present    faultId=7300
    log to console    start unlock bbmod via WEBUI
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        selenium_coam.unlock_baseband    baseband_idx=${bbmod_index}    timeout=240
        Wait Until Keyword Succeeds    5min    5s    bbmod Should Be unLocked    bbmod_index=${bbmod_index}
    END
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    5min    10s    Expect Fault Should Absent    faultId=7300
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]    Run keywords    Run Keyword And Ignore Error    unlock Baseband module via WEBUI
    ...    bbmod_index_list=${bbmod_index_list}    AND   Selenium Logout And Close Browser
