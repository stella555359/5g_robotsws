*** Settings ***
Documentation
...  author:  Michal Jonczyk    Monika Myśliwiec   Szymon Mastalski   Mateusz Potoniec
...  contact: michal.jonczyk@nokia.com    monika.mysliwiec@nokia.com    szymon.mastalski@nokia.com
...           mateusz.potoniec@nokia.com

Library     DateTime                                                                         WITH NAME    dt
Library     taf/rfrl/procedures/resources/python/sleeping_cell_detector.py                   WITH NAME    scd
Library     ./suite_specific_keywords.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${skip_commissioning}=     ${NONE}
${bts_id}                  ${tl.gnbs[0].instance_id}
@{tc17_counters_ru}     M51401C0    M51401C1    M51401C2    M51401C3    M51401C5    M51401C6    M51401C7    M51401C8
@{tc17_counters_bts}    M51300C0    M51301C0    M51301C1    M51301C2    M51301C3    M51301C4    M51300C7    M51300C8
@{tc17_allowed_zero_counter_ru}     M51401C1    M51401C3
@{tc17_allowed_zero_counter_bts}    M51300C0    M51301C4    M51300C7    M51300C8

*** Keywords ***
Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :datatime:    determines if include timestamp in log
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   dt.Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Suite Setup
    [Documentation]    Test Setup, performs commissioning on gNB and ASIR
    Log Action To Console    Suite Setup ==========================================
    Run Keyword If    '${skip_commissioning}'!='true'    Common Suite Setup With OnAir Test Line Preparation
    Log Action To Console    End Suite Setup ======================================   new_line_after=True

Test Setup
    [Documentation]    Test Setup
    Log Action to Console    Start Sleeping Cell Detection Watchdog
    scd.Start Sleeping Cell Detection Watchdog       log_dir=${LOG_PATH}/SleepingCell
    Log Action to Console    Perform Common Preconditions
    Modify Moler Logging Directory    mode=test case
    Verify On-Air
    Add Custom Allowed Alarms If Defined
    Verify Default Allowed Alarms on gNB
    Verify Mandatory Configuration Params Enabled
    Log Action To Console    Test Procedure ======================================

Test Teardown
    [Documentation]    Performs Common Postconditions
    Log Action To Console    End Test Procedure ==================================   new_line_after=True
    Log Action to Console    Verify Sleeping Cell Detection
    scd.Verify Sleeping Cell Detection
    Log Action to Console    Perform Common Postconditions
    Common Postconditions

Fail And Log Error
    [Arguments]   ${msg}
    [Documentation]    The keyword performs failure and logs error message.
    ...                :param msg:     message logged

    Log    message=${msg}    level=ERROR
    Fail   msg=${msg}

Check RU Counters
    [Documentation]    Checks if specific RU counters exists and if are allowed to have value 0

    Log Action to Console    Check RU Counters
    Check RU Counters for path    dist_name=TRS/MRBTS-${BTS_ID}/EQM-1/APEQM-1/ASIRMOD-1/SFP-5
    Check RU Counters for path    dist_name=TRS/MRBTS-${BTS_ID}/EQM-1/APEQM-1/ASIRMOD-1/SFP-6
    Check RU Counters for path    dist_name=TRS/MRBTS-${BTS_ID}/EQM-1/APEQM-1/ASIRMOD-2/SFP-5
    Check RU Counters for path    dist_name=TRS/MRBTS-${BTS_ID}/EQM-1/APEQM-1/ASIRMOD-2/SFP-6
    Check RU Counters for path    dist_name=TRS/MRBTS-${BTS_ID}/EQM-1/APEQM-1/ASIRMOD-3/SFP-5
    Check RU Counters for path    dist_name=TRS/MRBTS-${BTS_ID}/EQM-1/APEQM-1/ASIRMOD-3/SFP-6

Check RU Counters for path
    [Arguments]    ${dist_name}
    ${counters_check_status}=    Check Counters    counters_list=@{tc17_counters_ru}
    ...                                            allowed_zero_value_counters_list=@{tc17_allowed_zero_counter_ru}
    ...                                            dist_name=${dist_name}
    Run Keyword If    ${counters_check_status}==False
    ...               Fail And Log Error    msg=Missing RU counter or RU counter has unallowed 0 value

Check BTS Counters
    [Documentation]    Checks if specific BTS counters exists and if are allowed to have value 0

    Log Action to Console    Check BTS Counters
    ${counters_check_status}=    Check Counters    counters_list=@{tc17_counters_bts}
    ...                                            allowed_zero_value_counters_list=@{tc17_allowed_zero_counter_bts}
    ...                                            dist_name=TRS/MRBTS-${BTS_ID}/TNLSVC-1/TNL-2/ETHSVC-1
    Run Keyword If    ${counters_check_status}==False
    ...               Fail And Log Error    msg=Missing RU counter or RU counter has unallowed 0 value

Change Counter Capture Interval Time
    [Arguments]       ${minutes}=15min
    [Documentation]    Change Counters Capture Intercal time (ruEthernetInterfaceStatisticsInterval),
    ...                to value of minutes given by an argument.
    ...                :param minutes:    Minutes to which ruEthernetInterfaceStatisticsInterval
    ...                                   should be set

    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0
    ...    du_id=0
    ...    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    ...    param_name=ruEthernetInterfaceStatisticsInterval
    ...    param_value=${minutes}
    ...    skip_parameter_relation_errors=true
    ...    timeout=300

    Log Action to Console       Parameter ruEthernetInterfaceStatisticsInterval set to ${minutes}

Verify allowed faults on gNB
    [Arguments]     @{allowed_alarms}
    [Documentation]    Keyword verifies if there are no any alarms despite of allowed alarms gNB.
    ...                :param faults_names:    List of allowed alarms.

    Log Action to Console    Verify Allowed Alarms on gNB
    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}    gnb_id=0    du_id=${0}
