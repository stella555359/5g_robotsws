*** Settings ***
Documentation
...    Author: Jacek Dziedzicki
...    Contact: Jacek.Dziedzicki@nokia.com
...    Description: Test cases for CB008696 Idle mode Traffic Steering from NR SA to LTE EN-DC carrier

Resource      testsuite/Krakow/RRM/RAN_PZ/regression/KRK8/CB008696/resources/CB008696_Keywords.robot

Test Timeout  11 hours 55 minutes

Force Tags    CA_VRF_KRK    RF50

Suite Setup       Test Suite Setup
Suite Teardown    CB008696_Keywords.Test Suite Teardown
Test Setup        CB008696_Keywords.Test Setup
Test Teardown     Test Teardown

*** Test Cases ***
004_CB008696-A_B1_cellReselectionPriorities__WRR_enabled_without_A4_two_freq__without_mobility_profiles
    CB008696_Keywords.Wait for next pm period
    Wait until keyword succeeds  15 min  60s   UTF Lab Start Tracing gNB
    Attach UE
    Wait for UE release and cell reselection    timeout=${60}
    UTF Lab Stop Tracing
    CB008696_Keywords.Wait for next pm period    timeout=${15}
    Verify LTE Primary Target counters
    ${utf_zip_file}    ${trace_id}=     UTF Lab Collect Results    timeout=${1800}
    ${json_file}    Extract Emil from UTF logs and decode to json    ${utf_zip_file}
    ${status}    ${value}    Run Keyword And Ignore Error
    ...     Verify RRC Release and t320 timer and reselection    ${freq_priority_04a}
            ...                                                  timer not configured
            ...                                                  ${json_file}
    Run Keyword If    '${status}' == 'FAIL'
    ...     Verify RRC Release and t320 timer and reselection    ${freq_priority_04b}
            ...                                                  timer not configured
            ...                                                  ${json_file}

006_CB008696-A_B2_Fallback_to_CB007516_nonCA__LTE_target_is_not_found__without_mobility_profiles
    [Setup]    CB008696_Keywords.Test Setup    prefix_tag=CB008696_8SK111_TC06
    CB008696_Keywords.Wait for next pm period
    Wait until keyword succeeds  15 min  60s   UTF Lab Start Tracing gNB
    Attach UE
    Wait for UE release and cell reselection    timeout=${0}
    UTF Lab Stop Tracing
    CB008696_Keywords.Wait for next pm period    timeout=${15}
    Verify NR Primary Target counters
    ${utf_zip_file}    ${trace_id}=     UTF Lab Collect Results    timeout=${1800}
    ${json_file}    Extract Emil from UTF logs and decode to json    ${utf_zip_file}
    ${status}    ${value}    Run Keyword And Ignore Error
    ...     Verify RRC Release and t320 timer and reselection    ${freq_priority_06a}
    ...                                                          timer not configured
    ...                                                          ${json_file}
    Run Keyword If    '${status}' == 'FAIL'
    ...     Verify RRC Release and t320 timer and reselection    ${freq_priority_06b}
            ...                                                  timer not configured
            ...                                                  ${json_file}

010_CB008696-B_B1_cellReselectionPriorities__WRR_disabled_with_A4_two_freq__with_mobility_profiles
    [Setup]    CB008696_Keywords.Test Setup    prefix_tag=CB008696_8SK111_TC10
    CB008696_Keywords.Wait for next pm period
    Wait until keyword succeeds  15 min  60s   UTF Lab Start Tracing gNB
    Attach UE
    Wait for UE release and cell reselection    timeout=${40}
    UTF Lab Stop Tracing
    CB008696_Keywords.Wait for next pm period    timeout=${15}
    Verify Mobility Profile and Mode Mobility EN-DC aware steering counters
    ${utf_zip_file}    ${trace_id}=     UTF Lab Collect Results    timeout=${1800}
    ${json_file}    Extract Emil from UTF logs and decode to json    ${utf_zip_file}
    Verify in RRC messages that UE was candidate for EN-DC aware steering    ${json_file}
    Verify RRC Release and t320 timer and reselection    ${freq_priority_10}
    ...                                                  min5
    ...                                                  ${json_file}
