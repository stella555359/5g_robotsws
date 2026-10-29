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
CB012149-SR-AA_16
    ${CASE_DIR}/LPQ_AP_LOO/CB012149/CB012149-SR-AA_16.robot

CB012149-SR-AC_10_12-AA_08_12_19-AZ_01_02
    ${CASE_DIR}/LPQ_AP_LOO/CB012149/CB012149-SR-AC_10_12-AA_08_12_19-AZ_01_02.robot

CB012149_EDA_05437018.robot
    ${CASE_DIR}/LPQ_AP_LOO/CB012149_AP/CB012149_EDA_05437018.robot


