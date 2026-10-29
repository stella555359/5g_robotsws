*** Settings ***
Documentation
...  Test Suite Author: Dawid Bak
...  Test Suite Owner:  Dawid Bak

Force Tags  CLOUD_RF_AIR_B4-6_CRT_16_CHM_06

Resource          ../../../test_resources/BS-RF/SiSo_FM_SFP_TX_Fault_2928_4699_4700.robot

*** Variables ***

${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/
...  SBTS_1430_UTESRANSISO905/commissioning/devtest_SBTS00.xml
${TESTLINE_NAME}  10_16_UTESRANSISO905

*** Test Cases ***

[dev_test][1.0] Automated__SiSo_FM_SFP_TX_Fault_2928_4699_4700
    [Setup]  Run Keywords  Set Test Variable  ${COMMISSIONING_PATH}
    ...  AND  Set Test Variable  ${RMOD_SN}  BL1909V001M
    ...  AND  SiSo_FM_SFP_TX_Fault_2928_4699_4700.TC Setup
    ...  AND  Set Library Search Order  SiSo_FM_SFP_TX_Fault_2928_4699_4700
    [Timeout]  14400
    TC__SiSo_FM_SFP_TX_Fault_2928_4699_4700
    [Teardown]  SiSo_FM_SFP_TX_Fault_2928_4699_4700.TC Teardown