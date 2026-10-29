*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  description:   8152 Test Cases - Specific UE must be used for tests due to limited 35MHz chwb capability
...  topology:      CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2_2xAEQN_FRGY -> SA5

Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008152/resources/keywords.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008152/resources/tests_8152.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/attenuators.robot


Suite Setup    Run Keywords
...  Prepare TL for CB008152  AND
...  Setup attenuators  AND
...  Turn off attenuation

Test Setup  run keywords
...  Get UEs  ${ues}  REAL_ANDROID_MTK  AND
...  Start syslog capture

Test Teardown  run keywords
...      Stop syslog capture                 AND
...      Add Scout Data Info To Testcase     AND
...      Collect snapshot if test failed


*** Variables ***
@{ues}  ue1

*** Test Cases ***
CB008152-B.B1_05_SA_2UEs_FDD_35MHz_PeakTput_UL_DL
    [Tags]  b105
    [1]CB008152-B.B1_05_SA_2UEs_FDD_35MHz_PeakTput_UL_DL


CB008152-B.B1.B4_14_SA_FDD_35MHz_64QAM_L3call_UL_DL_tput
    [Tags]  b104
    [1]CB008152-B.B1.B4_14_SA_FDD_35MHz_64QAM_L3call_UL_DL_tput
