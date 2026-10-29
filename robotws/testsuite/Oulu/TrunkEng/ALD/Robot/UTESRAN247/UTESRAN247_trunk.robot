*** Settings ***
Force Tags    RF50

Documentation
...   contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...     2_11_UTESRAN247

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_1836_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_10_alarm_RF_lock_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_1836_alarm_RF_reset_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_10_alarm_RF_reset_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_1836_alarm_BTS_block_RMOD1_ANT5.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_10_alarm_BTS_block_RMOD1_ANT5.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_1836_alarm_RF_lock_RMOD2_ANT4.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_1836_alarm_RF_reset_RMOD2_ANT4.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_1835_alarm_RF_lock_RMOD2_ANT4.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_1835_alarm_RF_reset_RMOD2_ANT4.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_1834_alarm_RF_reset_RMOD2_ANT4.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/UTESRAN247/ald_1834_alarm_BTS_block_RMOD2_ANT4.robot

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

01_1836_RFlock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5147
    ALD 1836 Alarm With Rf Lock RMOD1 ANT1

02_10_RFlock_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5148
    ALD 10 Alarm With Rf Lock RMOD1 ANT1

03_1836_RFreset_RMOD1_ ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5149
    ALD 1836 Alarm With Rf Reset RMOD1 ANT3

04_10_RFreset_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5150
    ALD 10 Alarm With Rf Reset RMOD1 ANT3

05_1836_BTSblock_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5151
    ALD 1836 Alarm With BTS Block RMOD1 ANT5

06_10_BTSblock_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5152
    ALD 10 Alarm With BTS Block RMOD1 ANT5

07_1836_RFlock_RMOD2_ANT4
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5153
    ALD 1836 Alarm With Rf Lock RMOD2 ANT4

08_1836_RFreset_RMOD2_ANT4
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5154
    ALD 1836 Alarm With Rf Reset RMOD2 ANT4

09_1835_RFlock_RMOD2_ANT4
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5155
    ALD 1835 Alarm With Rf Lock RMOD2 ANT4

10_1835_RFreset_RMOD2_ANT4
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5156
    ALD 1835 Alarm With Rf Reset RMOD2 ANT4

11_1834_RFreset_RMOD2_ANT4
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5157
    ALD 1834 Alarm With Rf Reset RMOD2 ANT4

12_1834_BTSblock_RMOD2_ANT4
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_5158
    ALD 1834 Alarm With BTS Block RMOD2 ANT4
