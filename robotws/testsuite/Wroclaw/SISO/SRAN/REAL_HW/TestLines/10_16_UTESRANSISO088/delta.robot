*** Settings ***
Documentation    Suite description
...    Responsible tester:

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/CM/CM_Delta_Recommissioning_With_KPI_15.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***

#@{additional_common_fault_list}=
#...     faultId=1933, severity=Minor
#
#&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

${CELLS_YAML_PATH}=                 /home/ute/testline_configuration/10_16_UTESRANSISO088/cells.yaml
${UTE_UE_CONFIG}=                   /home/ute/testline_configuration/10_16_UTESRANSISO088/ute_ue_config.yml
#${FORCE_RESET_CONFIGURATION}=    True
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    None
#${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=    True
${CHECK_SWCONFIG}  False

${SKIP_TRUCK_ROLL}=   ${True}
*** Test Cases ***
[2][0.1] TC__CM_Delta_Recommissioning_With_KPI_15
    [Setup]  Run Keywords
    ...  Configuration Precondition   # CN=REF_10_16_UTESRANSISO808
    ...  AND  Set Test Variable  ${DELTA}     delta_2
    TC__CM_Delta_Recommissioning_With_KPI_15
    [Teardown]  Configuration Postcondition

[1][0.1] TC__CM_Delta_Recommissioning_With_KPI_15
    [Setup]  Run Keywords
    ...  Configuration Precondition   # CN=REF_10_16_UTESRANSISO808
    ...  AND  Set Test Variable  ${DELTA}     delta_1
    ...  AND  Set Test Variable  ${DELTA_RESET}     True
    TC__CM_Delta_Recommissioning_With_KPI_15
    [Teardown]  Configuration Postcondition

