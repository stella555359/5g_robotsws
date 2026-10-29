*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_CPRI_link_configuration.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_reset_with_RF_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_LED_states_management_basic.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_IP_adress_allocation.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot

Documentation
...    Author: geyou fan
...    Contact: geyou.fan@nokia-sbell.com
...    squad group:SG_04
...    Feature 5GC002361-A in 5G20A program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AZNA
...   PY36

*** Variables ***

*** Test Cases ***
[1]5GC002361_A_AZNA_General_SiSo_CPRI_link_configuration
    [Tags]    CRT_TRUNK    SBTS00    CIT
    General_SiSo_CPRI_link_configuration

[1]5GC002361_A_AZNA_General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK    SBTS00    CIT
    General_SiSo_RU_lock_unlock

[1]5GC002361_A_AZNA_General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB

[1]5GC002361_A_AZNA_General_SiSo_RF_module_power_reset
    [Tags]    SBTS00    CIT
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_module_power_reset    with_call=${True}

[1]5GC002361_A_AZNA_General_SiSo_BTS_reset_with_RF_power_reset
    [Tags]    CIT_22R4    SBTS00    CIT
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_BTS_reset_with_RF_power_reset

[1]5GC002361_A_AZNA_General_SiSo_LED_states_management_basic
    [Tags]    CRT_TRUNK    SBTS00    CIT
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_LED_states_management_basic

[1]5GC002361_A_AZNA_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    SBTS00    CIT_22R4    CIT
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]5GC002361_A_AZNA_General_SiSo_RF_module_addition_in_BIM_and_WebUI
    [Tags]    SBTS00    CIT
    General_SiSo_RF_module_addition_in_BIM_and_WebUI

[1]5GC002361_A_AZNA_General_SiSo_RF_module_IP_adress_allocation
    [Tags]    SBTS00    CIT
    General_SiSo_RF_module_IP_adress_allocation

[1]5GC002361_A_AZNA_General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    CRT_TRUNK    SBTS00    CIT
    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]5GC002361_A_AZNA_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Tags]    SBTS00    CIT
    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1]5GC002361_A_AZNA_General_SiSo_RF_module_reset_from_GUI
    [Tags]    CIT_22R4    SBTS00    CIT
    General_SiSo_RF_module_reset_from_GUI    with_call=${True}

[1]5GC002361_A_AZNA_General_SiSo_BTS_startup_with_RF_delayed_startup
    [Tags]    CRT_TRUNK    SBTS00    CIT
    ${fault_list}    Create List    10    4589    4590
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_BTS_startup_with_RF_delayed_startup

[1]5GC002361_A_AZNA_General_SiSo_RF_alarms_with_recovery
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${fault_list}    Create List    1901
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_alarms_with_recovery

[1]5GC002361_A_AZNA_General_SiSo_RF_alarms_without_recovery
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${fault_list}    Create List    1937
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_alarms_without_recovery

#[1]5GC002361_A_AZNA_General_SiSo_Cell_lock_and_unlock
#    General_SiSo_Cell_lock_and_unlock
#
#[1]5GC002361_A_AZNA_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
#    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
#
#[1]5GC002361_A_AZNA_General_SiSo_SOAP_RP1_verification
#    General_SiSo_SOAP_RP1_verification
#
#[1]5GC002361_A_AZNA_General_SiSo_NR-ARFCN_check
#    [Tags]    ARFCN
#    General_SiSo_NR-ARFCN_check
#
#[1]5GC002361_A_AZNA_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Timeout]    8h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
#
#[1]5GC002361_A_AZNA_General_SiSo_stability_with_L3Call_Full_Panel_MCS0
#    General_SiSo_E2E_system_setup_with_data_transfer    band=20
#
#[1]5GC002361_A_AZNA_General_SiSo_Auto_Cell_lock_and_unlock
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Cell_lock_and_unlock    times=${5}    pass=${4}
#
#[1][1.0] 5GC002361_A_AZNA_General_SiSo_E2E_system_setup_with_data_transfer_conducted_30km_Fiber_20MHz
#    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_A7
#
#[1][1.0] 5GC002361_A_AZNA_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100m_Fiber_20MHz
#    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_A7
#
#[1]5GC002361_A_AZNA_General_SiSo_Auto_Automatic_RAT_SW_upgrade
#    General_SiSo_Auto_Automatic_RAT_SW_upgrade

*** Keywords ***
