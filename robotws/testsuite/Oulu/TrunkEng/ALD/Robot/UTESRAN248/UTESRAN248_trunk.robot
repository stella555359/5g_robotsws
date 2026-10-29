*** Settings ***
Force Tags    RF50

Documentation
...   contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...   TL 2_11_UTESRAN248

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1836_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1835_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1834_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1836_alarm_RF_lock_RMOD2_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1835_alarm_RF_lock_RMOD2_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1834_alarm_RF_lock_RMOD2_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1836_alarm_RF_lock_RMOD2_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1835_alarm_RF_lock_RMOD2_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1834_alarm_RF_lock_RMOD2_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1836_alarm_RF_lock_RMOD1_ANT5.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_10_alarm_RF_lock_RMOD1_ANT5.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_10_alarm_RF_lock_RMOD3_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1847_alarm_Site_reset_RMOD3_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1869_alarm_Site_reset_RMOD3_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN248/ald_1870_alarm_RF_lock_RMOD3_ANT3.robot

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
01_1836_alarm_RFlock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5188
    ALD 1836 Alarm With Rf Lock RMOD1 ANT1

02_1835_alarm_RFlock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5189
    ALD 1835 Alarm With Rf Lock RMOD1 ANT1

03_1834_alarm_RFlock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5190
    ALD 1834 Alarm With Rf Lock RMOD1 ANT1

04_1836_alarm_RFlock_RMOD2_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5191
    ALD 1836 Alarm With Rf Lock RMOD2 ANT1

05_1835_alarm_RFlock_RMOD2_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5192
    ALD 1835 Alarm With Rf Lock RMOD2 ANT1

06_1834_alarm_RFlock_RMOD2_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5193
    ALD 1834 Alarm With Rf Lock RMOD2 ANT1

07_1836_alarm_RFlock_RMOD2_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5194
    ALD 1836 Alarm With Rf Lock RMOD2 ANT3

08_1835_alarm_RFlock_RMOD2_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5195
    ALD 1835 Alarm With Rf Lock RMOD2 ANT3

09_1834_alarm_RFlock_RMOD2_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5196
    ALD 1834 Alarm With Rf Lock RMOD2 ANT3

10_1836_alarm_RFlock_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5197
    ALD 1836 Alarm With Rf Lock RMOD1 ANT5

11_10_alarm_RFlock_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5198
    ALD 10 Alarm With Rf Lock RMOD1 ANT5

12_10_alarm_RFlock_RMOD3_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5199
    ALD 10 Alarm With Rf Lock RMOD3 ANT1

13_1847_alarm_Sitereset_RMOD3_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5200
    ALD 1847 Alarm With Site Reset RMOD3 ANT3

14_1869_alarm_Sitereset_RMOD3_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5201
    ALD 1869 Alarm With Site reset RMOD3 ANT3

15_1870_alarm_RFlock_RMOD3_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5202
    ALD 1870 Alarm With Rf Lock RMOD3 ANT3
