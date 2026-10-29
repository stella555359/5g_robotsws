*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         200 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/RF/General_SiSo_Beamforming_calibration.robot
Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    ${BASIC_PATH_5G}/BTS/Capture_snapshot_during_tracffic.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Modify_Prach_Online_with_Frame_Structure.robot
Resource    ${BASIC_PATH_5G}/RF/Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_based_on_CNI-51714.robot

Documentation
...    Author:tingting zhong
...    contact:tingting.zhong@nokia-sbell.com
...    squad group:SG_04
...    Feature 5GC002433 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQQ_ENB
...   PY310    HAZ4_T04

*** Test Cases ***
# TL593 1S-2CC-8D-4U
[1]5GC002433_AC_02_AQQY_General_SiSo_RU_module_reset_from_GUI
    [Tags]    CIT_22R4    CIT_TRUNK
    General_SiSo_RF_module_reset_from_GUI    with_call=${True}

[1]5GC002433_AC_01_AQQY_General_SiSo_RF_module_power_reset
    [Tags]    CIT_22R4    CRT_22R3    CDRT_22R3    CIT_TRUNK
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_module_power_reset    with_call=${True}

[1]5GC002433_AC_11_AQQY_General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification
    [Tags]    CIT_22R4    CRT_22R3    CDRT_22R3    CIT_TRUNK
    General_SiSo_Beamforming_calibration    check_time=30

# CB010410 1S-2CC-8D-4U (100Mhz/160W and 100Mhz/80W)
[1]5GC002433_BA_04_AQQY_cell_block_unblock_with_Dual_carrier_100+100Mhz
    [Tags]    CIT_22R4    CRT_22R3    CDRT_22R3    CIT_TRUNK    RF50    HAZ4_T04
    [Setup]    SISO Coam Test Setup    fail_with_alarms=${True}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_gnb_can_be_on_air_with_Given_Information    band=100    frame_structure=1116_0ms_GP1_A8    prach_index=198
    ...    beamset=2 beams    basicBeamSet=beamSet_2
    ${cell_list}    Get All Cell Id
    ${stream}    get stream from version    version=${Active_SW_version}    convert_to_trunk=${False}
    Run Keyword If   '${stream}'>='SBTS23R4'    update pMAX Via Webem    cell_id_list=${cell_list}
    Wait Until Keyword Succeeds    10 min    30 sec    Check all cells info should be onair
    # Annotate the preceding L3 call to save case execution time
    # ${ue_num_each_call}    Get Tput ue Number    given_num=2
    # run keyword and continue on failure
    # ...    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}
    # ...    duration=${300}  ue_num_each_call=${ue_num_each_call}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_peak=${True}    upload_tp=${False}    upload_duration=${False}

[1]5GC002433_AB_03_AQQY_General_SiSo_NR-ARFCN_check
    [Tags]    CIT_22R4    CRT_22R3    CDRT_22R3    CIT_TRUNK
    ${fault_list}    Create List    1900
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_NR-ARFCN_check

[1]5GC002433_BAA_02_AQQY_cell_block_unblock_with_Dual_carrier_50+100Mhz
    [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_gnb_can_be_on_air_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ${cell_list}    Get All Cell Id
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    run keyword and continue on failure
    ...    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}
    ...    duration=${300}  ue_num_each_call=${ue_num_each_call}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_peak=${True}    upload_tp=${False}    upload_duration=${False}

[1]5GC002433_BY_02_AQQY_RU_lock_unlock_with_Dual_carrier_30+90Mhz
    [Tags]    CIT_22R4    CRT_22R3    CIT_TRUNK    RF50
    General_gnb_can_be_on_air_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ${cell_list}    Get All Cell Id
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    run keyword and continue on failure
    ...    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}
    ...    duration=${300}  ue_num_each_call=${ue_num_each_call}
    E2E_SiSo_RU_lock_and_unlock_gNB    with_peak=${True}    upload_tp=${False}    upload_duration=${False}

