*** Settings ***

Documentation
...   description: CB002271
...   last update: scout data and RF50 fixes

Library         5GC002271-lib.py
Library         taf.sbts.oam.coam.admin     WITH NAME    admin
Library         taf.converters.pcaptopdml     WITH NAME    pcaptopdml
Library         taf.wts.config
Library          ../../resources_KRK/conformance_tests/luashark_tools.py
Library          luashark_tools.analyzer       WITH NAME       analyzer_pdml
Library         ute_wtssim
Library         ute_fsmaccess
Library         ta5g_commissioning
Library         ta5g_enb
Library         ta5g_egate
Library         ta5g_tshark
Library         ta5g_iphy
Library         ta5g_ue_mobility
Library         taf.sbts.oam.coam.admin
Library         taf.sw.scout                               WITH NAME    scout
Library         taf.sw.reporting_portal                    WITH NAME    reporting_portal

Resource        ../../../../resources/SWENG/robot/Setup.robot

Resource        ../../resources_KRK/krk3_common/utilities.robot
Resource        CB007090-variables.robot
Resource        CB007090-keywords.robot
Resource        5GC002493-keywords.robot
Resource        ../../resources_KRK/external/ttitrace.robot
Variables       ue-cap-variables.py

*** Variables ***
${DEFAULT_WTS_CFG}     /opt/wts/latest/basic_setup.cfg
${TTI_TRACE_CSV}       ${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv
${filter_udp_tcp_packets}          !aasyslog && !tcp && !arp && !icmp &&!icmpv6 && !udp
${egate_console_log}    /opt/wts/latest/egate_console.log
${A_d_32_cfg}     ${OUTPUT_DIR}/testsuite/Paris/RRM/ET/5GC002271/resources/wts_config_a_d_tc32.cfg

*** Keywords ***
Set and start capture CPRT
    ${capture_cprt}       Capture CPRT Set Upon Config
    Capture init	   	  ${capture_cprt}
	Capture start		  ${capture_cprt}
	Set suite variable    ${capture_cprt}

Add UE with skipUplink and without Drx capability for FDD NSA
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=12
    ...         ue_type=NSA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${skip_uplink_tx_dynamic_fdd_nsa_without_drx}
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}

Add 1 NSA UEs with skipUplinkTxDynamic and DRX capabilities
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=12
    ...         ue_type=NSA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${skip_uplink_tx_dynamic_fdd_nsa_drx}
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}

Add UEs from UE-${first_ue} to UE-${last_ue} with basic capabilities for BL TDD SA
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=${first_ue}-${last_ue}
    ...         ue_type=SA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${default_bl_tdd_sa}
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}

Add UEs from UE-${first_ue} to UE-${last_ue} with skipUplinkTxDynamic and DRX capabilities for NSA TDD
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=${first_ue}-${last_ue}
    ...         ue_type=NSA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${skip_uplink_tx_dynamic_tdd_nsa_drx}
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}

Add 7 SA UEs with basic capabilities for BL FDD
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=2-8
    ...         ue_type=SA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${default_bl_fdd_sa}
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}

Add UE with skipUplink and with skipUplinkEnhanced and with Drx capability for TDD SA with id ${id}
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=${id}
    ...         ue_type=SA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${skip_uplink_enhanced_drx_tdd_sa}
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}

Add UE with skipUplink and without skipUplinkEnhanced and with Drx capability for TDD SA with id ${id}
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=${id}
    ...         ue_type=SA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${skip_uplink_dynamic_and_drx_tdd_sa}
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}

Add UEs from UE-${first_ue} to UE-${last_ue} with basic capabilities for SA LO_AP_LO TDD
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=${first_ue}-${last_ue}
    ...         ue_type=SA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${default_lo_ap_lo_tdd_sa}
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}


Add 5 NSA UEs with basic capabilities
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=12-16
    ...         ue_type=NSA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${skip_uplink_tx_dynamic_fdd_nsa_without_drx}
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}

Stop CPRT capture
    ${cprt_pcap_path}      Capture stop		${capture_cprt}
    Set suite variable        ${cprt_pcap_path}

