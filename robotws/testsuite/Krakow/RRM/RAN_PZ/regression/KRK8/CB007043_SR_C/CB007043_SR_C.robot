*** Settings ***
Documentation
...    Author: Bartosz Odziomek
...    Contact: bartosz.odziomek@nokia.com
...    Description: Test cases for CB007043-SR-C Sleeping cell detection feature configuration enhancements feature

Resource      resources/CB007043_keywords.robot

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Test teardown for CB007043


*** Variables ***
${top}                         ToP reference missing
${001_alarm}                   Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
${002_alarm}                   Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
${bbu_reset}                   Baseband card autonomous reset as recovery action
${site_reset}                  BTS site autonomous reset as recovery action
${unit_reset}                  Unit autonomous reset as recovery action
${bts_reset}                   BTS Reset Cause
${x2}                          Setup of X2 connectivity to gNB failed
@{CUSTOM_ALLOWED_ALARMS}  ${001_alarm}  ${002_alarm}  ${bbu_reset}  ${x2}  ${site_reset}  ${top}  ${unit_reset}  ${bts_reset}

*** Test Cases ***
[1][1.0] 001_CB007043_Abnormal Antenna Rx Power Measurement Sleeping Cell Detection and Recovery - all recovery phases
    Run keyword and ignore error   Perform Delta Commissioning On gNB    delta=${sleeping_cell_object_creation}
    # Enable 7043
    Wait for next pm period if little time left   min_minutes_left=${15}
    Perform Delta Commissioning On gNB    delta=${delta_force_reset_true}


    # Phase 1
    Perform Delta Commissioning On gNB    delta=${delta_test_01_actAutAntRecPwrBasedSlCellDetRec}  # base method
    Perform Delta Commissioning On gNB    delta=${delta_test_01_actAutAntRecPwrAntBasedSlCellDetRec}
    Perform Delta Commissioning On gNB    delta=${delta_test_01_actAutAntRecPwrDiff2AntBasedSlCellDetRec}
    Perform Delta Commissioning On gNB    delta=${delta_test_01_phase_1}
    Sleep   ${autAntRecPwrBasedSlCellDetHCheckFreq}s   Health check period
    Wait until keyword succeeds   ${autAntRecPwrBasedSlCellRecPh1Timer}s   10s   gnb_alarms.verify_alarm_is_active
       ...   ${001_alarm}
    Wait for next pm period if little time left   min_minutes_left=${15}
    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M8020C16
    Disable 7043 feature

    #Phase 2
    Perform Delta Commissioning On gNB    delta=${delta_test_01_actAutAntRecPwrBasedSlCellDetRec}  # base method
    Perform Delta Commissioning On gNB    delta=${delta_test_01_actAutAntRecPwrAntBasedSlCellDetRec}
    Perform Delta Commissioning On gNB    delta=${delta_test_01_actAutAntRecPwrDiff2AntBasedSlCellDetRec}
    Perform Delta Commissioning On gNB    delta=${delta_test_01_phase_2}
    Sleep   ${autAntRecPwrBasedSlCellDetHCheckFreq}   Health check period
    Wait For Bbmod Reboot   bbmod_id=1   timeout=240
    Wait for next pm period if little time left   min_minutes_left=${15}
    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M8020C17
    Disable 7043 feature

    #Phase 3
    Perform Delta Commissioning On gNB    delta=${delta_test_01_actAutAntRecPwrBasedSlCellDetRec}  # base method
    Perform Delta Commissioning On gNB    delta=${delta_test_01_actAutAntRecPwrAntBasedSlCellDetRec}
    Perform Delta Commissioning On gNB    delta=${delta_test_01_actAutAntRecPwrDiff2AntBasedSlCellDetRec}
    Perform Delta Commissioning On gNB    delta=${delta_test_01_phase_3}
    gnb_recovery.Verify autonomous reset   timeout=900  # added Health check period
    Wait for next pm period if little time left   min_minutes_left=${15}
    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M8020C18
    Disable 7043 feature
    Sleep    120s    waiting for tl stable after disabling feature


[1][1.0] 002_CB007043_Abnormal Antenna Tx Power Measurement Sleeping Cell Detection and Recovery - all recovery phases
    Disable 7043 feature
    Run keyword and ignore error   Perform Delta Commissioning On gNB    delta=${sleeping_cell_object_creation}
    # Enable 7043
    Wait for next pm period if little time left   min_minutes_left=${15}
    Perform Delta Commissioning On gNB    delta=${delta_force_reset_true}

    # Phase 1
    Perform Delta Commissioning On gNB    delta=${delta_test_02_phase_1}
    Sleep   ${autAntRecPwrBasedSlCellDetHCheckFreq}s   Health check period
    Wait until keyword succeeds   ${autAntRecPwrBasedSlCellRecPh1Timer}s   10s   gnb_alarms.verify_alarm_is_active
       ...    ${002_alarm}
    Wait for next pm period if little time left   min_minutes_left=${15}
    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M8020C26
    Disable 7043 feature

    #Phase 2
    Perform Delta Commissioning On gNB    delta=${delta_test_02_phase_2}
    Sleep   ${autAntRecPwrBasedSlCellDetHCheckFreq}   Health check period
    Wait For Bbmod Reboot   bbmod_id=1   timeout=240
    Wait for next pm period if little time left   min_minutes_left=${15}
    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M8020C27
    Disable 7043 feature
    Sleep    120s    waiting for tl stable after disabling feature


    #Phase 3
    Perform Delta Commissioning On gNB    delta=${delta_test_02_phase_3}
    gnb_recovery.Verify autonomous reset   timeout=1500  # added Health check period
#    Wait for next pm period if little time left   min_minutes_left=${15}
    Sleep    120s    waiting for properly set counters
    Wait until keyword succeeds  15 min  60s   gnb_counter.Get pm counter info via gui   counter_id=M8020C28
    Disable 7043 feature
    Sleep    120s    waiting for tl stable after disabling feature
