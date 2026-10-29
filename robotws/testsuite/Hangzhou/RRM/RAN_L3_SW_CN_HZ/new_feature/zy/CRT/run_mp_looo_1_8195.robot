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
CB008195-A-B5_ET_02
    ${CASE_DIR}/MP_AP_LOOO/CB008195/CB008195-A-B5_ET_02.robot

CB008195-A-B5_ET_04_A-B9_01
    ${CASE_DIR}/MP_AP_LOOO/CB008195/CB008195-A-B5_ET_04_A-B9_01.robot

CB008195-A-B7_07_EC4_06
    ${CASE_DIR}/MP_AP_LOOO/CB008195/CB008195-A-B7_07_EC4_06.robot

CB008195-A-EC4_04_05
    ${CASE_DIR}/MP_AP_LOOO/CB008195/CB008195-A-EC4_04_05.robot
