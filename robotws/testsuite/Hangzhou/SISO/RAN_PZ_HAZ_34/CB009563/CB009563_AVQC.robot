*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         4h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Modify_Prach_Online_with_Frame_Structure.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_5GC001866_K_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_5GC001866_K_Deactivate_Custome_BSR_WebEM_NSA_Classical.robot
Resource    ${BASIC_PATH_5G}/RF/General_SiSo_Beamforming_calibration.robot
Resource    ${BASIC_PATH_5G}/RF/General_SiSo_Activate_RuProtectEnabled_from_RuProtectDisabled_via_WebEM.robot
Resource    ${BASIC_PATH_5G}/General_Enabling_microDTXAdvanced_on_AVQC.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/Test_Model/General_SiSo_DL_Test_Model_Verification.robot
Resource    ${BASIC_PATH_5G}/General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause.robot
Resource    ${BASIC_PATH_5G}/Troubleshooting/General_SiSo_Running_the_troubleshooting_scripts_avqc.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Activate_Deactivate_Load-Based_Reduced_TX_Path_Power_Saving_WebEM_CB010471.robot
Resource    ${BASIC_PATH_5G}/KPI/KPI_51_SiSo_Manual_RU_reset_downtime.robot
Resource    ${BASIC_PATH_5G}/KPI/KPI_17_Manual_block_unblock_cell_duration.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_AVQC_CB010796_Start_slot_blanking_triggered_by_RFU_for_the_high_temperature_detected.robot
Resource    Resource/CB009563_common_keyword.robot
Resource    ${BASIC_PATH_COMMON}/General_UUF_in_UTE_cloud.robot
Resource    ${TEAM_COMMON}/DL_MU-MIMO_with_SRS_Beamforming.robot
Resource    ${TEAM_COMMON}/Multi_Cell_configuration_interation_with_Beamforming_and_Carrier_Aggregation.robot

Documentation
...    Author:tingting zhong
...    contact:tingting.zhong@nokia-sbell.com
...    squad group:SG_04
...    Feature Owner: Shi Gaofan,Xu mingming
...    Feature CB009563  AVQC in trunk program
...    Known PR: FID1900_PR757199

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AVQC
...   PY310    HAZ4_T04

*** Variables ***
${TEAM_COMMON}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG4/Classical/cases

*** Test Cases ***
[1]CB009563_General_UUF_in_UTE_cloud
    [Setup]    SISO Coam Test Setup
    General_UUF_in_UTE_cloud    TEST_ITERATION=1
    [Teardown]    SISO Coam Test Teardown

# 1S-1CC-8D-4U
[1]CB009563_SR_BB_08_General_SiSo_RU_module_reset_from_GUI
    [Tags]  1S-1CC-8D-4U
    General_SiSo_RF_module_reset_from_GUI    with_call=${True}

[1]CB009563_SR_F_01_General_SiSo_DL_Test_Model_Verification
    [Tags]  1S-1CC-8D-4U
    Modify Params before Test Mode
    ${test_model_list}    create list    NR-FR1-TM1.1    NR-FR1-TM1.2    NR-FR1-TM2    NR-FR1-TM2a
    ...    NR-FR1-TM3.1    NR-FR1-TM3.1a    NR-FR1-TM3.2    NR-FR1-TM3.3
    General_SiSo_DL_Test_Model_Verification    test_model_list=${test_model_list}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

# 1S-2CC-16D-8U
[1]CB009563_SR_BB_09_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    1S-2CC-16D-8U
    General_SiSo_Auto_BTS_site_reset    with_call=${True}

[1]CB009563_SR_BB_15_Manual_SiSo_SM_NR_RAT_reset
    [Tags]    1S-2CC-16D-8U
    Manual_SiSo_SM_NR_RAT_reset    with_call=${True}

