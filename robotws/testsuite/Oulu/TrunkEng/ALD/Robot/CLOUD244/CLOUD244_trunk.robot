*** Settings ***
Force Tags    RF50

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...  ALD testing with 2_11_CLOUD244

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1870_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1869_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_10_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1836_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1872_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1847_alarm_RF_lock_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_10_alarm_RF_lock_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1836_alarm_RF_lock_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1848_alarm_RF_lock_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1871_alarm_RF_lock_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_10_alarm_RF_lock_RMOD2_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1836_alarm_RF_lock_RMOD2_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1869_alarm_RF_lock_RMOD2_ANT5.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1870_alarm_RF_lock_RMOD2_ANT5.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_10_alarm_RF_lock_RMOD2_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/CLOUD244/ald_1836_alarm_RF_lock_RMOD2_ANT3.robot


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
#Cases 1-5: LNA1 and LNA2 serving other BTS
01_1870_alarm_RF_lock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5159
    ALD 1870 Alarm With Rf Lock RMOD1 ANT1

02_1869_alarm_RF_lock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5160
    ALD 1869 Alarm With Rf Lock RMOD1 ANT1

03_10_alarm_RF_lock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5161
    ALD 10 Alarm With Rf Lock RMOD1 ANT1

04_1836_alarm_RF_lock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5162
    ALD 1836 Alarm With Rf Lock RMOD1 ANT1

05_1872_alarm_RF_lock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5163
    ALD 1872 Alarm With Rf Lock RMOD1 ANT1

#Cases 6-10: LNA1 serving this BTS and LNA2 serving other BTS
06_1847_alarm_RF_lock_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5164
    ALD 1847 Alarm With Rf Lock RMOD1 ANT3

07_10_alarm_RF_lock_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5165
    ALD 10 Alarm With Rf Lock RMOD1 ANT3

08_1836_alarm_RF_lock_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5166
    ALD 1836 Alarm With Rf Lock RMOD1 ANT3

09_1848_alarm_RF_lock_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5167
    ALD 1848 Alarm With Rf Lock RMOD1 ANT3

10_1871_alarm_RF_lock_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5168
    ALD 1871 Alarm With Rf Lock RMOD1 ANT3

#Cases 11-12: One MHA serving this BTS and two MHAs serving other BTS
11_10_alarm_RF_lock_RMOD2_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5169
    ALD 10 Alarm With Rf Lock RMOD2 ANT1

12_1836_alarm_RF_lock_RMOD2_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5170
    ALD 1836 Alarm With Rf Lock RMOD2 ANT1

#cases 22-26: not commissioned MHAs

13_1869_alarm_RF_lock_RMOD2_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5171
    ALD 1869 Alarm With Rf Lock RMOD2 ANT5

14_1870_alarm_RF_lock_RMOD2_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5172
    ALD 1870 Alarm With Rf Lock RMOD2 ANT5

15_10_alarm_RF_lock_RMOD2_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5173
    ALD 10 Alarm With Rf Lock RMOD2 ANT3

16_1836_alarm_RF_lock_RMOD2_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5174
    ALD 1836 Alarm With Rf Lock RMOD2 ANT3
