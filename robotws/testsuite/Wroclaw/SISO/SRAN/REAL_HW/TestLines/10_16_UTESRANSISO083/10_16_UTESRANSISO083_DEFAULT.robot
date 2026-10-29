*** Settings ***
Documentation  Maintainers: roksana.spychala-malolepsza@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
Resource    ../../robotlte_legacy/hran_ta/SiSo_PM_BTS_Fronthaul_SFP_Static_Parameters_Monitoring.robot
Resource    ../../robotlte_legacy/hran_ta/SiSo_PM_BTS_Backhaul_SFP_Static_Parameters_Monitoring.robot
#Resource    ../../robotlte_legacy/SiSo_L3_Call.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_NR_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_LTE_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset_With_Graceful_Shutdown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Baseband_Module_Reset_With_Graceful_Shutdown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=             Failed    # possible settings: Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=             True      # to disable hardware reconfiguration set value False
${CELLS_YAML_PATH}=                            /home/ute/testline_configuration/10_16_UTESRANSISO083/cells.yaml
${SKIP_TRUCK_ROLL}=   ${True}
@{tc_additional_1382_fault_list}=
...  faultId=7107
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=
...  1382=@{EMPTY}

*** Test Cases ***
[AUTO][1.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset_With_Graceful_Shutdown
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO083_DEFAULT  N=20
  ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  2400
  Execute Test In Loop  Automated SiSo BTS Startup Multiple Site Reset With Graceful Shutdown
  [Teardown]  Configuration Postcondition

[AUTO][1.0] Automated_SiSo_CALL_LTE_Data_Transfer
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO083_DEFAULT
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   353868
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[AUTO][1.0] Automated_SiSo_CALL_NR_Data_Transfer
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO083_DEFAULT
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   22643402
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[AUTO][2.0] Automated_SiSo_SM_NR_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO083_DEFAULT  N=1
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     180
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     800
    ...  AND  Set Test Variable  ${NR_RAT_RESET_TIMEOUT}     240
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
     Execute Test In Loop  TC__STATE__NR_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition

[AUTO][2.0] Automated_SiSo_SM_LTE_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO083_DEFAULT  N=1
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     180
    ...  AND  Set Test Variable  ${LTE_RAT_RESET_TIMEOUT}     240
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1382=@{tc_additional_1382_fault_list}
    Execute Test In Loop  TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]  Run Keywords
    ...  Configuration Postcondition
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1382=@{EMPTY}

[True][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO083_DEFAULT  N=5
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        AH243007606      AH243007605      AH243007603
    ...  BL2221N4056     BL2222N4078    BL2216N4016    # custom radio list for testing
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[False][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO083_DEFAULT  N=5
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        	L1251300675    L1251300676      L1251300674
    ...  L1250710361      L1250710360      L1250710362    # custom radio list for testing
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${FALSE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[AUTO][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO083_DEFAULT    N=5
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition

[AUTO][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO083_DEFAULT
  ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  900
  Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
  [Teardown]  Configuration Postcondition
