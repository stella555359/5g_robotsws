*** Settings ***
Documentation
...  Author:  Valtteri Lamberg
...  Contact:  valtteri.lamberg@nokia.com

Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library           testsuite.Oulu.TrunkEng.Common.Python.Interfaces.pass_rate

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Common Test Setup
Test Teardown     Common Test Teardown

*** Test Cases ***
Lock Unlock BTS
    run keyword in loop and return pass rate
        ...    name=Lock Unlock BTS
        ...    test_case=1
        ...    loops=1
    	...    keywords=Lock Unlock BTS
        ...    expected_pass_rate=1

*** Keywords ***
Lock Unlock BTS
    Print Step Text                      1  Check Preconditions
    Common Preconditions
    Print Step Text                      2  Lock BTS
    ${dist_name}=                           Get distName Based On Class  com.nokia.srbts.nrbts:NRDU
    # https://jiradc.ext.net.nokia.com/browse/TAF-2849 Problems with lock when using only this distName
    Run Keyword And Continue On Failure     ADMIN.Lock  dist_name=${dist_name}  connection=default  timeout=120
    Sleep                                   3 min
    #TODO Check that BTS is locked
    Print Step Text                      3  Check alarms
    Run Keyword And Continue On Failure     ALARMS.Check Alarm History  reset_alarms=True
    Print Step Text                      4  Unlock BTS
    Run Keyword And Continue On Failure     ADMIN.Unlock  dist_name=${dist_name}  connection=default
    Run Keyword And Continue On Failure     Wait For All Cells Up  time_limit=${300}
    Print Step Text                      5  Check alarm history
    Run Keyword And Continue On Failure     ALARMS.Check Alarm History  reset_alarms=True
    Print Step Text                      6  Check Postconditions
    Common Postconditions
