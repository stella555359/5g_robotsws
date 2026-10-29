*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Suite Setup
Test Template     Run Test Suite
Resource          ./resource.robot

*** Variables ***
${CASE_DIR}    testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/trunk_sbts/CRT_AIC/CN3/

*** Test Case ***
CB009021_suite1
    ${CASE_DIR}/Regression_dRNIC_4vDU_P_AP_LOO_MassiveVlan/CB009021/CB009021-ET-BB-B1_03_06-C_16-Aic.robot

CB009021_suite2
    ${CASE_DIR}/Regression_dRNIC_4vDU_P_AP_LOO_MassiveVlan/CB009021/CB009021-ET-B3_03_04-TA.robot
