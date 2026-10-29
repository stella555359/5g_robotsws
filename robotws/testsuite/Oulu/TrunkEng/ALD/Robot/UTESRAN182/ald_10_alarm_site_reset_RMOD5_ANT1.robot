*** Settings ***

Documentation
...  Author:   Jere Jacklin
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/ald_10_alarm_with_site_reset.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py

*** Keywords ***
ALD 10 Alarm With Site Reset RMOD-5 ANT1

    ${ALARM_ANTL}  Set Variable                        RMOD-5/ANTL-1
    ${WAIT_TIME_BEFORE_ALARM}  Set Variable            120
    ${WAIT_TIME_AFTER_CANCELLING_ALARM}  Set Variable  60
    #  Affected ANTLs is used for FEG calculation, FEGs are allowed to change for this specific ANTL
    #  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
    @{AFFECTED_ANTLS}=  Create List
    ${ALARM}  Set Variable                             10

    [Documentation]    Generate No Connection To Unit Alarm
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...   ${ALARM_ANTL}  ${WAIT_TIME_BEFORE_ALARM}  ${WAIT_TIME_AFTER_CANCELLING_ALARM}
        ...   ${AFFECTED_ANTLS}  ${ALARM}
        ...   name=ALD 10 Alarm With Site Reset RMOD-5 ANT1
        ...   test_case=1
        ...   collect_test_logs=${COLLECT_LOGS}
        ...   loops=${TEST_LOOPS}
        ...   keywords=ALD 10 Alarm With Site Reset
        ...   expected_pass_rate=1