[1]CB009563_SR_BB_38_eCPRI_attach_detach_loop_with_Configurable_1116_0ms_Structure
    [Tags]    1S-2CC-16D-8U
    [Timeout]  7h
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    ${prach_index_list}    create list    150
    General_SiSo_Modify_Prach_Online_with_Frame_Structure_Without_Call    prach_index_list=${prach_index_list}
    ...    frame_structure=1116_0ms_GP2_A7    ue_num_each_call=${ue_num_each_call}    times=${5}

[1]CB009563_SR_BB_19_General_SiSo_RF_alarms_with_autonomous_reset
    [Tags]    1S-2CC-16D-8U    RF50
    ${fault_list}    Create List    2922
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_alarms_with_autonomous_reset

[1]CB009563_SR_BB_34_eCPRI_L3_Call_with_Configurable_1116_0ms_Structure
    [Tags]    1S-2CC-16D-8U
    [Timeout]  7h
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    ${prach_index_list}    create list    9  14  90  92  96  97  102  150  156  158  194  195  198  206
    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
    ...    frame_structure=1116_0ms_GP2_A7    ue_num_each_call=${ue_num_each_call}

[1]CB009563_SR_BB_35_eCPRI_L3_Call_with_Configurable_1116_3ms_Structure
    [Documentation]
    ...    *****************
    ...    tp check updated ticket: https://jiradc.ext.net.nokia.com/browse/LEOPARD-1833
    [Tags]    1S-2CC-16D-8U
    [Timeout]  12h
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    ${prach_index_list}    create list    3  5  7  12  87  89  93  94  98  145  146  147  148  151  157  160  162  189
    ...  190  196  201  202  203  205
    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
    ...    frame_structure=1116_3ms_GP1_A5    ue_num_each_call=${ue_num_each_call}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB009563_SR_BB_36_eCPRI_L3_Call_with_Configurable_1208_Structure
    [Tags]    1S-2CC-16D-8U
    [Timeout]  3h
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    ${prach_index_list}    create list    100  101  149  159  191  192
    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
    ...    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}

[1]CB009563_SR_BB_37_eCPRI_L3_Call_with_Configurable_1070_Structure
    [Tags]    1S-2CC-16D-8U
    [Timeout]  5h
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    ${prach_index_list}    create list    2  4  6  17  88  104  152  161  197
    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
    ...    frame_structure=1070_GP1_A3    ue_num_each_call=${ue_num_each_call}

[1]CB009563_SR_BB_31_General_SiSo_custom_beam_set_realization_to_Gnb
        [Documentation]
    ...    *****************
    ...    Feature Owner: Xu mingming
    ...    Add FID7529 into alarm watchdog whitelist, please refer to https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10235.
    [Tags]    1S-2CC-16D-8U
    ${fault_list}    Create List    7529
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_5GC001866_K_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical
    ...    BSR_package=BSR_AVQC_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    General_SiSo_5GC001866_K_Deactivate_Custome_BSR_WebEM_NSA_Classical
    [Teardown]  SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB009563_SR_BB_30_General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification
    [Tags]    1S-2CC-16D-8U
    General_SiSo_Beamforming_calibration    check_time=10

[1]CB009563_SR_BB_12_Activate_RuProtectEnabled_from_RuProtectDisabled_via_WebEM
    [Documentation]
    ...    *****************
    ...    Feature Owner: Xu mingming
    ...    Known PR: PR757150
    ...    Other PR: PR765268
    ...    Add FID10 into alarm watchdog whitelist, because it is expected alarm after enable CB006114 actEcpriRuMPlaneSecurity.
    ...    For detail information, please refer to https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10235.
    [Tags]    1S-2CC-16D-8U    RF50
    ${fault_list}    Create List    10
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_Activate_RuProtectEnabled_from_RuProtectDisabled_via_WebEM

[1]CB009563_SR_C_20_Different_frame_structeres_configuraiton_with_gNB_timing_shifter
    [Tags]    1S-1CC-8D-4U    RF50    HAZ4_T04
    [Setup]    SISO Coam Test Setup    fail_with_alarms=${True}
    NR Feature CB007597 ON/OFF and Make Traffic

