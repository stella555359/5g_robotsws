*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB009333


Library      taf.ue
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/test_specific_keywords_9333.py
Library      ../../feature_CB008661/A/resources/test_specific_keywords.py   WITH NAME    keywords_8661_A
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod  WITH NAME  TcpdumpSmod
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2      WITH NAME    L1L2
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/test_specific_keywords_9333.py

*** Variables ***
${DL_TPUT_C3_LOW}=                       2Mbits/sec
${DL_TPUT_C3_INCREASING_START}=          100   # 180
${DL_TPUT_C3_INCREASING_END}=            120   # 220
${DL_TPUT_C6_HIGH}=                      100Mbits/sec     #200
${DL_TPUT_STEP}=                         30     # 20
${PACING_TIMER}=                         9000

${DL_TPUT_B_LOW}=                        2Mbits/sec
${DL_TPUT_D_F_LOW}=                      2Mbits/sec
${TTI_COLLECTION_TIME_LOW_TRAFFIC}=      30s
${SA_UE_CAPS_C_D}=                       REAL_UE_SA
${SA_UE_CAPS_B}=                         SA_VONR
${SA_UE_CAPS_F}=                         REAL_UE_SA
${NSA_UE_CAPS_F_W}=                      REAL_UE_NSA
${SA_UE_CAPS_CNI}=                       SA_UE
@{CELLS_USED_IN_C}=                      2   5   6
@{CELLS_TO_LOCK_IN_C}=                   0   1   3   4   7
@{CELLS_USED_IN_D_F1}=                   1
@{CELLS_USED_IN_F2_W}=                   18
@{CELLS_USED_IN_G6}=                     1
@{CELLS_TO_LOCK_IN_D_F1}=                2   3  4   5   6    7    8    9
@{CELLS_TO_LOCK_IN_F2_W}=                1   5    6    7    8    9
...                                      10   11   12   13   15   16   17   19
@{CELLS_TO_LOCK_IN_G6}=                  2    10
@{CELLS_TO_LOCK_IN_CNI}=                 2    10
${PM_INTERVAL_9333}=                     5
${UE_SERIAL_NUMBER}=                     ${tl.ues[${UE_IDX}].serial_number}
${PING_COUNT}=                           100
${PACKET_SIZE_HIGH}=                     1350
${PACKET_SIZE_LOW}=                      32
${UE_IDX}=                               0
${mnc}                                   260
${PING_DELAY_THRESHOLD_LOW_SCHEDULING_DEACTIVATED}=                 66
${PING_DELAY_THRESHOLD_HIGH_SCHEDULING_DEACTIVATED}=                70
${PING_DELAY_THRESHOLD_LOW_SCHEDULING_ACTIVATED_9333_OFF}=          26
${PING_DELAY_THRESHOLD_HIGH_SCHEDULING_ACTIVATED_9333_OFF}=         31
${PING_DELAY_THRESHOLD_LOW_SCHEDULING_ACTIVATED_9333_ON}=           24
${PING_DELAY_THRESHOLD_HIGH_SCHEDULING_ACTIVATED_9333_ON}=          29
#Commercial UEs will have around X-Y ms higher latency depending of UE vendor/type and RRU type
#Target values (66, 70, 24, 27) are with best performing UEs (typically UE simulators like Prisma and Viavi)


*** Keywords ***
CB009333_B_6_Multi_UE_interaction_with_micro_DTX_optimized_scheduling_enabled_on_Multiple_TDD_cell_on_Same_PA_SA_only
    [Documentation]   This Test Case describes expected Nokia gNB behavior and micro DTX optimized scheduling enabled
     ...              on multiple cells in TDD SA configuration.
     ${pre_change_scf}           test_specific_keywords_9333.Backup SCF
     ${two_cells_scf}            Resolve Two Cells SCF Path
     SCF Commissioning           ${two_cells_scf}
     TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
     Require UE   UE_1   capabilities=${SA_UE_CAPS_B}
     Require UE   UE_2   capabilities=${SA_UE_CAPS_B}
     Attach UEs To Separate Cells
     ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
     ${rntis}=   find_exactly_x_attached_rntis    ${sctp_logs}   2
     ${tti_file_path_low}=   Collect TTI from low traffic for both UEs   ${DL_TPUT_B_LOW}
     Check Optimized DTX For RNTI    ${tti_file_path_low}     ${rntis[0]}
     Check Optimized DTX For RNTI    ${tti_file_path_low}     ${rntis[1]}
     Check Multi Cell Sync Slot In dldtxoptimevent    ${tti_file_path_low}
     [Teardown]   TC_teardown_B    ${pre_change_scf}


