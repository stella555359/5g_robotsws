*** Settings ***
Documentation
...     [Author]        "Shankar Manurwar"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"



Resource        ${CURDIR}/../resources/common_keywords.robot

#Suite Setup       Setup Oamops
#Suite Teardown    Teardown Oamops
Suite Setup     Pre-conditions for testsuite
Suite Teardown     Post-conditions for testteardown


*** Test Cases ***
[1][1.0] BTS Site Reset with 25 times iteration for All HWs

    Loop reset

***Keywords***

Loop reset

    FOR     ${i}   IN RANGE    25
        ${alarm}=    Verify alarm
        Reset Bts   req_rat=5g     should_be_onair=False   wait_for=300
        Sleep   400
        Verify Alarm     check_unexpected_alarms=${True}     prev_alarms=${alarm}
    END
