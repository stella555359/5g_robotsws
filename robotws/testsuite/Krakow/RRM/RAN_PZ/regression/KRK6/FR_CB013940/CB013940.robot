*** Settings ***
Documentation     Suite for triggering unstable RU voltage
...               maintainer: dawid.dabrowski@nokia.com, jakub.1.bak@nokia.com

Resource          taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource          ./resources/suite_specific_keywords.robot

Variables         taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Test Cases ***
CB013940-A_101#EXC1_expT_Reconfiguration_during_Active_Fault_4680_for_new_RUs
    [Setup]    Common Preconditions
    Set alVoltUnstableExpirationTimer value      value=30       rmod_id=2
    Set alVoltUnstableThreshold value            threshold=1    rmod_id=2
    suite_specific_keywords.Change Ru Voltage   voltage=${30000}    ru_id=${1}
    suite_specific_keywords.Wait For Voltage Change    voltage=${30000}    ru_id=${1}
    Sleep   60s
    suite_specific_keywords.Change Ru Voltage   voltage=${52000}    ru_id=${1}
    suite_specific_keywords.Wait For Voltage Change    voltage=${52000}    ru_id=${1}
    Sleep    300s
    Set alVoltUnstableExpirationTimer value      value=15       rmod_id=2
    Wait for alVoltUnstableExpirationTimerRU min to expiry    waiting_time=15min
    Wait for all cells to be on air
    [Teardown]    Common Postconditions

CB013940-B_101#B1_Successful_Auto-Recovery_for_older_RUs
    [Setup]    Common Preconditions
    Set alVoltUnstableExpirationTimer value      value=15       rmod_id=3
    Set alVoltUnstableThreshold value            threshold=1    rmod_id=3
    suite_specific_keywords.Change Ru Voltage   voltage=${30000}    ru_id=${0}
    suite_specific_keywords.Wait For Voltage Change    voltage=${30000}    ru_id=${2}
    Sleep   60s
    suite_specific_keywords.Change Ru Voltage   voltage=${52000}    ru_id=${0}
    suite_specific_keywords.Wait For Voltage Change    voltage=${52000}    ru_id=${2}
    Wait for alVoltUnstableExpirationTimerRU min to expiry    waiting_time=15min
    Wait for all cells to be on air
    [Teardown]    Common Postconditions

CB013940_RelianceIndia_CVR_001
    [Setup]    Test Setup with on air tl preparation    prefix_tag=RJio
    Set alVoltUnstableExpirationTimer value      value=15       rmod_id=1
    Set alVoltUnstableExpirationTimer value      value=15       rmod_id=2
    Set alVoltUnstableExpirationTimer value      value=15       rmod_id=3
    Set alVoltUnstableThreshold value            threshold=1    rmod_id=1
    Set alVoltUnstableThreshold value            threshold=1    rmod_id=2
    Set alVoltUnstableThreshold value            threshold=1    rmod_id=3
    suite_specific_keywords.Change Ru Voltage   voltage=${30000}    ru_id=${0}
    suite_specific_keywords.Wait For Voltage Change    voltage=${30000}    ru_id=${1}
    suite_specific_keywords.Change Ru Voltage   voltage=${30000}    ru_id=${1}
    suite_specific_keywords.Wait For Voltage Change    voltage=${30000}    ru_id=${2}
    Sleep   60s
    suite_specific_keywords.Change Ru Voltage   voltage=${52000}    ru_id=${0}
    suite_specific_keywords.Wait For Voltage Change    voltage=${52000}    ru_id=${1}
    suite_specific_keywords.Change Ru Voltage   voltage=${52000}    ru_id=${1}
    suite_specific_keywords.Wait For Voltage Change    voltage=${52000}    ru_id=${2}
    Sleep    120s
    suite_specific_keywords.Change Ru Voltage   voltage=${30000}    ru_id=${0}
    suite_specific_keywords.Wait For Voltage Change    voltage=${30000}    ru_id=${1}
    suite_specific_keywords.Change Ru Voltage   voltage=${30000}    ru_id=${1}
    suite_specific_keywords.Wait For Voltage Change    voltage=${30000}    ru_id=${2}
    Wait for alVoltUnstableExpirationTimerRU min to expiry    waiting_time=30min
    suite_specific_keywords.Change Ru Voltage   voltage=${52000}    ru_id=${0}
    suite_specific_keywords.Wait For Voltage Change    voltage=${52000}    ru_id=${1}
    suite_specific_keywords.Change Ru Voltage   voltage=${52000}    ru_id=${1}
    suite_specific_keywords.Wait For Voltage Change    voltage=${52000}    ru_id=${2}
    Wait for alVoltUnstableExpirationTimerRU min to expiry    waiting_time=15min
    Wait for all cells to be on air
    [Teardown]    Common Postconditions

