*** Settings ***
Documentation
...  Test Suite Author: Kamil Adamowski
...  Test Suite Owner: Kamil Adamowski
...  Team: T07

Resource          ../../../test_resources/BS-RF/SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band.robot


*** Variables ***
${HW_LOCATION_CODE}         Wroclaw
${COMMISSIONING_PATH}       /home/ute/testline_init_results/execution/configs/topology_configs/node_1/CB008392-SR-A.xml
${COLLECT_SNAPSHOT_FLAG}    Never
${TESTLINE_NAME}            10_16_UTESRANSISO051

${ENABLE_TRUCK_ROLL_FLAG}    ${False}
${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}

*** Test Cases ***

[CB007769][1.0] Automated_SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
    [Setup]    Run Keywords
    ...    Set Test Variable    ${CELLS}   37901
    ...    AND    Set Test Variable    ${SISO_L3_CALL}    True
    ...    AND    Set Test Variable    ${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO051/ta_ue_config.yaml
    ...    AND    SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band.TC Setup
    ...    AND    Set Library Search Order    SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
    [Timeout]    14400
    TC__SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
    [Teardown]     SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band.TC Teardown
