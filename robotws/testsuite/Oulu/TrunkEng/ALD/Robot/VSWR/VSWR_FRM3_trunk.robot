*** Settings ***
Force Tags    RF50

Documentation
...   contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...     Tests VSWR with FRM3 radio

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/VSWR/vswr_alarm_telnet_tests_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/VSWR/vswr_alarm_telnet_tests_RMOD1_ANT2.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/VSWR/vswr_alarm_telnet_tests_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/VSWR/vswr_alarm_telnet_tests_RMOD1_ANT4.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/VSWR/vswr_alarm_telnet_tests_RMOD1_ANT5.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/VSWR/vswr_alarm_telnet_tests_RMOD1_ANT6.robot

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
01_1837_VSWR_Alarm_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10447
    1837 VSWR Alarm RMOD1 ANT1

02_1838_VSWR_Alarm_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10449
    1838 VSWR Alarm RMOD1 ANT1

03_1838_and_1837_VSWR_Alarms_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10450
    1838 and 1837 VSWR Alarms RMOD1 ANT1

04_1837_VSWR_Alarm_RMOD1_ANT2
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10451
    1837 VSWR Alarm RMOD1 ANT2

05_1838_VSWR_Alarm_RMOD1_ANT2
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10452
    1838 VSWR Alarm RMOD1 ANT2

06_1838_and_1837_VSWR_Alarms_RMOD1_ANT2
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10453
    1838 and 1837 VSWR Alarms RMOD1 ANT2

07_1837_VSWR_Alarm_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10454
    1837 VSWR Alarm RMOD1 ANT3

08_1838_VSWR_Alarm_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10455
    1838 VSWR Alarm RMOD1 ANT3

09_1838_and_1837_VSWR_Alarms_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10456
    1838 and 1837 VSWR Alarms RMOD1 ANT3

10_1837_VSWR_Alarm_RMOD1_ANT4
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10457
    1837 VSWR Alarm RMOD1 ANT4

11_1838_VSWR_Alarm_RMOD1_ANT4
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10458
    1838 VSWR Alarm RMOD1 ANT4

12_1838_and_1837_VSWR_Alarms_RMOD1_ANT4
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10459
    1838 and 1837 VSWR Alarms RMOD1 ANT4

13_1837_VSWR_Alarm_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10460
    1837 VSWR Alarm RMOD1 ANT5

14_1838_VSWR_Alarm_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10461
    1838 VSWR Alarm RMOD1 ANT5

15_1838_and_1837_VSWR_Alarms_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10462
    1838 and 1837 VSWR Alarms RMOD1 ANT5

16_1837_VSWR_Alarm_RMOD1_ANT6
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10463
    1837 VSWR Alarm RMOD1 ANT6

17_1838_VSWR_Alarm_RMOD1_ANT6
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10464
    1838 VSWR Alarm RMOD1 ANT6

18_1838_and_1837_VSWR_Alarms_RMOD1_ANT6
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_10465
    1838 and 1837 VSWR Alarms RMOD1 ANT6
