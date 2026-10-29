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
CB009021
    ${CASE_DIR}/Regression_dRNIC_2vDU_P_AP_LOO_DC_SANSA_FS_ECPRI_CMWV_TDD/CB009021/CB009021-BB-B6_ET_06.robot