CB009333_C_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_SCell_FDD_TDD_SA_Buffer_based_SCell_activation_method_3CC
    [Documentation]   This Test Case describes expected Nokia gNB behaviour with FDD-TDD
     ...              interaction (with buffer based SCell activation method) and micro DTX optimized scheduling
     ...              enabled on SCell in FDD-TDD SA configuration.
    ${pre_change_scf}           test_specific_keywords_9333.Backup SCF
    Check Preconditions C3    ${CELLS_USED_IN_C}
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_C}
    initialise attenuator
    Require UE   UE_1   capabilities=${SA_UE_CAPS_C_D}
    Set Attenuation             value_string=10            port=${tl.cell_5_6_ports}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    BuiltIn.Sleep   10s
    Attach UE    UE_1
    BuiltIn.Sleep   10s
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Set Attenuation             value_string=0            port=${tl.cell_5_6_ports}

    ${rntis}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    ${tti_file_path_low}=   Collect TTI from low DL traffic   ${DL_TPUT_C3_LOW}
    Stop Data Transfer  dt_name=DT_DL
    Check Optimized DTX For Scell Deactivated    ${tti_file_path_low}   ${rntis[0]}
    ${tti_file_path_high}=    Collect TTI from increasing traffic
    Stop Data Transfer  dt_name=DT_DL
    Check Optimized DTX For Scell Activated    ${tti_file_path_high}     ${rntis[0]}

    [Teardown]   TC_teardown_C_D_F_W    ${pre_change_scf}


CB009333_C_6_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_PCell_FDD_TDD_SA_Buffer_based_Scell_activation_method_3CC
    [Documentation]   This Test Case describes expected Nokia gNB behaviour with TDD-FDD 3CC interaction and micro DTX
     ...              optimized scheduling enabled on PCell in FDD-TDD SA configuration with buffer
     ...              based SCell activation method.

    ${pre_change_scf}           test_specific_keywords_9333.Backup SCF
    Check Preconditions C6    ${CELLS_USED_IN_C}
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_C}
    initialise attenuator

    Require UE   UE_1   capabilities=${SA_UE_CAPS_C_D}
    Set Attenuation             value_string=5            port=${tl.cell_5_6_ports}
    Set Attenuation             value_string=0            port=${tl.cell_1_2_ports}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    ${tti_file_path_high}=     Collect TTI from traffic with PCELL attenuation   ${DL_TPUT_C6_HIGH}
    Check Optimized DTX For Scell Activated   ${tti_file_path_high}     ${rntis[0]}

    [Teardown]   TC_teardown_C_D_F_W    ${pre_change_scf}


CB009333_D_1_Micro-DTX_scheduler_with_DRX_configured
    [Documentation]   This Test Case describes expected Nokia gNB behaviour for UE with configured DRX is scheduled
     ...              during the DRX Active time
    ${pre_change_scf}           test_specific_keywords_9333.Backup SCF
    AdminUtils.Unlock All Cells
    test_specific_keywords_9333.Nullify Attenuation On All Cells
    Check Preconditions 9333 D1    ${CELLS_USED_IN_D_F1}
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_D_F1}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_C_D}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    BuiltIn.Sleep   10s
    Attach UE    UE_1
    BuiltIn.Sleep   10s
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    ${tti_file_path_low_d}=     Collect TTI from low DL traffic    ${DL_TPUT_D_F_LOW}
    Check Optimized DTX For RNTI    ${tti_file_path_low_d}     ${rntis[0]}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    Check DRX Active And Sleep Counters    ${CELLS_USED_IN_D_F1}
    [Teardown]    TC_teardown_C_D_F_W    ${pre_change_scf}


CB009333_F_1_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_SA
    [Documentation]   This Test Case describes expected Nokia gNB behaviour for RLC status PDU (for UL packets)
    ...               are scheduled on DL in the same manner as any delay-sensitive data in terms of
    ...               micro-DTX functionality. Scheduling of delay-sensitive data is not impacted.
    ...               Delay-sensitive data includes: SSBs, TRS, System Information including SIB1 (optional for NSA),
    ...               other SIBs (only for SA), paging ? SA Case.
    ${pre_change_scf}           test_specific_keywords_9333.Backup SCF
    AdminUtils.Unlock All Cells
    test_specific_keywords_9333.Nullify Attenuation On All Cells
    Check Preconditions 9333 F    ${CELLS_USED_IN_D_F1}
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_D_F1}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_F}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Attach UE    UE_1
    BuiltIn.Sleep   10s
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    ${tti_file_path_low_d}=     Collect TTI from low UL traffic    ${DL_TPUT_D_F_LOW}
    Check Prio Class For RLC Traffic    ${tti_file_path_low_d}     ${rntis[0]}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    Check DTX Optimized Counter     ${CELLS_USED_IN_D_F1}
    [Teardown]    TC_teardown_C_D_F_W    ${pre_change_scf}