[1]CB009563_SR_D_01_General_SiSo_Online_Cell_addition_deletion
    [Tags]    2S-4CC-8D-8U_CB013584
    Selenium Login And Disable Screen Lock
    Prepare for delete NRPGRP
    Online delete NRPGRP
    General_SiSo_Online_Cell_addition_deletion
    [Teardown]  run keywords    SISO Coam Test Teardown    perform_case_scf=${True}    AND
    ...    Selenium Logout And Close Browser

[1]CB009563_SR_D_03_General_SiSo_RAT_Block_Unblock_with_L3call
    [Tags]    1S-2CC-16D-8U
    ${fault_list}    Create List    4614
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RAT_Block_Unblock    with_call=${True}

[1]CB009563_SR_D_11_L3call_with_Dual_carrier_30+90MHz
    [Tags]    2S-2CC-16D-8U    RF50    HAZ4_T04
    [Setup]    SISO Coam Test Setup    fail_with_alarms=${True}
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ...    ue_num_each_call=${ue_num_each_call}    ru_index=${1}
    L3Call_setup_with_data_transfer_conducted    with_call=${True}    with_peak=${True}    duration=${300}
    ...    ue_num_each_call=${ue_num_each_call}   suite_name=default_peak   test_name=default_peak    ru_index=${2}

[1]CB009563-SR-J_05_Micro-DTX_advanced_for_energy_efficiency_base_on_parity_CB008655
    [Tags]    1S-2CC-16D-8U    RF50
    General_Enabling_microDTXAdvanced_on_AVQC
    [Teardown]  run keywords    SISO Coam Test Teardown    perform_case_scf=${True}    AND
    ...    Selenium Logout And Close Browser

[1]CB009563-SR-J_06_deep_sleep_mode_for enery_efficiency_base_on_parity_CB007511
    [Tags]    2S-2CC-16D-8U    RF50
    ${status}   Run Keyword And Return Status   General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled
    Run Keyword If   not ${status}   Fail   General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled failed

    Trigger Enter And Exit Deepsleep Mode Repetitively    duration=${3600}
    [Teardown]  run keywords    Run Keyword And Ignore Error   SISO Coam Test Teardown   perform_case_scf=${True}    AND
    ...   Run Keyword And Ignore Error   Selenium Logout And Close Browser

[1]CB009563-SR-E_10_VET_Configuration_Management_l3call_traffic_By_Tiltoffset5
    [Tags]    1S-2CC-16D-8U
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    General_SiSo_Configuration_Management_l3call_traffic_By_Tiltoffset  with_call=${True}   with_peak=${False}   tiltOffset=5
    ...   ue_num_each_call=${ue_num_each_call}
    [Teardown]  SISO Coam Test Teardown   perform_case_scf=${True}

[1]CB009563-SR-E_11_fault_trigge_4598_TiltOffset_out_of_Range
    [Tags]    1S-2CC-16D-8U
    ${fault_list}    Create List    4598
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_fault_trigge_4598_TiltOffset_out_of_Range
    [Teardown]  SISO Coam Test Teardown   perform_case_scf=${True}

[1]CB009563_SR_H_02_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    1S-2CC-16D-8U    RF50
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_AVQC    is_get_snapshot_via_selenium=${True}

[1]CB009563_SR_H_03_General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
    [Tags]    1S-2CC-16D-8U    RF50
    ${fault_list}    Create List    1937
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    # WESTLAKE-10402 update fault_logger.json as info changed for latest load
    Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started_AVQC
    ...    fault_logger_json=${CURDIR}/TestData/fault_logger.json

[1]CB009563_SR_H_18_Snapshot_Showing_Radio_Last_Reset_Cause
    [Documentation]
    ...    *****************
    ...    Feature Owner: Xu mingming
    ...    Add FID10 into alarm watchdog whitelist, please refer to https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10235.
    [Tags]    1S-2CC-16D-8U
    ${fault_list}    Create List    10
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause   ru_type=AVQC

