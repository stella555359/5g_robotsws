*** Settings ***
Resource  testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB005958_D/resources/comm_5958D.robot

*** Keywords ***

Check New Counter Period
    [Arguments]    ${counter_id}
    Log To Console    Wait Until New Counter Period
    sleep    15min
    ${counter_list}    Get GNSS PM Counter    counter_id=${counter_id}

    [Return]    ${counter_list}

Get GNSS PM Counter
    [Arguments]    ${counter_id}    ${alias}=default
    Log To Console    Get GNSS PM Counter
    comm_5958D.Rest Login DU
    ${result}    coam.get_PM_counters    couter_ids=${counter_id}    connection=${alias}
    ${counter_list}    get dictionary values    ${result['BTS']['BTS']['MRBTS-${MRBTS_ID}']['CLOCK-1']['GNSSE-1']['NGNS']['${counter_id}']}
    [Return]    ${counter_list}
    [Teardown]    comm_5958D.Rest Logout DU


