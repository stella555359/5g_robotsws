# *** Settings ***
# Suite Setup     Common Suite Setup
# Suite Teardown  Common Suite Teardown
# Test Setup      Common Test Setup
# Test Teardown   Common Test Teardown
# Test Timeout         12h
# 
# Resource    taf/rfrl/procedures/SISO/setups_teardowns/SuiteSetupTeardown.robot
# Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Radio_Module_Power_Reset.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Radio_Module_Reset_From_GUI.robot
# Resource    taf/rfrl/procedures/SISO/Classical_gNB_Power_Reset_Startup_success_rate.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_eCPRI_Sync_Counters.robot
# Resource    taf/rfrl/procedures/SISO/eCPRI_sync_counters.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
# Resource    taf/rfrl/procedures/SISO/Classical_Site_Reset_Startup_Success_Rate.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Radio_Module_Lock_Unlock.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Cell_Block_Unblock.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_power_reset.robot
# #Resource    taf/rfrl/procedures/SISO/Online_Cell_addition_deletion.robot
# 
# Documentation
# ...    Author:zhihao shi
# ...    contact:zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# 
# Force Tags    CLOUD_5G_CLASSICAL_ASIBL_ABINB1_AQQY_ENB
# ...           CRT   SBTS00   PY36
# 
# *** Variables ***
# ${runs_success_rate}     ${10}
# ${dist_name}           MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1
# ${abbr_group_name}     eCpriMasterStatisticsInterval
# ${measurments}         2
# ${PM_interval_init}    5min
# 
# *** Test Cases ***
# [1]General_SiSo_Commissioning_BTS_Template_Commissioning
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General SiSo Comissioning BTS Template Comissioning    parameter=mnc    correct_value=6
#     ...    incorrect_value=99999    dist_name=MRBTS-{}/NRBTS-{}
# 
# [1]General_SiSo_Auto_BTS_Site_Reset
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General_SiSo_Auto_BTS_Site_Reset
# 
# [1]General_SiSo_Cell_block_and_unblock
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General_SiSo_Cell_block_and_unblock
# 
# [1]General_SiSo_Auto_RF_lock_unlock
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General_SiSo_Auto_RF_lock_unlock
# 
# [1]General_SiSo_BTS_startup_with_RF_delayed_startup
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     Alarms.Allow alarm  fault_id=10
#     Set Test Variable    @{mandatory_alarms}    No connection to unit
#     General SiSo BTS startup with RF delayed startup    mandatory_alarms=${mandatory_alarms}
# 
# [1]General_SiSo_Auto_Radio_Module_Power_Reset
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General_SiSo_Auto_Radio_Module_Power_Reset
# 
# [1]General_SiSo_Auto_RF_module_reset_from_WebUI
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General_SiSo_Auto_RF_module_reset_from_WebUI
# 
# [1]General_SiSo_Auto_Radio_Module_Reset_From_GUI
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General_SiSo_Auto_Radio_Module_Reset_From_GUI
# 
# #no in case list
# Classical_gNB_Power_Reset_Startup_success_rate
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     Set Test Variable    ${target}    0.99
#     Classical gNB Power Reset Startup success rate    target=${target}    runs_success_rate=${runs_success_rate}
# 
# General_SiSo_Auto_eCPRI_Sync_Counters
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General_SiSo_Auto_eCPRI_Sync_Counters
# 
# eCPRI_sync_counters
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     eCPRI sync counters    dist_name=${dist_name}    abbr_group_name=${abbr_group_name}    interval_1=5min
#     ...    interval_2=15min    measurments=${measurments}    pm_interval_init=${PM_interval_init}
# 
# General_SiSo_Auto_gNB_Site_Reset_From_WebUI
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General SiSo Auto gNB Site Reset From WebUI
# 
# Classical_Site_Reset_Startup_Success_Rate
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     Set Test Variable    ${target}    0.99
#     Classical Site Reset Startup Success Rate    target=${target}    runs_success_rate=${runs_success_rate}
# 
# General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General SiSo Auto Collect RFSW logs from RU into BTS Snapshot
# 
# General_SiSo_Auto_RF_module_power_reset
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     Alarms.Allow alarm  fault_id=10
#     Set Test Variable    @{mandatory_alarms}    No connection to unit
#     General SiSo Auto RF module power reset    mandatory_alarms=${mandatory_alarms}
# 
# General_SiSo_Auto_Radio_Module_Lock_Unlock
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General_SiSo_Auto_Radio_Module_Lock_Unlock
# 
# General_SiSo_Auto_Cell_Block_Unblock
#     Alarms.Allow alarm  fault_id=7300
#     Alarms.Allow alarm  fault_id=7319
#     General_SiSo_Auto_Cell_Block_Unblock
# 
# #Online_Cell_addition_deletion
# #    Alarms.Allow alarm  fault_id=7300
# #    Alarms.Allow alarm  fault_id=7319
# #    Online Cell addition deletion
# 
# *** Keywords ***