[1]CB009563_SR_H_19_General_SiSo_Running_Radio_Module_Troubleshooting_scripts_via_OAM_interface
    [Tags]    1S-1CC-8D-4U    RF50
    General_SiSo_Running_the_troubleshooting_scripts_avqc

[1]CB009563-SR-W_13_RU_reset_downtime_KPI51a
    [Tags]    1S-2CC-16D-8U    RF50
    Selenium Login And Disable Screen Lock
    ${get_cell_from_ru}    Get All Cell Id    ru_index=${1}
    ${add_extra_time}   Set Variable   ${0}
    ${ru_reset_startup_duration}   Set Variable   ${240}
    FOR  ${cell_id}  IN   @{get_cell_from_ru}
        ${actDlSrsBm}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Activate downlink SRS based beam management
        ${actUlSrsBm}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Activate uplink SRS based beam management
        ${dlMimoMode}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Downlink MIMO Mode
        ${add_extra_time}   Set Variable If
        ...   '${actDlSrsBm}'=='true' and '${actUlSrsBm}'=='true' and '${dlMimoMode}'=='8x4 Closed Loop Spatial Multiplexing'    ${20}   ${0}
    END
    ${add_extra_time}   Get Extra Time For KPI51    cell_list=${get_cell_from_ru}    default_extra_time=${add_extra_time}
    ${ru_reset_startup_duration}=   Evaluate   ${ru_reset_startup_duration}+${add_extra_time}
    KPI_51_SiSo_Manual_RU_reset_downtime      special_ru=${ru_type_init}   ru_reset_startup_duration=${ru_reset_startup_duration}

[1]CB009563-SR-W_11_Cell_block_duration_KPI17a
    [Tags]    1S-2CC-16D-8U    RF50
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    KPI_17_Manual_block_unblock_cell_duration

[1]CB009563-SR-N_09_Activate_Deactivate_Load-Based_Reduced_TX_Path_Power_Saving_WebEM_CB010471
    [Tags]    2S-2CC-16D-2U_72E    RF50
    General_SiSo_Activate_Deactivate_Load-Based_Reduced_TX_Path_Power_Saving_WebEM_CB010471
    [Teardown]  SISO Coam Test Teardown   perform_case_scf=${True}

[1]CB009563-SR-O_03_AVQC_ASIM_ABIP_Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    1S-2CC-16D-8U
    E2E_SiSo_RU_lock_and_unlock_gNB  with_call=${True}   with_peak=${True}   call_duration=${300}
    ...    suite_name=${SUITE NAME}   test_name=${TEST NAME}

[1]CB009563-SR-O_13_AVQC_CB010796_Start_slot_blanking_triggered_by_RFU_for_the_high_temperature_detected
    [Tags]    2S-2CC-16D-2U_72E    RF50
    ${ue_num_each_call}    Get Tput ue Number    given_num=1
    General_SiSo_AVQC_CB010796_Start_slot_blanking_triggered_by_RFU_for_the_high_temperature_detected
    ...    ue_num_each_call=${ue_num_each_call}    ru_index=${1}

[1]CB009563_SR_BB_13_General_SiSo_E2E_system_setup_with_data_transfer_conducted_8D4U_with_BF
    [Tags]  1S-1CC-8D-4U
    General_SiSo_Peak_with_Given_Information    band=90    frame_structure=1070_GP1_A3    prach_index=196
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB009563_SR_BB_13_General_SiSo_Cell_block_and_unblock
    [Tags]    1S-1CC-8D-4U
    [Timeout]  6h
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}    with_peak=${True}    call_duration=${300}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB009563-SR-G_12_DL_MU-MIMO_with_SRS_Beamforming_1S2CC_8D8U
    [Tags]    SBTS00
    DL_MU-MIMO_with_SRS_Beamforming

[1]CB009563-SR-G_11_Multi_Cell_configuration_interation_with_Beamforming_and_Carrier_Aggregation
    [Tags]    SBTS00
    Multi_Cell_configuration_interation_with_Beamforming_and_Carrier_Aggregation
    ...    suite_name=${SUITE NAME}   test_name=${TEST NAME}