Set L1L2 capture
    ${capture_var_l1l2}        Capture L1L2 Set Upon Config
    Capture init		${capture_var_l1l2}
	Capture start		${capture_var_l1l2}
	Set suite variable      ${capture_var_l1l2}

Stop L1L2 capture
    ${bip_pcap_path}      Capture stop		 ${capture_var_l1l2}
    Set suite variable        ${bip_pcap_path}

Establish X2 Link
    establish_connection_with_x2_link     enb_id=1  target_id=2
    sleep     5s

Verify that ${message} contains ${field} equal to ${value}
    Log to console        Verify that ${message} contains ${field} equal to ${value}
    verify_that_a_specific_message_meets_the_post_conditions_criteria       message=${message}
    ...                                                                     field=${field}
    ...                                                                     value=${value}
    ...                                                                     pdml_file=${filtered_pdml_file}

Modify ${parameter} parameter and set to ${value} in ${object} with the type of operation set to ${operation}
    admin.Setup admin
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/${object}
    ...    parameter=${parameter}
    ...    operation=${operation}
    ...    value=${value}
    ...    skip_parameter_relation_errors=True
    admin.Teardown admin

Force DTX detection with profile id ${profile_id} and force_dtx_pusch time:interval ${force_dtx_pusch}
    [Documentation]   Force DTX detection parameters explanation
    ...   Usage example of force_dtx_pusch: total:interval - for example "10:25"

    start_dtx_detection                                       profile_id=${profile_id}
    ...                                                       force_dtx_pusch=${force_dtx_pusch}
    sleep       1s

Set testmode of the ue with id ${id} and profile_id ${profile_id}
    [Documentation]   Set testmode of the ue parameters explanation
    ...   Usage example of testmode: Testmode to be used - for example "forced_dtx"
    ...   Usage example of action: Triggers the activation or the deactivation of the test mode - for example "activate"

    set_ue_testmode                                           id_testmode=${id}
    ...                                                       testmode=forced_dtx
    ...                                                       profile_id=${profile_id}
    ...                                                       action=activate
    sleep       1s

Verify that counter is equal to a specific value in PM Counter file
    [Arguments]      ${counter}      ${value}     ${pm_counter_path}
    ${counter_list}=    Create List    ${counter}
    pmcounter.verify_if_latest_pm_counters_in_counter_id_list_have_exact_value
    ...    counter_id_list=${counter_list}
    ...    value=${value}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${pm_counter_path}


Verify that SR pools counters are equal to a specific value
    [Arguments]       ${value}       ${pm_counter_path}
    ${sr_pools_counters_except_sr20_sr40}=     Create List        M55165C00007    M55165C00008    M55165C00011    M55165C00012
    pmcounter.verify_if_latest_pm_counters_in_counter_id_list_have_exact_value
    ...    counter_id_list=${sr_pools_counters_except_sr20_sr40}
    ...    value=${value}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${pm_counter_path}

Verify that counter is bigger than a specific value in PM Counter file
    [Arguments]      ${counter}     ${base_value}     ${pm_counter_path}
    ${counter_list}=    Create List    ${counter}
    pmcounter.verify_if_latest_pm_counters_from_the_list_are_bigger_than_the_given_value
    ...    counter_list=${counter_list}
    ...    value=${base_value}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${pm_counter_path}

Start ${data_rate} ${order} ${dir} bursty traffic of ${burst} with ${period} ms period for UEs from UE-${first_ue_id} to UE-${last_ue_id} in ${mode}
    ${dir}=         Convert To Lower Case       ${dir}
    Run keyword if     '${mode}' =='NSA'        start_data_traffic_for_multiple_ues
    ...          first_ue_id=${first_ue_id}        last_ue_id=${last_ue_id}    mode=${mode}      order=${order}
    ...          dir=${dir}         id=2         mbps=${data_rate}     burst=${burst}     period_ms=${period}
    Run keyword if     '${mode}' == 'SA'        start_data_traffic_for_multiple_ues
    ...          first_ue_id=${first_ue_id}        last_ue_id=${last_ue_id}     mode=${mode}       order=${order}
    ...          pdu=1      qfi=1       dir=${dir}       mbps=${data_rate}     burst=${burst}     period_ms=${period}


