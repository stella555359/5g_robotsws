*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/mha_alarm_during_site_reset.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py


*** Keywords ***
ALD 1869 Alarm With Site Reset RMOD-1 ANT5

    ${WAIT_BEFORE_ALARMS}  Set Variable                120
    ${WAIT_AFTER_SITE_RESET}  Set Variable             30
    ${WAIT_AFTER_CANCEL_ALARM}  Set Variable           60
    ${LNA}  Set Variable                               lna2
    ${ALARM_TYPE}  Set Variable                        MinorTmaFault
    ${EMULATOR_LINE}  Set Variable                     EmulatorLine1
    #  ALARM = fault id
    ${ALARM}  Set Variable                             1869
    ${ALARM_ANTL}  Set Variable                        RMOD-1/ANTL-5
    #  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
    #  If there is not going to be change in FEG values, leave this variable empty
    @{AFFECTED_ANTLS}=  Create List
    ${WANTED_STATE}  Set Variable                      degraded
    ${ALLOWED_ALARMS_FILE}  Set Variable               testsuite/Oulu/TrunkEng/ALD/allowed_alarms.txt
    ${FAULT_NAME}    Set Variable                      Mast Head Amplifier fault

    [Documentation]    Raise MHA alarm during site Reset
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...  ${WAIT_BEFORE_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}  ${WAIT_AFTER_SITE_RESET}
    ...  ${LNA}  ${ALARM_TYPE}  ${EMULATOR_LINE}  ${ALARM}  ${ALARM_ANTL}  ${AFFECTED_ANTLS}
    ...  ${WANTED_STATE}  ${FAULT_NAME}
    ...   name=ALD 1869 Alarm With Site Reset RMOD-1 ANT5
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=Mha Alarm During Site Reset
    ...   expected_pass_rate=1
