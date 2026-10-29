*** Settings ***
Force Tags    RF50

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...   ALD testing with 2_11_UTESRAN246

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN246/ald_1847_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN246/ald_1847_alarm_site_reset_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN246/ald_1869_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN246/ald_1869_alarm_site_reset_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN246/ald_1870_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN246/ald_1870_alarm_site_reset_RMOD1_ANT1.robot

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
${USER_DEFINED_RESET}=                site


*** Test Cases ***
01_1847_alarm_RF_lock_RMOD1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5037
    ALD 1847 Alarm With Rf Lock RMOD-1 ANT5

02_1847_alarm_site_reset_RMOD1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5038
    ALD 1847 Alarm With Site Reset RMOD-1 ANT5

03_1869_alarm_RF_lock_RMOD1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5039
    ALD 1869 Alarm With Rf Lock RMOD-1 ANT5

04_1869_alarm_site_reset_RMOD1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5040
    ALD 1869 Alarm With Site Reset RMOD-1 ANT5

05_1870_alarm_RF_lock_RMOD1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5041
    ALD 1870 Alarm With Rf Lock RMOD-1 ANT5

06_1870_alarm_site_reset_RMOD1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5042
    ALD 1870 Alarm With Site Reset RMOD-1 ANT5
