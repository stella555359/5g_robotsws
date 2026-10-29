*** Settings ***
Documentation
...  Test Suite Author: Zuzanna Adles
...  Test Suite Owner: Zuzanna Adles
...  Team: T05

Resource    ../../../test_resources/BS-RF/SiSo_FM_Temperature_Fault_1927_1936_1938.robot

*** Variables ***
${HW_LOCATION_CODE}      Wroclaw
${TESTLINE_NAME}    10_16_UTESRANSISO085
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${COMMISSIONING_PATH}  /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO085_DEFAULT.xml

*** Test Cases ***
[1][2.0] Automated__SiSo_FM_Temperature_Fault_1927_1936_1938
    [Setup]   Run Keywords    Set Test Variable   ${COMMISSIONING_PATH}
    ...    AND    Set Test Variable    ${RMOD_SN}    	K9180124579
    ...    AND    SiSo_FM_Temperature_Fault_1927_1936_1938.TC Setup
    ...    AND    Set Library Search Order    SiSo_FM_Temperature_Fault_1927_1936_1938
    [Timeout]   14400
    TC__SiSo_FM_Temperature_Fault_1927_1936_1938
    [Teardown]   SiSo_FM_Temperature_Fault_1927_1936_1938.TC Teardown
