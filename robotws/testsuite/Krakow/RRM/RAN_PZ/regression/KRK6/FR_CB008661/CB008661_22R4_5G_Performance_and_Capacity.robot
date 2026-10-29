*** Settings ***
Documentation
...   Test suite for testing of 5G Performance and Capacity feature, executed over gNB sofrware releases.
...   Tests in the suite measure the following aspects for 5G FR2 NSA:
...   - Call Release Latency
...   - Inter gNB Handover Latency
...   - Inter eNB Handover Latency
...   - Data Interruption Time for UL and DL during Inter gNB Handover
...   - Data Interruption Time for UL and DL during Inter eNB Handover
...   - Unscheduled ping latency with 32B packets from UE for FR2 without TSN
...   - Unscheduled ping latency with 1350B packets from appserver for FR2 without TSN
...   - Scheduled ping latency with 32B packets from UE for FR2 without TSN

...   author: Sara Nowak Mateusz Potoniec
...   contact: sara.nowak@nokia.com mateusz.potoniec@nokia.com
...   maintainer: sara.nowak@nokia.com mateusz.potoniec@nokia.com

Resource    ./resources/suite_specific_keywords.robot


*** Variables ***
${ITERATIONS_NUMBERS}                10
${PING_COUNT}                        200
${PACKET_SIZE_HIGH}                  1350
${PACKET_SIZE_LOW}                   32
${CORE_IP}                           10.84.169.60

${TEST_LATENCY_THRESHOLD_TC_03}      35.7
${TEST_LATENCY_THRESHOLD_TC_04}      68.5
${TEST_LATENCY_THRESHOLD_TC_05}      108.0
${UL_TEST_LATENCY_THRESHOLD_TC_06}   160.1
${DL_TEST_LATENCY_THRESHOLD_TC_06}   159.7
${UL_TEST_LATENCY_THRESHOLD_TC_08}   154.6
${DL_TEST_LATENCY_THRESHOLD_TC_08}   154.3
${TEST_LATENCY_THRESHOLD_TC_10}      26.3
${TEST_LATENCY_THRESHOLD_TC_11}      30.2
${TEST_LATENCY_THRESHOLD_TC_13}      7.5

${GNB_1_CELL_1_ID}                   50
${GNB_2_CELL_1_ID}                   60
${GNB_2_CELL_2_ID}                   61
${ENB_1_CELL_1_ID}                   19730433
${ENB_2_CELL_1_ID}                   19730689

${GNB_1_ADDRESS}                     10.84.190.55
${GNB_2_ADDRESS}                     10.84.190.29
${ENB_1_ADDRESS}                     10.84.190.72
${ENB_2_ADDRESS}                     10.84.190.73


*** Test Cases ***
CB008661_5G_03_NSA_Call_Release
    [Setup]    Test Setup eNB1
    @{call_release_latencies}=    Create List
    FOR    ${i}    IN RANGE    1    ${ITERATIONS_NUMBERS}+1
        logger.Log Info to Console    Start Iteration ${i}
        ${alias_for_tcpdump}=      Connect to BTS    ${GNB_1_ADDRESS}
        ${attach_tcpdump_logs}=    Attach UE With Pcap Check    ${GNB_1_CELL_1_ID}    ${ENB_1_CELL_1_ID}
        ...                        10s    iter_${i}_call_release_logs.pcap
        Detach UE
        logger.Log Info to Console    Calculate and verify Call Release Latency
        ${call_release_latency}=    latency_analyzer.Calculate Call Release Latency
        ...                         ${OUTPUTDIR}/${attach_tcpdump_logs}
        logger.Log Info to Console    Call Release Latency: ${call_release_latency}
        Append to List    ${call_release_latencies}    ${call_release_latency}
    END
    logger.Log Info to Console    Call Release Latencies: ${call_release_latencies}
    ${average_release_latency}=    suite_specific_keywords.Verify Average Latency
    ...                            ${call_release_latencies}
    ...                            ${TEST_LATENCY_THRESHOLD_TC_03}
    logger.Log Info to Console    Average Call Release Latency: ${average_release_latency} | Threshold: ${TEST_LATENCY_THRESHOLD_TC_03}
    [Teardown]   Test Teardown    logs_gnb1=${True}    logs_gnb2=${False}
    ...                           logs_enb1=${True}    logs_enb2=${False}

