*** Settings ***
Documentation    Keywords for testing activation and deactivation of temperature counters
...              author: MN_RAN_PZ_KRK_1
...              contact: MN_RAN_PZ_KRK_1

Library     testsuite.Wroclaw.RRM.sim_resources.Krk_regression.resources.pm_counters.pm_counters_fetcher.GnbPmCounterFetcher

*** Keywords ***
Full counters verification
    [Arguments]    ${interval}    ${temperature_counters}
    Set Interval                            interval=${interval}
    Set Temperature Counters                temperature_counters=${temperature_counters}
    Validate Counters Values Are Disabled
    Set Counters Interval to Default
    Wait For Proper Statuses
    Wait for Next PM Period for Default Interval
    Fetch Data and Validate
    Validate Counters Intervals
    Disable Counters Interval

Counters deactivation
    [Arguments]    ${interval}    ${temperature_counters}
    Set Interval                            interval=${interval}
    Set Temperature Counters                temperature_counters=${temperature_counters}
    Set Counters Interval to Default
    Wait for Next PM Period for Default Interval
    Validate Counters Have Default Values
    Save Current Counters Values
    Disable Counters Interval
    Wait for Next PM Period for Previous Interval
    Validate Counters Inactive

Disable counters
    [Arguments]    ${temperature_counters}
    Set Temperature Counters                temperature_counters=${temperature_counters}
    Disable Counters Interval
