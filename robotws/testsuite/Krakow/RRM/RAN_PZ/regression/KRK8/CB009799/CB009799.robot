*** Settings ***
Documentation
...    Author: Bartosz Odziomek
...    Contact: bartosz.odziomek@nokia.com
...    Description: The test case checks automatic NR sleeping cell detection and the required recovery actions.

Resource      resources/CB009799_keywords.robot

Suite Setup         Suite Setup 9799
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Test teardown for CB009799


*** Variables ***
${x2}                    No X2 link available
${x2_spec}               No X2 link available for a specific LTEENB
${trs}                   Transport layer connection failure in X2 interface
${bbu}                   Baseband card autonomous reset as recovery action
${rx_expected_alarm}     Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
${tx_expected_alarm}     Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
${site_reset}            BTS site autonomous reset as recovery action
${reset_cause}           BTS Reset Cause
${top}                   ToP reference missing
@{CUSTOM_ALLOWED_ALARMS}    ${x2}  ${x2_spec}  ${bbu}  ${rx_expected_alarm}  ${tx_expected_alarm}  ${site_reset}  ${reset_cause}  ${top}  ${trs}

*** Test Cases ***
[1][2.0] 010_CB007043_Antenna RX Power measurement sleeping cell detection and recovery (5G Classical) - all recovery phases
    Run keyword and ignore error   Perform Delta Commissioning On gNB    delta=${sleeping_cell_object_creation}
    Perform Delta Commissioning On gNB    delta=${maintanance_disabled}
    Perform Delta Commissioning On gNB    delta=${delta_force_reset_true}

    # Phase 1
    Perform Delta Commissioning On gNB    delta=${delta_test_010_phase1}
    Sleep   ${autAntRecPwrBasedSlCellDetHCheckFreq}s   Health check period
    Wait until keyword succeeds   ${${autAntRecPwrBasedSlCellRecPh1Timer}+${630}}s   10s   gnb_alarms.verify_alarm_is_active  ${rx_expected_alarm}
    Wait for next pm period if little time left   min_minutes_left=${15}
    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M55601C00003
    Disable 9799 feature

    #Phase 2
    Perform Delta Commissioning On gNB    delta=${delta_test_010_phase2}
    gnb_recovery.Verify autonomous reset   timeout=900  # added Health check period
    Wait for next pm period if little time left   min_minutes_left=${15}
    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M55601C00004
    Disable 9799 feature

    #Phase 3
    Perform Delta Commissioning On gNB    delta=${delta_test_010_phase3}
#    Sleep   ${autAntRecPwrBasedSlCellDetHCheckFreq}   Health check period
    gnb_recovery.Verify autonomous reset   timeout=900  # added Health check period
    Wait for next pm period if little time left   min_minutes_left=${15}
    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M55601C00005
    Disable 9799 feature

[1][3.0] 011_CB007043_Antenna TX Power measurement sleeping cell detection and recovery (5G Classical) - all recovery phases
    Run keyword and ignore error   Perform Delta Commissioning On gNB    delta=${sleeping_cell_object_creation}
    Perform Delta Commissioning On gNB    delta=${maintanance_disabled}
    Perform Delta Commissioning On gNB    delta=${delta_force_reset_true}
    # Phase 1
    Perform Delta Commissioning On gNB    delta=${delta_test_011_phase1}
    Sleep   ${autAntRecPwrBasedSlCellDetHCheckFreq}s   Health check period
    Wait until keyword succeeds   ${${autAntRecPwrBasedSlCellRecPh1Timer}+${630}}s   10s   gnb_alarms.verify_alarm_is_active  ${tx_expected_alarm}
    Wait for next pm period if little time left   min_minutes_left=${15}
#    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M55601C01514
    Disable 9799 feature

    #Phase 2
    Perform Delta Commissioning On gNB    delta=${delta_test_011_phase2}
#    Sleep   ${autAntRecPwrBasedSlCellDetHCheckFreq}   Health check period
    gnb_recovery.Verify autonomous reset   timeout=900  # added Health check period
    Wait for next pm period if little time left   min_minutes_left=${15}
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M55601C01515
    Disable 9799 feature

    #Phase 3
    Perform Delta Commissioning On gNB    delta=${delta_test_011_phase3}
#    Sleep   ${autAntRecPwrBasedSlCellDetHCheckFreq}   Health check period
    gnb_recovery.Verify autonomous reset   timeout=900  # added Health check period
    Wait for next pm period if little time left   min_minutes_left=${15}

    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M55601C01516
    Wait until keyword succeeds   ${${autAntRecPwrBasedSlCellRecPh1Timer}+${630}}s   10s   Disable 9799 feature
    Wait For onAir State


[1][1.0] 019_CB007043_Sleeping Cell Detection and Recovery Maintenance Window
    Run keyword and ignore error   Perform Delta Commissioning On gNB    delta=${sleeping_cell_object_creation}
    Perform Delta Commissioning On gNB    delta=${maintanance_disabled}
    Perform Delta Commissioning On gNB    delta=${delta_test_011_phase1}
    Wait For onAir State
    Perform Delta Commissioning On gNB    delta=${maintanance_enabled}
    ${msg} =    Run Keyword And Expect Error   *    Verify alarm is active    ${tx_expected_alarm}
    Log to console    Alarm is inactive as expected: ${msg}
    Perform Delta Commissioning On gNB    delta=${maintanance_disabled}
    Verify alarm is active    ${tx_expected_alarm}
    Wait until keyword succeeds   ${${autAntRecPwrBasedSlCellRecPh1Timer}+${630}}s   10s   Disable 9799 feature
    Wait For onAir State


