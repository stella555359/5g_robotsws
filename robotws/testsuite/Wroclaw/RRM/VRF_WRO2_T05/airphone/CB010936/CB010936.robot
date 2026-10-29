*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED
...           SBTS00    RAN_5G    CRT    PY311
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com
...              :testsuite description: L4S stands for Low Latency, Low Loss, Scalable throughput. It significantly reduces latency
...              experienced by packets traveling across the Internet, where the main cause of delays is queueing, and for example the usual
...              congested best effort bearer latency of few hundred ms could be reduced to several dozen. However, it requires support at the
...              transmitter, receiver and before the bottleneck i.e. at the server, UE, and gNB.
...              In this test suite special iperf version is used - iperf2 configured to enable L4S.

Resource    CB010936_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=enable_l4s_DL.json
...             AND             Set Counter Collecting Interval To Five Minutes
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_l4s.lua
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords  Roll Delta Back
...                                initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                                delta_scf_filename=enable_l4s_DL.json
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB010936_A_2_DL_L4S_Variant_1_Alt1_Handover
    [Documentation]  This test case uses DL L4S Variant 1 and checks DL UDP throughput and latency of L4S flow and Classic flows.
    ...              Traffic on 7261 port - L4S traffic on 5QI 9.
    ...              Traffic on 7262 port - Classic traffic on 5QI 9.
    ...              Traffic on 7263 port - Classic traffic on 5QI 8.
    ...              Traffic on 7264 port - Classic traffic on 5QI 8.
    ...              Traffic on 7260 port - Classic traffic on 5QI 7 - triggered only to fill the buffer.
    ...              During procedure UE is registered to cell-3, PDU session is established and 5 different traffics are triggered.
    ...              After counters are checked in cell-3, intra-gNB handover to cell-4 is triggered by A5 measurement.
    ...              In the bearer with 5QI 9 the L4S throuput should be in range of 25 - 75% of Classic flow.
    ...              L4S latency should be smaller than 100 ms, while Classic flows latency should be greater than 300 ms.
    ...              Requirements covered: 5G_RAN_USR_RRM_26408 with Alternate Scenario with a intra-gNB handover, 5G_PM_1938.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE  ue_id=51
    Establish PDU Session  ue_id=51    pdu_id=1    gw_id=1
    Start UDP DL L4S Traffic    port=7261    bandwidth=50Mb    duration=1000
    Start UDP DL Classic Traffic    port=7262    bandwidth=50Mb    duration=1000
    Start UDP DL Classic Traffic    port=7263    bandwidth=50Mb    duration=1000
    Start UDP DL Classic Traffic    port=7264    bandwidth=50Mb    duration=1000
    Start UDP DL Classic Traffic    port=7260    bandwidth=50Mb    duration=1000
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55352C03021   >0    DL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03022   >0    DL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03025   >0    DL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    M55352C03023   >0    DL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03024    0    DL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55352C03021    0    DL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03022    0    DL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03025    0    DL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    M55352C03023    0    DL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03024    0    DL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55352C03021    0    DL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03022    0    DL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03025    0    DL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    M55352C03023    0    DL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03024    0    DL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55352C03021    0    DL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03022    0    DL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03025    0    DL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    M55352C03023    0    DL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03024    0    DL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Average DL L4S Throughput On Port    port=7261    direction=DL    expected_throughput=20    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL L4S Latency On Port    port=7261    direction=DL    max_latency=100    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Throughput On Port    port=7262    direction=DL    expected_throughput=30    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Latency On Port    port=7262    direction=DL    min_latency=300    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Throughput On Port    port=7263    direction=DL    expected_throughput=30    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Latency On Port    port=7263    direction=DL    min_latency=300    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Throughput On Port    port=7264    direction=DL    expected_throughput=30    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Latency On Port    port=7264    direction=DL    min_latency=300    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Send Custom UE Measurement NR  id=51 meas_id=2 index=0 nrs_result=50:56:0 event=A5 phycell_id=53 nrsrp_nr=50 srsrp_nr=56
    ...                            pass_regexp=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.4 performed
    ...                            timeout=7
    Sleep    60s    reason= Wait For The Traffic
    Verify Average DL L4S Throughput On Port    port=7261    direction=DL    expected_throughput=20    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL L4S Latency On Port    port=7261    direction=DL    max_latency=100    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Throughput On Port    port=7262    direction=DL    expected_throughput=30    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Latency On Port    port=7262    direction=DL    min_latency=300    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Throughput On Port    port=7263    direction=DL    expected_throughput=30    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Latency On Port    port=7263    direction=DL    min_latency=300    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Throughput On Port    port=7264    direction=DL    expected_throughput=30    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average DL Classic Latency On Port    port=7264    direction=DL    min_latency=300    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Stop Specific Traffic    port=7262
    Stop Specific Traffic    port=7263
    Stop Specific Traffic    port=7264
    Sleep    180s    reason= Wait For The Traffic
    Verify Average DL L4S Latency On Port    port=7261    direction=DL    max_latency=100    log_directory=${OUTPUT_DIR}/${TEST_NAME}

    [Teardown]    Run Keywords   Stop All Traffics
    ...           AND            Deregister Ue Without Confirmation    ue_id=51
    ...           AND            Add Scout External Execution ID To Reporting Portal
    ...           AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB010936_B_1_UL_L4S
    [Documentation]  This test case uses UL L4S and checks UL UDP throughput and latency of L4S flow and Classic flows.
    ...              Traffic on 7361 port - L4S traffic on 5QI 9.
    ...              Traffic on 7362 port - Classic traffic on 5QI 9.
    ...              Traffic on 7363 port - Classic traffic on 5QI 8.
    ...              Traffic on 7364 port - Classic traffic on 5QI 8.
    ...              Traffic on 7360 port - Classic traffic on 5QI 7 - triggered only to fill the buffer.
    ...              During procedure UE is registered to cell-3, PDU session is established and 5 different traffics are triggered.
    ...              L4S latency should be smaller than 100 ms.
    ...              Requirements covered: 5G_RAN_USR_RRM_26170, 5G_PM_1939.

    [Setup]    Run Keywords   Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND            Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_test_commissioning.xml
    ...        AND            Find Scfc And Send Delta Commissioning    scfc_filename=enable_l4s_UL.json

    Attach UE  ue_id=52
    Establish PDU Session  ue_id=52    pdu_id=2    gw_id=52
    Start UDP UL L4S Traffic    port=7361    bandwidth=25Mb    duration=450
    Start UDP UL Classic Traffic    port=7362    bandwidth=25Mb    duration=450
    Start UDP UL Classic Traffic    port=7363    bandwidth=25Mb    duration=450
    Start UDP UL Classic Traffic    port=7364    bandwidth=25Mb    duration=450
    Start UDP UL Classic Traffic    port=7360    bandwidth=25Mb    duration=450
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55352C03026    >0    UL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03027    >0    UL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03030    >0    UL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    M55352C03028    >0    UL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03029    0    UL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55352C03026    0    UL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03027    0    UL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03030    0    UL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    M55352C03028    0    UL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03029    0    UL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55352C03026    0    UL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03027    0    UL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03030    0    UL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    M55352C03028    0    UL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03029    0    UL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55352C03026    0    UL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03027    0    UL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03030    0    UL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    M55352C03028    0    UL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03029    0    UL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Average UL L4S Throughput On Port    port=7361    direction=UL    expected_throughput=10    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average UL L4S Latency On Port    port=7361    direction=UL    max_latency=80    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average UL Classic Throughput On Port    port=7362    direction=UL    expected_throughput=20    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average UL Classic Throughput On Port    port=7363    direction=UL    expected_throughput=20    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Verify Average UL Classic Throughput On Port    port=7364    direction=UL    expected_throughput=20    log_directory=${OUTPUT_DIR}/${TEST_NAME}
    Stop Specific Traffic    port=7362
    Stop Specific Traffic    port=7363
    Stop Specific Traffic    port=7364
    Sleep    180s    reason= Wait For The Traffic
    Verify Average UL L4S Latency On Port    port=7361    direction=UL    max_latency=80    log_directory=${OUTPUT_DIR}/${TEST_NAME}

    [Teardown]    Run Keywords   Stop All Traffics
    ...           AND            Deregister Ue Without Confirmation    ue_id=52
    ...           AND            Roll Delta Back
    ...                             initial_scf_filename=${OUTPUT_DIR}/initial_test_commissioning.xml
    ...                             delta_scf_filename=enable_l4s_UL.json
    ...           AND            Add Scout External Execution ID To Reporting Portal
    ...           AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}