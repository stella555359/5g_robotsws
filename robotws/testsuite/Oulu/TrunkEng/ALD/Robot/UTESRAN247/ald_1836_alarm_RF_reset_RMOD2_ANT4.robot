*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/ald_1836_alarm_with_rf_reset.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py


*** Keywords ***
ALD 1836 Alarm With Rf Reset RMOD2 ANT4

    ${ALARM_ANTL}  Set Variable                        RMOD-2/ANTL-4
    ${RADIO}  Set Variable                             RMOD-2
    #  Possible second radio for RF reset
    ${POSSIBLE_RADIO}  Set Variable
    ${WAIT_TIME_BEFORE_ALARM}  Set Variable            120
    ${WAIT_TIME_AFTER_LOCK}  Set Variable              30
    #  Affected ANTLs is used for FEG calculation, FEGs are allowed to change for this specific ANTL
    #  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
    @{AFFECTED_ANTLS}=  Create List                    RMOD-2/ANTL-3  RMOD-2/ANTL-4
    ${ALARM}  Set Variable                             1836

    [Documentation]    Generate Overcurrent Alarm
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...   ${ALARM_ANTL}  ${RADIO}
        ...   ${POSSIBLE_RADIO}  ${WAIT_TIME_BEFORE_ALARM}
        ...   ${AFFECTED_ANTLS}  ${ALARM}
        ...   name=ALD 1836 Alarm With Rf Reset RMOD2 ANT4
        ...   test_case=1
        ...   collect_test_logs=${COLLECT_LOGS}
        ...   loops=${TEST_LOOPS}
        ...   keywords=ALD 1836 Alarm With Rf Reset
        ...   expected_pass_rate=1
