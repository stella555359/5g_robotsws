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
CB011080_A001_A002_C003_A006_C002_C006_C004
    ${CASE_DIR}/BOO_AP_LOO/CB011080/CB011080_A001_A002_C003_A006_C002_C006_C004.robot

CNI128106_CNI125505-ET-A006_AP
    ${CASE_DIR}/BOO_AP_LOO/CNI128106_CNI125505/CNI128106_CNI125505-ET-A006_AP.robot
