*** Settings ***
Documentation    Suite description
...    Responsible tester:  mateusz.chryplewicz@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
Resource    ../../robotlte_legacy/variables.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/LOGS/LOGS_BlackBox_Temperature_and_FanSpeed_Verification.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_NR_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_LTE_Rat_Reset.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${CELLS_YAML_PATH}=                            /home/ute/testline_configuration/10_16_UTESRANSISO136/cells.yaml
${SKIP_TRUCK_ROLL}=   ${True}       # to disable Truck And Roll feature set this flag to False
@{additional_common_fault_list}=
...             faultId=6278, severity=Warning

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

*** Test Cases ***
[1][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO136_DEFAULT
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  900
    Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
    [Teardown]  Configuration Postcondition


[1][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO136_DEFAULT   N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     800
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition


[1][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO136_DEFAULT  N=5
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        YK220600001      AH250400463      YK220600003
    ...  K9245128883     K9245128908      K9245128887    # custom radio list for testing
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition


[CRT][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO136_DEFAULT  N=5
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        L1251205187    L1251205185      L1251205184
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${FALSE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition


[1][2.0] Automated_SiSo_SM_NR_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO136_DEFAULT    N=5
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     180
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     1200
    ...  AND  Set Test Variable  ${NR_RAT_RESET_TIMEOUT}     540
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     ${TRUE}    #because of AHLOA
     Execute Test In Loop  TC__STATE__NR_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition


[AUTO][1.0] Automated_SiSo_CALL_LTE_Data_Transfer
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO136_DEFAULT
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   336691
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition


[1][1.0] General_SiSo_Auto_BBO_Temperature_and_FanSpeed_Verification
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO136_DEFAULT
    ...  AND  Set Test Variable  ${RMOD_SERIAL_NUMBER}  K9245128908
    Execute Test In Loop    TC__SiSo_LOGS_RU_Black_Box_Temperature_and_FanSpeed_Verification
    [Teardown]  Configuration Postcondition
