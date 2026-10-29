*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_LED_states_management_basic.robot
Resource    ${BASIC_PATH_5G}/5GC000560/5GC000560_eLLF_PTP_Failure.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/RF/General_SiSo_Beamforming_calibration.robot
Resource    ${BASIC_PATH_5G}/General_Enabling_microDTXAdvanced_on_Galvatron_cMAAr62_32T32R_Radio.robot
Resource    ${BASIC_PATH_5G}/Test_Model/General_SiSo_DL_Test_Model_Verification.robot
Resource    ${BASIC_PATH_5G}/Test_Model/General_SiSo_UL_Test_Model_Verification.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_5GC001866_K_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_5GC001866_K_Deactivate_Custome_BSR_WebEM_NSA_Classical.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call.robot
Resource    ${BASIC_PATH_5G}/General_Power_Consumption_and_Power_Saving_percentage_measured_in_Idle_Load.robot
Resource    ${BASIC_PATH_5G}/General_RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Modify_Prach_Online_with_Frame_Structure.robot
Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/KPI/KPI_51_SiSo_Manual_RU_reset_downtime.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB008194 in trunk program

Force Tags            RAN_5G_TDD    5G_RAN_TDD    5G_RAN    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AQQF
...   PY36

*** Variables ***

*** Test Cases ***
# TL585 default scf: 1S-1CC-8D-4U 100M
# CIT
[1]CB008194_AA_13_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CIT_TRUNK    SBTS00    CIT_UTE
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]CB008194_BA_10_General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS L3_call
    [Tags]    CIT_TRUNK    SBTS00    CIT_UTE    RF50
    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1

[1]CB008194_CA_23_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_30M
    [Tags]    CIT_TRUNK    SBTS00    CIT_UTE
    General_SiSo_Peak_with_Given_Information    band=30    frame_structure=1208_GP1_A1

[1]CB008194_CD_18_General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification
    [Tags]    CIT_TRUNK    SBTS00    CIT_UTE
    General_SiSo_Beamforming_calibration

[1]CB008194_CD_22_20M+20M_cell_block_unblock
    [Tags]    1S-2CC-8D-4U    CIT_TRUNK    SBTS00    CIT_UTE
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_gnb_can_be_on_air_with_Given_Information    band=20    frame_structure=1208_GP1_A1
    ${cell_list}    Get All Cell Id
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    run keyword and continue on failure
    ...    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    duration=${300}    ue_num_each_call=${ue_num_each_call}
    E2E_SiSo_Cell_block_and_unblock_gNB    upload_tp=${False}    upload_duration=${False}

[1]CB008194_CD_23_50M+50M_RU_lock_unlock
    [Tags]    1S-2CC-8D-4U    CIT_TRUNK    SBTS00    CIT_UTE
    General_gnb_can_be_on_air_with_Given_Information    band=50    frame_structure=1070_GP1_A3
    ${cell_list}    Get All Cell Id
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    run keyword and continue on failure
    ...    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    duration=${300}    ue_num_each_call=${ue_num_each_call}
    E2E_SiSo_RU_lock_and_unlock_gNB    upload_tp=${False}    upload_duration=${False}

[1]CB008194_CD_11_General_SiSo_Online_Cell_addition_deletion_50M+50M
    [Tags]    1S-2CC-8D-4U    CIT_TRUNK    SBTS00    CIT_UTE
    General_gnb_can_be_on_air_with_Given_Information    band=50    frame_structure=1070_GP1_A3
    Selenium Login And Disable Screen Lock
    Prepare for delete NRPGRP
    Online delete NRPGRP
    General_SiSo_Online_Cell_addition_deletion
    [Teardown]  run keywords    SISO Coam Test Teardown    perform_case_scf=${True}    AND
    ...    Selenium Logout And Close Browser

[1]CB008194_BA_08_General_SiSo_DL_Test_Model_Verification
    [Tags]    CIT_TRUNK    SBTS00    CIT_UTE    RF50
    Modify Params before Test Mode
    ${test_model_list}    create list    NR-FR1-TM1.1    NR-FR1-TM1.2    NR-FR1-TM2    NR-FR1-TM2a
    ...    NR-FR1-TM3.1    NR-FR1-TM3.1a    NR-FR1-TM3.2    NR-FR1-TM3.3
    General_SiSo_DL_Test_Model_Verification    test_model_list=${test_model_list}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB008194_BA_17_General_SiSo_UL_Test_Model_Verification
    [Tags]    CIT_TRUNK    SBTS00    CIT_UTE
    Modify Params before Test Mode
    ${frc_index_list}    create list     G-FR1-A1-2
    General_SiSo_UL_Test_Model_Verification    frc_index_list=${frc_index_list}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

# CRT
[1]CB008194_AA_08_General_SiSo_RF_alarms_with_recovery
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${fault_list}    Create List    1901
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_alarms_with_recovery

[1]CB008194_AA_10_General_SiSo_NR-ARFCN_check
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${fault_list}    Create List    1900
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_NR-ARFCN_check

[1]CB008194_AA_21_5GC000560_eCPRI_PTP_Failure
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${fault_list}    Create List    16    4298    1899
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    5GC000560_eLLF_PTP_Failure

[1]CB008194_AA_23_General_SiSo_LED_states_management_basic
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_LED_states_management_basic

[1]CB008194_BA_02_General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    General_SiSo_RF_module_reset_from_GUI    with_call=${True}

