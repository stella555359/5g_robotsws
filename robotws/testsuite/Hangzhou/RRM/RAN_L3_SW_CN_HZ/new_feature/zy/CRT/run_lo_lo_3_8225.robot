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
CB008225
    ${CASE_DIR}/LO_AP_LO/CB008225-I/CB008225_ET_I010_I006_I007_I002_I003_I005_I008_I001.robot

