*** Settings ***
Force Tags    RF50

Documentation
...   I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...     UTESRAN181 with ALD.

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN181/ald_10_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN181/ald_10_alarm_RF_lock_RMOD2_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN181/ald_10_alarm_RF_lock_RMOD2_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN181/ald_1869_alarm_RF_lock_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN181/ald_1870_alarm_RF_lock_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN181/ald_1870_alarm_site_reset_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN181/ald_1837_alarm_RMOD2_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN181/ald_1838_alarm_RMOD2_ANT1.robot

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
1_1869_RF_lock_RMOD1_ANT3_LNA2
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_850925
    ALD 1869 Alarm With Rf Lock RMOD1 ANT3

2_1870_RF_lock_RMOD1_ANT3_LNA1
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_850926
    ALD 1870 Alarm With Rf Lock RMOD1 ANT3

3_1870_Site_reset_RMOD1_ANT3_LNA1
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_850927
    ALD 1870 Alarm With Site Reset RMOD1 ANT3

4_1837_VSWR_threshold_RMOD2_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_850928
    ALD 1837 Alarm RMOD2 ANT1

5_1838_VSWR_threshold_RMOD2_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_850929
    ALD 1838 Alarm RMOD2 ANT1

6_10_RF_lock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_850930
    ALD 10 Alarm With Rf Lock RMOD1 ANT1

7_10_RF_lock_RMOD2_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_850931
    ALD 10 Alarm With Rf Lock RMOD2 ANT1

8_10_RF_lock_RMOD2_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_850932
    ALD 10 Alarm With Rf Lock RMOD2 ANT3
