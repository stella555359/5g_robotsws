# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         600 min
# 
# Resource    resource/common_resource.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009576_SG05/resource/CB009576_X_resource.robot
# Documentation
# ...    Author: Liu Yue
# ...    Contact: yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature AVQE Bootmap in 5G24R1 program
# 
# Force Tags    RAN_5G_TDD
# ...    PY36
# 
# *** Variables ***
# @{addition_deletion_cell_list}    ${4}
# @{addition_deletion_cellgrp_list}    ${3}
# @{lcrid_list}    ${4}
# @{cell_grp}     ${3}
# *** Test Cases ***
# [1][1.0] General_SiSo_HWPTA_BTS_Site_Reset
#     #[Tags]    QC_819974
#     #[Tags]    QC_819946
#     General_SiSo_Auto_BTS_site_reset    with_call=${True}    with_peak=${False}   
# [1][1.0] General_SiSo_HWPTA_Radio_Module_Reset_From_GUI
#     [Tags]    QC_819983
#     General_SiSo_RF_module_reset_from_GUI    with_call=${True}
# [1][1.0] General_SiSo_HWPTA_Radio_Module_Power_Reset
#     [Tags]    QC_819982
#     General_SiSo_RF_module_power_reset    with_call=${True}
# [1][1.0] General_SiSo_HWPTA_BB_Module_Reset
#     [Tags]    QC_819973
#     Baseband_module_reset_via_WEBUI    with_call=${True}
# [1][1.0] E2E_TL_Capacity_Module_Reset_with_sleeping_cell_check
#     [Tags]    QC_819994
#     Baseband_module_reset_via_WEBUI    with_call=${True}
# [1][1.0] E2E_TL_RU_Reset_with_sleeping_cell_check
#     [Tags]    QC_819998
#      General_SiSo_RF_module_reset_from_GUI    with_call=${True}
# [1][1.0] General_SiSo_HWPTA_Cell_Block_Unblock
#     [Tags]    QC_819976
#     General_SiSo_Cell_block_and_unblock
# [1][1.0] General_SiSo_HWPTA_Radio_Module_Lock_Unlock
#     [Tags]    QC_819981
#     General_SiSo_RU_lock_unlock
# [1][1.0] General_SiSo_HWPTA_Cell_Lock_Unlock
#     [Tags]    QC_819977
#     General_SiSo_Cell_lock_and_unlock
# [1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_sleeping_cell_check
#     [Tags]    QC_819996
#     E2E_SiSo_Cell_lock_and_unlock_gNB
# [1][1.0] E2E_TL_Cell_Block_Unblock_NR_with_sleeping_cell_check
#     [Tags]    QC_819995
#     E2E_SiSo_Cell_block_and_unblock_gNB
# [1][1.0] General_SiSo_HWPTA_BTS_Template_Commissioning_Recommissioning
#     [Tags]    QC_819975
#     General_SiSo_Commissioning_BTS_Template_Commissioning
# #[1][1.0] General_SiSo_HWPTA_Online_Cell_Addition_Deletion
# #    [Tags]    QC_819980
# #    General_SiSo_Online_Cell_addition_deletion_Sametimes
# [1][1.0] General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
#     [Tags]    QC_819978
#     General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# [1][3.0] General_SiSo_Test_Model_Stability_Run
#     [Tags]    QC_819990    3S-1CC-TDS
#     ${test_model_list}    create list    NR-FR1-TM1.1
#     General_SiSo_DL_Test_Model_Verification    test_model_list=${test_model_list}
# [1]Attach SR on different Prach configuration recommison
#     Change prach configuration
#     Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
#     ${cell_list}    create list    ${1}
#     Get UE From Init File and Make call   cell_list=${cell_list}     with_peak=${False}    duration=${300}
# [1]Different frame structures configuration with cell frame or SFN offset
#     Change msg1frequencyStart configuration
#     sleep    2min
#     Modify_Band_Frame_Structure    frame_structure=1116_3ms_GP1_A5    band=80
#     log to console    \n prepare to l3call
#     ${cell_list}    create list    ${1}
#     Get UE From Init File and Make call   cell_list=${cell_list}    with_peak=${False}    duration=${300}
# [1][1.0] E2E_TL_Delta_Commissioning_With_NR_Rat_sleeping_cell_check
#     Change RAT restart needed parameter
#     log to console    \n prepare to l3call
#     ${cell_list}    create list    ${1}
#     Get UE From Init File and Make call   cell_list=${cell_list}    with_peak=${False}    duration=${300}    
# [1][1.0] General_SiSo_Auto_Deep_Sleep_RU_awake_after_parameter_change
#     General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled
#     Disable energy powing
#     wait until keyword succeeds   10min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
#     wait until keyword succeeds   10min    30s    Verify all cells should be onair
# [1][1.0] General_SiSo_Auto_Deep_Sleep_RU_awake_after_adding_new_cell
#     General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled
#     @{split_version}    string.split string    ${Active_SW_version}    separator=_
#     ${stream}    set variable     @{split_version}[0]
#     Selenium Login And Disable Screen Lock    version=${stream}
#     Online add cells    addition_deletion_cell_list=@{addition_deletion_cell_list}
#     ...    addition_deletion_cellgrp_list=@{addition_deletion_cellgrp_list}
#     ...   lcrid_list=@{lcrid_list}
#     ...    cell_grp=@{cell_grp}    scf_path=${Case_SCF_Path}
#     Online delete cells    addition_deletion_cell_list=@{addition_deletion_cell_list}
#     ...    addition_deletion_cellgrp_list=@{addition_deletion_cellgrp_list}
#     ...   lcrid_list=@{lcrid_list}
#     ...    cell_grp=@{cell_grp}    scf_path=${Case_SCF_Path}
#     [Teardown]    Selenium Logout And Close Browser
# [1][1.0] General_SiSo_Auto_Deep_Sleep_RU_cells_lock_unlock_with_L3call
#     General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled
#     General_SiSo_RF_module_reset_from_GUI    with_call=${False}
#     log to console    \n prepare to l3call
#     ${cell_list}    create list    ${1}
#     Get UE From Init File and Make call   cell_list=${cell_list}    with_peak=${False}    duration=${300}
# [1][2.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
#     CB009576-SR-X_KPI2c_d_Software_Upgrade_duration
