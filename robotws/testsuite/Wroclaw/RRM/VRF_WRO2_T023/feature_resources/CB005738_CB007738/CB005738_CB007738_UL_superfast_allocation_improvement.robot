*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: oleksandr.kulieshov@nokia.com

Library         ute_ue
Library         taf.sbts.oam.coam.admin    WITH NAME   admin
Library         CB005738_CB007738_keywords.py
Resource        ../../resources/ca_IWK.robot
Variables       CB005738_CB007738_keywords.py


*** Variables ***
${NR_DELTA_ID}=                    NR_DELTA                                                               # ID of all NR-related SCF deltas
${LTE_DELTA_ID}=                   LTE_DELTA                                                              # ID of all LTE-related SCF deltas
${NR_CELL_ID}                                                                                             # NR cell ID of the tested NR cell
${GLOBAL_CELL_ID_LTE}                                                                                     # Global cell ID of the tested LTE cell
${GLOBAL_CELL_ID_NR}                                                                                      # Global cell ID of the tested NR cell
${LTE_ID}                                                                                                 # BTS ID of the tested LTE
${NR_ID}                                                                                                  # BTS ID of the tested NR
${DSSNR_DIST_NAME_LTE}                                                                                    # Dist name of DSSNR object on LTE
${NRDSSLTE_DIST_NAME_NR}                                                                                  # Dist name of NRDSSLTE object on NR
${DEFAULT_SYSLOG_IP}=              192.168.255.126                                                        # Default IP for syslog collection
${TRAFFIC_TIME}=                   70s                                                        # Duration of sleep for throughput measurements
${BURST_TRAFFIC}=                  10Mbits/sec                                                # Value of throughput parameter for burst traffic
${NORMAL_TRAFFIC}=                 10Mbits/sec                                                # Value of throughput parameter for non-burst traffic
${PACING_TIMER}=                   130000                                                     # Value of pacing-timer parameter for iperf3
${UL_CRM_LOG_LENGTH}=              350                                                        # Threshold for differentiating between UL/DL CRM logs
${ALLOC_PERIOD_ERROR_THRESHOLD}=   90                                                         # Error threshold for checking CRM allocation period


*** Keywords ***
TC__CB005738_CB007738_UL_superfast_allocation_improvement
    Preconditions
    Step 1: Attach NR UE with UL WITHOUT superfast
    Step 2: Attach NR UE with BURST UL WITHOUT superfast
    Step 3: Attach LTE UE with UL WITHOUT superfast
    Step 4: Attach LTE UE with BURST UL WITHOUT superfast
    Step 5: Change fast allocation parameter to true
    Step 6: Attach NR UE with UL WITH superfast
    Step 7: Attach NR UE with BURST UL WITH superfast
    Step 8: Attach LTE UE with UL WITH superfast
    Step 9: Attach LTE UE with BURST UL WITH superfast
    Step 10: Compare throughputs
    Step 11: Analyse CRM logs


Preconditions
    Log    Start Preconditions...    console=True
    Initial config
    Require UE   UE_1   capabilities=NR_LOCKED_NL
    Require UE   UE_2   capabilities=LTE_LOCKED_WL
    Log    Preconditions finished    console=True


Step 1: Attach NR UE with UL WITHOUT superfast
    Log    Start Step 1...            console=True
    Log    Start syslog collection    console=True
    ${savepoint1} =  syslog.Capture savepoint    alias=master
    ${ul_tput}=   Attach NR UE with UL
    syslog.Collect from savepoint    savepoint=${savepoint1}  destination_file=${LOG_PATH}/syslog_step_1_eNB    alias=master
    Set test variable    ${TPUT_NR_NO_BURST_NO_SUPERFAST}    ${ul_tput}
    Log    Stop syslog collection     console=True
    Log    Step 1 finished            console=True


Step 2: Attach NR UE with BURST UL WITHOUT superfast
    Log    Start Step 2...            console=True
    Log    Start syslog collection    console=True
    ${savepoint2} =  syslog.Capture savepoint    alias=master
    ${ul_tput}=   Attach NR UE with BURST UL
    syslog.Collect from savepoint    savepoint=${savepoint2}  destination_file=${LOG_PATH}/syslog_step_2_eNB    alias=master
    Set test variable    ${TPUT_NR_WITH_BURST_NO_SUPERFAST}    ${ul_tput}
    Log    Stop syslog collection     console=True
    Log    Step 2 finished            console=True


