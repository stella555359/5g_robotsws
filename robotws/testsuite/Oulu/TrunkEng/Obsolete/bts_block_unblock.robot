*** Settings ***
Force Tags  PY36

Documentation
...   Author:   Essi Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.pass_rate

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Common Test Setup
Test Teardown     Common Test Teardown

*** Test Cases ***
Block unblock BTS
    [Documentation]   Blocks and unblocks BTS.
    run keyword in loop and return pass rate
        ...    name=Block unblock BTS
        ...    test_case=1
        ...    loops=1
		...    keywords=Block unblock BTS
        ...    expected_pass_rate=1

*** Keywords ***
Block unblock BTS
    BTS.Print Step Text                          1  Check Preconditions
    Common Preconditions
    BTS.Print Step Text                          2  Block BTS
    BuiltIn.Run Keyword And Continue On Failure     ADMIN.Block
    BTS.Print Step Text                          3  Wait for alarm
    ALARMS.Add Expected Alarm                       unit_path=[2_11_UTESRAN072] MRBTS-80124  alarm_id=7102
                                               ...  fault_id=50   fault_name=BTS blocked  severity=Critical
    ALARMS.Add Expected Alarm To Allowed
    BuiltIn.Run Keyword And Continue On Failure     ALARMS.Check Expected Alarms  wait_active_timeout=${120}
    BTS.Print Step Text                          4  Check alarms
    BuiltIn.Run Keyword And Continue On Failure     ALARMS.Check Alarm History  reset_alarms=True
    BTS.Print Step Text                          5  Unblock BTS
    BuiltIn.Run Keyword And Continue On Failure     ADMIN.Unblock  timeout=180
    ALARMS.Reset Alarm Listener
    BuiltIn.Run Keyword And Continue On Failure     Wait For All Cells Up  time_limit=${300}
    BTS.Print Step Text                          6  Check alarm history
    BuiltIn.Run Keyword And Continue On Failure     ALARMS.Check Alarm History  reset_alarms=True
    BTS.Print Step Text                          7  Check Postconditions
    Common Postconditions