CB008661_5G_04_NSA_Handover_latency_Inter_gNB_HO
    [Setup]    Test Setup eNB1
    @{inter_gnb_ho_latencies}  Create List
    FOR    ${i}    IN RANGE    1    ${ITERATIONS_NUMBERS}+1
        logger.Log Info to Console    Start Iteration ${i}
        Prepare Cells Before HO
        ${alias_for_tcpdump}=      Connect to BTS    ${GNB_2_ADDRESS}
        Attach UE With Pcap Check    ${GNB_2_CELL_2_ID}    ${ENB_1_CELL_1_ID}
        ${inter_gnb_ho_tcpdump_logs}=    Perform Inter gNB HO    iteration=${i}
        logger.Log Info to Console    Calculate and verify Inter gNB Handover Latency
        ${inter_gnb_ho_latency}=   latency_analyzer.Calculate Inter gNB Handover Latency
        ...                        pcap_file=${OUTPUTDIR}/${inter_gnb_ho_tcpdump_logs}
        ...                        pci_5g=${GNB_1_CELL_1_ID}
        ...                        source_address=${ENB_1_ADDRESS}
        ...                        destination_address=${GNB_1_ADDRESS}
        logger.Log Info to Console    Inter gNB HO latency: ${inter_gnb_ho_latency}
        Append to List    ${inter_gnb_ho_latencies}    ${inter_gnb_ho_latency}
    END
    logger.Log Info to Console    Inter gNB Handover Latencies: ${inter_gnb_ho_latencies}
    ${average_inter_gnb_ho_latency}=    suite_specific_keywords.Verify Average Latency
    ...                                 ${inter_gnb_ho_latencies}
    ...                                 ${TEST_LATENCY_THRESHOLD_TC_04}
    logger.Log Info to Console    Average Inter gNB Handover Latency: ${average_inter_gnb_ho_latency} | Threshold: ${TEST_LATENCY_THRESHOLD_TC_04}
    [Teardown]   Test Teardown    logs_gnb1=${True}    logs_gnb2=${True}
    ...                           logs_enb1=${True}    logs_enb2=${False}

CB008661_5G_05_NSA_Handover_latency_Inter_MeNB_LTE_HO_Intra_DU_HO
    [Setup]    Test Setup
    @{inter_enb_ho_latencies}  Create List
    FOR    ${i}   IN RANGE    1    ${ITERATIONS_NUMBERS}+1
        logger.Log Info to Console    Start Iteration ${i}
        ${attach_tcpdump_logs}=    Attach UE to gNB1 and Perform Inter MeNB HO With Pcap Check
        ...                        iter_${i}_inter_enb_ho_logs.pcap
        Detach UE
        logger.Log Info to Console    Calculate and verify Inter eNB Handover Latency
        ${inter_enb_ho_latency}=   latency_analyzer.Calculate Inter eNB Handover Latency
        ...                        pcap_file=${OUTPUTDIR}/${attach_tcpdump_logs}
        ...                        source_address=${ENB_2_ADDRESS}
        logger.Log Info to Console    Inter eNB HO latency: ${inter_enb_ho_latency}
        Append to List    ${inter_enb_ho_latencies}    ${inter_enb_ho_latency}
    END
    logger.Log Info to Console    Inter eNB Handover Latencies: ${inter_enb_ho_latencies}
    ${average_inter_enb_ho_latency}=    suite_specific_keywords.Verify Average Latency
    ...                                 ${inter_enb_ho_latencies}
    ...                                 ${TEST_LATENCY_THRESHOLD_TC_05}
    logger.Log Info to Console    Average Inter eNB Handover Latency: ${average_inter_enb_ho_latency} | Threshold: ${TEST_LATENCY_THRESHOLD_TC_05}
    [Teardown]   Test Teardown    logs_gnb1=${True}    logs_gnb2=${False}
    ...                           logs_enb1=${True}    logs_enb2=${True}

