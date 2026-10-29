*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource      ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource      ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
Resource      ${BASIC_PATH_COMMON}/Manual_SiSo_SM_BTS_Block_Site.robot
Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CB012827-SR-B ASOG/H BB cell sets 6 cells NR FR1 TDD eCPRI 16DL - VRF_RRM
...    This feature introduces baseband cell sets NR FR1 TDD eCPRI up to 6 cells up to 16DL MIMO layers on full ASOG/H.

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Test Cases ***
[1]CB012827-SR-B-18-Manual_SiSo_SM_BTS_Block_Site
    [Tags]    6S-1CC-16D8U_CB012827    CRT_25R2    CRT_TRUNK
    Selenium Login And Disable Screen Lock
    Manual_SiSo_SM_BTS_Block_Site
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}

[1]CB012827-SR-B-13-General_SiSo_RAT_Block_Unblock_with_L3Call
   [Tags]    6S-1CC-mixed-celltype_CB012827    CRT_25R2    CRT_TRUNK
   General_SiSo_RAT_Block_Unblock    with_call=${True}