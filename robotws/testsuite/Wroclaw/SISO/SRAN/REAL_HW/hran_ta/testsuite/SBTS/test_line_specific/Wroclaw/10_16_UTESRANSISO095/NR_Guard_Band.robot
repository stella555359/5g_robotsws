*** Settings ***
Documentation
...  Test Suite Author: Marta Bak
...  Test Suite Owner: marta.bak@nokia.com
...  Team: T03


Resource          ../../../test_resources/BS-RF/SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band.robot



*** Variables ***
${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO095/ue_config.yaml
${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}    SEPARATOR=    /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO095_DEFAULT.xml
${COLLECT_SNAPSHOT_FLAG}    Always
${TESTLINE_NAME}  10_16_UTESRANSISO095

${POST_ALARMS_IGNORED_PATTERN}  1300
${ADDITIONAL_IGNORED_ALARMS}  1300

*** Test Cases ***

[RM_5.1][1.0] Automated_SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}
    ...    AND    Set Test Variable    ${CELLS}    4
    ...    AND    SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band.TC Setup
    ...    AND    Set Library Search Order    SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
    [Timeout]    14400
    TC__SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
    [Teardown]  SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band.TC Teardown