CB008661_5G_06_NSA_Handover_data_interruption_time_Inter_gNB_HO
    [Setup]    Test Setup eNB1
    @{ul_latencies}  Create List
    @{dl_latencies}  Create List
    Perform Delta Commissioning on gNB   ${DELTA_TEARDOWN}
    FOR    ${i}    IN RANGE    1    ${ITERATIONS_NUMBERS}+1
        logger.Log Info to Console    Start Iteration ${i}
        ${alias_for_tcpdump}=      Connect to BTS    ${GNB_2_ADDRESS}
        Attach UE With Pcap Check    ${GNB_2_CELL_2_ID}    ${ENB_1_CELL_1_ID}
        Start UL and DL Data Transfer
        Start TTI Trace GNB1                        collector_name=l2stream31
        Start TTI Trace GNB2                        collector_name=l2stream3
        Perform Inter gNB HO by Delta Commissioning
        Stop TTI Trace                              collector_name=l2stream31
        ...                                         split=${False}
        ...                                         tcpdump_file=tcpdump
        ${splited_pcaps_list}=    Stop TTI Trace    collector_name=l2stream3
        ...                                         split=${True}
        ...                                         tcpdump_file=tcpdump2
        Stop UL and DL Data Transfer
        Detach UE
        Perform Delta Commissioning on gNB   ${DELTA_TEARDOWN}
        logger.Log Info to Console    Calculate and verify Data Interruption Time For UL and DL
        ${ul_latency}    ${dl_latency}=    tti_trace_analyzer.Verify Data Interuption Time For UL and DL
        ...                                ${splited_pcaps_list}
        logger.Log Info to Console    Data interruption time UL latency: ${ul_latency}
        logger.Log Info to Console    Data interruption time DL latency: ${dl_latency}
        Append to List    ${ul_latencies}    ${ul_latency}
        Append to List    ${dl_latencies}    ${dl_latency}
    END
    logger.Log Info to Console    Data interruption time UL latencies: ${ul_latencies}
    logger.Log Info to Console    Data interruption time DL latencies: ${dl_latencies}
    ${average_ul_latency}=    suite_specific_keywords.Verify Average Latency
    ...                       ${ul_latencies}
    ...                       ${UL_TEST_LATENCY_THRESHOLD_TC_06}
    ${average_dl_latency}=    suite_specific_keywords.Verify Average Latency
    ...                       ${dl_latencies}
    ...                       ${DL_TEST_LATENCY_THRESHOLD_TC_06}
    logger.Log Info to Console    Average Data Interruption Time UL latency: ${average_ul_latency} | Threshold: ${UL_TEST_LATENCY_THRESHOLD_TC_06}
    logger.Log Info to Console    Average Data Interruption Time DL latency: ${average_dl_latency} | Threshold: ${DL_TEST_LATENCY_THRESHOLD_TC_06}
    [Teardown]   Test Teardown    logs_gnb1=${True}    logs_gnb2=${True}
    ...                           logs_enb1=${True}    logs_enb2=${False}

CB008661_5G_08_NSA_Handover_data_interruption_time_Inter_MeNB_LTE_HO_Intra_DU_HO
    [Setup]    Test Setup
    @{ul_latencies}  Create List
    @{dl_latencies}  Create List
    FOR    ${i}   IN RANGE    1    ${ITERATIONS_NUMBERS}+1
        logger.Log Info to Console    Start Iteration ${i}
        Perform Attenuation of eNB1 and eNB2    enb1_cell_1_value=0%      enb1_cell_2_value=100%
        ...                                     enb2_cell_1_value=100%    enb2_cell_2_value=100%
        ${alias_for_tcpdump}=      Connect to BTS    ${GNB_1_ADDRESS}
        Attach UE With Pcap Check    ${GNB_1_CELL_1_ID}    ${ENB_1_CELL_1_ID}
        Start UL and DL Data Transfer
        Start TTI Trace
        Perform handover from eNB1 Cell1 to eNB2 Cell1
        ${splited_pcaps_list}=    Stop TTI Trace
        Stop UL and DL Data Transfer
        Detach UE
        logger.Log Info to Console    Calculate and verify Data Interruption Time For UL and DL
        ${ul_latency}    ${dl_latency}=    tti_trace_analyzer.Verify Data Interuption Time For UL and DL
        ...                                ${splited_pcaps_list}
        logger.Log Info to Console    Data interruption time UL latency: ${ul_latency}
        logger.Log Info to Console    Data interruption time DL latency: ${dl_latency}
        Append to List    ${ul_latencies}    ${ul_latency}
        Append to List    ${dl_latencies}    ${dl_latency}
    END
    logger.Log Info to Console    Data interruption time UL latencies: ${ul_latencies}
    logger.Log Info to Console    Data interruption time DL latencies: ${dl_latencies}
    ${average_ul_latency}=    suite_specific_keywords.Verify Average Latency
    ...                       ${ul_latencies}
    ...                       ${UL_TEST_LATENCY_THRESHOLD_TC_08}
    ${average_dl_latency}=    suite_specific_keywords.Verify Average Latency
    ...                       ${dl_latencies}
    ...                       ${DL_TEST_LATENCY_THRESHOLD_TC_08}
    logger.Log Info to Console    Average Data Interruption Time UL latency: ${average_ul_latency} | Threshold: ${UL_TEST_LATENCY_THRESHOLD_TC_08}
    logger.Log Info to Console    Average Data Interruption Time DL latency: ${average_dl_latency} | Threshold: ${DL_TEST_LATENCY_THRESHOLD_TC_08}
    [Teardown]   Test Teardown    logs_gnb1=${True}    logs_gnb2=${False}
    ...                           logs_enb1=${True}    logs_enb2=${True}

