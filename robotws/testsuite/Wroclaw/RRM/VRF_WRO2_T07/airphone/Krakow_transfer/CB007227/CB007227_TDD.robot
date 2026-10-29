*** Settings ***

Documentation
...   author: Justyna Balcerzak, Mateusz Adamek
...   contact: justyna.balcerzak@nokia.com, mateusz.adamek@nokia.com
...   description: CB007227

Library    ute_fsmaccess
Library    ute_wtssim
Library    ta5g_enb
Library    ta5g_iphy
Library    ta5g_egate
Library    ta5g_tshark
Library    ta_messaging
Library    ta5g_throughput
Library    ta_egate_cmd_parser
Library    ta5g_testline_management
Library    ta5g_delta
Library    ta5g_setups_and_teardowns


Library    ../../../../sim_resources/Krk_regression/CB007227/resources/pcap_verify.py       WITH NAME   pcap_verify
Library    ../../../../sim_resources/Krk_regression/CB007227/resources/egate_actions.py    WITH NAME   egate_actions
Library    ../../../../sim_resources/Krk_regression/CB007227/resources/dcap_keywords.py    WITH NAME   dcap_keywords
Library    ../../../../sim_resources/Krk_regression/CB007227/resources/suite_specific_keywords.py   WITH NAME   suite_specific_keywords
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts    WITH NAME   common_wts
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters   WITH NAME   pm_counters

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   ../../../../sim_resources/Krk_regression/CB007227/resources/keywords.robot



Suite Setup    Run keywords     dcap_keywords.enable_dcap
...                     AND     dcap_keywords.print_dcap_basic_controller_version
...                     AND     Set variables based on deployment and release
...                     AND     Add CCS Decode To Wireshark
...                     AND     Add ntrstr Preference To Wireshark Config
...                     AND     Add SysCom Preference To Wireshark Config
... 			        AND     Backup And Modify Swconfig File    parameters_list=@{swconfig_rndFlag}
...                     AND     Reset Testline And Wait For Rmods

Variables    ../../../../sim_resources/Krk_regression/CB007227/resources/variables.py


*** Variables ***
@{swconfig_rndFlag}=    0xA40000=0

