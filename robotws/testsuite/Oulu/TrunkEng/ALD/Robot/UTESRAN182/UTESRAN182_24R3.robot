*** Settings ***
Force Tags    RF50

Documentation
...   contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...     2_11_UTESRAN182

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_10_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_10_alarm_RF_reset_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_10_alarm_site_reset_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_1836_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_1836_alarm_RF_reset_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_1836_alarm_site_reset_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_10_alarm_RF_lock_RMOD4_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_10_alarm_RF_reset_RMOD4_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_10_alarm_site_reset_RMOD4_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_1836_alarm_RF_lock_RMOD4_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_1836_alarm_RF_reset_RMOD4_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_1836_alarm_site_reset_RMOD4_ANT1.robot
#Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_10_alarm_RF_lock_RMOD5_ANT1.robot
#Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_10_alarm_RF_reset_RMOD5_ANT1.robot
#Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_10_alarm_site_reset_RMOD5_ANT1.robot
#Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_1836_alarm_RF_lock_RMOD5_ANT1.robot
#Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_1836_alarm_RF_reset_RMOD5_ANT1.robot
#Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN182/ald_1836_alarm_site_reset_RMOD5_ANT1.robot

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
#testcases 1-6 tested with AHPMDB and FLMB
01_10-alarm-RF-lock-RMOD-1
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5102
    ALD 10 Alarm With Rf Lock RMOD-1 ANT1

02_10-alarm-RF-reset-RMOD-1
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5103
    ALD 10 Alarm With Rf Reset RMOD-1 ANT1

03_10-alarm-Site-reset-RMOD-1
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5104
    ALD 10 Alarm With Site Reset RMOD-1 ANT1

04_1836-alarm-RF-lock-RMOD-1
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_851103
    ALD 1836 Alarm With Rf Lock RMOD-1 ANT1

05_1836-alarm-RF-reset-RMOD-1
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_851104
    ALD 1836 Alarm With Rf Reset RMOD-1 ANT1

06_1836-alarm-Site-reset-RMOD-1
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5107
    ALD 1836 Alarm With Site Reset RMOD-1 ANT1

#testcases 7-12 tested with AREA and FLGA
07_10-alarm-RF-lock-RMOD-4
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5108
    ALD 10 Alarm With Rf Lock RMOD-4 ANT1

08_10-alarm-RF-reset-RMOD-4
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5109
    ALD 10 Alarm With Rf Reset RMOD-4 ANT1

09_10-alarm-Site-reset-RMOD-4
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5110
    ALD 10 Alarm With Site Reset RMOD-4 ANT1

10_1836-alarm-RF-lock-RMOD-4
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_851109
    ALD 1836 Alarm With Rf Lock RMOD-4 ANT1

11_1836-alarm-RF-reset-RMOD-4
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_851110
    ALD 1836 Alarm With Rf Reset RMOD-4 ANT1

12_1836-alarm-Site-reset-RMOD-4
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5113
    ALD 1836 Alarm With Site Reset RMOD-4 ANT1

#testcases 13-18 tested with ARGA and FLGA
#13_10-alarm-RF-lock-RMOD-5
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5113
#    ALD 10 Alarm With Rf Lock RMOD-5 ANT1

#14_10-alarm-RF-reset-RMOD-5
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5113
#    ALD 10 Alarm With Rf Reset RMOD-5 ANT1

#15_10-alarm-Site-reset-RMOD-5
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5113
#    ALD 10 Alarm With Site Reset RMOD-5 ANT1

#16_1836-alarm-RF-lock-RMOD-5
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5113
#    ALD 1836 Alarm With Rf Lock RMOD-5 ANT1

#17_1836-alarm-RF-reset-RMOD-5
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5113
#    ALD 1836 Alarm With Rf Reset RMOD-5 ANT1

#18_1836-alarm-Site-reset-RMOD-5
#    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_5113
#    ALD 1836 Alarm With Site Reset RMOD-5 ANT1
