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
CB009485_SR_A_TC18
    ${CASE_DIR}/LO_LO_AP_LOO/CB009485/CB009485_SR_A_TC18_B4_06_AP.robot

CB009485_SR_A_TC08_B3_02_AP_XN
    ${CASE_DIR}/LO_LO_AP_LOO/CB009485/CB009485_SR_A_TC08_B3_02_AP_XN.robot

CB009485_SR_A_TC25_B4_13_AP_NG
    ${CASE_DIR}/LO_LO_AP_LOO/CB009485/CB009485_SR_A_TC25_B4_13_AP_NG.robot