Step 3: Attach LTE UE with UL WITHOUT superfast
    Log    Start Step 3...            console=True
    Log    Start syslog collection    console=True
    ${savepoint3} =  syslog.Capture savepoint    alias=master
    ${ul_tput}=   Attach LTE UE with UL
    syslog.Collect from savepoint    savepoint=${savepoint3}  destination_file=${LOG_PATH}/syslog_step_3_eNB    alias=master
    Set test variable    ${TPUT_LTE_NO_BURST_NO_SUPERFAST}    ${ul_tput}
    Log    Stop syslog collection     console=True
    Log    Step 3 finished            console=True


Step 4: Attach LTE UE with BURST UL WITHOUT superfast
    Log    Start Step 4...            console=True
    Log    Start syslog collection    console=True
    ${savepoint4} =  syslog.Capture savepoint    alias=master
    ${ul_tput}=   Attach LTE UE with BURST UL
    syslog.Collect from savepoint    savepoint=${savepoint4}  destination_file=${LOG_PATH}/syslog_step_4_eNB    alias=master
    Set test variable    ${TPUT_LTE_WITH_BURST_NO_SUPERFAST}    ${ul_tput}
    Log    Stop syslog collection     console=True
    Log    Step 4 finished            console=True


Step 5: Change fast allocation parameter to true
    Log    Start Step 5...    console=True
    Log    Perform delta commissioning in order to turn actLteNrDssFastAlloc on    console=True
    Create delta    ${NR_DELTA_ID}
    Append parameter update to delta    ${NRDSSLTE_DIST_NAME_NR}   actLteNrDssFastAlloc    true   delta_id=${NR_DELTA_ID}

    Create delta    ${LTE_DELTA_ID}
    Append parameter update to delta    ${DSSNR_DIST_NAME_LTE}     actLteNrDssFastAlloc    true   delta_id=${LTE_DELTA_ID}

    ${nr_delta}=   Get Delta   delta_id=${NR_DELTA_ID}
    Perform Delta Recommissioning  ${nr_delta}

    ${lte_delta}=   Get Delta   delta_id=${LTE_DELTA_ID}
    Perform Delta Recommissioning  ${lte_delta}
    Sleep   70s    reason=Wait for cells to properly activate after delta commissioning
    Log    Delta commissioning finished successfully    console=True
    Log    Step 5 finished    console=True


Step 6: Attach NR UE with UL WITH superfast
    Log    Start Step 6...            console=True
    Log    Start syslog collection    console=True
    ${savepoint5} =  syslog.Capture savepoint    alias=master
    ${ul_tput}=   Attach NR UE with UL
    syslog.Collect from savepoint    savepoint=${savepoint5}  destination_file=${LOG_PATH}/syslog_step_6_eNB    alias=master
    Set test variable    ${TPUT_NR_NO_BURST_WITH_SUPERFAST}    ${ul_tput}
    Log    Stop syslog collection     console=True
    Log    Step 6 finished            console=True


Step 7: Attach NR UE with BURST UL WITH superfast
    Log    Start Step 7...            console=True
    Log    Start syslog collection    console=True
    ${savepoint6} =  syslog.Capture savepoint    alias=master
    ${ul_tput}=   Attach NR UE with BURST UL
    syslog.Collect from savepoint    savepoint=${savepoint6}  destination_file=${LOG_PATH}/syslog_step_7_eNB    alias=master
    Set test variable    ${TPUT_NR_WITH_BURST_WITH_SUPERFAST}    ${ul_tput}
    Log    Stop syslog collection     console=True
    Log    Step 7 finished            console=True


Step 8: Attach LTE UE with UL WITH superfast
    Log    Start Step 8...            console=True
    Log    Start syslog collection    console=True
    ${savepoint7} =  syslog.Capture savepoint    alias=master
    ${ul_tput}=   Attach LTE UE with UL
    syslog.Collect from savepoint    savepoint=${savepoint7}  destination_file=${LOG_PATH}/syslog_step_8_eNB    alias=master
    Set test variable    ${TPUT_LTE_NO_BURST_WITH_SUPERFAST}    ${ul_tput}
    Log    Stop syslog collection     console=True
    Log    Step 8 finished            console=True


Step 9: Attach LTE UE with BURST UL WITH superfast
    Log    Start Step 9...            console=True
    Log    Start syslog collection    console=True
    ${savepoint8} =  syslog.Capture savepoint    alias=master
    ${ul_tput}=   Attach LTE UE with BURST UL
    syslog.Collect from savepoint    savepoint=${savepoint8}  destination_file=${LOG_PATH}/syslog_step_9_eNB    alias=master
    Set test variable    ${TPUT_LTE_WITH_BURST_WITH_SUPERFAST}    ${ul_tput}
    Log    Stop syslog collection     console=True
    Log    Step 9 finished            console=True