Start ${dir} traffic with burst=${burst} and size=${size} and period=${period} for UE-${ue_id} in ${mode} Mode
    Log to console  Start ${dir} traffic with burst=${burst} and size=${size} and period=${period} for UE-${ue_id} in ${mode} Mode
    ${dir}=         Convert To Lower Case       ${dir}

    start_data_traffic_for_ue_in_sa_nsa_configuration         mode=${mode}
    ...                                                       ue=${ue_id}
    ...                                                       dir=${dir}
    ...                                                       mbps=1
    ...                                                       id=2
    ...                                                       burst=${burst}
    ...                                                       size=${size}
    ...                                                       period_ms=${period}

Convert TTI trace from csv to dict
    ${tti_trace_dict}    read_and_parse_tti_data    ${TTI_TRACE_CSV}
    Set suite variable    ${tti_trace_dict}


Verify that retransmission for proactive grant is not started
    FOR    ${separate_csv}    IN    @{separate_tti_file_list}
        set test variable    ${TTI_TRACE_CSV}    ${separate_csv}
        Convert TTI trace from csv to dict
        verify_that_retransmission_for_skippable_grant_is_not_started    tti_trace_dict=${tti_trace_dict}
    END
    set test variable    ${TTI_TRACE_CSV}    ${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv

Verify that retransmission is started for non-proactive grant
    FOR    ${separate_csv}    IN    @{separate_tti_file_list}
        set test variable    ${TTI_TRACE_CSV}    ${separate_csv}
        Convert TTI trace from csv to dict
        verify_that_retransmission_is_started_for_non_proactive_grant    tti_trace_dict=${tti_trace_dict}
    END
    set test variable    ${TTI_TRACE_CSV}    ${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv

Verify that there is no retransmission for fake Scheduling Request
    FOR    ${separate_csv}    IN    @{separate_tti_file_list}
        set test variable    ${TTI_TRACE_CSV}    ${separate_csv}
        Convert TTI trace from csv to dict
        verify_that_there_is_no_retransmission_for_fake_sr    tti_trace_dict=${tti_trace_dict}
    END
    set test variable    ${TTI_TRACE_CSV}    ${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv

Filter CPRT pcap and remove not needed packets
    ${cprt_file_without_tcp_udp}     analyzer_pdml.filter_pcap    pcapInFile=${cprt_pcap_path}
    ...                                                          filterName=${filter_udp_tcp_packets}
    ...                                                          filterExp=${filter_udp_tcp_packets}
    [Return]             ${cprt_file_without_tcp_udp}

Filter and convert pcap file to pdml
    ${cprt_file_without_tcp_udp}      Filter CPRT pcap and remove not needed packets
    ${filtered_pdml_file}             analyzer_pdml.pcap_to_pdml      pcapFile=${cprt_file_without_tcp_udp}
    Set suite variable        ${filtered_pdml_file}

Filter and convert bip pcap
    [Arguments]         ${pcap_input}     ${filter_exp}=None
    ${filtered_file}     analyzer_pdml.filter_pcap    pcapInFile=${pcap_input}
    ...                                              filterName=${filter_exp}
    ...                                              filterExp=${filter_exp}
    ${filtered_temp_pdml}      analyzer_pdml.pcap_to_pdml      pcapFile=${filtered_file}
    [Return]         ${filtered_temp_pdml}

Verify that ${field_name} is set to ${value} in nr-rrc
    Log to console       Verify that ${field_name} is set to ${value} in nr-rrc
    Run Keyword If       '${value}'=='true'
    ...                   verify_that_skip_uplink_tx_dynamic_is_set_in_rrc     pdml_file=${filtered_pdml_file}    value=1
    ...       ELSE        verify_that_skip_uplink_tx_dynamic_is_set_in_rrc     pdml_file=${filtered_pdml_file}    value=0

Verify ${timer}ms proactive grants assignment
    ${parsed_data}     read_and_parse_tti_data     path_to_tti=${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv
    verify_proactive_grants_assignment    val=${timer}
    ...                                   parsed_data=${parsed_data}
    ...                                   tti_csv=${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv

Verify that the size of UL grant in bytes is equal to ${payload_size} bytes
    ${filtered_bip_packets}    Filter pcap using mcshark    ${bip_pcap_path}    uldata_puschreceiveresplo    uldata_puschreceiveresplo
    5GC002271-keywords.Convert PCAP file to PDML    ${filtered_bip_packets}
    verify_the_size_of_ul_pro_grant            pdml_file=${filtered_pdml_file}
    ...                                        payload_size=${payload_size}

Verify that the sum of SR_SLOT20_POOL_AS_MAIN and SR_SLOT40_POOL_AS_MAIN is equal to full period interval
    [Arguments]     ${value}      ${pm_counter_path}
    ${value_sr20}=     pmcounter.get_pm_counter_value     counter=M55165C00009     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr40}=     pmcounter.get_pm_counter_value     counter=M55165C00010     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    check_sum          value_1=${value_sr40}     value_2=${value_sr20}     base_value=${value}

Verify if counter at NRCELL is bigger than a specific value
    [Arguments]     ${counter_id}     ${value}      ${pm_counter_path}
    pmcounter.verify_if_latest_pm_counter_is_bigger_than_the_given_value    counter_id=${counter_id}     value=${value}
    ...       local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1   filepath=${pm_counter_path}

Set ${timestamp} for proper counters counting
    ${timestamp}    set_timestamp
    [Return]     ${timestamp}

Set ${localtime} for pool 10 and 80 counters
    ${localtime}    local_time_counter
    [Return]     ${localtime}

Count time between timestamps
    [Arguments]     ${time0}    ${time1}    ${time2}
    ${counter_p20}     counter count    ${time0}    ${time1}
    ${counter_p40}     counter count    ${time1}    ${time2}
    Set suite variable     ${counter_p20}
    Set suite variable     ${counter_p40}

Verify SR_SLOT_POOL_AS_MAIN for pool 10 20 40 and 80 is correct
    [Arguments]        ${pm_counter_path}     ${localtime1}     ${localtime2}
    ${value_sr10}=     pmcounter.get_pm_counter_value     counter=M55165C00008     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr20}=     pmcounter.get_pm_counter_value     counter=M55165C00009     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr40}=     pmcounter.get_pm_counter_value     counter=M55165C00010     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr80}=     pmcounter.get_pm_counter_value     counter=M55165C00011     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    check_pool20_pool40_counters    counter_p20=${counter_p20}    counter_p40=${counter_p40}    value_sr20=${value_sr20}    value_sr40=${value_sr40}
    check_pool_max_counter            localtime=${localtime2}       value_sr=${value_sr80}
    check_pool_min_counter            localtime=${localtime1}       value_sr=${value_sr10}

Verify that ${number_ues} UEs are being allocated with the SR period set to srPeriodicityMin equal to ${periodicity}
    verify_that_slot_pool_in_rrc_is_present_a_number_of_times      expected_pool=${periodicity}
    ...                                                            number_of_ues=${number_ues}
    ...                                                            log_path=${egate_console_log}

Verify that reconfiguration from shorter SR period to the longer SR period was achieved after adaptiveSrLoad x rdSrLoadThreshold is met
    verify_that_after_threshold_is_met_reconfiguration_from_shorter_pool_to_longer_pool_is_achieved      log_path=${egate_console_log}

Verify that after UEs release SR period is reconfigured from longer to shorter SR period once cell load is low
    verify_that_after_ues_release_sr_period_is_reconfigured_from_longer_to_shorter_pool      log_path=${egate_console_log}
`

Verify that SR Pools AS MAIN for slot 20, 40 and 80 after attach are correctly pegged
    [Arguments]       ${timestamp0}     ${timestamp1}      ${localtime1}      ${localtime2}
    ...               ${pm_counter_path}
    ${value_sr20}=     pmcounter.get_pm_counter_value     counter=M55165C00009     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr40}=     pmcounter.get_pm_counter_value     counter=M55165C00010     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr80}=     pmcounter.get_pm_counter_value     counter=M55165C00011     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${diff_timestamps}      counter_count     timestamp0=${timestamp0}      timestamp1=${timestamp1}

    check_pool_min_counter      ${localtime1}             ${value_sr20}
    check_pool_min_counter      ${diff_timestamps}        ${value_sr40}
    check_pool_max_counter      ${localtime2}             ${value_sr80}

Verify that SR Pools AS MAIN for slot 20, 40 and 80 after detach are correctly pegged
    [Arguments]       ${timestamp2}     ${timestamp3}      ${localtime3}      ${localtime4}
    ...               ${pm_counter_path}
    ${value_sr20}=     pmcounter.get_pm_counter_value     counter=M55165C00009     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr40}=     pmcounter.get_pm_counter_value     counter=M55165C00010     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr80}=     pmcounter.get_pm_counter_value     counter=M55165C00011     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}

    ${diff_timestamps_sl40}      counter_count     ${timestamp2}     ${timestamp3}
    ${timeout_localtime3}=          Evaluate     ${localtime3}+${20}

    check_pool_min_counter       ${timeout_localtime3}          ${value_sr80}
    check_pool_min_counter       ${diff_timestamps_sl40}        ${value_sr40}
    check_pool_max_counter       ${localtime4}                  ${value_sr20}

Split original ttitrace csv to separate files by RNTI
    ${tti_trace_dict}    read_and_parse_tti_data    ${TTI_TRACE_CSV}
    @{separate_tti_file_list}    move_each_rnti_to_separate_tti_trace_csv    parsed_data=${tti_trace_dict}
    ...                                                                      ttitrace_csv=${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv
    Set test variable    @{separate_tti_file_list}

Verify that there is no skippableDynamicEnhanced grant and CSI report in the same slot
    FOR    ${separate_csv}    IN    @{separate_tti_file_list}
        set test variable    ${TTI_TRACE_CSV}    ${separate_csv}
        Convert TTI trace from csv to dict
        check_if_grant_scheduled_in_the_same_slot_with_csi_report_is_not_type_of_skippabledynamicenhanced    ttitrace_dict=${tti_trace_dict}
    END
    set test variable    ${TTI_TRACE_CSV}    ${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv

Verify that there is no skippableDynamicEnhanced grant and DL ACK in the same slot
    FOR    ${separate_csv}    IN    @{separate_tti_file_list}
        set test variable    ${TTI_TRACE_CSV}    ${separate_csv}
        Convert TTI trace from csv to dict
        check_if_grant_scheduled_in_the_same_slot_with_downlink_ack_is_not_type_of_skippabledynamicenhanced    ttitrace_dict=${tti_trace_dict}
    END
    set test variable    ${TTI_TRACE_CSV}    ${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv

Verify that there is no skippableDynamic or nonSkippable grant and CSI report in the same slot
    FOR    ${separate_csv}    IN    @{separate_tti_file_list}
        set test variable    ${TTI_TRACE_CSV}    ${separate_csv}
        Convert TTI trace from csv to dict
        check_if_there_is_no_skippabledynamic_or_nonskippable_grant_and_csi_report_in_the_same_slot    ttitrace_dict=${tti_trace_dict}
    END
    set test variable    ${TTI_TRACE_CSV}    ${OUTPUT_DIR}/ttitrace_logs_dl_and_ul.csv

Reach on air using ${name_of_wts_cfg}
    Reach Onair     lua_cfg=${CURDIR}/${name_of_wts_cfg}

Register ue${ue_id} and expect assignment to pool ${periodicity}
    ${ret}    execute egate command      cmd=ue_register id=${ue_id}
    ...    pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    Should contain    ${ret}    periodicityAndOffset ${periodicity}

Setup 5QI-1 bearer for ue${ue_id} and expect reconfiguration to pool ${periodicity}
    ${ret}    execute egate command      cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 1 qfi 2
    Should contain    ${ret}    periodicityAndOffset ${periodicity}

Start vonr throughput for ue${ue_id}
    execute egate command      cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul trf_id=1 size=100 burst=2 period_ms=20
    ...    pass_regexp=UE${ue_id}: Started Uplink Internal traffic over UDP

Perform handover to simulated gnb for ue${ue_id}
    execute egate command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=52
    ...    pass_regexp=GNB-3: UE${ue_id}: PATH_SWITCH_REQUEST_ACK Received

Perform handover to real gnb for ue${ue_id} and expect assignment to pool ${periodicity}
    execute egate command    cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01
    execute egate command    cmd=time_ue_stayed_in_cell=100
    execute egate command    cmd=ue_history_information_list id=1 action=commit
    execute egate command    cmd=ue_enb_param id=${ue_id} ue_history_list=1
    ${ret}    execute egate command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=A5 srsrp_nr=18 srsrq_nr=10 phycell_id=50 nrsrp_nr=85
    ...    pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    should contain    ${ret}    periodicityAndOffset ${periodicity}

Remove 5qi-1 bearer for ue${ue_id} and expect reconfiguration to pool ${periodicity}
    ${ret}    execute egate command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Removed FiveQi:Qfi mapping fiveQi 1 qfi 2
    Should contain    ${ret}    periodicityAndOffset ${periodicity}

Establish pdu session using ue-${ue_id}
    execute egate command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    establish pdu session    ue_id=${ue_id}   gw_id=${ue_id}

PM counters verification
     [Arguments]    ${pmcounters_path}
     ta5g_pm_counters.verify if latest pm counter has exact value    counter_id=M55165C00020    value=3
     ...                                                             local_moid=${local_moid}    filepath=${pmcounters_path}

     ta5g_pm_counters.verify if latest pm counter has exact value    counter_id=M55165C00022    value=2
     ...                                                             local_moid=${local_moid}    filepath=${pmcounters_path}

     ta5g_pm_counters.verify if latest pm counter has exact value    counter_id=M55165C00024    value=0
     ...                                                             local_moid=${local_moid}    filepath=${pmcounters_path}

     ta5g_pm_counters.verify if latest pm counter has exact value    counter_id=M55165C00028    value=0
     ...                                                             local_moid=${local_moid}    filepath=${pmcounters_path}

     ta5g_pm_counters.verify if latest pm counter has exact value    counter_id=M55165C00029    value=0
     ...                                                             local_moid=${local_moid}    filepath=${pmcounters_path}

Verify that SR Pools AS MAIN for slot 20 and 40 are correctly pegged
    [Arguments]       ${timestamp0}     ${timestamp1}      ${timestamp2}     ${timestamp3}     ${timestamp4}     ${timestamp5}
    ...               ${timestamp6}     ${timestamp7}      ${timestamp8}     ${timestamp9}     ${timestamp10}     ${timestamp11}
    ...               ${timestamp12}     ${timestamp13}    ${pm_counter_path}
    ${value_sr20}=     pmcounter.get_pm_counter_value     counter=M55165C00021     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr40}=     pmcounter.get_pm_counter_value     counter=M55165C00023     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${diff_0}      counter_count     timestamp0=${timestamp0}      timestamp1=${timestamp2}
    ${diff_1}      counter_count     timestamp0=${timestamp1}      timestamp1=${timestamp3}
    ${diff_2}      counter_count     timestamp0=${timestamp6}      timestamp1=${timestamp13}
    ${diff_3}      counter_count     timestamp0=${timestamp9}      timestamp1=${timestamp11}
    ${diff_4}      counter_count     timestamp0=${timestamp10}      timestamp1=${timestamp12}
    ${sum_of_timestamps1}     sum_timestamps     ${diff_0}     ${diff_1}     ${diff_2}     ${diff_3}     ${diff_4}
    ${diff_5}      counter_count     timestamp0=${timestamp2}      timestamp1=${timestamp4}
    ${diff_6}      counter_count     timestamp0=${timestamp3}      timestamp1=${timestamp5}
    ${diff_7}      counter_count     timestamp0=${timestamp7}      timestamp1=${timestamp9}
    ${diff_8}      counter_count     timestamp0=${timestamp8}      timestamp1=${timestamp10}
    ${sum_of_timestamps2}     sum_timestamps     ${diff_5}     ${diff_6}     ${diff_7}     ${diff_8}

    check_pool_min_counter      ${sum_of_timestamps1}       ${value_sr20}
    check_pool_min_counter      ${sum_of_timestamps2}       ${value_sr40}

Verify that SUM USED RES for sl40 and sl80 are correctly pegged
    [Arguments]       ${timestamp0}     ${timestamp1}      ${timestamp2}     ${timestamp3}     ${timestamp4}     ${timestamp5}
    ...               ${timestamp6}     ${timestamp7}      ${timestamp8}     ${timestamp9}     ${timestamp10}     ${timestamp11}
    ...               ${pm_counter_path}
    ${value_used_sl40}=     pmcounter.get_pm_counter_value     counter=M55165C00023     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_used_sl80}=     pmcounter.get_pm_counter_value     counter=M55165C00025     localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${diff_0}      counter_count     timestamp0=${timestamp0}      timestamp1=${timestamp3}
    ${diff_1}      counter_count     timestamp0=${timestamp6}      timestamp1=${timestamp8}
    ${diff_2}      counter_count     timestamp0=${timestamp1}      timestamp1=${timestamp4}
    ${diff_3}      counter_count     timestamp0=${timestamp7}      timestamp1=${timestamp9}
    ${diff_4}      counter_count     timestamp0=${timestamp2}      timestamp1=${timestamp10}
    ${diff_5}      counter_count     timestamp0=${timestamp5}      timestamp1=${timestamp11}
    ${sum_of_timestamps1}     sum_timestamps     ${diff_0}     ${diff_1}     ${diff_2}     ${diff_3}     ${diff_4}     ${diff_5}
    ${diff_6}      counter_count     timestamp0=${timestamp3}      timestamp1=${timestamp6}
    ${diff_7}      counter_count     timestamp0=${timestamp4}      timestamp1=${timestamp7}
    ${sum_of_timestamps2}     sum_timestamps     ${diff_6}     ${diff_7}

    check_pool_min_counter      ${sum_of_timestamps1}       ${value_used_sl40}
    check_pool_min_counter      ${sum_of_timestamps2}       ${value_used_sl80}

Redirect egate console log to separate file
    [Arguments]    ${output_file}
    Execute Egate Command    cmd=sim_log_set flush
    Run    tail -f ${egate_log_file} > ${output_file} &
    [Return]    ${output_file}

Stop redirecting egate console log
    Execute Egate Command    cmd=sim_log_set flush
    Sleep    1s    reason=Wait for egate to dump all the buffer
    Run    pkill tail

Check if SA UE has not reconfigured
    [Arguments]    ${input_file}    ${ue_id}
    ${start_reconf}=    Set Variable    [NR-RRC]: <- DL-DCCH-NR
    ${log}    OperatingSystem.Get file    ${input_file}
    ${log}    Remove String Using Regexp    ${log}    \n
    ${matches}    Get Regexp Matches    ${log}     UEC-1: UE${ue_id}\\[NR-RRC\\]: <- DL-DCCH-NR.*?UE[0-9]

    FOR    ${element}    IN    @{matches}
        BuiltIn.Log    ${element}    console=yes
        ${contains}=    Run Keyword And Return Status    Should contain    ${element}    rrcReconfiguration
        Continue For Loop If    '${contains}' == 'False'
        Should Not Match Regexp    ${element}    periodicityAndOffset sl[0-9]+
    END

Reach Onair In ${n} Attempts using ${cfg_path}
    Wait Until Keyword Succeeds    ${n} times    5s    Try Reach Onair And Reboot On Failure    ${cfg_path}

Try Reach Onair And Reboot On Failure
    [Arguments]    ${cfg_path}
    ${status}    ${msg}    Run Keyword And Ignore Error    Reach Onair    lua_cfg=${cfg_path}    align_tac_values=False
    Run Keyword If    '${status}' == 'FAIL'    Run Keywords
    ...                                Log to Console    Failed to Reach Onair, rebooting BTS
    ...    AND                         admin.Setup Admin
    ...    AND                         admin.Reset Site
    ...    AND                         admin.Teardown Admin
    ...    AND                         Teardown Egate And Collect Logs
    ...    AND                         Fail    ${msg}

Configure UTE interfaces
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.44.76.27/24 dev eth3
    Run    sudo ip addr add 10.44.76.28/24 dev eth3
    Run    sudo ip addr add 10.0.2.121/24 dev eth4

Testline Teardown
    RunnerExtension.Reset wts
    Copy egate console log to output dir
    Close All WTS connections

Clean basic_setup.cfg file
    Copy File    ${CURDIR}/basic_setup.cfg    /opt/wts/latest/basic_setup.cfg

Perform scf comissioning using ${scf_path_to_specific_file}
    ${scf_converted}    Fix vlan id in scfc    input_filepath=${scf_path_to_specific_file}
    admin.Setup admin
    admin.Perform commissioning   scf_file=${scf_converted}    skip_parameter_relation_errors=${TRUE}
    admin.Teardown admin

Load gnb swconfig using ${swconfig_path_to_specific_file}
    Put swconfig file    input_filepath=${swconfig_path_to_specific_file}

Attach UE${first} to UE${last} to LTE
    FOR    ${ue}    IN RANGE    ${first}    ${last}+1
        Attach UE to enb   ue_id=${ue}
    END

Establish dual connectivity for UE${ue_id} and expect reconfiguration with periodicity ${periodicity}
    ${ret}    Execute Egate Command    ue_dc_enb_start ue\=${ue_id} target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    ...       pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity
    ${ret}    Remove String Using Regexp    ${ret}    \n
    ${success_reconf}=    Set Variable    Successfully reconfigured dual connectivity
    Should Match Regexp    ${ret}   UE${ue_id}\\[NR-RRC\\]: <- gNB.*periodicityAndOffset ${periodicity}.*UE${ue_id}: ${success_reconf}


Establish dual connectivity for UE${first} to UE${last} with ${interval}s interval and expect reconfigurations with periodicity ${periodicity}
    FOR    ${ue}    IN RANGE    ${first}    ${last}+1
        sleep    ${interval}    reason=user defined time interval between dual connectivities
        Establish dual connectivity for UE${ue} and expect reconfiguration with periodicity ${periodicity}
    END

Wait for ${wait_time}s and check if UE${first} to UE${last} have reconfigured to pool ${periodicity}
    ${output_file}=    Set Variable    ${OUTPUT_DIR}/reconf_${periodicity}.txt

    Execute egate command    cmd=sim_log_set flush
    Execute Egate Command    cmd=sim_log_set file\=${output_file}
    Sleep    ${wait_time}s    reason=user defined log collecting time
    Execute egate command    cmd=sim_log_set flush
    Sleep    2s    reason=Wait for egate to dump all the buffer

    Verify that UEs have reconfigured to correct SR pool    first_ue_id=${first}    last_ue_id=${last}
    ...                                                     periodicity=${periodicity}    egate_log_file=${output_file}

Verify that UEs have reconfigured to correct SR pool
    [Arguments]    ${first_ue_id}   ${last_ue_id}    ${periodicity}    ${egate_log_file}

    ${start_reconf}=    Set Variable    Sending RRC Connection Reconfiguration
    ${end_reconf}=    Set Variable    Successfully reconfigured dual connectivity
    ${input}     OperatingSystem.Get file    ${egate_log_file}
    ${reconfigurations}    Get Lines Matching Regexp    ${input}
    ...    periodicityAndOffset sl[0-9]+|UE[0-9]+: ${start_reconf}|UE[0-9]+: ${end_reconf}    partial_match=true
    ${reconfigurations}    Remove String Using Regexp    ${reconfigurations}    \n

    FOR    ${ue}    IN RANGE    ${first_ue_id}    ${last_ue_id}+1
        ${match}    Should Match Regexp    ${reconfigurations}   UE${ue}: ${start_reconf}.*?UE${ue}: ${end_reconf}
        BuiltIn.Log    ${match}
        Should Match Regexp    ${match}    periodicityAndOffset ${periodicity}
    END

Collect Snapshot to Logs
    Log to Console    Collecting Snapshot
    admin.Setup Admin
    ${sw_ver}    admin.Get SW Version
    admin.Get Snapshot    target_file_name=${OUTPUT_DIR}/Snapshot_${sw_ver}.zip
    admin.Teardown Admin

Convert PCAP file to PDML
    [Arguments]       ${pcap_location}
    pcaptopdml.create_pcap_to_pdml_converter
    ...      name=converter
    ...      file_path_pattern=${pcap_location}
    pcaptopdml.convert    converter
    ${filtered_pdml_file}    Replace String    ${pcap_location}    .pcap    .pdml
    Remove Non-printable Characters And Tab From File     ${filtered_pdml_file}
    Set suite variable        ${filtered_pdml_file}
