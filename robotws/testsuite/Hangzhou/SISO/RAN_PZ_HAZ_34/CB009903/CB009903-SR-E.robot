*** Settings ***
Force Tags    PY36
Suite Setup       CI_interface common setup
Suite Teardown    robot_common_operations.Common suite Teardown
Documentation
...   author: miao.1.lu@nokia-sbell.com
...   contact: miao.1.lu@nokia-sbell.com
Variables         Resources/CB009903_modify_para.py
Resource          Resources/CB009903_Keyword.robot

*** Test Cases ***
[1]CB009903-SR-E_01_Minor_Fault_2919_trigger_and_recover
     [Documentation]    Minor Fault 2919 trigger and recover
     [Tags]     CRT_TRUNK
     [Setup]     Case Setup 9903

     config alVoltHighThresholdMinor == 88% voltage=56010 and set volt to trigger 2919 alarm

     config voltage=56999 and check 2919 alarm voltage 56V cancelled

     [Teardown]    Recover action

[2]CB009903-SR-E_01_Minor_Fault_2919_trigger_and_recover_via_NIDD_reconfiguration
     [Documentation]    Minor Fault 2919 trigger and recover
     [Tags]     CRT_TRUNK
     [Setup]     Case Setup 9903

     config alVoltHighThresholdMinor == 88% voltage=56010 and set volt to trigger 2919 alarm

     Reconfigure alVoltHighThresholdMinor and check alarm

     check Critical FID2919 and check minor cancel

     [Teardown]    Recover action

[1]CB009903-SR-E_02_Minor_Fault_2920_trigger_and_recover
     [Documentation]    Minor Fault 2920 trigger and recover
     [Tags]     CRT_TRUNK
     [Setup]     Case Setup 9903

     config alVoltHighThresholdMinor == -88% voltage=41490 and check 2920 alarm cancel

     config voltage=40550 and check 2920 alarm cancel

     [Teardown]    Recover action

[2]CB009903-SR-E_02_Minor_Fault_2920_trigger_and_recover_via_NIDD_reconfiguration
     [Documentation]    Minor Fault 2920 trigger and recover
     [Tags]     CRT_TRUNK
     [Setup]     Case Setup 9903
     config alVoltHighThresholdMinor == -88% voltage=41490 and check 2920 alarm cancel

     Reconfigure alVoltLowThresholdMinor and check alarm 2920

     check Critical FID2920 and check minor cancel

     [Teardown]    Recover action

