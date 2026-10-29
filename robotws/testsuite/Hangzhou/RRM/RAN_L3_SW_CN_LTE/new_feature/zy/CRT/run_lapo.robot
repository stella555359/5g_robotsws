*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Suite Setup
Test Template     Run Test Suite
Resource          ./resource.robot

*** Variables ***
${CASE_DIR}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_LTE/new_feature/zy/CRT

*** Test Case ***
CB010397_suite1
    ${CASE_DIR}/CLOUD_R4LAPO_CUS/CB010397/CB010397-A-a.robot

CB010397_suite2
    ${CASE_DIR}/CLOUD_R4LAPO_CUS/CB010397/CB010397-A-c-robustness.robot

CB010397_suite3
    ${CASE_DIR}/CLOUD_R4LAPO_CUS/CB010397/CB010397-A-d.robot

CB010397_suite4
    ${CASE_DIR}/CLOUD_R4LAPO_CUS/CB010397/CB010397-A-e.robot

LTE872
    ${CASE_DIR}/CLOUD_R4LAPO_CUS/LTE872_001/LTE872_001_Instance5.robot

CB010763
    ${CASE_DIR}/CLOUD_R4LAPO_CUS/CB010763/CB010763_SR-A-B1_04_06_07-B-B5_01.robot

# other powersaving features in CRT dir
LTE1203
    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_LTE/trunk_sbts/CRT/LTE1203/LTE1203-B-a-02-d-04.robot

CB008800
    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_LTE/trunk_sbts/CRT/CB008800/CB008800_B3_01-05-07_B4-03.robot
