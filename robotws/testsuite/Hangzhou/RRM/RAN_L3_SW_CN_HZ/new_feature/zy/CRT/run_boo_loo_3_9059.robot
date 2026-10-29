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
CB009059-AD
    ${CASE_DIR}/BOO_AP_LOO/CB009059/CB009059-AD.robot

CB009059-ET-BA13
    ${CASE_DIR}/BOO_AP_LOO/CB009059/CB009059-ET-BA13.robot

CB009059-SR-AD-B4_ET_09
    ${CASE_DIR}/BOO_AP_LOO/CB009059/CB009059-SR-AD-B4_ET_09.robot
