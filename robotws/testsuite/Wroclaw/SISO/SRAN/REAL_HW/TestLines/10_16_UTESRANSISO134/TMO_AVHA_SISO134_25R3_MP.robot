*** Settings ***
Documentation    Suite description
...    Responsible tester:  krzysztof.brykman@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/variables.robot
Resource    ../../TestCases/STARTUP/SiSo_STARTUP_Baseband_Module_Reset_With_Graceful_Shutdown.robot
Resource    ../../TestCases/STARTUP/SiSo_STARTUP_Site_Reset_With_Graceful_Shutdown.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${TESTLINE_NAME}     10_16_UTESRANSISO134
${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}    /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO134_DEFAULT.xml

${SKIP_TRUCK_ROLL}=   ${True}       # to disable Truck And Roll feature set this flag to False

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    Failed    # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=    False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

${SKIP_SW_VERSION_CHECK_STEP}       True

@{additional_common_fault_list}=
...                             faultId=4589, severity=Warning
...                             faultId=7525, severity=Minor
...                             faultId=7532, severity=Minor
...                             faultId=7535, severity=Minor

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=      common=@{additional_common_fault_list}
${CHECK_SWCONFIG}=    True
${BBMOD_STARTUP_TIMEOUT}

*** Test Cases ***
[TMO][1.0] Automated_SiSo_Reset_of_BB card_WebEM_With_Graceful_Shutdown
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT    N=10
    ...  AND  Set Test Variable  ${BBMOD_STARTUP_TIMEOUT}     600
    Execute Test In Loop  Automated SiSo BTS Startup Multiple Baseband Module Reset With Graceful Shutdown
    [Teardown]  Configuration Postcondition

[TMO][1.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset_With_Graceful_Shutdown
    [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT    N=10
    Execute Test In Loop  Automated SiSo BTS Startup Multiple Site Reset With Graceful Shutdown
    [Teardown]  Configuration Postcondition

[TMO][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO134_DEFAULT
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  600
    Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
    [Teardown]  Configuration Postcondition