*** Test Cases ***
# Test transferred from Krakow, will be rewritten
[1]CB007227-C#006_TDD_SANSA_L2-Lo_DU_PCMD_with_L2_Lo_DU_PCMD_Trace_Report_Framework_activated_in_parallel_actvation_deactivation_verification_4UE
     [Tags]      CLOUD_5G_I_MP_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD    CRT    RF50
    [Setup]     Run Keywords    suite_specific_keywords.prepare_delta_for_tc_C05_C06_C014     delta_path=${delta_split_C}
    ...                 AND     Prepare environment     sib1_reception_dict=${CELLS_ENBx1_GNBx1}
    ...                 AND     suite_specific_keywords.start_collecting_logs

    ${ue_1} =     Set Variable    1
    ${ue_2} =     Set Variable    2
    ${pdu_1} =    Set Variable    1
    ${pdu_2} =    Set Variable    2
    ${ue_11} =    Set Variable    11
    ${ue_12} =    Set Variable    12

    ${counters_list} =    Create List    ${PDCP_SDU_DATA_VOL_DL_SLICE}
    ...                                  ${DL_PDCP_VOL_RCV_F1_QoS_GRP_09}

    ${traffic_time_duration} =   Set Variable    130
    ${time_delay} =    Set Variable    25

    dcap_keywords.configure_dcap
    dcap_keywords.stop_dcap_collecting_if_exist
    ${trace_id_1} =    dcap_keywords.start_dcap_pcmd_and_emil_collecting

    suite_specific_keywords.change_rdL2LoTraceEnabled_rad_parameters     value=0

    Start L2 PCMD Trace Report Framework Logs Collecting     step=1

    egate_actions.prepare_internal_traffic_generator    ue_id=${ue_1}    pdu_id=${pdu_1}
    egate_actions.prepare_internal_traffic_generator    ue_id=${ue_2}    pdu_id=${pdu_2}

    Attach UE and Establish PDU session    ue_id=${ue_1}    pdu_id=${pdu_1}
    Attach UE and Establish PDU session    ue_id=${ue_2}    pdu_id=${pdu_2}

    common_wts.setup_x2_link
    common_wts.attach_ue_and_perform_sgnb_addition  ue_id=${ue_11}    bearer=2    cell_id=1   enb_id=2    profile=1   timeout=15
    common_wts.attach_ue_and_perform_sgnb_addition  ue_id=${ue_12}    bearer=2    cell_id=2   enb_id=2    profile=1   timeout=15

    pm_counters.wait_for_next_pm_period      interval=${PM_INTERVAL}    delay=${time_delay}

    ${start_time_step1_ue1} =   egate_actions.start_traffic_stream
    ...                         ue=${ue_1}    pdu=${pdu_1}    qfi=1    dir=dl    trf_id=1    mbps=15    seconds=${traffic_time_duration}
    ${start_time_step1_ue2} =   egate_actions.start_traffic_stream
    ...                         ue=${ue_2}    pdu=${pdu_2}    qfi=1    dir=dl    trf_id=2    mbps=20    seconds=${traffic_time_duration}
    ${start_time_step1_ue11} =  egate_actions.start_traffic_stream
    ...                         ue=${ue_11}    id=2    dir=dl    trf_id=1    mbps=25    seconds=${traffic_time_duration}
    ${start_time_step1_ue12} =  egate_actions.start_traffic_stream
    ...                         ue=${ue_12}    id=2    dir=dl    trf_id=2    mbps=30    seconds=${traffic_time_duration}

    pm_counters.wait_for_next_pm_period      interval=${PM_INTERVAL}    delay=${time_delay}

    ${counters_data} =   pm_counters.get_pm_counters_values  counter_ids_list=${counters_list}    csv_filepath=${OUTPUT_DIR}/${TEST_PREFIX}/counters

    Validate throughput C005 C006    counters_data=${counters_data}    timestamp_offset=${0}

    Stop L2 PCMD Trace Report Framework Logs Collecting
    dcap_keywords.stop_dcap_collecting    trace_id=${trace_id_1}
    dcap_keywords.stop_dcap_collecting_if_exist

    ${trace_id_2} =    dcap_keywords.start_dcap_pcmd_and_emil_collecting

    suite_specific_keywords.change_rdL2LoTraceEnabled_rad_parameters     value=1
    Start L2 PCMD Trace Report Framework Logs Collecting     step=2

    ${start_time_step2_ue1} =   egate_actions.start_traffic_stream
    ...                         ue=${ue_1}    pdu=${pdu_1}    qfi=1    dir=dl    trf_id=1    mbps=15    seconds=${traffic_time_duration}
    ${start_time_step2_ue2} =   egate_actions.start_traffic_stream
    ...                         ue=${ue_2}    pdu=${pdu_2}    qfi=1    dir=dl    trf_id=2    mbps=20    seconds=${traffic_time_duration}
    ${start_time_step2_ue11} =  egate_actions.start_traffic_stream
    ...                         ue=${ue_11}    id=2     dir=dl    trf_id=1    mbps=25    seconds=${traffic_time_duration}
    ${start_time_step2_ue12} =  egate_actions.start_traffic_stream
    ...                         ue=${ue_12}    id=2     dir=dl    trf_id=2    mbps=30    seconds=${traffic_time_duration}

    pm_counters.wait_for_next_pm_period    interval=${PM_INTERVAL}    delay=${time_delay}

    ${counters_data} =   pm_counters.get_pm_counters_values    counter_ids_list=${counters_list}    csv_filepath=${OUTPUT_DIR}/${TEST_PREFIX}/counters
    Validate throughput C005 C006    counters_data=${counters_data}    timestamp_offset=${0}

    Stop L2 PCMD Trace Report Framework Logs Collecting
    dcap_keywords.stop_dcap_collecting    trace_id=${trace_id_2}

    dcap_keywords.stop_dcap_collecting_if_exist

    ${trace_id_3} =    dcap_keywords.start_dcap_pcmd_and_emil_collecting

    suite_specific_keywords.change_rdL2LoTraceEnabled_rad_parameters     value=0
    Start L2 PCMD Trace Report Framework Logs Collecting     step=3

    ${start_time_step3_ue1} =  egate_actions.start_traffic_stream
    ...                        ue=${ue_1}    pdu=${pdu_1}    qfi=1    dir=dl    trf_id=1    mbps=15    seconds=${traffic_time_duration}
    ${start_time_step3_ue2} =  egate_actions.start_traffic_stream
    ...                        ue=${ue_2}    pdu=${pdu_2}    qfi=1    dir=dl    trf_id=2    mbps=20    seconds=${traffic_time_duration}
    ${start_time_step3_ue11} =  egate_actions.start_traffic_stream
    ...                         ue=${ue_11}    id=2    dir=dl    trf_id=1    mbps=25    seconds=${traffic_time_duration}
    ${start_time_step3_ue12} =  egate_actions.start_traffic_stream
    ...                         ue=${ue_12}    id=2    dir=dl    trf_id=2    mbps=30    seconds=${traffic_time_duration}

    pm_counters.wait_for_next_pm_period    interval=${PM_INTERVAL}    delay=${time_delay}

    ${counters_data} =   pm_counters.get_pm_counters_values    counter_ids_list=${counters_list}    csv_filepath=${OUTPUT_DIR}/${TEST_PREFIX}/counters

    Validate throughput C005 C006    counters_data=${counters_data}    timestamp_offset=${0}

    egate_actions.pdu_session_release    ue_id=${ue_1}    pdu_id=${pdu_1}
    egate_actions.pdu_session_release    ue_id=${ue_2}    pdu_id=${pdu_2}
    egate_actions.deregister_given_ue    ue_id=${ue_1}
    egate_actions.deregister_given_ue    ue_id=${ue_2}

    egate_actions.detach_ue    ue=${ue_11}    bearer=2    by=enb    cause=MISC_CauseMisc_unspecified
    egate_actions.detach_ue    ue=${ue_12}    bearer=2    by=enb    cause=MISC_CauseMisc_unspecified

    Stop L2 PCMD Trace Report Framework Logs Collecting
    dcap_keywords.stop_dcap_collecting    trace_id=${trace_id_3}
    dcap_keywords.stop_dcap_collecting_if_exist

    dcap_keywords.extract_ipCapture_from_all_dcap_packages

    Validate test C005 C006 for ue      ue_id=${ue_1}    time_step_1=${start_time_step1_ue1}
    ...                                 time_step_2=${start_time_step2_ue1}    time_step_3=${start_time_step3_ue1}
    Validate test C005 C006 for ue      ue_id=${ue_2}    time_step_1=${start_time_step1_ue2}
    ...                                 time_step_2=${start_time_step2_ue2}    time_step_3=${start_time_step3_ue2}
    Validate test C005 C006 for ue      ue_id=${ue_11}   time_step_1=${start_time_step1_ue11}
    ...                                 time_step_2=${start_time_step2_ue11}    time_step_3=${start_time_step3_ue11}
    Validate test C005 C006 for ue      ue_id=${ue_12}   time_step_1=${start_time_step1_ue12}
    ...                                 time_step_2=${start_time_step2_ue12}    time_step_3=${start_time_step3_ue12}

    [Teardown]    Run Keywords    Teardown collecting logs in robot
    ...                    AND    suite_specific_keywords.perform_recomissioning_with_delta   path_to_delta=${cleanup_delta_split_C}
    ...                    AND    dcap_keywords.stop_dcap_collecting_if_exist


