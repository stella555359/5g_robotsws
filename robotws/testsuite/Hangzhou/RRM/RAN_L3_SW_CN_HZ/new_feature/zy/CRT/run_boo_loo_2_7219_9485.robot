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
CB007219-ET-B001_B004
    ${CASE_DIR}/BOO_AP_LOO/CB007219/CB007219-ET-B001_B004.robot

CB009485_SR_A_TC10_B3_04_AP_NG
    ${CASE_DIR}/BOO_AP_LOO/CB009485/CB009485_SR_A_TC10_B3_04_AP_NG.robot
