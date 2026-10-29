*** Settings ***
Documentation  Test Suite for CB006877 test cases. More information are stored in test_6877.robot file.
...            Topology: CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2B3_3xAEQN_FRGU -> T177

Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB006877/resources/tests_6877.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/attenuators.robot
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/utils.py

Suite Setup  run keywords
...    Prepare Test Line for CB006877  AND
...    Setup attenuators               AND
...    Turn off attenuation

Test Setup  run keywords
...  Get UEs  ${ues}  RFCX51BXKLV  AND
...  Start syslog capture

Test Teardown  run keywords
...      Stop syslog capture                 AND
...      Add Scout Data Info To Testcase     AND
...      Collect snapshot if test failed

Suite Teardown  Back to default TL state


*** Test Cases ***
[1]CB006877_A#1_TC_02_Long_PUCCH_for_FDD_Cells_and_CB006877_1_UE_35MHz_CPRI_counter
    utils.run_keyword_and_allow_retest  [1]CB006877_A#1_TC_02_Long_PUCCH_for_FDD_Cells_and_CB006877_1_UE_35MHz_CPRI_counter  6

[1]CB006877_A#7_TC_16_SA_PRBblanking_LowEdgeUL_35MHz
    utils.run_keyword_and_allow_retest  [1]CB006877_A#7_TC_16_SA_PRBblanking_LowEdgeUL_35MHz

[1]CB006877_A#9_TC_21_SA_FDD_35MHz_CB006137_UL_2CC_CA_F+T
    utils.run_keyword_and_allow_retest  [1]CB006877_A#9_TC_21_SA_FDD_35MHz_CB006137_UL_2CC_CA_F+T
