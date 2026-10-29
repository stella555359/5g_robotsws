*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
#Test Setup
#Test Teardown
#Test Timeout      120 minutes

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
Resource     ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource     ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource     ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
#Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008238_A/resource/CB008238_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007511_AQQL/resource/CB007511_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009333/resource/CB009333_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010823/resource/CB010823_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011159/resource/CB011159_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010766/Resource/CB010766_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008502/resource/CB008502_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012611_SG5/Resource/CB012611_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011039_SG05/resource/CB011039_common_resource.robot

Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG5/UTE_CLOUD/Resource/T666_KW.robot

Documentation
...    author: hu annie
...    contact: annie.hu@nokia-sbell.com
...    squad group: SG_05
...    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE

*** Variables ***
${change_interval}    15min
@{rdDtxCS1SizeThreshold}        0x580578=2    # default: 8. IntrodValue used to determinate
#    ... if the UEs under DTX optimization are available for scheduling [0..16]

*** Test Cases ***
#### part-1: CB009925 - 2 TCs ###
[1]CB009925-SR-A_03 RU returning from PowerSaving Mode to normal operation due to at least one carrier enabling on RU triggered by 5GC000431
    [Tags]   1S-2CC-4D-4U_SA   CRT_UTE   CRT_TRUNK   CRT_26R1   CRT_25R3
    [Setup]    SISO Coam Test Setup
    RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_disable_5GC000431
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB009925-SR-A_04 RU returning from PowerSaving Mode to normal operation due to at least one cell unlocked
    [Tags]    1S-2CC-4D-4U_SA    CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_at_least_one_cell_unlocked
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#### part-2: CB009333 - 3 TCs ###
[1]CB009333-A_01_03_drbDifferentiationEnabled_when_DRB_delay_profile_less_than_Cell_level_for_single_UE_with_single_non-GBR_on_Classical_SA
    [Tags]    1S-2CC-4D-4U_SA    CRT_UTE    CRT_TRUNK    CDRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Selenium Login And Disable Screen Lock
    add fault to the allowed fault list    faultId=${4681}
    Step 2 Online modify parameter to activate legacy feature
    Step 3 Online modify parameter to activate CB009333
    Step 4 One single-UE make L3Call and attach to Cell
    Step 5 Check CB008238 counters
    [Teardown]    Run keywords     Selenium Logout And Close Browser
    ...    AND   Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND   Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND   SISO Coam Test Teardown

[1]CB009333-B_01_02_multiCellSyncEnabled_when_dtxRoundingOffset_equal_to_0_for_multiple_UE_with_multiple_Cell_connected_the_same_PA_on_Classical_SA
    [Tags]    1S-2CC-4D-4U_SA    CRT_UTE    CRT_TRUNK    CDRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Selenium Login And Disable Screen Lock
    add fault to the allowed fault list    faultId=${4681}
    Step 2 Online modify parameter to activate legacy feature
    Step 3 Activate CB009333-B Multiple cells synchronization for both cells
    Step 4 Two UE attach to both cells and do DL traffic with low traffic tput
    [Teardown]    Run keywords     Selenium Logout And Close Browser
    ...    AND   Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND   Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND   SISO Coam Test Teardown

[1]CB009333-W_01_04_Single-UE_EnhDtxOptimizedScheduler_E2E_scheduled_ping_latency_for_TDD_FR1_5GC001208_on_Classical_SA
    [Tags]    1S-2CC-4D-4U_SA    CRT_UTE    CRT_TRUNK    CDRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_gnb_can_be_on_air_with_Given_Information    band=100   frame_structure=1208_GP1_A1   dl_ul_layer=4DL4UL
    ...    prach_index=${92}
    Selenium Login And Disable Screen Lock
    Step 1 Online modify parameter to activate legacy feature 5GC000430 CB008238
    Step 2 Online modify CB009333 on WebUI
    Step 3 Online modify Scheduled ping latency
    Step 4 UE attach and check ping latency
    [Teardown]    Run keywords     Selenium Logout And Close Browser
    ...    AND   Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND   Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND   SISO Coam Test Teardown