CB008661_5G_10_Unscheduled_ping_latency_with_32B_packets_from_UE_for_FR2_without_TSN
    [Setup]    Test Setup eNB1
    ${alias_for_tcpdump}=    Connect to BTS    ${GNB_1_ADDRESS}
	Attach UE With Pcap Check    ${GNB_1_CELL_1_ID}    ${ENB_1_CELL_1_ID}
    logger.Log Info to Console    Ping on UE with ${PING_COUNT} packets and ${PACKET_SIZE_LOW} bytes
    ${average_ping_latency}    ${ping_latencies}=    ping.Perform Ping On UE
    ...                                              ${PING_COUNT}
    ...                                              ${PACKET_SIZE_LOW}
    ...                                              ${CORE_IP}
    ...                                              ${TEST_LATENCY_THRESHOLD_TC_10}
    logger.Log Info to Console    Ping on UE ended successfully
    logger.Log Info to Console    Ping latencies: ${ping_latencies}
    logger.Log Info to Console    Average ping latency: ${average_ping_latency} | Threshold: ${TEST_LATENCY_THRESHOLD_TC_10}
    [Teardown]   Test Teardown    logs_gnb1=${True}    logs_gnb2=${False}
    ...                           logs_enb1=${True}    logs_enb2=${False}

CB008661_5G_11_Unscheduled_ping_latency_with_1350B_packets_from_appserver_for_FR2_without_TSN
    [Setup]    Test Setup eNB1
    ${alias_for_tcpdump}=    Connect to BTS    ${GNB_1_ADDRESS}
	Attach UE With Pcap Check    ${GNB_1_CELL_1_ID}    ${ENB_1_CELL_1_ID}
    logger.Log Info to Console    Ping on Core with ${PING_COUNT} packets and ${PACKET_SIZE_HIGH} bytes
	${average_ping_latency}    ${ping_latencies}=    ping.Perform Ping On Core
    ...                                              ${PING_COUNT}
    ...                                              ${PACKET_SIZE_HIGH}
    ...                                              ${TEST_LATENCY_THRESHOLD_TC_11}
    logger.Log Info to Console    Ping on Core ended successfully
    logger.Log Info to Console    Ping latencies: ${ping_latencies}
    logger.Log Info to Console    Average ping latency: ${average_ping_latency} | Threshold: ${TEST_LATENCY_THRESHOLD_TC_11}
    [Teardown]   Test Teardown    logs_gnb1=${True}    logs_gnb2=${False}
    ...                           logs_enb1=${True}    logs_enb2=${False}

CB008661_5G_13_Scheduled_ping_latency_with_32B_packets_from_UE_for_FR2_without_TSN
    [Setup]    Test Setup eNB1
    ${alias_for_tcpdump}=    Connect to BTS    ${GNB_1_ADDRESS}
	Attach UE With Pcap Check    ${GNB_1_CELL_1_ID}    ${ENB_1_CELL_1_ID}
    logger.Log Info to Console    Ping on UE with ${PING_COUNT} packets and ${PACKET_SIZE_LOW} bytes
    ${average_ping_latency}    ${ping_latencies}=    ping.Perform Ping On UE
    ...                                              ${PING_COUNT}
    ...                                              ${PACKET_SIZE_LOW}
    ...                                              ${CORE_IP}
    ...                                              ${TEST_LATENCY_THRESHOLD_TC_13}
    logger.Log Info to Console    Ping on UE ended successfully
    logger.Log Info to Console    Ping latencies: ${ping_latencies}
    logger.Log Info to Console    Average ping latency: ${average_ping_latency} | Threshold: ${TEST_LATENCY_THRESHOLD_TC_13}
    [Teardown]   Test Teardown    logs_gnb1=${True}    logs_gnb2=${False}
    ...                           logs_enb1=${True}    logs_enb2=${False}
