*** Settings ***
Force Tags    RF50

Documentation
...   contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...     Tests VSWR with VEG2 radio

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/VSWR/vswr_alarm_telnet_tests_RMOD1_ANT1.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/VSWR/vswr_alarm_telnet_tests_RMOD1_ANT3.robot
Resource    testsuite/Oulu/TrunkEng/ALD/Robot/VSWR/vswr_alarm_telnet_tests_RMOD1_ANT5.robot

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
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_4889
    1837 VSWR Alarm RMOD1 ANT1

02_1838_VSWR_Alarm_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_4890
    1838 VSWR Alarm RMOD1 ANT1

03_1838_and_1837_VSWR_Alarms_RMOD1_ANT1
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_4891
    1838 and 1837 VSWR Alarms RMOD1 ANT1

04_1837_VSWR_Alarm_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_4892
    1837 VSWR Alarm RMOD1 ANT3

05_1838_VSWR_Alarm_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_4893
    1838 VSWR Alarm RMOD1 ANT3

06_1838_and_1837_VSWR_Alarms_RMOD1_ANT3
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_4894
    1838 and 1837 VSWR Alarms RMOD1 ANT3

07_1837_VSWR_Alarm_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_4888
    1837 VSWR Alarm RMOD1 ANT5

08_1838_VSWR_Alarm_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_4887
    1838 VSWR Alarm RMOD1 ANT5

09_1838_and_1837_VSWR_Alarms_RMOD1_ANT5
    [Tags]  QCD_MN_RAN  QCP_RAN_VAL  QC_4886
    1838 and 1837 VSWR Alarms RMOD1 ANT5
