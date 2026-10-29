*** Settings ***
Documentation    Suite description
...    Responsible tester:  krzysztof.brykman@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/Bbox/Automated_SiSo_RU_BlackBox_enhancements_testing.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/variables.robot
Resource    ../../TestCases/STARTUP/SiSo_STARTUP_Baseband_Module_Reset_With_Graceful_Shutdown.robot
Resource    ../../TestCases/STARTUP/SiSo_STARTUP_Site_Reset_With_Graceful_Shutdown.robot
Resource    ../../robotlte_legacy/Test_Cases/Automated_SiSo_Encrypting_and_storing_configured_and_detected_location_data_into_black_box.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/LOGS/SiSo_LOGS_RU_Black_Box_enhancement_for_POST_data.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${TESTLINE_NAME}     10_16_UTESRANSISO134
${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}    /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO134_DEFAULT.xml

${SKIP_TRUCK_ROLL}=   ${True}       # to disable Truck And Roll feature set this flag to False

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    Failed    # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=    False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

${CELLS_YAML_PATH}=                 /home/ute/testline_configuration/10_16_UTESRANSISO134/cells.yaml
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
[TMO][3.0] Automated_SiSo_Reset_of_BB card_WebEM
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT    N=5
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    ...  AND  Set Test Variable  @{BB_LIST}     L1231800036  L1244806844  L1244806850  L1244806878
    Execute Test In Loop  BB Reset On Every Node
    [Teardown]  Configuration Postcondition

[AVHA][1.0] Automated__SiSo__FV_Testing_RF_Factory_SW_update
      [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L1251101913
    ...  AND  Set Test Variable  ${FACTORYSW}  factory
    Execute Test In Loop  Incompatible Software Detection and Update
    [Teardown]  Configuration Postcondition

[AVHA_303][1.0] Automated_SiSo_CALL_NR_Data_Transfer
        [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT
    ...    AND    Set Test Variable  @{SELECTED_CELLS}  5374255
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[TMO][2.0] Automated_SiSo_SM_Cell_Block_Unblock
    [Setup]  Run Keyword    Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT
    Execute Test In Loop  Execute Cell Block Unblock On Every Node
    [Teardown]  Configuration Postcondition

[TMO][2.0] Automated_SiSo_Delta recommissioning
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}    600
    ...  AND  Set Test Variable  ${DELTA}     delta
    ...  AND  Set Test Variable  ${DELTA_RESET}    False
    Execute Test In Loop  Delta Recommissioning
    [Teardown]  Configuration Postcondition

[AVHA_313][1.0] Automated_SiSo_CALL_NR_Data_Transfer
        [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT
    ...    AND    Set Test Variable  @{SELECTED_CELLS}  5374265
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[TMO_AVHA][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT     N=5
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     60
    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     300
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L1251101948  L1251101913  L1251101947
    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     300
    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
    [Teardown]    Configuration Postcondition

[TMO][1.0] Automated_SiSo_Reset_of_BB card_WebEM_With_Graceful_Shutdown
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT    N=10
    ...  AND  Set Test Variable  ${BBMOD_STARTUP_TIMEOUT}     600
    Execute Test In Loop  Automated SiSo BTS Startup Multiple Baseband Module Reset With Graceful Shutdown
    [Teardown]  Configuration Postcondition

[TMO][1.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset_With_Graceful_Shutdown
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT    N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  1200
    Execute Test In Loop  Automated SiSo BTS Startup Multiple Site Reset With Graceful Shutdown
    [Teardown]  Configuration Postcondition

[TMO][1.0] Automated_SiSo_Encrypting_and_storing_configured_and_detected_location_data_into_black_box
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT
#    ...  AND  Set Test Variable  @{CUSTOM_FHS_UNIT_LIST}     ${EMPTY}
#    ...  AND  Set Test Variable  @{CUSTOM_FHS_UNIT_LIST}    FHS=
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}    	K9245001208
    Execute Test In Loop  Check Location Information In Black Box File
    [Teardown]  Configuration Postcondition

[TMO][1.0] Automated_SiSo_LOGS_RU_Black_Box_enhancement_for_POST_data
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO134_DEFAULT
    ...  AND  Set Test Variable  ${RMOD_SERIAL_NUMBER}  K9245001205
    TC__SiSo_LOGS_RU_Black_Box_enhancement_for_POST_data
    [Teardown]  Configuration Postcondition

[TMO][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO134_DEFAULT
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  600
    Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
    [Teardown]  Configuration Postcondition