[1]5GC002433_BU_01_AQQY_L3call_with_Dual_carrier_20+40Mhz
    [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ...    ue_num_each_call=${ue_num_each_call}

[1]5GC002433_BP_05_different_frame_structeres_configuraiton_with_gNB_timing_shifter
    [Tags]    CRT_TRUNK    RF50    1S-1CC-8D-4U_CHT
    run keyword and continue on failure    Peak Case Check Timing Offset    frame_structure=1208_GP1_A1    time=1
    run keyword and continue on failure    Peak Case Check Timing Offset    frame_structure=1116_0ms_GP2_A7    time=2

[1]5GC002433_BA_02_AQQY_L3call_IWK
    [Tags]    1S-2CC-8D-4U_IWK    CRT_TRUNK
    ${cell_list}    Get All Cell Id
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${False}
    ...    duration=${300}  loop_times=${1}  ue_num_each_call=${ue_num_each_call}

[1]5GC002433_BW_01_AQQY_L3call_with_Dual_carrier_20+100Mhz
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ...    ue_num_each_call=${ue_num_each_call}

[1]5GC002433_BZ_01_AQQY_L3call_with_Dual_carrier_40+80Mhz
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ...    ue_num_each_call=${ue_num_each_call}

[1]5GC002433_BAB_01_AQQY_L3call_with_Dual_carrier_60+90Mhz
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ...    ue_num_each_call=${ue_num_each_call}

[1]5GC002433_BAC_01_AQQY_L3call_with_Dual_carrier_70+80Mhz
    # 2433 parity feature 6941
    General_gnb_can_be_on_air_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ${release}    Get program version based on gNB active version
    ${cell_list}    get all cell id
    run keyword if    '${release}'=='SBTS22R2'    Verify cableLenghtRangeMin in Peak Case    cell_list=${cell_list}
    ...    ELSE    Get UE From Init File and Make call
    ...    cell_list=${cell_list}  with_peak=${True}  ue_num_each_call=2

[1]5GC002433_BA_06_AQQY_Radio_memory_verification_by_capturing_snapshot_during_L3call
    Capture_snapshot_during_tracffic

[1]5GC002433_BP_02_AQQY_eCPRI_L3_Call_with_Configurable_1116_3ms_Structure
    [Timeout]  12h
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    ${prach_index_list}    create list    3  5  7  12  87  89  93  94  98  145  146  147  148  151  157  160  162  189
    ...  190  196  201  202  203  205
    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}    band=100
    ...    frame_structure=1116_3ms_GP1_A5    ue_num_each_call=${ue_num_each_call}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]5GC002433_BP_04_AQQY_eCPRI_L3_Call_with_Configurable_1070_Structure
    [Timeout]  6h
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    ${prach_index_list}    create list    2  4  6  17  88  104  152  161  197
    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}    band=100
    ...    frame_structure=1070_GP1_A3    ue_num_each_call=${ue_num_each_call}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]5GC002433_AQQY_Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_based_on_CNI-51714
    [Tags]    RF50    1S-1CC-8D-4U_CHT
    ${fault_list}    Create List    1907    1911    1920
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_based_on_CNI-51714    made_type=made2

