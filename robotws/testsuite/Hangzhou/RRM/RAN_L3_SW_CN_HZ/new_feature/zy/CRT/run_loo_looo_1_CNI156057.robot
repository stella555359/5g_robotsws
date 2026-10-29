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
CNI-156057-A-B1_AP
    ${CASE_DIR}/LOO_AP_LOOO/CNI-156057/CNI-156057-A-B1_AP.robot

CNI-156057-A-B2_AP
    ${CASE_DIR}/LOO_AP_LOOO/CNI-156057/CNI-156057-A-B2_AP.robot

CNI-156057-A-B3_AP
    ${CASE_DIR}/LOO_AP_LOOO/CNI-156057/CNI-156057-A-B3_AP.robot


