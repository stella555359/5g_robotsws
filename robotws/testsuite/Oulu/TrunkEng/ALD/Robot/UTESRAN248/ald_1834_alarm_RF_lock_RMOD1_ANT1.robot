*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/ald_1834_alarm_with_rf_lock.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py

*** Keywords ***
ALD 1834 Alarm With Rf Lock RMOD1 ANT1

    ${ALARM_ANTL}  Set Variable                        RMOD-1/ANTL-1
    ${RADIO}  Set Variable                             RMOD-1
    #  Possible second radio for RF lock/unlock
    ${POSSIBLE_RADIO}  Set Variable                    RMOD-2
    ${WAIT_TIME_BEFORE_ALARM}  Set Variable            150
    ${WAIT_TIME_AFTER_LOCK}  Set Variable              30
    ${WAIT_TIME_AFTER_CANCELLING_ALARM}  Set Variable  60
    #  Affected ANTLs is used for FEG calculation, FEGs are allowed to change for this specific ANTL
    #  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
    @{AFFECTED_ANTLS}=  Create List
    ${ALARM}  Set Variable                             1834

    [Documentation]    Generate above current window alarm for LNA
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...   ${ALARM_ANTL}  ${RADIO}  ${WAIT_TIME_AFTER_CANCELLING_ALARM}
        ...   ${POSSIBLE_RADIO}  ${WAIT_TIME_BEFORE_ALARM}  ${WAIT_TIME_AFTER_LOCK}
        ...   ${AFFECTED_ANTLS}  ${ALARM}
        ...   name=ALD 1834 Alarm With Rf Lock RMOD1 ANT1
        ...   test_case=1
        ...   collect_test_logs=${COLLECT_LOGS}
        ...   loops=${TEST_LOOPS}
        ...   keywords=ALD 1834 Alarm With Rf Lock
        ...   expected_pass_rate=1
