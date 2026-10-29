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
CB008195-A-B1_02_EC4_25
    ${CASE_DIR}/LO_AP_LO/CB008195/CB008195-A-B1_02_EC4_25.robot

CB008195-A-B5_ET_01_08
    ${CASE_DIR}/LO_AP_LO/CB008195/CB008195-A-B5_ET_01_08.robot

CB008195-A-EC4_ET_03_30
    ${CASE_DIR}/LO_AP_LO/CB008195/CB008195-A-EC4_ET_03_30.robot

CB008195-SR-B31
   ${CASE_DIR}/LO_AP_LO/CB008195/CB008195-SR-B31.robot

