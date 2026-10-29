*** Settings ***
Documentation         Suite description
...    Author:        Marta Bak
...    Maintainer:    marta.bak@nokia.com


Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource    ../../TestCases/PM/SiSo_PM_SMOD_Internal_Temperature_Counters.robot
Resource    ../../TestCases/PM/SiSo_PM_Cabinet_Fan_Speed_Counters.robot
Resource    ../../TestCases/PM/SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring.robot
Resource    ../../TestCases/FM/FM_SMOD_High_Low_Temp_Offset.robot
Resource    ../../TestCases/PM/PM_SMOD_Min_Max_Avg_Temp_Counters_Activation.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/PM/PM_LTE_uDTX.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${CELLS_YAML_PATH}=                  /home/ute/testline_configuration/10_16_UTESRANSISO095/ue_config.yaml

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=
#...  faultId=1300, severity=Minor

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}   common=@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}
${SKIP_TRUCK_ROLL}=   ${True}

*** Test Cases ***
#[FRCJ][1.0] Automated_SiSo_CALL_LTE_Data_Transfer
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO095_DEFAULT
#    ...  AND  Set Test Variable  @{SELECTED_CELLS}   363268
#    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
#    SiSo Basic L3 Call
#    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Cabinet_Fan_Speed_Counter
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO095_DEFAULT
    ...  AND  Set Test Variable  ${INTERVAL}  5
    ...  AND  Set Test Variable  ${CABINET_TYPE}  AMOE
    TC__SiSo_PM_Cabinet_Fan_Speed_Counters
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_Radio_Module_Fan_Speed_Counters_Monitoring
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO095_DEFAULT
    ...  AND  Set Test Variable  ${INTERVAL}  5
    TC__SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_SMOD_Internal_Temperature_Counters
    [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO095_DEFAULT
    TC__SiSo_PM_SMOD_Internal_Temperature_Counters
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_FM_SMOD_High_Low_Temp_Offset
  [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO095_DEFAULT
  TC__FM_SMOD_High_Low_Temp_Offset
  [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_PM_SMOD_Min_Max_Avg_Temp_Counters_Activation
  [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO095_DEFAULT
  TC__PM_SMOD_Min_Max_Avg_Temp_Counters_Activation
  [Teardown]  Configuration Postcondition

[1][1.0] Automated__SiSo_PM_LTE_uDTX
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO095_DEFAULT
    ...  AND  Set Test Variable  ${RMOD_SN}   EA224756747
    TC__PM_LTE_uDTX
    [Teardown]  Configuration Postcondition