#### part-3: CB010823 - 1 TCs ###
[1]CB010823-SR-A_2_Run RF Diagnostic check online from WebEM
    [Tags]   CRT_UTE   CRT_TRUNK   CRT_26R1   CRT_25R3
    [Setup]    Run Keywords  AlarmWatchdog.Add allow alarms  fault_id=4681  AND  SISO Coam Test Setup
    RF Diagnostic check online from WebEM
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#### part-4: CB011159 - 3 TCs ###
[1]CB011159_SR_A_11_Verify_Tput_With_1UE_Different_Parameters_mMIMO
    [Tags]    1S-1CC-8D8U    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Verify_Tput_With_1UE_Different_Parameters_mMIMO
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB011159_SR_B_2_Verify_Tput_With_1UE_50+50_mMIMO
    [Tags]   1S-2CC-4D4U   CRT_UTE   CRT_TRUNK   CDRT_TRUNK   CRT_25R2   CDRT_25R2
    [Setup]    SISO Coam Test Setup
    Verify_Tput_With_1UE_50+50_mMIMO
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB011159_SR_D_1_Verify_CellSetup_With_NR_1cc+1cc_8D8U_split_mode_64TRX
    [Tags]    1S-2CC-4D4U   CRT_TRUNK
    [Setup]   SISO Coam Test Setup
    Configure NRCELL to 2CC Split Mode
    Verify_Tput_With_1UE_50+50_mMIMO
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#### part-5: TCs from T061 - 3 TCs ###
[1]CB010766-SR-A_18 Awake RU from deep sleep when the time window ends (AEQE)
    [Tags]    1S-2CC-4D-4U    CRT_TRUNK   CRT_26R1   CRT_25R3
    [Setup]    SISO Coam Test Setup
    Awake RU from deep sleep when the time window ends
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB006293_5G_AEQE_03_Initiate_RF_diagnostic_test_RSSI_test_withL3call
    [Tags]   CRT_UTE   CRT_TRUNK
    [Setup]   SISO Coam Test Setup
    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AEQE
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1][1.0]General_SiSo_Auto_RF_Module_Stability_Run
    [Tags]   CRT_UTE   CRT_TRUNK
    [Timeout]   180min
    [Setup]   SISO Coam Test Setup
    General_SiSo_Auto_RF_Module_Stability_Run
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#### part-6: CB012611 - 1 TC ###
[1]CB012611_5G_B_04_ABIO_reset_with_single_failed_Loki
    [Tags]    CRT_UTE    CRT_TRUNK   CRT_26R1   CRT_25R3
    [Setup]   SISO Coam Test Setup
    ABIO reset with single failed Loki  bbmod_index=${1}
    [Teardown]    SISO Coam Test Teardown

#### part-7: CB011039 - 1 TC ###
[1]CB011039-5G-H_Radio_Module_online_dignostics_test_during_fail_safe_mode
    [Tags]    CRT_UTE    CRT_TRUNK
    [Setup]   SISO Coam Test Setup
    ${fault_list}    Create List    2934    4681
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Get test RU index
    CB011039-5G-H_Radio_Module_online_dignostics_test_during_fail_safe_mode
    [Teardown]    Run keywords    run keyword and ignore error    RU exit fail safe mode
    ...    AND    Wait until keyword succeeds    10 min    30 sec   verify all cells should be onair
    ...    AND    add fault to allowed history fault list    faultId=${2934}
    ...    AND    add fault to allowed history fault list    faultId=${4681}
    ...    AND    SISO Coam Test Teardown

#### Optimized TCs
# [1]CB008502_02_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10_eCPRI
#     [Tags]     CRT_UTE    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10_eCPRI
#     [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#     ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#     ...    AND    SISO Coam Test Teardown
#
# [1]CB010823-SR-A_7_Check 4681 fault in NOK cases
#     [Tags]    CRT_UTE    CRT_25R1    CRT_25R2    CRT_25R3    CRT_TRUNK
#     [Setup]    Run Keywords  AlarmWatchdog.Add allow alarms  fault_id=4681  AND  SISO Coam Test Setup
#     Check 4681 fault in NOK cases
#     [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#     ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#     ...    AND    SISO Coam Test Teardown

