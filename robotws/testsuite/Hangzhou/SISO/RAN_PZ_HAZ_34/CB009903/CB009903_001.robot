*** Settings ***
Force Tags    PY36
Suite Setup       CI_interface common setup
Suite Teardown    robot_common_operations.Common suite Teardown
Documentation
...   author: xiaofeng.1.zhu@nokia-sbell.com
...   contact: xiaofeng.1.zhu@nokia-sbell.com
Variables         Resources/CB009903_modify_para.py
Resource          Resources/CB009903_Keyword.robot
*** Test Cases ***
[1]CB009903-SR-A-B2_01_Critical_Fault_2919_trigger_and_recover
     [Documentation]    Critical Fault 2919 trigger and recover
     [Tags]     CRT_TRUNK
     [Setup]     Case Setup 9903
     config alVoltHighThreshold to 116% and set volt to trigger 2919 alarm
     set 58.5 volt and wait 5min to recover 2919 alarm
     log to console   recover
     [Teardown]    Recover action

[2]CB009903-SR-A-B2_01_Critical_Fault_2919_trigger_and_recover_via_NIDD_reconfiguration
     [Documentation]    Critical Fault 2919 trigger and recover
     [Tags]     CRT_TRUNK
     [Setup]     Case Setup 9903
     config alVoltHighThreshold to 116% and set volt to trigger 2919 alarm
     config different alVoltHighThreshold parameter to trigger or recover 2919 alarm
     [Teardown]    Recover action

[1]CB009903-SR-A-B2_02_Critical_Fault_2920_trigger_and_recover
    [Documentation]    Critical Fault 2920 trigger and recover
     [Tags]     CRT_TRUNK
     [Setup]    Case Setup 9903
     config alVoltLowThreshold to -111% and set volt to trigger 2920 alarm
     set 38.6 volt and wait 5min to recover 2920 alarm
     [Teardown]    Recover action

[2]CB009903-SR-A-B2_02_Critical_Fault_2920_trigger_and_recover_via_NIDD_reconfiguration
    [Documentation]    Critical Fault 2920 trigger and recover
     [Tags]     CRT_TRUNK
     [Setup]    Case Setup 9903
     config alVoltLowThreshold to -111% and set volt to trigger 2920 alarm
     config different alVoltLowThreshold parameter to trigger or recover 2920 alarm
     [Teardown]    Recover action

[1]CB009903-SR-A-B2_03_Fault_4680_trigger_and_recover
    [Documentation]    Fault 4680 trigger and recover
     [Tags]     CRT_TRUNK
     [Setup]    Case Setup 9903
     config alVoltUnstableThreshold to 2 and set volt to trigger 2919 and 2920 alarm
     set 50v and wait 5min to recover 2919 and 2920 alarm
     AlarmWatchdog.add_allow_alarms    fault_id=4680
     set 36v on RMOD1 and 60v on RMOD 2 to trigger 4680 alarm
     set 50v and config alVoltUnstableThreshold to 1 recover 4680 alarm
     AlarmWatchdog.remove_allow_alarms    fault_id=4680
     [Teardown]    Recover action