# Test transferred from Krakow, will be rewritten
[1]CB007227-D#005_TDD_SANSA_L2_Hi_CU_PCMD_Trace_Report_Framework_DL_UL_PDCP_volume_data_verification_actvation_deactivation_verification_2UE
    [Tags]      CLOUD_5G_I_MP_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD    RF50
    [Setup]     Run Keywords    suite_specific_keywords.prepare_delta_for_tc_D003_D011_D004     delta_path=${delta_split_D}
    ...                 AND     suite_specific_keywords.add_rdL2HiPcmdTraceReportEnabled_flag_to_swconfig
    ...                 AND     Prepare environment     sib1_reception_dict=${CELLS_ENBx1_GNBx1}
    ...                 AND     suite_specific_keywords.start_collecting_logs

    ${ue_1} =      Set Variable    1
    ${ue_11} =     Set Variable    11
    ${pdu_1} =     Set Variable    1
    ${time_delay} =     Set Variable    25
    ${traffic_duration} =   Set Variable   300
    ${pm_period_advance} =  Set Variable    10
    ${traffic_duration_scheduled} =   Evaluate    ${traffic_duration} + ${pm_period_advance}

    ${counters_list} =    Create List    ${PDCP_SDU_DATA_VOL_DL_SLICE}
    ...                                  ${PDCP_SDU_DATA_VOL_UL_SLICE}
    ...                                  ${DL_PDCP_VOL_RCV_F1_QoS_GRP_09}
    ...                                  ${UL_PDCP_VOL_SNT_F1_QoS_GRP_09}

    change_rdPdcpPcmdTraceReportEnabled_rad_parameter    value=0
    Start L2 PCMD Trace Report Framework Logs Collecting    step=1
    egate_actions.prepare_internal_traffic_generator    ue_id=${ue_1}    pdu_id=${pdu_1}
    Attach UE and Establish PDU session    ue_id=${ue_1}    pdu_id=${pdu_1}

    common_wts.setup_x2_link
    common_wts.attach_ue_and_perform_sgnb_addition    ue_id=${ue_11}    bearer=2    cell_id=1    enb_id=2    profile=1    timeout=15

    pm_counters.wait_for_next_pm_period_with_advance     interval=${PM_INTERVAL}    advance=${pm_period_advance}

    ${start_time_step1_ue1} =    egate_actions.start_traffic_stream    ue=${ue_1}    pdu=${pdu_1}    qfi=1    dir=dl    trf_id=1
    ...                          mbps=${D004_D005_DL_MBPS_SA}    seconds=${traffic_duration_scheduled}

    egate_actions.start_traffic_stream    ue=${ue_1}    pdu=${pdu_1}    qfi=1    dir=ul    trf_id=1
    ...                                   mbps=${D004_D005_UL_MBPS_SA}    seconds=${traffic_duration_scheduled}

    ${start_time_step1_ue11} =    egate_actions.start_traffic_stream    ue=${ue_11}    id=2    dir=dl    trf_id=1
    ...                           mbps=${D004_D005_DL_MBPS_NSA}    seconds=${traffic_duration_scheduled}

    egate_actions.start_traffic_stream    ue=${ue_11}    id=2    dir=ul    trf_id=1    mbps=${D004_D005_UL_MBPS_NSA}
    ...                                   seconds=${traffic_duration_scheduled}

    Wait for throughput stable    sec=${pm_period_advance}

    pm_counters.wait_for_next_pm_period    interval=${PM_INTERVAL}

    Stop L2 PCMD Trace Report Framework Logs Collecting

    change_rdPdcpPcmdTraceReportEnabled_rad_parameter    value=1

    Start L2 PCMD Trace Report Framework Logs Collecting    step=2

    ${pm_period_start_time_step2}=   pm_counters.wait_for_next_pm_period_with_advance    interval=${PM_INTERVAL}    advance=${pm_period_advance}
    ${start_time_step_2}=    suite_specific_keywords.Count Start Traffic Time With Advance    start_time=${pm_period_start_time_step2}
    ...                                                                                       advance=${pm_period_advance}

    ${start_time_dl_step2_ue1} =   egate_actions.start_traffic_stream    ue=${ue_1}    pdu=${pdu_1}    qfi=1    dir=dl    trf_id=1
    ...                                                                  mbps=${D004_D005_DL_MBPS_SA}     seconds=${traffic_duration_scheduled}
    ${start_time_ul_step2_ue1} =   egate_actions.start_traffic_stream    ue=${ue_1}    pdu=${pdu_1}    qfi=1    dir=ul    trf_id=1
    ...                                                                  mbps=${D004_D005_UL_MBPS_SA}     seconds=${traffic_duration_scheduled}
    ${start_time_dl_step2_ue11} =  egate_actions.start_traffic_stream    ue=${ue_11}   id=2    dir=dl    trf_id=1
    ...                                                                  mbps=${D004_D005_DL_MBPS_NSA}    seconds=${traffic_duration_scheduled}
    ${start_time_ul_step2_ue11} =  egate_actions.start_traffic_stream    ue=${ue_11}   id=2    dir=ul    trf_id=1
    ...                                                                  mbps=${D004_D005_UL_MBPS_NSA}    seconds=${traffic_duration_scheduled}

    Wait for throughput stable    sec=${pm_period_advance}

    pm_counters.wait_for_next_pm_period    interval=${PM_INTERVAL}

    Stop L2 PCMD Trace Report Framework Logs Collecting

    change_rdPdcpPcmdTraceReportEnabled_rad_parameter    value=0

    pm_counters.wait_for_next_pm_period_with_advance    interval=${PM_INTERVAL}    advance=${pm_period_advance}

    Start L2 PCMD Trace Report Framework Logs Collecting    step=3

    ${start_time_step3_ue1} =   egate_actions.start_traffic_stream    ue=${ue_1}    pdu=${pdu_1}    qfi=1    dir=dl    trf_id=1
    ...                                                               mbps=${D004_D005_DL_MBPS_SA}  seconds=${traffic_duration_scheduled}

    egate_actions.start_traffic_stream    ue=${ue_1}    pdu=${pdu_1}    qfi=1    dir=ul    trf_id=1
    ...                                   mbps=${D004_D005_UL_MBPS_SA}    seconds=${traffic_duration_scheduled}

    ${start_time_step3_ue11} =  egate_actions.start_traffic_stream    ue=${ue_11}    id=2    dir=dl    trf_id=1
    ...                                                               mbps=${D004_D005_DL_MBPS_NSA}    seconds=${traffic_duration_scheduled}

    egate_actions.start_traffic_stream    ue=${ue_11}    id=2    dir=ul    trf_id=1
    ...                                   mbps=${D004_D005_UL_MBPS_NSA}    seconds=${traffic_duration_scheduled}

    Wait for throughput stable    sec=${pm_period_advance}

    pm_counters.wait_for_next_pm_period     interval=${PM_INTERVAL}

    Stop L2 PCMD Trace Report Framework Logs Collecting

    ${counters_data} =  pm_counters.get_pm_counters_values    counter_ids_list=${counters_list}    csv_filepath=${OUTPUT_DIR}/${TEST_PREFIX}/counters

    egate_actions.pdu_session_release    ue_id=${ue_1}    pdu_id=${pdu_1}
    egate_actions.deregister_given_ue    ue_id=${ue_1}
    egate_actions.detach_ue    ue=${ue_11}    bearer=2    by=enb    cause=MISC_CauseMisc_unspecified

    ###VALIDATION###
    ###STEP_1###
    Validate throughput D004    counters_data=${counters_data}    timestamp_offset=${4}
    pcap_verify.check_the_message_itf_l2_hi_cu_trace_XxRadioBearerPdcpMeasData_not_exist    step=1
    ############
    ###STEP_2###
    Validate test D004 for ue  ue_id=${ue_1}    start_time=${start_time_step_2}    traffic_duration=${traffic_duration}
    ...                        counters_data=${counters_data}    timestamp_offset=${2}    step=2
    Validate test D004 for ue  ue_id=${ue_11}   start_time=${start_time_step_2}    traffic_duration=${traffic_duration}
    ...                        counters_data=${counters_data}    timestamp_offset=${2}    step=2
    pcap_verify.validate_syscom_message_length  direction=dl    start_time=${start_time_step_2}    traffic_duration=${traffic_duration}    step=2
    ############
    ###STEP_3###
    Validate throughput D004    counters_data=${counters_data}    timestamp_offset=${0}
    pcap_verify.check_the_message_itf_l2_hi_cu_trace_XxRadioBearerPdcpMeasData_not_exist    step=3
    ############
    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...                    AND    Teardown collecting logs in robot
    ...                    AND    suite_specific_keywords.perform_recomissioning_with_delta   path_to_delta=${cleanup_delta_split_D}