#[1]5GC002433_AB_05_AQQY_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_LA
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#[1]5GC002433_BQ_01_AQQY_eCPRI_TDD_Call_setup_with_PRACH_A2
#    run keyword and continue on failure   General_SiSo_Peak_with_Given_Information
#    ...    band=100    frame_structure=1116_0ms_GP2_A7    prach_index=97
#    run keyword and continue on failure    General_SiSo_Peak_with_Given_Information
#    ...    band=100    frame_structure=1116_0ms_GP2_A7    prach_index=96
#
#[1]5GC002433_BR_01_AQQY_eCPRI_TDD_Call_setup_with_PRACH_C2
#    run keyword and continue on failure   General_SiSo_Peak_with_Given_Information
#    ...    band=100    frame_structure=1116_0ms_GP2_A7    prach_index=194
#    run keyword and continue on failure    General_SiSo_Peak_with_Given_Information
#    ...    band=100    frame_structure=1116_0ms_GP2_A7    prach_index=206
#
#[1]5GC002433_BS_01_AQQY_eCPRI_TDD_Call_setup_with_PRACH_PRACH_0
#    run keyword and continue on failure   General_SiSo_Peak_with_Given_Information
#    ...    band=100    frame_structure=1116_0ms_GP1_A8    prach_index=9
#    run keyword and continue on failure    General_SiSo_Peak_with_Given_Information
#    ...    band=100    frame_structure=1116_0ms_GP1_A8    prach_index=14
#
#[1]5GC002433_AC_10_AQQY_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#
#[1]5GC002433_AA_05_AQQY_General_SiSo_RF_module_IP_address_allocation
#    General_SiSo_RF_module_IP_adress_allocation
#
#[1]5GC002433_AC_09_AQQY_5GC000560_eCPRI_sync_generic_startup_at_RU
#    5GC000560_eLLF_sync_generic_startup_at_RU
#
#[1]5GC002433_AG_03_AQQY_General_SiSo_RF_alarms_with_recovery
#    General_SiSo_RF_alarms_with_recovery
#
#[1]5GC002433_AG_04_AQQY_General_SiSo_RF_alarms_without_recovery
#    General_SiSo_RF_alarms_without_recovery
#
#[1][1.0] 5GC002433_AA_06_AQQY_General_SiSo_Commissioning_BTS_Template_cell_setup_2x2_no_BF
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#[1]5GC002433_AA_01_AQQY_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#
#[1]5GC002433_AA_03_AQQY_General_SiSo_SOAP_RP1_verification
#    General_SiSo_SOAP_RP1_verification
#
#[1]5GC002433_AC_08_AQQY_5GC000561_eCPRI_sync_generic_startup_at_RAU
#    5GC000561_eCPRI_sync_generic_startup_at_RAU
#
#[1]5GC002433_AB_04_AQQY_General_SiSo_E2E_system_setup_with_data_transfer_conducted_MCS0_without_BF
#    General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1116_0ms_GP2_A7
#
#[1]5GC002433_EQ_01_AQQY_Snapshot_Minor_level_showing_reason_for_a_failure_after_radio_has_been_had_a_power_break
#    Snapshot_Minor_level_showing_reason_for_a_failure_after_radio_has_been_had_a_power_break
#
#[1]5GC002433_EQ_03_AQQY_Snapshot_includes_RU_log_related_to_critical_failures_raise_any_time_early
#    Snapshot_includes_RU_log_related_to_critical_failures_raise_any_time_early
#
#[1]5GC002433_EP_02_AQQY_5GC001991_01_05_Fault_4598_EFaultId_TiltOffsetOutOfRangeAl_raise
#    General_SiSo_Fault_4598_EFaultId_TiltOffsetOutOfRangeAl_raise    frame_structure=1208_GP1_A1    prach_index=98
#    ...    basicBeamSet=beamSet_2    numberOfTransmittedSsBlocks=2 beams
#
#[1]5GC002433_BP_01_AQQY_eCPRI_L3_Call_with_Configurable_1116_0ms_Structure
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_0ms_GP2_A7
#
#
#[1]5GC002433_BP_03_AQQY_eCPRI_L3_Call_with_Configurable_1208_Structure
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#[1]5GC002433_AC_04_AQQY_General_SiSo_BTS_reset_with_RF_power_reset
#    General_SiSo_BTS_reset_with_RF_power_reset
#
#[1]5GC002433_AC_13_AQQY_call_with_data_transfer_2x2_with_BFC
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#[1]5GC002433_AE_08_AQQY_General_SiSo_BTS_startup_with_delayed_RF_link_setup
#    General_SiSo_BTS_startup_with_RF_delayed_startup
#
#[1]5GC002433_AE_01_AQQY_basic_L3_call_with_4x4MIMO
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#[1]5GC002433_AC_12_AQQY_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2X2_BFC
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#[1]5GC002433_AF_08_AQQY_General_SiSo_E2E_system_setup_with_data_transfer_OTA
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#[1]5GC002433_AF_01_AQQY_basic_L3_call_with_4x4_beamforming
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#[1]5GC002433_BB_03_AQQY_L3call_with_chbw_20Mhz_SA
#    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1208_GP1_A1
#
#[1]5GC002433_BG_01_AQQY_L3call_with_chbw_40Mhz
#    General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1208_GP1_A1
#
#[1]5GC002433_BH_01_AQQY_L3call_with_chbw_50Mhz
#    General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1208_GP1_A1
#
#[1]5GC002433_BI_01_AQQY_L3call_with_chbw_60Mhz
#    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1208_GP1_A1
#
#[1]5GC002433_BD_01_AQQY_L3call_with_chbw_80Mhz
#    General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1208_GP1_A1
#
#[1]5GC002433_BK_01_AQQY_L3call_with_chbw_90Mhz
#    General_SiSo_Peak_with_Given_Information    band=90    frame_structure=1208_GP1_A1
#
#[1]5GC002433_BC_01_AQQY_L3call_with_Dual_carrier_20+20Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BL_01_AQQY_L3call_with_Dual_carrier_40+40Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BM_01_AQQY_L3call_with_Dual_carrier_50+50Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BN_01_AQQY_L3call_with_Dual_carrier_60+60Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BE_01_AQQY_L3call_with_Dual_carrier_80+80Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BA_01_AQQY_cell_setup_with_Dual_carrier_100+100Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BA_05_AQQY_L3attach_with_Dual_carrier_100+100Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BAA_01_AQQY_L3call_with_Dual_carrier_50+100Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#    ...    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BX_01_AQQY_L3call_with_Dual_carrier_30+60Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#    ...    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BY_01_AQQY_L3call_with_Dual_carrier_30+90Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#    ...    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BV_01_AQQY_L3call_with_Dual_carrier_20+70Mhz
#    ${ue_num_each_call}    Get Tput ue Number    given_num=2
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#    ...    ue_num_each_call=${ue_num_each_call}
#
#[1]5GC002433_BF_02_AQQY_cell_block_unblock_with_chbw_30Mhz
#    General_gnb_can_be_on_air_with_Given_Information    band=30    frame_structure=1208_GP1_A1
#    General_SiSo_Cell_block_and_unblock
#
#[1]5GC002433_AE_04_AQQY_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Timeout]    8h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
#
#[1]5GC002433_AE_03_AQQY_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
#    [Timeout]    8h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_RF_module_reset_from_GUI    times=${20}    pass=${19}
#    ...    with_call=${True}
#
#[1]5GC002433_AE_05_AQQY_General_SiSo_Auto_Cell_block_and_unblock_with_L3call
#    [Timeout]    8h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Cell_block_and_unblock    times=${20}    pass=${19}
#
#[1]5GC002433_AD_06_AQQY_General_SiSo_Automatic_RAT_SW_upgrade
#    General_SiSo_Auto_Automatic_RAT_SW_upgrade
#
#[1]5GC002433_FI_02_AQQY_CB006941_fault1900_report_when_RU_responses_failure_status
#    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
#
#[1]5GC002433_FI_03_AQQY_CB006941_modify_FH_delay_parameter_cableLenghtRangeMin
#    General_SiSo_modify_FH_delay_parameter_cableLenghtRangeMin
#
#[1]5GC002433_CB_01_AQQY_CB006466-5G-A_Lock_Unlock_eCPRI_reMask_RU_Support
#    E2E_SiSo_RU_lock_and_unlock_gNB      with_call=${False}
#    ${output}    Check Btsom Log file on ASIK    filter=ruSupportsExtType6    alias=ASIK Master
#    Should Contain    ${output}    ruSupportsExtType6: boolean = true
#
#[1]5GC002433_AQQY_call_with_data_transfer_2UE
#    ${cell_list}    Get All Cell Id
#    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}  duration=${300}  ue_num_each_call=${2}

