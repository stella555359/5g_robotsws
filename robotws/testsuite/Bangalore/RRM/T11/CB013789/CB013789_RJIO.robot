*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes to Validate Monitoring of Fault 8000
...                                for SBA trace session on gNB-CU-CP during TCP connection to TCE failure.
...             TEST SET NAME:    CB013789
...             TESTING SPLIT:    Refer CB013789 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013789 CFAM
...             Requirement ID:   12454710

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ./resources/CB013789_keywords.robot
Resource         ../../../resources/ECEcommon/common_setup_teardown.robot
Resource         ../../../resources/robot/configuration_id.robot
Resource         ../5G_CRT/resources/common_Resource.robot
Resource         ../5G_CRT/resources/common_keywords.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Update bsr package
...                 AND     sleep   2s


*** Test Cases ***
USCB013789-D#B1_TC1_Monitoring_of_Fault_8000_for_SBA_trace_session_on_gNB-CU-CP_during_TCP_connection_to_TCE_failure
    [Documentation]   This user scenario describes to Validate Monitoring of Fault 8000
    ...               for SBA trace session on gNB-CU-CP during TCP connection to TCE failure.
    [Setup]      Testcase setup with delta Commissioning   ${TC1_delta_file_name}   ${wts_cfg_file_TC1}   ${no_of_cells_TC1}
    Setup PCMD
    ${TEST_NAME}    Set Variable   USCB013789_D_B1_TC1
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    btslog
    Start Tcp Pcap
    Attach 2 UEs with SBA trace type   ${start_ue_id}    ${end_ue_id}
    sleep   5s
    Detach UEs   ${start_ue_id}   ${end_ue_id}
    Stop Tcp Pcap
    ${path1}   Stop Log    btslog
    Verify syslog for 8000 cancel time   ${path1}[btslog]
    sleep   20s
    [Teardown]      Run Keywords
    ...             Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    ...             AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...             AND     Teardown PCMD
    ...             AND     Send Delta Commissioning     ${TC1_delta_revert}

USCB013789-E#B1-ALT1_TC3_Monitoring_RLC_Level_PCMD_Throughput_Trace_Records_when_PM_counters_for_throughput_estimation_are_disabled_for_SBA_FR1
    [Documentation]   This user scenario describes Monitoring of RLC Level PCMD Throughput Trace Records in gNB-DU when PM counters
    ...     for throughput estimation are disabled for SBA FR1
    [Setup]    Run keywords
    ...        Log to console    "start"
    ...        Start Log   btslog
    ...        AND    Start WTS Using WTS_Runner      ${wts_cfg_file_TC57}
    ...        AND     sleep   60s
    ${TEST_NAME}    Set Variable   TC3
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    Log to console    ${AOA_PMI_record}
    Log to console    ${DOA_PMI_record}
    Log to console    ${AOA_SSB_record}
    Log to console    ${DOA_SSB_record}
    Send Delta Commissioning    ${enable_pcmd}
    Start Tcp Pcap
    Setup PCMD
    Send Delta Commissioning    ${TC57_delta}
    sleep   10s
    Start Log    cprt
    log to console   "SA UE attach with NBR Bearers are trigerring now"
##Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres
    ${rnti_list}   MultiUE Register should be Successful    ${TC57_sa_ue_id1}     ${TC57_sa_ue_id4}
    sleep     2s
    Add new Bearer for Multiple SA UE    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID5}
    Add new Bearer for Multiple SA UE    ${TC57_sa_ue_id3}    ${TC57_sa_ue_id3}    ${Pdu_session_ID}    ${QFI_ID5}
    Log to console   ${rnti_list}
    Log to console  "Iteration 1: DL and UL Data start"
    MultiUE Trigger DL Traffic for SA   ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}    Traffic_rate=mbps   dl_rate=150
    ...   pdu_id=1     trf_id=1
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id1}    ${TC57_sa_ue_id1}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id2}    ${TC57_sa_ue_id2}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id3}    ${TC57_sa_ue_id3}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id4}    ${TC57_sa_ue_id4}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    sleep   60s
##Validate all UE thput before MIMO position is activated
    Validate UL Traffic For all UEs   52   8   52   8
    Set And Activate Srs beam position   ${TC57_sa_ue_id1}
    sleep   60s
##Validate all UE thput After MIMO position is activated
    Validate UL Traffic For all UEs   109   109   109    109
    Validate DL Traffic For MultiUE for SA     ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}     150
    Log to console  "Iteration 1: DL and UL Data stop"
    Stop UL and DL data Traffic For all UEs    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}     1
    sleep   60s
    Log to console  "Iteration 2: DL and UL Data start"
    MultiUE Trigger DL Traffic for SA   ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}    Traffic_rate=mbps   dl_rate=150
    ...   pdu_id=1     trf_id=1
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}    Traffic_rate=mbps   ul_rate=50
    ...   pdu_id=1     trf_id=1
    sleep   60s
    Log to console  "Iteration 2: DL and UL Data stop"
    Stop UL and DL data Traffic For all UEs    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}     1
    sleep   60s
    Log to console  "Iteration 3: DL and UL Data start"
    MultiUE Trigger DL Traffic for SA   ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}    Traffic_rate=mbps   dl_rate=150
    ...   pdu_id=1     trf_id=1
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}    Traffic_rate=mbps   ul_rate=50
    ...   pdu_id=1     trf_id=1
    sleep   60s
    Log to console  "Iteration 3: DL and UL Data stop"
#    Stop UL and DL data Traffic For all UEs    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}     1
#    sleep   4s
    MultiUE Deregister should be Successful    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}
    sleep   60s
    Stop Log   cprt
##Validate DU Trace Records wrt DOA and AOA
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${AOA_SSB_record}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${AOA_PMI_record}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${AOA_DFT_record}

    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${DOA_SSB_record}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${DOA_PMI_record}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${DOA_DFT_record}

##Validate DU RLC Trace Records
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${ulRbRlcMeasRecord}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${dlRbRlcMeasRecord}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${ulRbrlcthroughputRecord}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${dlRbrlcthroughputRecord}
    ...   pass_criteria= >=0
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${ulRbHighRlcMeasRecord}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${dlRbHighRlcMeasRecord}

##Validate CUCP PDCP Trace Records
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${ulRbPdcpMeasRecord}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${dlRbPdcpMeasRecord}
    Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${dlRbPdcpThroughputRecord}
    sleep    5s
    [Teardown]    Run Keywords
    ...     Stop Tcp Pcap
    ...     AND   Teardown PCMD
    ...     AND   Link SCOUT SCF to Configuration ID for Reporting
    ...     AND   Run Keyword and Ignore Error    MultiUE Deregister should be Successful    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id4}
    ...     AND   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...     AND   Send Delta Commissioning    ${disable_pcmd}
    ...     AND   Stop Log   btslog   snapshot    sosreport


