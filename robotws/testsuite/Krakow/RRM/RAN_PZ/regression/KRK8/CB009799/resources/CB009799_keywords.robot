*** Settings ***
Documentation
...    Author: Bartosz Odziomek
...    Contact: bartosz.odziomek@nokia.com
...    Description: Resource for NR sleeping cell detection and the required recovery actions.

Library       testsuite.Krakow.RRM.RAN_PZ.resources.pm_counter_du.PmCounterDu
Library       testsuite/Krakow/RRM/RAN_PZ/resources/pm_counters.py
Library       taf.rfrl.bts.recovery.SmodFaultRecovery    WITH NAME   gnb_recovery
Library       taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME   gnb_counter

Library       taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification     WITH NAME    gnb_alarms
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/bts/robot/recovery_gnb.robot

Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     vars_deltas.py

*** Keywords ***
Verify alarm is active
    [Arguments]    ${alarm}
    Wait until keyword succeeds   ${${autAntRecPwrBasedSlCellRecPh1Timer}+${630}}s   10s   gnb_alarms.verify_alarm_is_active  ${alarm}

Test teardown for CB009799
    Run Keyword If Test Failed    Disable 9799 feature
    Perform Delta Commissioning On gNB    delta=${maintanance_disabled}
    Wait For onAir State
    Common Postconditions With Watching Alarms

Disable 9799 feature
    Perform Delta Commissioning On gNB    delta=${delta_disable_7043}

Suite setup 9799
    Perform Full Commissioning On Classical gnb     prefix_tag=main_gnb    update_timeout=1200
    Common Suite Setup