CB009333_F_2_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_NSA
   [Documentation]   This Test Case describes expected Nokia gNB behaviour for RLC status PDU (for UL packets)
    ...              are scheduled on DL in the same manner as any delay-sensitive data in terms of
    ...              micro-DTX functionality. Scheduling of delay-sensitive data is not impacted.
    ...              Delay-sensitive data includes: SSBs, TRS, System Information including SIB1 (optional for NSA),
    ...              other SIBs (only for SA), paging ? NSA Case.
    AdminUtils.Unlock All Cells
    Check Preconditions 9333 F    ${CELLS_USED_IN_F2_W}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_F2_W}
    Require UE   UE_1   MTK_UE
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    ${tti_file_path_low_d}=     Collect TTI from low UL traffic    ${DL_TPUT_D_F_LOW}
    Check Prio Class For RLC Traffic    ${tti_file_path_low_d}     ${rntis[0]}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    Check DTX Optimized Counter    ${CELLS_USED_IN_F2_W}
    [Teardown]    TC_teardown_C_D_F_W    ${None}    ${True}


CB009333_G_6_Multi_UE_micro_DTX_optimized_scheduling_and_SIB&Pagin_Common_Search_Space_Optimatization_FDD
   [Documentation]     This Test Case describes expected Nokia gNB behavior and micro DTX optimized scheduling
    ...                interworking with CB009550 feature on FDD deployment with SA UEs.
    ${pre_change_scf}           test_specific_keywords_9333.Backup SCF
    AdminUtils.Unlock All Cells
    test_specific_keywords_9333.Nullify Attenuation On All Cells
    Check Preconditions 9333 G    ${CELLS_USED_IN_G6}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_G6}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_CNI}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    L1L2.start_gnbmirroring
    ${tti_file_path_low_d}=     Collect TTI from low UL and DL traffic    ${DL_TPUT_D_F_LOW}
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs
    Check Prio Class For RLC Traffic    ${tti_file_path_low_d}     ${rntis[0]}
    Check Optimized DTX For RNTI    ${tti_file_path_low_d}     ${rntis[0]}
    Check SIB
    ...    pcap_file=${l1l2_logs}
    Check DRB
    ...    pcap_file=${l1l2_logs}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    Check DTX Optimized Counter   ${CELLS_USED_IN_G6}
    Check DRX Active And Sleep Counters     ${CELLS_USED_IN_G6}
    Check UE Multiplexed With SI RNTI For C RNTI In DL Slot     ${CELLS_USED_IN_G6}
    Check Sum Of Times When UE Multiplexed With SI RNTI For C RNTI In DL Slot      ${CELLS_USED_IN_G6}
    [Teardown]    TC_teardown_C_D_F_W    ${pre_change_scf}


CB009333_W_4_Single_UE_Ping_latency_Check_NSA_mode
   [Documentation]     This is a comparison testing ping latency under feature CB009333.
    AdminUtils.Unlock All Cells
    ${pre_change_scf}           test_specific_keywords_9333.Backup SCF
    test_specific_keywords_9333.Nullify Attenuation On All Cells
    Require UE   UE_1   capabilities=${NSA_UE_CAPS_F_W}

    Log    Measuring ping latency with ActProactUIScheduling=false and default SCF.
    Deactivate ActProactUIScheduling    ${CELLS_USED_IN_F2_W}
    Measure ping delay during throughput    ${DL_TPUT_D_F_LOW}
    ...     ${PING_DELAY_THRESHOLD_LOW_SCHEDULING_DEACTIVATED}    ${PING_DELAY_THRESHOLD_HIGH_SCHEDULING_DEACTIVATED}

    Log    Measuring ping latency with ActProactUIScheduling=false and CB009333_W parameters set to true.
    Check Preconditions 9333 W    ${CELLS_USED_IN_F2_W}
    Measure ping delay during throughput    ${DL_TPUT_D_F_LOW}
    ...     ${PING_DELAY_THRESHOLD_LOW_SCHEDULING_DEACTIVATED}    ${PING_DELAY_THRESHOLD_HIGH_SCHEDULING_DEACTIVATED}

    Log    Measuring ping latency with ActProactUIScheduling=true and default SCF.
    SCF commissioning           ${pre_change_scf}
    Activate ActProactUIScheduling    ${CELLS_USED_IN_F2_W}
    Measure ping delay during throughput    ${DL_TPUT_D_F_LOW}
    ...     ${PING_DELAY_THRESHOLD_LOW_SCHEDULING_ACTIVATED_9333_OFF}    ${PING_DELAY_THRESHOLD_HIGH_SCHEDULING_ACTIVATED_9333_OFF}

    Log    Measuring ping latency with ActProactUIScheduling=true and CB009333_W parameters set to true.
    Check Preconditions 9333 W    ${CELLS_USED_IN_F2_W}
    Measure ping delay during throughput    ${DL_TPUT_D_F_LOW}
    ...     ${PING_DELAY_THRESHOLD_LOW_SCHEDULING_ACTIVATED_9333_ON}    ${PING_DELAY_THRESHOLD_HIGH_SCHEDULING_ACTIVATED_9333_ON}

    [Teardown]    TC_teardown_C_D_F_W    ${pre_change_scf}


