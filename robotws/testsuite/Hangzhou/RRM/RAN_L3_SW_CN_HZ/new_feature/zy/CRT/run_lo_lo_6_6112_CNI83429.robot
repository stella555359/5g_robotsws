*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Suite Setup
Test Template     Run Test Suite
Resource          ./resource.robot

*** Variables ***
${CASE_DIR}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/new_feature/zy/CRT

*** Test Case ***
CB006112-ET-C-01
    ${CASE_DIR}/LO_AP_LO/CB006112/CB006112-ET-C-01.robot

CNI83429-SR-A_ET_08_01
     ${CASE_DIR}/LO_AP_LO/CNI83429/CNI83429-SR-A_ET_08_01.robot
