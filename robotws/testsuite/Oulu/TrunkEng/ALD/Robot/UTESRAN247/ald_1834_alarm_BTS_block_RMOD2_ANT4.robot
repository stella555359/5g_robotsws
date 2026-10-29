*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/ald_1834_alarm_with_BTS_block.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py


*** Keywords ***
ALD 1834 Alarm With BTS Block RMOD2 ANT4

    ${ALARM_ANTL}  Set Variable                        RMOD-2/ANTL-4
    #  Possible second radio for RF lock/unlock
    ${WAIT_TIME_BEFORE_ALARM}  Set Variable            150
    ${WAIT_TIME_AFTER_CANCELLING_ALARM}  Set Variable  60
    #  Affected ANTLs is used for FEG calculation, FEGs are allowed to change for this specific ANTL
    #  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
    @{AFFECTED_ANTLS}=  Create List
    ${ALARM}  Set Variable                             1834

    [Documentation]    Generate Above Current Window Alarm
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...   ${ALARM_ANTL}  ${WAIT_TIME_BEFORE_ALARM}  ${WAIT_TIME_AFTER_CANCELLING_ALARM}
        ...   ${AFFECTED_ANTLS}  ${ALARM}
        ...   name=ALD 1834 Alarm With BTS Block RMOD2 ANT4
        ...   test_case=1
        ...   collect_test_logs=${COLLECT_LOGS}
        ...   loops=${TEST_LOOPS}
        ...   keywords=ALD 1834 Alarm With BTS Block
        ...   expected_pass_rate=1
