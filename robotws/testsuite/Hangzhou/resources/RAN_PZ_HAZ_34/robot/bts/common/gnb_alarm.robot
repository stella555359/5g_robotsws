*** Settings ***
Documentation    gnb alarm info related keywords for both classical and cloud.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com

Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.GnbAlarmAnalyzer    WITH NAME    GnbAlarmAnalyzer
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource   ../../coam_gnb_classical.robot

*** Variables ***

*** Keywords ***
Get active alarm from Gnb
    [Arguments]
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}
    ...            Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Cloud DU connect to gnb coam via ssl
    ...    ELSE    Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Connect to gnb coam via ssl
    ${active_alarms_list}    coam.get_active_alarms    connection=GNB_OAM
    [Return]    ${active_alarms_list}
    [Teardown]  coam.teardown    connection=GNB_OAM

Get alarms from Gnb
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}
    ...            Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Cloud DU connect to gnb coam via ssl
    ...    ELSE    Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${active_alarms_list}    coam.get_active_alarms    connection=GNB_OAM
    ${history_alarms_list}    coam.get_historic_alarms    connection=GNB_OAM    load_history=${True}    timeout=60
    [Return]    ${active_alarms_list}    ${history_alarms_list}
