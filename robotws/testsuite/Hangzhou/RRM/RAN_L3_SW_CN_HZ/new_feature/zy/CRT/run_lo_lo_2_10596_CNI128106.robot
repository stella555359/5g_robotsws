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
CB010596
    ${CASE_DIR}/LO_AP_LO/CB010596/CB010596_CRT-C_B2_01-C_B5_01_02_03.robot

#CNI128106_CNI125505-ET-A002_AP
#    ${CASE_DIR}/LO_AP_LO/CNI128106_CNI125505/CNI128106_CNI125505-ET-A002_AP.robot