[1]CB008194_BA_05_General_SiSo_BTS_startup_with_delayed_RF_link_setup
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${fault_list}    Create List    10    4589    4590
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_BTS_startup_with_RF_delayed_startup

[1]CB008194_CA_05_Remote_diagnostics_for_Ecpri_radios
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call

[1]CB008194_CB_09_different_frame_structeres_configuraiton_with_gNB_timing_shifter
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    Site General Modify via Webem on gNB    timing_shifter=ON
    run keyword and continue on failure    General_SiSo_Peak_with_Given_Information    band=20
    ...    frame_structure=1116_0ms_GP2_B7
    run keyword and continue on failure    General_SiSo_Peak_with_Given_Information    band=20
    ...    frame_structure=1116_3ms_GP1_A5
    run keyword and continue on failure    General_SiSo_Peak_with_Given_Information    band=20
    ...    frame_structure=1070_GP1_A3
     run keyword and continue on failure    General_SiSo_Peak_with_Given_Information    band=20
    ...    frame_structure=1208_GP1_A1
    Site General Modify via Webem on gNB    timing_shifter=OFF

[1]CB008194_CD_06_Enabling_microDTXAdvanced_on_Galvatron_cMAAr6.2_32T32R_Radio
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    General_Enabling_microDTXAdvanced_on_Galvatron_cMAAr62_32T32R_Radio

[1]CB008194_CD_RRM_15_Udtx_function_activation
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    General_Power_Consumption_and_Power_Saving_percentage_measured_in_Idle_Load

[1]CB008194_CB_04_eCPRI_L3_Call_with_Configurable_1208_Structure
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${prach_index_list}    create list    100  101  149  159  191  192
    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
    ...    frame_structure=1208_GP1_A1
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

#[1]CB008194_CB_03_eCPRI_L3_Call_with_Configurable_1070_Structure
#    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#    ${prach_index_list}    create list    2  4  6  17  88  104  152  161  197
#    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
#    ...    frame_structure=1070_GP1_A3
#
#[1]CB008194_CB_02_eCPRI_L3_Call_with_Configurable_1116_3ms_Structure
#    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#    ${prach_index_list}    create list    3  5  7  12  87  89  93  94  98  145  146  147  148  151  157  160  162  189
#    ...  190  196  201  202  203  205
#    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
#    ...    frame_structure=1116_3ms_GP1_A5

[1]CB008194_CB_01_eCPRI_L3_Call_with_Configurable_1116_0ms_Structure
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE    RF50
    ${prach_index_list}    create list    9  14  90  92  96  97  102  150  156  158  194  195  198  206
    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
    ...    frame_structure=1116_0ms_GP2_A7
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB008194_CA_12_General_SiSo_custom_beam_set_realization_to_gNB
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
        [Documentation]
    ...    *****************
    ...    Feature Owner: Fang Yi
    ...    Add FID7529 into alarm watchdog whitelist,please refer to https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10251
    ${fault_list}    Create List    7529
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_5GC001866_K_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical
    ...    BSR_package=BSR_AQQF_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    General_SiSo_5GC001866_K_Deactivate_Custome_BSR_WebEM_NSA_Classical
    ...    BSR_package=BSR_AQQF_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    [teardown]  run keywords    run keyword if test failed     Commissioning SCF And Check On Air
    ...    scf_path=${Case_SCF_Path}    AND    SISO Coam Test Teardown

[1]CB008194_CD_07_KPI_51_SiSo_Manual_RU_reset_downtime
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE    RF50
    KPI_51_SiSo_Manual_RU_reset_downtime    ru_reset_startup_duration=380

[1]CB008194_CD_RRM_18_RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled
    [Tags]    1S-2CC-8D-4U    CRT_TRUNK    SBTS00    CRT_UTE
    General_RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled

*** Keywords ***
Modify Params before Test Mode
        [Documentation]
    ...    *****************
    ...    Feature Owner: Fang Yi
    ...    Annotation: Activate large baseband resource pooling FR1 TDD,please refer to https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10518
    ...  Modify 'Activate TDD CSI-IM rate matching' to false,please refer to https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10580
    log to console    \nModify Params before Test Mode
    selenium login and disable screen lock
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate large baseband resource pooling FR1 TDD
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate enhanced algorithm of baseband resource pooling FR1 TDD
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate baseband resource pooling FR1 TDD enhancements
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate baseband resource pooling FR1 TDD extension
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate baseband resource pooling FR1 TDD
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate large baseband resource pooling FR1 TDD
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate enhanced algorithm of baseband resource pooling FR1 TDD
    # ...    new_value=false
    ${cell_list}    get all cell id
    FOR    ${cell_id}    IN    @{cell_list}
        ${dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        Modify Parameter if Need Modify    dist_name=${dist_name}
        ...    filter_param=Downlink MIMO Mode
        ...    new_value=4x4 or 4x2 Closed Loop Spatial Multiplexing
        Delete Parameter if Need Delete    dist_name=${dist_name}
        ...    filter_param=Number of CSI-RS resource period in one CSI report period
        Delete Parameter if Need Delete    dist_name=${dist_name}
        ...    filter_param=CSI-RS power
        Delete Parameter if Need Delete    dist_name=${dist_name}
        ...    filter_param=Maximum CSI-RS number
        Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate TDD CSI-IM rate matching
        ...    new_value=false
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}    timeout=${300}
    [Teardown]  selenium logout and close browser
