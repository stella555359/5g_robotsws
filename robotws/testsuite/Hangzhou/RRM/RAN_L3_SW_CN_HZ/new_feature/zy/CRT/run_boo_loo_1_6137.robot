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
CB006137_BA_ET_01_02_04_07_09_10_12_21
    ${CASE_DIR}/BOO_AP_LOO/CB006137/CB006137-BA/CB006137_BA_ET_01_02_04_07_09_10_12_21.robot

CB006137-SR-C-B8_ET_01_02_06_07_10
    ${CASE_DIR}/BOO_AP_LOO/CB006137/CB006137-C-B8/CB006137-SR-C-B8_ET_01_02_06_07_10.robot

CB006137_AA_ET_02_03_04
    ${CASE_DIR}/BOO_AP_LOO/CB006137/CB006137_AA/CB006137_AA_ET_02_03_04.robot

CB009059-AD
    ${CASE_DIR}/BOO_AP_LOO/CB009059/CB009059-AD.robot



