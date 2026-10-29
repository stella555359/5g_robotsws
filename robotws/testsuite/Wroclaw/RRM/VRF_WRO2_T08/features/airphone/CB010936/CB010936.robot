*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny
...              :maintainer: marcin.plawny@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library    ta5g_iperf_traffic
Library     ta5g_iphy
Library    ta5g_setups_and_teardowns
Library    ta5g_enb
Library    ta5g_ue_mobility
Library    ta5g_pm_counters
Library    ta5g_delta
Library    ta5g_commissioning
Library    ta5g_testline_management
Library    ta5g_tshark
Library    taf.sw.reporting_portal
Library    CB010936_Keywords.py
Library    testsuite/Wroclaw/RRM/resources/syslog_checker.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Change RD Parameters In Swconfig File
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_10936.json    skip_relation_errors=False
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_10936.cfg
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
Test Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...           AND             Wait For Next Full Pm Interval
Test Teardown    Teardown

*** Test Cases ***
CB010936_B1_L4S_UL_with_AMBR
    [Documentation]    This Test Case verifies UL L4S flows with AMBR limitation for the non-GBR bearers of the SA UE.
    ...                AMBR is lower than UL throughput capacity. L4S is activated on 5QI-9, corresponding to NRDRB-14 in the mentioned config.
    ...                2nd bearer used for classic flow only is 5QI-7.
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1
    Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=75
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 session_ambr_ul=41:Mbps by=amf
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt    10.0.2.1    7264    50    True
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic.txt   10.0.2.1    7267    50    False
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_1.txt    10.0.2.1    7261    50    False
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_2.txt   10.0.2.1    7265    50    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_udp_l4s.txt
    ...    72.23.0.1    1G    200    50    10.0.2.1    7264    1400    True
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic.txt
    ...    72.23.0.1    1G    150    50    10.0.2.1    7267    1400    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic_5qi7_1.txt
    ...    72.23.0.1    15M    140    50    10.0.2.1    7261    1400    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic_5qi7_2.txt
    ...    72.23.0.1    15M    220    50    10.0.2.1    7265    1400    False
    Sleep    200s
    Check If Average Latency Lower Then Threshold    100    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt
    Check If L4S Traffic Average Bandwidth At Least Half Of Every Other
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55352C03026  >0  UL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03027  >0  UL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03028  >0  UL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03029   0  UL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    M55352C03030  >0  UL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    M55125C13037  >0  SA_UL_UE_AMBR_AVG
    ...    M55125C13041   1  SA_UL_AMBR_INCREASE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

CB010936_B3_L4S_UL_with_Grant_Uplink
    [Documentation]    This Test Case verifies UL L4S flows with Uplink Grant Type 2 configured for the UE.
    ...                L4S is activated on 5QI-9, corresponding to NRDRB-14 in config. 2nd bearer used for classic flow only in test is 5QI-7.
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1
    Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=75
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt    10.0.2.1    7264    50    True
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic.txt   10.0.2.1    7267    50    False
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_1.txt    10.0.2.1    7261    50    False
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_2.txt   10.0.2.1    7265    50    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_udp_l4s.txt
    ...    72.23.0.1    1G    200    50    10.0.2.1    7264    1400    True
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic.txt
    ...    72.23.0.1    1G    150    50    10.0.2.1    7267    1400    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic_5qi7_1.txt
    ...    72.23.0.1    15M    140    50    10.0.2.1    7261    1400    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic_5qi7_2.txt
    ...    72.23.0.1    15M    220    50    10.0.2.1    7265    1400    False
    Sleep    200s
    Check If Average Latency Lower Then Threshold    80    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt

CB010936_A3_L4S_Variant2_DL_with_scheduling_request_per_DRB_profile
    [Documentation]    Test uses DL L4S variant 2 and compare the DL latencies and traffic distribution between flows.
    ...                The first bearer contains 1 L4S flow plus 1 Classic flow. The second bearer contains 2 Classic flows.
    ...                Interaction with CB009189 scheduling request per DRB profile.
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_10936_A3.json    skip_relation_errors=False
    ...        AND             Wait For Next Full Pm Interval

    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt    10.0.2.1    7264    1    True
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic.txt   10.0.2.1    7267    1    False
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_1.txt    10.0.2.1    7261    1    False
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_2.txt   10.0.2.1    7265    1    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_udp_l4s.txt
    ...    1.2.4.2    50Mb    150    1    10.0.2.1    7264    1300    True
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic.txt
    ...    1.2.4.2    50M    120    60    10.0.2.1    7267    1400    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic_5qi7_1.txt
    ...    1.2.4.2    50M    120    60    10.0.2.1    7261    1400    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic_5qi7_2.txt
    ...    1.2.4.2    50M    120    60    10.0.2.1    7265    1400    False
    Sleep    150s
    Check If Average Latency Lower Then Threshold    100    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt
    Check If Lowest Average Bandwidth Is Not 5 Times Lower Than Highest One
    Verify Tshark
    ...    alias=default_tcpdump_alias
    ...    packet_filter=f1ap.procedureCode == id-UEContextModification && nr-rrc.sl10
    ...    pass_criteria= >=1
    ...    pcap_file_path=default
    ...    timeout=16
    ...    continue_on_failure=${False}
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55352C03021  >0  DL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03022  >0  DL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03023  >0  DL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03024   0  DL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    M55352C03025  >0  DL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

*** Keywords ***
Check If L4S Traffic Average Bandwidth At Least Half Of Every Other
    ${l4s}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt
    ${tcp1}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic.txt
    ${tcp2}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_1.txt
    ${tcp3}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_2.txt
    Should Be True    ${l4s} >= ${tcp1} / 2    L4S bandwidth (${l4s} Mbits/sec) is less than half of TCP bandwidth (${tcp1} Mbits/sec).
    Should Be True    ${l4s} >= ${tcp2} / 2    L4S bandwidth (${l4s} Mbits/sec) is less than half of TCP bandwidth (${tcp2} Mbits/sec).
    Should Be True    ${l4s} >= ${tcp3} / 2     L4S bandwidth (${l4s} Mbits/sec) is less than half of TCP bandwidth (${tcp3} Mbits/sec).

Check If Lowest Average Bandwidth Is Not 5 Times Lower Than Highest One
    ${l4s}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt
    ${tcp1}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic.txt
    ${tcp2}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_1.txt
    ${tcp3}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_2.txt
    Check Average Bandwidth Condition    ${l4s}    ${tcp1}    ${tcp2}    ${tcp3}

Change RD Parameters In Swconfig File
    @{10936_rd_params}=    Create List
    ...    0x5A0614=1     # rdDebugBearerManagement
    ...    0x5A0618=1     # rdDebugPmqapCounters
    ...    0x5A0621=1     # rdDebugCounters
    ...    0x5A0622=1     # rdDebugPI2
    ...    0x5A0624=1     # rdDebugL4S
    ...    0x66001C=10    # NRBTS.cbtsFlowControlProf.maxTransferDelay
    Backup And Modify Swconfig File    parameters_list=${10936_rd_params}

Teardown
    Deregister UE Without Confirmation    ue_id=1
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Stop All Traffics
    Add Scout Scf Id To Test Data
    Run Keyword If Test Passed    Find Suspicious Logs
