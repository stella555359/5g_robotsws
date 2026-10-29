*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

...  Test Suite Author: Anna Plecha
...  Test Suite Owner: Anna Plecha
...  Team: T08


Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_FM_NR_PIMC_Faults_Triggering.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
Resource    ../../robotlte_legacy/hran_ta/SiSo_PM_Embedded_Power_Meter_Counters.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot
Variables   testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO112/ru_dict.py
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/PM/PM_KPI_Counters_benchmarking.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CONFIGURATION_STARTUP_TIMEOUT}=    600

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    Failed    # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

${SKIP_TRUCK_ROLL}=   ${True}

@{additional_common_fault_list}=
...  faultId=8000, severity=Minor

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

${CELLS_YAML_PATH}=                 /home/ute/testline_configuration/10_16_UTESRANSISO112/cells.yaml
${UTE_UE_CONFIG}=                   /home/ute/testline_configuration/10_16_UTESRANSISO112/ute_ue_config.yml
${START_POINT_GENERATION}=    True
${SCOUT_TL_NAME}=    10_16_UTESRANSISO112
${SCOUT_TEMPLATE_ID}=    1405

*** Test Cases ***

[RJIO][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO112_DEFAULT
  ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  600
  Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
  [Teardown]  Configuration Postcondition

[RJIO][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO112_DEFAULT     N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition

[RJIO][2.0] Automated_SiSo_SM_Cell_Block_Unblock
    [Setup]  Run Keyword
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO112_DEFAULT     N=5
    Execute Test In Loop  Execute Cell Block Unblock On Every Node
    [Teardown]  Configuration Postcondition

[AHPB][1.0] Automated_SiSo_CALL_NR_Data_Transfer
        [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO112_DEFAULT
    ...    AND    Set Test Variable  @{SELECTED_CELLS}  23592964
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[RJIO_gasp][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO112_DEFAULT     N=5
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        K9194404904     K9245128936
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[RJIO_nogasp][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO112_DEFAULT     N=10
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}      1M211806933      L1251403408      L1251403409      L1251403410
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${FALSE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[AHPB][3.0] Automated_SiSo_FM_NR_PIMC_Faults_Triggering
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO112_PIMC
    ...  AND  Set Test Variable  ${RMOD_SN}  K9194404904
    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
    ...  AND  TC__SiSo_FM_NR_PIMC_Faults_Triggering
    Execute Test In Loop  TC__SiSo_FM_NR_PIMC_Faults_Triggering
    [Teardown]  Configuration Postcondition

[EDA04330985][1.0] General_SiSo_Auto_KPI_PM_Counters_benchmarking
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO112_DEFAULT
    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO112/cells.yaml
    ...  AND  Set Test Variable  @{SELECTED_CELLS}  23592964
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  TC__PM_KPI_Counters_benchmarking
    [Teardown]  Configuration Postcondition