CNI_124437_CB009333_G_6_Micro_DTX_optimized_and_SIB&Pagin_Common_Search_Space_Optimatization_FDD_delay_param_depends_on_traffic
   [Documentation]     This Test Case describes behavior when dtxMaxRetentionDelay is set to 0 on one DRB.
   ...                 This Test Case describes also expected Nokia gNB behavior and micro DTX optimized scheduling
    ...                interworking with CB009550 feature on FDD deployment with SSA UEs.
    ${pre_change_scf}           test_specific_keywords_9333.Backup SCF
    AdminUtils.Unlock All Cells
    test_specific_keywords_9333.Nullify Attenuation On All Cells
    Check Preconditions 9333 G    ${CELLS_USED_IN_G6}    True
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_CNI}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_CNI}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    Log to Console    >>>>>>>>>>>>>>>>>>>>>> 5QI9 data <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    ${tti_file_path_low_d}=     Collect TTI from low UL and DL traffic    ${DL_TPUT_D_F_LOW}
    Check Prio Class For RLC Traffic    ${tti_file_path_low_d}     ${rntis[0]}
    Check Optimized DTX For RNTI    ${tti_file_path_low_d}     ${rntis[0]}    no_dtx

    Check 5QI used for tput    ${mnc}     0
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Log to Console    >>>>>>>>>>>>>>>>>>>>>> 5QI8 data <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    L1L2.start_gnbmirroring
    ${tti_file_path_low_d}=     Collect TTI from low UL and DL traffic    ${DL_TPUT_D_F_LOW}     port  5008
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs
    Check Prio Class For RLC Traffic    ${tti_file_path_low_d}     ${rntis[0]}
    Check Optimized DTX For RNTI    ${tti_file_path_low_d}     ${rntis[0]}
    Check SIB
    ...    pcap_file=${l1l2_logs}
    Check DRB
    ...    pcap_file=${l1l2_logs}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    Check UE Multiplexed With SI RNTI For C RNTI In DL Slot     ${CELLS_USED_IN_G6}
    Check Sum Of Times When UE Multiplexed With SI RNTI For C RNTI In DL Slot      ${CELLS_USED_IN_G6}
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_9333}
    Check DTX Optimized Counter   ${CELLS_USED_IN_G6}
    Check DRX Active And Sleep Counters     ${CELLS_USED_IN_G6}
     Check UE Multiplexed With SI RNTI For C RNTI In DL Slot     ${CELLS_USED_IN_G6}
    Check Sum Of Times When UE Multiplexed With SI RNTI For C RNTI In DL Slot      ${CELLS_USED_IN_G6}
    Check 5QI used for tput     ${mnc}
    [Teardown]    TC_teardown_C_D_F_W    ${pre_change_scf}


Collect TTI from low DL traffic             # C_3_01
    [Arguments]   ${tput}
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                     direction=dl       duration=60s
    ...                   packet_size=1200            throughput=${tput}                protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    10s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME_LOW_TRAFFIC}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    [Return]   ${tti_file_path}