# move to 6892
#[1]5GC002433_AD_09_AQQY_General_SiSo_LED_states_management_basic
#[1]5GC002433_BA_03_AQQY_General_SiSo_Online_Cell_addition_deletion

*** Keywords ***
Verify cableLenghtRangeMin in Peak Case
    [Arguments]  ${cell_list}
    Selenium Login And Disable Screen Lock
    ${dist_name}    set variable    MRBTS-${mrbtsId}/EQM-1/APEQM-1/RMOD-1
    ${filter_param}    set variable    Minimum value of range of cable length between baseband and radio
    ${get_value}    Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_param}
    run keyword if    '${get_value}'==''    run keywords    selenium_coam.set_parameter_value  dist_name=${dist_name}
    ...    filter_param=${filter_param}    new_value=1    AND
    ...    selenium_coam.validate_plan    AND
    ...    selenium_coam.activate_plan    AND
    ...    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    run keyword and continue on failure    Get UE From Init File and Make call
    ...    cell_list=${cell_list}  with_peak=${True}  ue_num_each_call=2
    run keyword if    '${get_value}'==''    run keywords    selenium_coam.delete_parameter
    ...    dist_name=${dist_name}    filter_param=${filter_param}    AND
    ...    selenium_coam.validate_plan    AND
    ...    selenium_coam.activate_plan    AND
    ...    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]    selenium logout and close browser

Peak Case Check Timing Offset
    [Arguments]  ${frame_structure}=1208_GP1_A1    ${time}=1
    ...    ${suite_name}=${SUITE NAME}    ${test_name}=${TEST NAME}
    General_gnb_can_be_on_air_with_Given_Information    band=90    frame_structure=${frame_structure}
    Selenium Login And Disable Screen Lock
    ${cell_list}    get all cell id
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=3000    sfnOffset=1
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${300}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    run keyword if    '${time}'=='1'    run keywords
    ...    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=4000    sfnOffset=-1    AND
    ...    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${300}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    [Teardown]    run keywords    NR Feature CB007597 OFF and Check    AND    selenium logout and close browser
