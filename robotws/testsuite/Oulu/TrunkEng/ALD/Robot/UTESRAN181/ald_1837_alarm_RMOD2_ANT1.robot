*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/vswr_exceed_threshold.robot
Library      testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.VSWR
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py


*** Keywords ***
ALD 1837 Alarm RMOD2 ANT1

    ${ANTL}                     Set Variable     RMOD-2/ANTL-1
    ${RMOD}                     Set Variable     RMOD-2
    ${ALARM}                    Set Variable     1837
    ${THRESHOLD}                Set Variable     15  # VSWR threshold, actual threshold is 1.5 if given value is 15
    ${WAIT_FOR_ALARMS}          Set Variable     300
    ${WAIT_AFTER_CANCEL_ALARM}  Set Variable     60


    [Documentation]    Change VSWR threshold causing major alarm 1837.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ANTL}  ${RMOD}  ${ALARM}  ${THRESHOLD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    ...   name=ALD 1837 Alarm RMOD2 ANT1
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=Exceed VSWR Threshold
    ...   expected_pass_rate=1
