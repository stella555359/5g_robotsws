*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Resource          common_resource.robot

*** Keywords ***
GUI Capture Screenshot
    selenium_coam.Save Screenshot    EM    ${SUITE_LOG_PATH}

GUI GNB Onair check
    Wait Until Keyword Succeeds    ${ONAIR_MAX_DURATION}    30s    GUI Get gNB Cell Status

GUI Get gNB Cell Status
    ${cellno}    selenium_coam.Get Number Of Cells
    : FOR    ${index}    IN RANGE    1    ${cellno}+1
    \    ${cell_st}    selenium_coam.Get Cell Info    ${index}
    \    Should Be Equal    ${cell_st['Status']['Operational state']}    Enabled    msg=Cell onair check failed.    values=False

GUI Check gNB GPS Status
    ${status}    ${GPS_State} =    Run Keyword And Ignore Error    selenium_coam.get_gnss_info
    ${gps_ext}    Get Value From Result    ${GPS_State}    Status:Availability status
    Run Keyword If    "Online" in "${gps_ext}"    Wait Until Keyword Succeeds    40 min    5 min    Check gNB GPS Survey Status

Check gNB GPS Survey Status
    ${status}    ${GPS_St} =    Run Keyword And Ignore Error    selenium_coam.Get Gnss Info
    ${Survey}    Get Value From Result    ${GPS_St}    Self-survey status
    Log    ${GPS_St}
    Run Keyword If    "Completed" not in "${Survey}"    Fail    GPS self-survey not completed.

GUI Wait Until gNB On Air
    Wait Until Keyword Succeeds    ${ONAIR_MAX_DURATION}    30s

GUI Alarm Special Check
    ${active_alarms}=    selenium_coam.Get Active Alarm Info
    Run Keyword And Ignore Error    selenium_coam.Save Screenshot    Alarm_Act    ${SUITE_LOG_PATH}
    Run Keyword And Ignore Error    selenium_coam.Save Current Alarms
    ${historical_alarms}=    selenium_coam.Get History Alarm Info
    Run Keyword And Ignore Error    selenium_coam.Save Screenshot    Alarm_His    ${SUITE LOG DIRECTORY}
    Run Keyword And Ignore Error    selenium_coam.Save Historical Alarms
    GUI Capture Screenshot
    ${alarm_list}    Combine Lists    ${active_alarms}    ${historical_alarms}
    Set Suite Variable    ${active_alarms}
    Set Suite Variable    ${historical_alarms}
    Set Suite Variable    ${alarm_list}
    ${specials}    ${value}    Run Keyword And Ignore Error    Variable Should Exist    ${ALARM_SPECIAL}
    ${specialv}    ${value}    Run Keyword And Ignore Error    Should Not Be Empty    ${ALARM_SPECIAL}
    Run Keyword If    '${specials}' == 'PASS' and '${specialv}' == 'PASS'    Alarm Exist Check by ID

Alarm Exist Check by ID
    ${active_alarms}    admin.get_active_alarms
    ${historical_alarms}    admin.get_historic_alarms
    ${alarm_list}    Combine Lists    ${active_alarms}    ${historical_alarms}
    Check Alarm Existed By Faultid    ${alarm_list}    ${ALARM_SPECIAL}
