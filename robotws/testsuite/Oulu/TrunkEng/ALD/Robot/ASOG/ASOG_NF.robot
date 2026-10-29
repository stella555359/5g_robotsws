*** Settings ***
Force Tags    RF50

Documentation
...   contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...     Tests with ASOG

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
#Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/ald_10_alarm_RF_lock_RMOD1_ANT1.robot
#Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/ald_1836_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/ald_1834_alarm_RF_lock_RMOD3_ANT2.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/ald_1835_alarm_RF_lock_RMOD3_ANT2.robot
#Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/vswr_alarm_telnet_tests_RMOD3_ANT1.robot



Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup  AND
...                Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown

*** Variables ***
${ALLOWED_ALARMS_FILE}=               testsuite/Oulu/TrunkEng/ALD/allowed_alarms.txt
${COLLECT_LOGS}=                      Always
${TEST_LOOPS}                         1
${SCOUT_TL_NAME}                      True

*** Test Cases ***
#Test with OBSAI Radio
03_1834_RFlock_RMOD3_ANT2
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_459
    ALD 1834 Alarm With Rf Lock RMOD3 ANT2

04_1835_RFlock_RMOD3_ANT2
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_457
    ALD 1835 Alarm With Rf Lock RMOD3 ANT2
