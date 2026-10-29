*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ./Resources/CB007963_common_keywords.robot

Documentation
...    Author: Shifu Lan
...    Contact: shifu.lan@nokia-sbell.com
...    squad group:SG_04
...    Feature CB007963 for switching ToP Master with L3 call and alarm check

Force Tags    HAZ4_T04

*** Test Cases ***
[1]CB007963-SR-F_001_switch_current_Best_ToP_Master_With_L3CALL_CheckAlram
    [Tags]    RF50
    ${fault_list}    Create List    16    4298    61631
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Switch Current Best ToP Master With L3CALL Check Alarm
