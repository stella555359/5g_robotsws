*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           Run keywords    CBRS Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=6832   
Test Teardown        CB010475 CBRS Test Teardown

Resource    Resources/CB010475_common_keywords.robot


Documentation
...    Author:linjiangjing
...    contact:jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB0010475

Force Tags            RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    STATE_SW_UPLOADED
...    PY36


*** Variables ***


*** Test Cases ***
[1]CB010475_SR_B_NR_only_Manual_SiSo_SM_NR_RAT_reset
    [Tags]    CRT_TRUNK    CRT_23R4
    Start SAS server for NR
    CB010475_SR_B_NR_only_Manual_SiSo_SM_NR_RAT_reset

[1]CB010475_SR_B_NR_only_General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK    CRT_23R4
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Start SAS server for NR
    CB010475_SR_B_NR_only_General_SiSo_Cell_block_and_unblock

[1]CB010475_SR_B_NR_only_General_SiSo_E2E_system_setup_with_data_transfer_conducted_NR30+40+40+40MHz
    [Tags]    CRT_TRUNK    CRT_23R4
    Start SAS server for NR
    CB010475_SR_B_NR_only_General_SiSo_E2E_system_setup_with_data_transfer_conducted_NR30+40+40+40MHz

[1]CB010475_SR_B_NR-LTE_Concurrent_BBMOD_reset_from_GUI
    [Tags]    CRT_TRUNK    CRT_23R4
    Start SAS server for NR LTE
    CB010475_SR_B_NR-LTE_Concurrent_BBMOD_reset_from_GUI

[1]CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK    CRT_23R4
    Start SAS server for NR LTE
    CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_RU_lock_unlock

[1]CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK    CRT_23R4
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Start SAS server for NR LTE
    CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_Cell_block_and_unblock

[1]CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_E2E_system_setup_with_data_transfer_conducted_NR30+40MHz_LTE20+20+20+20MHz
    [Tags]    CRT_TRUNK    CRT_23R4
    run keyword and ignore error    Simply_reboot_ue
    Start SAS server for NR LTE
    CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_E2E_system_setup_with_data_transfer_conducted_NR30+40MHz_LTE20+20+20+20MHz

[1]CB010475_SR_B_NR-LTE_Concurrent_Cell online add delete NR cell
    [Tags]    CRT_TRUNK    CRT_23R4
    Start SAS server for NR LTE
    CB010475_SR_B_NR-LTE_Concurrent_Cell online add delete NR cell

[1]CB010475_SR_B_NR-LTE_Concurrent_Manual_SiSo_SM_NR_RAT_reset
    [Tags]    CRT_TRUNK    CRT_23R4
    Start SAS server for NR LTE
    CB010475_SR_B_NR-LTE_Concurrent_Manual_SiSo_SM_NR_RAT_reset

[1]CB010475_SR_B_NR-LTE_Concurrent_Manual_SiSo_SM_LTE_RAT_reset
    [Tags]    CRT_TRUNK    CRT_23R4
    Start SAS server for NR LTE
    CB010475_SR_B_NR-LTE_Concurrent_Manual_SiSo_SM_LTE_RAT_reset

[1]CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_RAT_Block_Unblock_with_L3Call
    [Tags]    CRT_TRUNK    CRT_23R4
    AlarmWatchdog.add_allow_alarms    fault_id=50
    Start SAS server for NR LTE
    CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_RAT_Block_Unblock_with_L3Call

[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_23R4
    Start SAS server for NR LTE
    CB010475_SR_B_NR-LTE_Concurrent_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    Connect to gnb coam via ssl

*** Keywords ***