# [1]CB010823-SR-A_8_Scheduled Execution of Diagnostic check from WebEM
#     [Tags]    CRT_UTE    CRT_25R1    CRT_25R2    CRT_25R3    CRT_TRUNK
#     [Setup]    Run Keywords  AlarmWatchdog.Add allow alarms  fault_id=4681  AND  SISO Coam Test Setup
#     Scheduled Execution of Diagnostic check from WebEM
#     [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#     ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#     ...    AND    SISO Coam Test Teardown

# [1]CB010823-SR-A_9_Automatic Execution of Diagnostic check from webEM with cell onAir
#     [Tags]    CRT_UTE    CRT_25R1    CRT_25R2    CRT_25R3    CRT_TRUNK
#     [Setup]    Run Keywords  AlarmWatchdog.Add allow alarms  fault_id=4681  AND  SISO Coam Test Setup
#     Automatic Execution of Diagnostic check from webEM with cell onAir
#     [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#     ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#     ...    AND    SISO Coam Test Teardown
#
#[1]CB009333-C_01_01_caSupportEnabled_only_on_Scell_for_T+T_2CC_when_sCellActivationMethod_bufferBased_on_Classical_SA
#    [Tags]     1S-2CC-4D-4U_CA_50M_50M    CRT_UTE    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE
#    [Setup]    SISO Coam Test Setup
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Step 4 DL CA UE make L3Call and attach to Pcell and check TTI
#    [Teardown]    Run keywords     Selenium Logout And Close Browser
#    ...    AND   Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND   Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#    ...    AND   SISO Coam Test Teardown
#
#[1]CB009333-D_01_01_drxSupportEnabled_when_drxOnDurationTimer_less_than_dtxMaxRetentionDelay_on_Classical_SA
#    [Tags]    1S-2CC-4D-4U_SA    CRT_UTE    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE
#    [Setup]    SISO Coam Test Setup
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Step 1 Activated legacy DRX feature where drxOnDurationTimer morethan dtxMaxRetentionDelay
#    Step 2 Online modify parameter to activate legacy feature 5GC000430 5GC000433 CB008238
#    Step 3 Online modify parameter to activate CB009333 on WebUI
#    Step 4 One UE attach and do DL traffic with low traffic tput
#    Step 5 Check TTI and PM counters
#    [Teardown]    Run keywords     Selenium Logout And Close Browser
#    ...    AND   Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND   Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#    ...    AND   SISO Coam Test Teardown
#
#[1]CB009333-E_01_01_EnhDtxOptimizedScheduler_interaction_with_SliceAwareScheduler_when_multiple_UE_with_single_non-GBR_on_Classical_SA
#    [Tags]    CRT_UTE    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    1S-2CC-4D-4U_9333-E
#    [Setup]    SISO Coam Test Setup
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Step 1 Activated legacy Slice Aware Scheduler feature
#    Step 2 Online modify parameter to activate legacy feature 5GC000430 5GC000433
#    Step 3 Online modify parameter to activate CB008238 and CB009333 on WebUI
#    Step 4 Two UEs attach and do DL traffic with low traffic tput
#    Step 5 CB009333-E Check TTI and PM counters
#    [Teardown]    Run keywords     Selenium Logout And Close Browser
#    ...    AND   Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND   Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#    ...    AND   SISO Coam Test Teardown
#
#[1]CB009333-F_01_01_rlcStatusPduSupportEnabled_for_DL_RLC_ACK_NACK_status_PDU_for_UL_packet_when_single_UE_with_single_non-GBR_on_Classical_SA
#    [Tags]    1S-2CC-4D-4U_SA    CRT_UTE    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE
#    [Setup]    SISO Coam Test Setup
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Step 1 Online modify parameter to activate legacy feature CB008238
#    Step 2 Online modify CB009333 rlcStatusPduSupportEnabled on WebUI
#    Step 3 UE attach and do UL traffic
#    # Step 4 Check highestClassPriority17 not in TTI log
#    Step 5 UE attach and do DL traffic
#    # Step 6 Check highestClassPriority17 in TTI log
#    [Teardown]    Run keywords     Selenium Logout And Close Browser
#    ...    AND   Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND   Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#    ...    AND   SISO Coam Test Teardown
#
#[1]CB009925-SR-A_01 RU entering deep sleep mode during low traffic periods with 5GC000431 enabled
#    [Tags]    1S-2CC-4D-4U_SA    CRT_UTE    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE
#    [Setup]    SISO Coam Test Setup
#    RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#    ...    AND    SISO Coam Test Teardown
#
#[1]CB009925-SR-A_02 RU entering deep sleep mode after all cells locked
#    [Tags]    1S-2CC-4D-4U_SA    CRT_UTE    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE
#    [Setup]    SISO Coam Test Setup
#    RU_entering_deep_sleep_mode_after_all_cells_locked
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#    ...    AND    SISO Coam Test Teardown
#
#[1]CB008238-5G-A_02_01_Single-UE_small_packet_timer_lower_than_dtxMaxRetentionDelay_on_SA
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE    CDRT_UTE    1S-2CC-4D-4U_SA
#    [Setup]    SISO Coam Test Setup
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Modify actDtxOptimizedScheduler Parameter    false
#    Start L3Call and DL small packet    throughput=30M
#    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#    Sleep    ${log_capture_time}
#    ${tti_trace}=    Stop TTI Traces in Streaming mode
#    set test variable    ${tti_trace}
#    Stop L3Call and DL Traffic
#    Check highestClassPriority and numOfPrb when CB008238 off for SA
#
#    Modify actDtxOptimizedScheduler Parameter    true
#    Start L3Call and DL small packet    throughput=30M
#    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#    Sleep    ${log_capture_time}
#    ${tti_trace}=    Stop TTI Traces in Streaming mode
#    Stop L3Call and DL Traffic
#    Check highestClassPriority and numOfPrb when CB008238 on for SA
#    #Delete temp csv tti file on gnb
#    [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
#
#[1]CB008238-5G-A_03_02_Single-UE_small_packet_timer_higher_than_dtxMaxRetentionDelay_on_NSA
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE   1S-2CC-4D-4U_SA
#    [Setup]    SISO Coam Test Setup
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Modify actDtxOptimizedScheduler Parameter    false
#    Start L3Call and DL small packet    throughput=10K
#    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#    Sleep    ${log_capture_time}
#    ${tti_trace}=    Stop TTI Traces in Streaming mode
#    ...  tti_trace_path=${TS_CASE_LOG_PATH}
#    set test variable    ${tti_trace}
#    Stop L3Call and DL Traffic
#    Check highestClassPriority and numOfPrb when CB008238 off for NSA
#
#    Modify actDtxOptimizedScheduler Parameter    true
#    Start L3Call and DL small packet    throughput=10K
#    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#    Sleep    ${log_capture_time}
#    ${tti_trace}=    Stop TTI Traces in Streaming mode
#    ...  tti_trace_path=${TS_CASE_LOG_PATH}
#    Stop L3Call and DL Traffic
#    Check highestClassPriority and numOfPrb when CB008238 on for NSA
#    #Delete temp csv tti file on gnb
#    [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
#
#[1]CB008238-5G-B_01_02_Multi-UE_Micro-DTX_optimized_scheduler_interaction_with_non-GBR_traffic
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE    CDRT_UTE    1S-2CC-4D-4U_SA
#    [Setup]    SISO Coam Test Setup
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Modify actDtxOptimizedScheduler Parameter    true
#    Start L3Call and DL small packet    throughput=30M    ue_index=0
#    Start L3Call and DL small packet    throughput=30M    ue_index=1
#    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#    Sleep    ${log_capture_time}
#    ${tti_trace}=    Stop TTI Traces in Streaming mode
#    ...  tti_trace_path=${TS_CASE_LOG_PATH}
#    Stop L3Call and DL Traffic    ue_index=0
#    Stop L3Call and DL Traffic    ue_index=1
#    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
#    ...   options=-d dl
#    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
#    # Delete temp csv tti file on gnb
#    ${tti_ana}   CB008238_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
#    @{rntis}=   Call Method    ${tti_ana}    check_cs1size_cs2size_in_event
#    Should Not Be Empty    ${rntis}
#    # ${check1}=   Call Method    ${tti_ana}    check_highestClassPriority17_for_mutiUE    rnti_list=${rntis}
#    ${check2}=   Call Method    ${tti_ana}    check_dlDtxOptimData_for_mutiUE    rnti_list=${rntis}
#    ${check3}=   Call Method    ${tti_ana}    check_dlFdSchedData_for_mutiUE    rnti_list=${rntis}
#    Should be True   ${check2} and ${check3}
#    #[Teardown]    Run keywords     Selenium Logout And Close Browser
#    [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
#
#
#[1]CB008238-5G-C_01_08_Multi-UE_Micro-DTX_optimized_scheduler_when_CS1_list_size_larger_than_rdDtxCS1SizeThreshold
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE   1S-2CC-4D-4U_SA
#    [Setup]    SISO Coam Test Setup
#    CB008238_Common_KW.Update SW Config file on System Module    param_list=${rdDtxCS1SizeThreshold}
#    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
#    sleep    120s
#    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
#    ${radMasterValue}    CB008238_Common_KW.Get AaShell SW Config    rad_param=0x580578
#    CB008238_Common_KW.Update SW Config file on System Module    del_param_list=${rdDtxCS1SizeThreshold}
##    Log to console    rdDtxCS1SizeThreshold[0x580578] old value: ${radMasterValue}
##    Set SW Config on Common Module    rad_param=0x580578    rad_param_value=2
##    ${radMasterValue}    Get AaShell SW Config
##    Log to console    rdDtxCS1SizeThreshold[0x580578] change to: ${radMasterValue}
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Modify actDtxOptimizedScheduler Parameter    actDtxOptimizedScheduler=true    dtxPrbThreshold=80
#    Start L3Call and DL small packet    throughput=30M    ue_index=0
#    Start L3Call and DL small packet    throughput=30M    ue_index=1
#    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#    Sleep    ${log_capture_time}
#    ${tti_trace}=    Stop TTI Traces in Streaming mode
#    ...  tti_trace_path=${TS_CASE_LOG_PATH}
#    Stop L3Call and DL Traffic    ue_index=0
#    Stop L3Call and DL Traffic    ue_index=1
#    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
#    ...   options=-d dl
#    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
#    #Delete temp csv tti file on gnb
#    ${tti_ana}   CB008238_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
#    ${check}=   Call Method    ${tti_ana}    check_dlDtxOptimEvent_in_dlDtxOptimData    dlDtxOptimEvent_value=CS1SIZETHRES
#    Should be True   ${check}
#    [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
#
#[1]CB008238-5G-D_01_01_Multi-UE_Micro-DTX_optimized_scheduler_dynamic_enabled_and_disabled_based_on_the_number_of_UEs_in_the_CS1_list
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE    CDRT_UTE    1S-2CC-4D-4U_SA
#    [Setup]    SISO Coam Test Setup
#    @{modify_flags}  create list    0x580574=0x3   0x580575=0x3   0x580576=0x64   0x580578=0x8
#    CB008238_Common_KW.Update SW Config file on System Module    param_list=${modify_flags}
#    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
#    sleep    120s
#    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
#    ${radMasterValue}    CB008238_Common_KW.Get AaShell SW Config
#    Log to console    SW config: ${radMasterValue}
#    @{modify_flags}  create list    0x580574   0x580575   0x580576   0x580578
#    CB008238_Common_KW.Update SW Config file on System Module    del_param_list=${modify_flags}
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Modify actDtxOptimizedScheduler Parameter    actDtxOptimizedScheduler=true    dtxPrbThreshold=80
#    Start L3Call and DL small packet    throughput=30M    ue_index=0
#    Start L3Call and DL small packet    throughput=30M    ue_index=1
#    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#    #Sleep    ${log_capture_time}
#    Stop L3Call and DL Traffic    ue_index=1
#    ${tti_trace}=    Stop TTI Traces in Streaming mode
#    ...  tti_trace_path=${TS_CASE_LOG_PATH}
#    Stop L3Call and DL Traffic    ue_index=0
#    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
#    ...   options=-d dl
#    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
#    #Delete temp csv tti file on gnb
#    ${tti_ana}   CB008238_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
#    ${check1}=   Call Method    ${tti_ana}    check_DtxCellNbUeCs1ThresholdHigh
#    ${check2}=   Call Method    ${tti_ana}    check_DtxCellNbUeCs1ThresholdLow
#    Should be True   ${check1} and ${check2}
#    [Teardown]    Run keywords     Selenium Logout And Close Browser    AND
#    ...    SISO Coam Test Teardown
#
#[1]CB008238-5G-E_02_01_Micro-DTX_optimized_scheduler_PM_counter_update_M55308C33000_ACC_UE_MICRO_DTX_OPTIMIZED
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE    CDRT_UTE    1S-2CC-4D-4U_SA
#    [Setup]    SISO Coam Test Setup
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Modify actDtxOptimizedScheduler Parameter    true
#    Modify miNrCellUtilization Parameter    ${change_interval}
#    Start L3Call and DL small packet    throughput=1M
#    Sleep    ${log_capture_time}
#    Stop L3Call and DL Traffic
#    sleep    11min
#    connect to common unit master
#    #${M55308C33000}    Get PM Counter via Webem    counter_id=M55308C33000    interval=${change_interval}    counter_type=BTS
#    ${M55308C33000}    Wait Until Keyword Succeeds    3x    30s    Get PM Counter via Webem    counter_id=M55308C33000
#    ...    interval=${change_interval}    counter_type=BTS
#    ${M55308C33000_value}    convert to integer     ${M55308C33000}
#    #${M55308C33001}    Get PM Counter via Webem    counter_id=M55308C33001    interval=${change_interval}    counter_type=BTS
#    ${M55308C33001}    Wait Until Keyword Succeeds    3x    30s    Get PM Counter via Webem    counter_id=M55308C33001
#    ...    interval=${change_interval}    counter_type=BTS
#    ${M55308C33001_value}    convert to integer     ${M55308C33001}
#    Should Be True    ${M55308C33000_value} >0
#    Should Be True    ${M55308C33001_value} >0
#    [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
#
#[1]CB008238-5G-W_01_01_Single-UE_Micro-DTX_optimized_scheduler_Classical_E2E_unscheduled_ping_latency_for_TDD_FR1_5GC001208
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE    1S-2CC-4D-4U_SA
#    [Setup]    SISO Coam Test Setup
#    General_gnb_can_be_on_air_with_Given_Information    band=100   frame_structure=1208_GP1_A1   dl_ul_layer=4DL4UL
#    ...    prach_index=${92}
#    Selenium Login And Disable Screen Lock
#    add fault to the allowed fault list    faultId=${4681}
#    Modify actProactUlScheduling Parameter    actProactUlScheduling=false    ulSchedTimeInterval=40    ulProGrantTimer=3000
#    Modify actCDrx Parameter    actCDrx=false    drxLongCycle=160ms    drxOnDurationTimer=10ms    drxInactivityTimer=80ms
#    Modify srPeriodicity Parameter    slots80
#    Modify csiReportPeriodicity Parameter    slots320
#    Modify pucchModeSelect Parameter    longPucch
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}
#    Connect to EPC APP    ue_index=${0}
#    ${output}    Start Ping    ue_ip=${UE_IP}    count=10   packet_size=32
#    Check Ping Latency    output=${output}    latency_target=${41.1}
#    ${output}    Start Ping    ue_ip=${UE_IP}    count=10    packet_size=1350
#    Check Ping Latency    output=${output}    latency_target=${45}
#    csn.Disconnect    connection=EPCAPP
#    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}
#    [Teardown]    Run keywords     Selenium Logout And Close Browser
#    ...    AND   SISO Coam Test Teardown
#
#[1]CB006293_5G_AEQE_09_Initiate_RF_Statistics_diagnostic_test_withL3call
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]   SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call_AEQE
#    ...   min_temperature=40   max_temperature=100   rf_port_id=0