Step 10: Compare throughputs
    Log     Start Step 10...                                                           console=True
    Log     Compare LTE and NR throughputs with superfast on/off                       console=True
    Log     THROUGHPUTS WITH SUPERFAST ON:                                             console=True
    Log     tput_lte_no_burst_with_superfast: ${TPUT_LTE_NO_BURST_WITH_SUPERFAST}      console=True
    Log     tput_lte_with_burst_with_superfast: ${TPUT_LTE_WITH_BURST_WITH_SUPERFAST}  console=True
    Log     tput_nr_no_burst_with_superfast: ${TPUT_NR_NO_BURST_WITH_SUPERFAST}        console=True
    Log     tput_nr_with_burst_with_superfast: ${TPUT_NR_WITH_BURST_WITH_SUPERFAST}    console=True
    Log     THROUGHPUTS WITH SUPERFAST OFF:                                            console=True
    Log     tput_lte_no_burst_no_superfast: ${TPUT_LTE_NO_BURST_NO_SUPERFAST}          console=True
    Log     tput_lte_with_burst_no_superfast: ${TPUT_LTE_WITH_BURST_NO_SUPERFAST}      console=True
    Log     tput_nr_no_burst_no_superfast: ${TPUT_NR_NO_BURST_NO_SUPERFAST}            console=True
    Log     tput_nr_with_burst_no_superfast: ${TPUT_NR_WITH_BURST_NO_SUPERFAST}        console=True


    compare_superfast_throughputs_for_lte   ${TPUT_LTE_NO_BURST_WITH_SUPERFAST}     ${TPUT_LTE_NO_BURST_NO_SUPERFAST}
    ...                                     ${TPUT_LTE_WITH_BURST_WITH_SUPERFAST}   ${TPUT_LTE_WITH_BURST_NO_SUPERFAST}

    compare_superfast_throughputs_for_nr    ${TPUT_NR_NO_BURST_WITH_SUPERFAST}      ${TPUT_NR_NO_BURST_NO_SUPERFAST}
    ...                                     ${TPUT_NR_WITH_BURST_WITH_SUPERFAST}    ${TPUT_NR_WITH_BURST_NO_SUPERFAST}
    Log    Step 10 finished    console=True


Step 11: Analyse CRM logs
    Log    Start Step 11...    console=True
    Log    Check whether there is a 10ms period between each allocation in CRM logs    console=True

    Log   Check CRM from NR call    console=True
    analyse_crm_logs_with_superfast       ${LOG_PATH}/syslog_step_7_eNB    ${TRUNK_SW}
    Log   CRM logs analysed successfully for NR call    console=True

    Log   Check CRM from LTE call                       console=True
    analyse_crm_logs_with_superfast       ${LOG_PATH}/syslog_step_9_eNB    ${TRUNK_SW}
    Log   CRM logs analysed successfully for LTE call    console=True
    Log    Step 11 finished                              console=True


Initial config
    Log    Performing delta commissioning   console=True
    Create delta    ${NR_DELTA_ID}

    ${lteNrDssUlRatio_nr}=   Create dictionary     minNrDssRatio=5    maxNrDssRatio=70
    Append complex item to delta     ${NRDSSLTE_DIST_NAME_NR}   lteNrDssUlRatio   delta_id=${NR_DELTA_ID}   &{lteNrDssUlRatio_nr}

    ${lteNrDssDlRatio_nr}=   Create dictionary     dlResourceSharingAlgo=DL PRB load based    minNrDssRatio=5    maxNrDssRatio=100
    Append complex item to delta     ${NRDSSLTE_DIST_NAME_NR}   lteNrDssDlRatio   delta_id=${NR_DELTA_ID}   &{lteNrDssDlRatio_nr}

    Append parameter update to delta   ${NRDSSLTE_DIST_NAME_NR}      actLteNrDssFastAlloc   false   delta_id=${NR_DELTA_ID}


    Create delta    ${LTE_DELTA_ID}

    ${lteNrDssUlRatio_lte}=   Create dictionary     minNrDssRatio=5    maxNrDssRatio=70    dssNrRelSchedWeight=1    dssLteRelSchedWeight=1
    Append complex item to delta       ${DSSNR_DIST_NAME_LTE}   lteNrDssUlRatio   delta_id=${LTE_DELTA_ID}   &{lteNrDssUlRatio_lte}

    ${lteNrDssDlRatio_lte}=   Create dictionary     dlResourceSharingAlgo=DL PRB load based    minNrDssRatio=5    maxNrDssRatio=100
    ...                                             dssNrRelSchedWeight=1    dssLteRelSchedWeight=1
    Append complex item to delta       ${DSSNR_DIST_NAME_LTE}   lteNrDssDlRatio   delta_id=${LTE_DELTA_ID}   &{lteNrDssDlRatio_lte}

    Append parameter update to delta   ${DSSNR_DIST_NAME_LTE}      actLteNrDssFastAlloc   false   delta_id=${LTE_DELTA_ID}


    ${lte_delta}=   Get delta   delta_id=${LTE_DELTA_ID}
    Perform delta recommissioning  ${lte_delta}

    ${nr_delta}=   Get delta   delta_id=${NR_DELTA_ID}
    Perform delta recommissioning  ${nr_delta}
    Log    BTS parameters were modified successfully   console=True
    Sleep   60s    reason=Wait for cells to properly activate after delta commissioning


