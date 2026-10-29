*** Settings ***
Documentation
...  Test Suite Author: Szymon Przybylak
...  Test Suite Owner:  Szymon Przybylak

Force Tags  CLOUD_10_16_UTESRANSISO904

Resource          ../../../test_resources/BS-RF/SiSo_FM_SFP_RX_Fault_2929_2931_4701.robot

*** Variables ***

${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/
...  SBTS_1509_UTESRANSISO904/commissioning/devtest_SBTS00.xml
${TESTLINE_NAME}  10_16_UTESRANSISO904

*** Test Cases ***

[dev_test][1.0] Automated__SiSo_FM_SFP_RX_Fault_2929_2931_4701
    [Setup]  Run Keywords  Set Test Variable  ${COMMISSIONING_PATH}
    ...  AND  Set Test Variable  ${RMOD_SN}  K9190542832
    ...  AND  SiSo_FM_SFP_RX_Fault_2929_2931_4701.TC Setup
    ...  AND  Set Library Search Order  SiSo_FM_SFP_RX_Fault_2929_2931_4701
    [Timeout]  14400
    TC__SiSo_FM_SFP_RX_Fault_2929_2931_4701
    [Teardown]  SiSo_FM_SFP_RX_Fault_2929_2931_4701.TC Teardown
