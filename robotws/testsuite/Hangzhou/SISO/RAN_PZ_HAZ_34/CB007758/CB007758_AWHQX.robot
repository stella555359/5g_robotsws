*** Settings ***
Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup    AND    SISO Suite Setup
Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown    AND    SISO Suite Teardown
Test Setup           Run Keywords    robot_common_operations.Common Case Setup    AND    SISO Test Setup
Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown    AND    SISO Test Teardown
Test Timeout         600 min

Resource     Resource/CB007758_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Documentation
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com
...    squad group:SG_01
...    Feature CB005845 in 5G22R2 program

Force Tags            5G_RAN    5G_RAN_TDD
...    PY36


*** Test Cases ***
[1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module_AWHQX
    [Tags]  TBD
    TC.01_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module_AWPTD
    [Tags]  TBD
    TC.01_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module_AWHQ2
    [Tags]  TBD
    TC.01_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1][1.0] General_SiSo_RF_module_power_reset_AWHQX
    [Tags]  CRT_Trunk  CRT  Peak_Tput
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=49
    TC.11_General_SiSo_RF_module_power_reset
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer
    ...          attach_cell_index=${TCCB007758_INPUT['TC24']['UE_Attach_Cell_index']}
    ...          UECFG=${TLCommonConfig_CB007758['MultiUECFG']}
    ...          UE_index=${TCCB007758_INPUT['TC24']['UE_index']}
    ...          peak_use_tool=False
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=49

[1][1.0] General_SiSo_RF_module_power_reset_AWPTD
    [Tags]  CRT_Trunk  CRT
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    TC.11_General_SiSo_RF_module_power_reset
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=49

[1][1.0] General_SiSo_RF_module_power_reset_AWHQ2
    [Tags]  CRT_Trunk  CRT
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=49
    TC.11_General_SiSo_RF_module_power_reset
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer
    ...          attach_cell_index=${TCCB009463_INPUT['E2E_with_data_transfer']['UE_Attach_Cell_index']}
    ...          UECFG=${TLCommonConfig['MultiUECFG_9463']}
    ...          UE_index=${TCCB009463_INPUT['E2E_with_data_transfer']['UE_index']}
    ...          peak_use_tool=True
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=49

[1][1.0] General_SiSo_BTS_startup_with_RF_delayed_startup_AWHQX
    [Tags]  TBD
    TC.15_General_SiSo_BTS_startup_with_RF_delayed_startup

[1][1.0] General_SiSo_BTS_startup_with_RF_delayed_startup_AWPTD
    [Tags]  TBD
    TC.15_General_SiSo_BTS_startup_with_RF_delayed_startup

[1][1.0] General_SiSo_BTS_startup_with_RF_delayed_startup_AWHQ2
    [Tags]  TBD
    TC.15_General_SiSo_BTS_startup_with_RF_delayed_startup

[1][1.0] General_SiSo_Cell_lock_unlock_AWHQX
    [Tags]  CRT_Trunk  CRT   Peak_Tput
    TC.16_01_General_SiSo_Cell_lock_and_unlock
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer
    ...          attach_cell_index=${TCCB007758_INPUT['TC24']['UE_Attach_Cell_index']}
    ...          UECFG=${TLCommonConfig_CB007758['MultiUECFG']}
    ...          UE_index=${TCCB007758_INPUT['TC24']['UE_index']}
    ...          peak_use_tool=True

[1][1.0] General_SiSo_Cell_lock_unlock_AWPTD
    [Tags]  CRT_Trunk  CRT
    TC.16_General_SiSo_Cell_lock_and_unlock

[1][1.0] General_SiSo_Cell_lock_unlock_AWHQ2
    [Tags]  CRT_Trunk  CRT
    TC.16_01_General_SiSo_Cell_lock_and_unlock
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer
    ...          attach_cell_index=${TCCB009463_INPUT['E2E_with_data_transfer']['UE_Attach_Cell_index']}
    ...          UECFG=${TLCommonConfig['MultiUECFG_9463']}
    ...          UE_index=${TCCB009463_INPUT['E2E_with_data_transfer']['UE_index']}
    ...          peak_use_tool=True

[1][1.0] General_SiSo_RF_alarms_with_recovery_AWHQX
    [Tags]  TBD
    TC.21_General_SiSo_RF_alarms_with_recovery

[1][1.0] General_SiSo_RF_alarms_with_recovery_AWPTD
    [Tags]  TBD
    TC.21_General_SiSo_RF_alarms_with_recovery

[1][1.0] General_SiSo_RF_alarms_with_recovery_AWHQ2
    [Tags]  TBD
    TC.21_General_SiSo_RF_alarms_with_recovery

[1][1.0] General_SiSo_RF_alarms_without_recovery_AWHQX
    [Tags]  TBD
    TC.22_General_SiSo_RF_alarms_without_recovery

[1][1.0] General_SiSo_RF_alarms_without_recovery_AWPTD
    [Tags]  TBD
    TC.22_General_SiSo_RF_alarms_without_recovery

[1][1.0] General_SiSo_RF_alarms_without_recovery_AWHQ2
    [Tags]  TBD
    TC.22_General_SiSo_RF_alarms_without_recovery

[1][2.0] General_SiSo_RU_module_reset_from_GUI_AWHQX
    [Tags]  CRT_Trunk  CRT    Peak_Tput
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=49
    TC.12_General_SiSo_RF_module_reset_from_GUI
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer
    ...          attach_cell_index=${TCCB007758_INPUT['TC24']['UE_Attach_Cell_index']}
    ...          UECFG=${TLCommonConfig_CB007758['MultiUECFG']}
    ...          UE_index=${TCCB007758_INPUT['TC24']['UE_index']}
    ...          peak_use_tool=True
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=49

[1][2.0] General_SiSo_RU_module_reset_from_GUI_AWPTD
    [Tags]  TBD
    TC.12_General_SiSo_RF_module_reset_from_GUI

[1][2.0] General_SiSo_RU_module_reset_from_GUI_AWHQ2
    [Tags]  CRT_Trunk  CRT
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=49
    TC.12_General_SiSo_RF_module_reset_from_GUI
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer
    ...          attach_cell_index=${TCCB009463_INPUT['E2E_with_data_transfer']['UE_Attach_Cell_index']}
    ...          UECFG=${TLCommonConfig['MultiUECFG_9463']}
    ...          UE_index=${TCCB009463_INPUT['E2E_with_data_transfer']['UE_index']}
    ...          peak_use_tool=True
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=49
#[3.0] General_SiSo_NR-ARFCN_check
#    [Tags]    CRT_22R3
#    TC.23_General_SiSo_NR-ARFCN_check
[1][2.0] General_SiSo_RU_lock_and_unlock
    [Tags]    CIT_TRUNK    No_L3Call    ALL_RUs_Lock_Unlock
    TC.60_General_SiSo_RU_lock_unlock

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]  CRT_TRUNK    Peak_Tput
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer
    ...          attach_cell_index=${TCCB007758_INPUT['TC24']['UE_Attach_Cell_index']}
    ...          UECFG=${TLCommonConfig_CB007758['MultiUECFG']}
    ...          UE_index=${TCCB007758_INPUT['TC24']['UE_index']}
    ...          peak_use_tool=True

[1][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]  CIT_TRUNK
    TC.25_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

