*** Settings ***
Documentation
...    Author: Bartosz Odziomek
...    Contact: bartosz.odziomek@nokia.com
...    Description: Resources for CB007043-SR-C Sleeping cell detection feature configuration enhancements feature

Library       testsuite.Krakow.RRM.RAN_PZ.resources.pm_counter_du.PmCounterDu
Library       testsuite/Krakow/RRM/RAN_PZ/resources/pm_counters.py
Library       taf.rfrl.bts.recovery.SmodFaultRecovery    WITH NAME   gnb_recovery
Library       taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME   gnb_counter
Library       taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification     WITH NAME    gnb_alarms
Library       taf.rfrl.bts.devices.du.cell_operations.EnbCellOperations    WITH NAME      enbcell
Library       taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell

Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/bts/robot/recovery_gnb.robot

Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     vars_deltas.py

*** Keywords ***
Test teardown for CB007043
    Disable 7043 feature
    Wait For onAir State
    gnbcell.Wait for all cells to be onair   timeout=900
    Common Postconditions With Watching Alarms

Disable 7043 feature
    Perform Delta Commissioning On gNB    delta=${delta_disable_7043}

Suite setup
    Perform Full Commissioning and Wait for onAir    prefix_tag=main_gnb
    Common Suite Setup



