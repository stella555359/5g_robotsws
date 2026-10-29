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
fault8000_robustness_testing_AP
    ${CASE_DIR}/LO_AP_LO/CB009485/fault8000_robustness_testing_AP.robot

trace_robustness_testing_AP
     ${CASE_DIR}/LO_AP_LO/CB009485/trace_robustness_testing_AP.robot

CB009485_SR_A_TC17
    ${CASE_DIR}/LO_AP_LO/CB009485/CB009485_SR_A_TC17_B4_05_AP.robot

CB009485_SR_B_TC05
    ${CASE_DIR}/LO_AP_LO/CB009485/CB009485_SR_B_TC05_B1_05_AP.robot

CB009485_SR_B_TC12
    ${CASE_DIR}/LO_AP_LO/CB009485/CB009485_SR_B_TC12_B3_03_AP.robot

CB009485_SR_A_TC28_B3_07_AP_XN
    ${CASE_DIR}/LO_AP_LO/CB009485/CB009485_SR_A_TC28_B3_07_AP_XN.robot

CB009485_SR_B_TC19_B5_03
    ${CASE_DIR}/LO_AP_LO/CB009485/CB009485_SR_B_TC19_B5_03.robot