Attach NR UE with UL
    Log    Attach NR UE    console=True
    Prepare UE for data transfer    ue_alias=UE_1    cell_id=${NR_CELL_ID}
    Log    Start normal UL traffic    console=True
    Start data transfer   dt_name=DT_UL_1         ue_alias=UE_1                   direction=ul     duration=100s
    ...                   packet_size=1400        throughput=${NORMAL_TRAFFIC}    protocol=udp     apn=${APN}
    Sleep    ${TRAFFIC_TIME}
    ${ul_tput}=    Get average throughput       dt_name=DT_UL_1    omit=5    end=60
    Log   Stop NR traffic   console=True
    Stop data transfer   dt_name=DT_UL_1
    Log   Detach NR UE   console=True
    Detach UE    UE_1

    [Return]   ${ul_tput}


Attach NR UE with BURST UL
    Log    Attach NR UE    console=True
    Prepare UE for data transfer    ue_alias=UE_1    cell_id=${NR_CELL_ID}
    Log    Start bursty UL traffic    console=True
    Start data transfer   dt_name=DT_UL_1             ue_alias=UE_1                  direction=ul      duration=100s
    ...                   packet_size=1400            throughput=${BURST_TRAFFIC}    protocol=udp      apn=${APN}
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}

    Sleep    ${TRAFFIC_TIME}
    ${ul_tput}=    Get average throughput       dt_name=DT_UL_1    omit=5    end=60
    Log   Stop NR traffic   console=True
    Stop data transfer   dt_name=DT_UL_1
    Log   Detach NR UE   console=True
    Detach UE    UE_1

    [Return]   ${ul_tput}


Attach LTE UE with UL
    Log    Attach LTE UE    console=True
    Prepare UE for data transfer    ue_alias=UE_2    cell_id=${GLOBAL_CELL_ID_LTE}
    Log    Start normal UL traffic    console=True
    Start data transfer   dt_name=DT_UL_2      ue_alias=UE_2                   direction=ul          duration=100s
    ...                   packet_size=1400     throughput=${NORMAL_TRAFFIC}    protocol=udp          apn=${APN}

    Sleep    ${TRAFFIC_TIME}
    ${ul_tput}=    Get average throughput       dt_name=DT_UL_2    omit=5    end=60
    Log   Stop LTE traffic   console=True
    Stop data transfer   dt_name=DT_UL_2
    Log   Detach LTE UE   console=True
    Detach UE    UE_2

    [Return]   ${ul_tput}


Attach LTE UE with BURST UL
    Log    Attach LTE UE    console=True
    Prepare UE for data transfer    ue_alias=UE_2    cell_id=${GLOBAL_CELL_ID_LTE}
    Log    Start bursty UL traffic    console=True
    Start data transfer   dt_name=DT_UL_2             ue_alias=UE_2                   direction=ul       duration=100s
    ...                   packet_size=1400            throughput=${BURST_TRAFFIC}     protocol=udp       apn=${APN}
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}

    Sleep    ${TRAFFIC_TIME}
    ${ul_tput}=    Get average throughput       dt_name=DT_UL_2    omit=5    end=60
    Log   Stop LTE traffic   console=True
    Stop data transfer   dt_name=DT_UL_2
    Log   Detach LTE UE   console=True
    Detach UE    UE_2

    [Return]   ${ul_tput}


TC setup
    Inter RAT Test Setup


TC teardown
    Stop data transfers for all UEs
    Detach UE    UE_1
    Detach UE    UE_2
    Inter RAT Test Teardown
