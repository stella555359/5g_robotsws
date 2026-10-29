*** Settings ***
Documentation    Keywords for testing activation and deactivation of temperature counters
...              author: MN_RAN_PZ_KRK_1
...              contact: MN_RAN_PZ_KRK_1

Library     testsuite.Krakow.resources.pm_counters.pm_counters_fetcher.GnbPmCounterFetcher

*** Keywords ***
Full counters verification
    [Arguments]    ${interval}    ${counters}
    Set Interval   interval=${interval}
    Set Counters   counters=${counters}
    Validate Counters Values Are Disabled
    Set Counters Interval to Default
    Wait For Proper Statuses
    Wait for Next PM Period for Default Interval
    Fetch Data and Validate
    Validate Counters Intervals
    Disable Counters Interval

Counters deactivation
    [Arguments]    ${interval}    ${counters}
    Set Interval   interval=${interval}
    Set Counters   counters=${counters}
    Set Counters Interval to Default
    Wait for Next PM Period for Default Interval
    Validate Counters Have Default Values
    Save Current Counters Values
    Disable Counters Interval
    Wait for Next PM Period for Previous Interval
    Validate Counters Inactive

Disable counters
    [Arguments]    ${counters}
    Set Counters   counters=${counters}
    Disable Counters Interval

Validate defined counters interval
    [Arguments]    ${interval}    ${counters}    ${timeout}=default
    Set Interval   interval=${interval}
    Set Counters   counters=${counters}
    Wait for Next PM Period for Default Interval    delay=60
    ${last_timestamp}    Validate Counters Intervals     timeout=${timeout}      delay=60
    Set Initial Timestamp    ${last_timestamp}

Verify counters values increased
    [Arguments]    ${interval}    ${counters}    ${wait_for_next_pm_period}=${False}
    Set Interval   interval=${interval}
    Set Counters   counters=${counters}
    Run Keyword If    ${wait_for_next_pm_period}    Wait for Next PM Period for Default Interval    delay=60
    Validate Counters Intervals     timeout=0min    delay=60
    Validate Counters Data Increased
