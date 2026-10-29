*** Settings ***

Documentation
...  Author:   Pasi Seppälä
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/mha_returncode_rf_lock.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py

*** Keywords ***
ALD 1848 Alarm With Rf Lock RMOD1 ANT3

    ${WAIT_BEFORE_ALARMS}  Set Variable                120
    ${WAIT_AFTER_RF_LOCK}  Set Variable                30
    ${EMULATOR_LINE}  Set Variable                     EmulatorLine2
    ${RETURN_CODE}  Set Variable                       WorkingSoftwareMissing
    #  ALARM = fault id
    ${ALARM}  Set Variable                             1848
    ${ALARM_ANTL}  Set Variable                        RMOD-1/ANTL-3
    ${RADIO}  Set Variable                             RMOD-1
    #  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
    #  If there is not going to be change in FEG values, leave this variable empty
    @{AFFECTED_ANTLS}=  Create List
    ${WANTED_STATE}  Set Variable                      degraded
    ${ALLOWED_ALARMS_FILE}  Set Variable               testsuite/Oulu/TrunkEng/ALD/allowed_alarms.txt
    ${FAULT_NAME}    Set Variable                      Antenna line device missing software

    [Documentation]    Set returncode for MHA during Rf Lock
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ALARM_ANTL}  ${ALARM}  ${EMULATOR_LINE}  ${RETURN_CODE}  ${RADIO}  ${WAIT_AFTER_RF_LOCK}
    ...   ${WAIT_BEFORE_ALARMS}  ${WANTED_STATE}  ${AFFECTED_ANTLS}  ${FAULT_NAME}
    ...   name=ALD 1848 Alarm With Rf Lock RMOD1 ANT3
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=Mha Returncode Rf Lock
    ...   expected_pass_rate=1
