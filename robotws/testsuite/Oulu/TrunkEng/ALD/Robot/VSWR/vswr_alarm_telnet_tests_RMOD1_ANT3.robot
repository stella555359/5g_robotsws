*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/vswr_fault_with_telnet_tests.robot
Library      testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.VSWR


*** Keywords ***
1838 VSWR Alarm RMOD1 ANT3
    ${ANTL}  Set Variable                        RMOD-1/ANTL-3
    ${RMOD}  Set Variable                        RMOD-1
    ${WAIT_FOR_ALARMS}  Set Variable             300
    ${WAIT_AFTER_CANCEL_ALARM}  Set Variable     60

    [Documentation]    Use telnet to set and cancel VSWR minor alarm.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ANTL}  ${RMOD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    ...   name=1838 VSWR Alarm RMOD1 ANT3
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=VSWR Minor Alarm With Telnet
    ...   expected_pass_rate=1

1837 VSWR Alarm RMOD1 ANT3
    ${ANTL}  Set Variable                        RMOD-1/ANTL-3
    ${RMOD}  Set Variable                        RMOD-1
    ${WAIT_FOR_ALARMS}  Set Variable             300
    ${WAIT_AFTER_CANCEL_ALARM}  Set Variable     60

    [Documentation]    Use telnet to set VSWR major alarm. Cancel of fault is done with RMOD lock and unlock.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ANTL}  ${RMOD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    ...   name=1837 VSWR Alarm RMOD1 ANT3
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=VSWR Major Alarm With Telnet
    ...   expected_pass_rate=1

1838 and 1837 VSWR Alarms RMOD1 ANT3
    ${ANTL}  Set Variable                        RMOD-1/ANTL-3
    ${RMOD}  Set Variable                        RMOD-1
    ${WAIT_FOR_ALARMS}  Set Variable             300
    ${WAIT_AFTER_CANCEL_ALARM}  Set Variable     60

    [Documentation]    Use telnet to set VSWR major alarm. Cancel of fault is done with RMOD lock and unlock.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ANTL}  ${RMOD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    ...   name=1838 and 1837 VSWR Alarms RMOD1 ANT3
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=VSWR Minor Major Alarm Telnet
    ...   expected_pass_rate=1
