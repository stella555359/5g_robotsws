*** Settings ***
Suite Setup          SISO Coam Suite Setup
#Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource    ./resource/CB011039_common_resource.robot

Documentation
...    Author: liu yue
...    contact: yue.2.liu@nokis-sbell.com
...    squad group:SG_05
...    Feature CB011039 in 24R3 program
...    Used for AEQE or AEQY

Force Tags     RAN_5G   RAN_5G_TDD    SBTS00    PY310

*** Test Cases ***
[1]CB011039-5G-H_Radio_Module_online_dignostics_test_during_fail_safe_mode
    [Tags]    master_classicalbts_all   CRT_TRUNK
    ${fault_list}    Create List    2934    4681
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Get test RU index
    CB011039-5G-H_Radio_Module_online_dignostics_test_during_fail_safe_mode
    [Teardown]    Run keywords    run keyword and ignore error    RU exit fail safe mode
    ...    AND    Wait until keyword succeeds    10 min    30 sec   verify all cells should be onair
    ...    AND    add fault to allowed history fault list    faultId=${2934}
    ...    AND    add fault to allowed history fault list    faultId=${4681}
    ...    AND    SISO Coam Test Teardown