Collect TTI from increasing traffic         # C3_02
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                     direction=dl       duration=15s
    ...                   packet_size=1200            throughput=100Mbits/sec          protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    10s
    Start data transfer   dt_name=DT_DL1               ue_alias=UE_1                     direction=dl       duration=15s
    ...                   packet_size=1200            throughput=200Mbits/sec           protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    10s
    Start data transfer   dt_name=DT_DL2               ue_alias=UE_1                     direction=dl       duration=15s
    ...                   packet_size=1200            throughput=300Mbits/sec           protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    10s
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    Stop Data Transfer  dt_name=DT_DL
    Stop Data Transfer  dt_name=DT_DL1
    Stop Data Transfer  dt_name=DT_DL2

    [Return]   ${tti_file_path}


Collect TTI from traffic with PCELL attenuation        # C_6
    [Arguments]   ${tput}
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                     direction=dl       duration=60s
    ...                   packet_size=1200            throughput=${tput}                protocol=udp
    ...                   iperf_version=3
    BuiltIn.Sleep    10s
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    gradually decrease attenuation    init_value=25  min_value=0  step=5  interval=1  port=${tl.cell_1_2_ports}
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME_LOW_TRAFFIC}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    Stop Data Transfer     dt_name=DT_DL
    [Return]   ${tti_file_path}


Collect TTI from low UL traffic
    [Arguments]   ${tput}
    Start data transfer   dt_name=DT_UL               ue_alias=UE_1                     direction=ul       duration=60s
    ...                   packet_size=1200            throughput=${tput}                protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    10s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME_LOW_TRAFFIC}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    [Return]   ${tti_file_path}

Collect TTI from low UL and DL traffic
    [Arguments]   ${tput}     ${opt_var}=None    ${port}=None
    Start data transfer   dt_name=DT_UL               ue_alias=UE_1                     direction=ul       duration=60s
    ...                   packet_size=1200            throughput=${tput}                protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}      ${opt_var}=${port}
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                     direction=dl       duration=60s
    ...                   packet_size=1200            throughput=${tput}                protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}      ${opt_var}=${port}
    BuiltIn.Sleep    10s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME_LOW_TRAFFIC}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    Stop data transfer     dt_name=DT_DL
    Stop data transfer     dt_name=DT_UL
    [Return]   ${tti_file_path}


Collect TTI from low traffic for both UEs
    [Arguments]   ${tput}
    Start data transfer   dt_name=DT_DL1              ue_alias=UE_1                     direction=dl       duration=60s
    ...                   packet_size=1200            throughput=${tput}                protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    Start data transfer   dt_name=DT_DL2              ue_alias=UE_2                     direction=dl       duration=60s
    ...                   packet_size=1200            throughput=${tput}                protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    10s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME_LOW_TRAFFIC}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    [Return]   ${tti_file_path}


Attach UEs To Separate Cells
     Set Attenuation To First Cell
     Attach UE    UE_1
     Set Attenuation To Second Cell
     Attach UE    UE_2
     Nullify Attenuation On Both Cells

Measure ping delay during throughput
    [Arguments]   ${tput}    ${ping_delay_threshold_low}    ${ping_delay_threshold_high}
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_F2_W}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Attach UE    UE_1
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                     direction=dl       duration=210s
    ...                   packet_size=1200            throughput=${tput}                protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    10s
    Check Data Transfer Is Alive     dt_name=DT_DL
    Perform Ping Test On UE   ${UE_SERIAL_NUMBER}   ${PING_COUNT}   ${PACKET_SIZE_LOW}
    ...                       ${tl.ues[${UE_IDX}].data_transfer[0].app_server.bind_interface_ip}   ${ping_delay_threshold_low}
    Perform Ping Test On UE   ${UE_SERIAL_NUMBER}   ${PING_COUNT}   ${PACKET_SIZE_HIGH}
    ...                       ${tl.ues[${UE_IDX}].data_transfer[0].app_server.bind_interface_ip}   ${ping_delay_threshold_high}
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    Stop data transfer      dt_name=DT_DL
    Detach UE     UE_1
    AdminUtils.Unlock All Cells

TC_teardown_B
    [Arguments]   ${pre_change_scf}
    Detach UE   UE_1
    Detach UE   UE_2
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    SCF Commissioning  ${pre_change_scf}


TC_teardown_C_D_F_W
    [Arguments]   ${pre_change_scf}=${None}    ${ignore_atten}=${False}
    Detach UE   UE_1
    AdminUtils.Unlock All Cells
    Run Keyword If    '${ignore_atten}'=='${False}'     test_specific_keywords_9333.nullify_attenuation_on_all_cells
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    Run Keyword If    '${pre_change_scf}'!='${None}'     test_specific_keywords_9333.SCF commissioning           ${pre_change_scf}
