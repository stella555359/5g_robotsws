*** Settings ***
Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Implementation of tests 1, 3 and 4 for feature CB010823

Library             taf.selenium.sbts    WITH NAME    selenium_sbts
Library             resources/CB010823_Keywords.py
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource            taf/rfrl/bts/robot/gnb.robot
Resource            resources/CB010823_Keywords.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

Force Tags          RF50

*** Variables ***
# robocop: disable=0920
@{expected_execution_values}    Check point successful    Check point unsuccessful
@{legacy_expected_execution_values}    OK    NOK
${fault_x2_link}                No X2 link available
${fault_x2_link_enb}            No X2 link available for a specific LTEENB
${diag_files}                   Diagnostic Files collected
${high_memory_consumption}      High memory consumption
${satelite_degraded}            GNSS satellite visibility degraded
@{CUSTOM_ALLOWED_ALARMS}
...    ${fault_x2_link}
...    ${fault_x2_link_enb}
...    ${diag_files}
...    ${high_memory_consumption}
...    ${satelite_degraded}


*** Test Cases ***
[1]CB010823_Test_Case_1_Run_Diagnostic_check_from_WebEM
    ${request_time}=    get_current_time
    selenium_sbts.start_diagnostic_check    scope=Full diagnostic check    timeout=300    allow_service_impact=${True}
    sleep    120s
    Wait For Site To Be Onair
    Handle Startup Window
    ${customized_report}=    selenium_sbts.get_report
    Log to console    \n-- Output --\n
    Log to console    ${customized_report}
    Log to console    \n-- RU check report --\n
    Log to console    ${customized_report["RU diagnostic check report"]}

    Verify values of checkpoints in RUreport    RUreport=${customized_report["RU diagnostic check report"]}
    ...    TriggerType=WebEM    RequestTime=${request_time}    VerifyId43=${True}
    sleep    120s

[1]CB010823_Test_Case_3_Automatic_execution_of_Diagnostic_check
    ${restart_time}=    get_current_time
    selenium_sbts.reset_site
    Wait For Site To Be Onair
    sleep    120s
    Wait until keyword succeeds
    ...    20x
    ...    60s
    ...    Verify diagnostic check with triggertype
    ...    ${restart_time}
    ...    Automatic
    sleep    300s

[1]CB010823_Test_Case_4_Scheduled_execution_of_Diagnostic_check
    ${time_offset_seconds}=    Set Variable    ${300}
    ${delta}    ${scheduled_time}=    generate_delta_for_scheduled_check    time_offset_seconds=${time_offset_seconds}
    Log to console    ${delta}
    Perform Delta Commissioning On gNB    delta=${delta}
    Wait For Site To Be Onair
    Wait until keyword succeeds
    ...    10x
    ...    60s
    ...    Verify diagnostic check with triggertype
    ...    ${scheduled_time}
    ...    Scheduled
    sleep    300s
