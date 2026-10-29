*** Settings ***
Force Tags    RF50

Documentation
...   contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...     Tests with ASOG

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/ald_10_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/ald_1836_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/ald_1834_alarm_RF_lock_RMOD3_ANT2.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/ald_1835_alarm_RF_lock_RMOD3_ANT2.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/ASOG/vswr_alarm_telnet_tests_RMOD3_ANT1.robot



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
#${MARVIN}                             ${True}

*** Test Cases ***
01_10_alarm_RFlock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5238
    ALD 10 Alarm With RF Lock RMOD1 ANT1

02_1836_alarm_RFlock_RMOD1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5239
    ALD 1836 Alarm With RF Lock RMOD1 ANT1

#Test with OBSAI Radio
03_1834_RFlock_RMOD3_ANT2
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5240
    ALD 1834 Alarm With Rf Lock RMOD3 ANT2

04_1835_RFlock_RMOD3_ANT2
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5241
    ALD 1835 Alarm With Rf Lock RMOD3 ANT2

05_1837_VSWR_Alarm_RMOD3_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5242
    1837 VSWR Alarm RMOD3 ANT1

06_1838_VSWR_Alarm_RMOD3_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5243
    1838 VSWR Alarm RMOD3 ANT1

07_1838_and_1837_VSWR_Alarms_RMOD3_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5244
    1838 and 1837 VSWR Alarms RMOD3 ANT1
