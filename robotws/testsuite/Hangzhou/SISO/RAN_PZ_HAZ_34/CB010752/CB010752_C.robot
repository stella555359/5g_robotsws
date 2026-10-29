*** Settings ***
Documentation
Resource    ./Resources/CB010752_common_keyword.robot


Suite Setup    Suite Setup CB010752-C
Suite Teardown    Suite Teardown

*** Test Cases ***
[1]CB010752-SR-C_006_General_SiSo_RF_module_Web_reset_and_power_reset
    [Setup]    robot_common_operations.Common case Setup     allowed_faults_ids=61675,7316,4476,7311
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    RMOD Power OFF/ON Operation And Check GNB Status
    sleep    2min
    Make CPE L3 Call And Check Peak Tput    dl_tp=1500   ul_tp=83
    ...    target_avg_percent_UL=0.90    target_avg_percent_DL=0.90
    ...    ue_list=${ALL_UE_INFO_LIST[0:1]}    Cell_Pci=${CALL_PCI_AND_NRCELLID_INFO_LET}
    Reset ALL RMOD And Check GNB Status
    sleep    2min
    Make CPE L3 Call And Check Peak Tput    dl_tp=1500   ul_tp=83
    ...    target_avg_percent_UL=0.90    target_avg_percent_DL=0.90
    ...    ue_list=${ALL_UE_INFO_LIST[0:1]}    Cell_Pci=${CALL_PCI_AND_NRCELLID_INFO_LET}
    [Teardown]    Case Teardown



[1]CB010752-SR-C_001_L3_call_on_LTE_normal_cell_configurationg_LTEFDD_NRTDD_cells_simultaneously
    [Setup]    robot_common_operations.Common case Setup     allowed_faults_ids=61675,7316,4476,7311
    log to console    [1]CB010752-SR-C_006
#    Make CPE L3 Call And Check Peak Tput    dl_tp=1500   ul_tp=83
#    ...    target_avg_percent_UL=0.90    target_avg_percent_DL=0.90
#    ...    ue_list=${ALL_UE_INFO_LIST[0:1]}    Cell_Pci=${CALL_PCI_AND_NRCELLID_INFO_LET}
    [Teardown]    Case Teardown


[1]CB010752-SR-C_005_General_SiSo_Cell_block_and_unblock
    [Setup]    robot_common_operations.Common case Setup     allowed_faults_ids=61675,7316,4476,7311
     Modify Parameters C_05
     Check GNB on air
     Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    Case Teardown

