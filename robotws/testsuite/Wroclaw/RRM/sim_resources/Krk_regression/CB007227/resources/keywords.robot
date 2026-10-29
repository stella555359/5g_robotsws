*** Settings ***

Documentation
...   author: Justyna Balcerzak, Mateusz Adamek
...   contact: justyna.balcerzak@nokia.com, mateusz.adamek@nokia.com
...   description: CB007227 keywords

Library     BuiltIn
Library     String
Library     Collections
Library     pcap_verify.py
Library     egate_actions.py
Library     suite_specific_keywords.py
Library     AaTrace/aatrace_mng.py     WITH NAME   aatrace
Library     ../../MN_RAN_L2/resources/Python/utilities.py    WITH NAME    logger


*** Keywords ***
Prepare environment
    [Arguments]    ${sib1_reception_dict}    ${wts_config_path}=${None}
    ${current_wts_config_path} =    decide_on_wts_config_file_source    ${wts_config_path}
    ${test_prefix} =    suite_specific_keywords.get_test_prefix
    copy_wts_cfg_file_to_output_dir    ${current_wts_config_path}    ${test_prefix}
    delete_localhost_ssh_key_from_known_hosts
    add_nsa_specific_addresses
    add_additional_specific_addresses
    wait_for_testline_icmp_echo_replies_and_ssh_services
    ensure_gnb_files_flags_are_in_order
    log_gnb_build
    log_airphone_build
    setup_radiohead_and_wts_and_wait_for_mibsib_wrapper    wts_config_path=${current_wts_config_path}
    ...                                                    sib1_reception_dict=${sib1_reception_dict}


Attach UE and Establish PDU session
    [Arguments]    ${ue_id}=1   ${pdu_id}=1    ${cell_id}=${None}     ${timeout}=${15}
    Attach UE    ue_id=${ue_id}    cell=${cell_id}
    ta5g_ue_mobility.Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${ue_id}   timeout=${timeout}
    BuiltIn.Sleep    3s


Wait for throughput stable
    [Arguments]   ${sec}
    BuiltIn.Sleep    ${sec}


Collect additional logs
    [Arguments]    ${prefix}
    Collect gnb snapshot        output_filepath=${OUTPUT_DIR}/${prefix}/snapshot_gNB_${prefix}.zip
    Collect sos report log      prefix=${prefix}    log_output_dir=${OUTPUT_DIR}/${prefix}
    Collect airphone snapshot   output_filepath=${OUTPUT_DIR}/${prefix}/snapshot_AP_${prefix}.zip


Collect additional logs if test failed
    [Arguments]    ${prefix}
    Run Keyword If Test Failed    Collect additional logs    ${prefix}


Teardown collecting logs in robot
    BuiltIn.Sleep    30s
    ${prefix} =   suite_specific_keywords.Get test prefix
    Teardown collecting logs
    Collect additional logs if test failed    ${prefix}
    Collect admin api logs    subdir=${prefix}    dir_name=admin_api_logs


Start L2 PCMD Trace Report Framework Logs Collecting
    [Arguments]      ${step}=${None}    ${file_name}=tshark.pcap
    ${prefix} =   suite_specific_keywords.Get test prefix
    ${log_dirpath} =    Set Variable If      ${step}==${None}
    ...                 ${OUTPUT_DIR}/${prefix}   ${OUTPUT_DIR}/${prefix}/step_${step}
    aatrace.Start Aatrace Script    ${AATRACE_NODE_LIST}    ${AATRACE_MSG_LIST}
    Start Tshark    alias=${ALIAS_TSHARK}
    ...             log_filename=${file_name}
    ...             log_dirpath=${log_dirpath}
    ...             eth_interface=eth1


Stop L2 PCMD Trace Report Framework Logs Collecting
    aatrace.Stop Aatrace Script
    Teardown Tshark    alias=${ALIAS_TSHARK}


Check If Preferences Exist
    [Documentation]      Checking if preferences exist on VM and return status

    [Arguments]    ${preference}
    ${preferences_file}    Set Variable    ~/.config/wireshark/preferences
    ${file_exist}=    Run Keyword And Return Status
        ...    File Should Exist    ${preferences_file}
    Run Keyword If   ${file_exist}==False    Create File    ${preferences_file}
    ${file_content}=  OperatingSystem.Get File   ${preferences_file}
    ${preferences_exist}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${file_content}    ${preference}
    [Return]    ${preferences_exist}


Add ntrstr Preference To Wireshark Config
    [Documentation]      Adding specific preferences to wireshark config file at
    ...                  ~/.config/wireshark/preferences

    ${preferences_exist}    Check If Preferences Exist   preference=ntrstr.port: 49148
    ${command}=  catenate  SEPARATOR=
    ...    echo "ntrstr.port: 49148" >> ~/.config/wireshark/preferences  &&
    ...    echo "ntrstr.defragment: TRUE" >> ~/.config/wireshark/preferences
    Run Keyword If    ${preferences_exist}==False
    ...    Run    ${command}
    ...    ELSE    Log    File '~/.config/wireshark/preferences' contains ntrstr.port: 49148


Add SysCom Preference To Wireshark Config
    [Documentation]      Adding specific preferences to wireshark config file at
    ...                  ~/.config/wireshark/preferences

    ${preferences_exist}    Check If Preferences Exist   preference=syscom.sic_tcp_ports: 15004,15003,50846
    ${command}=  catenate  SEPARATOR=
    ...    echo "syscom.sic_tcp_ports: 15004,15003,50846" >> ~/.config/wireshark/preferences
    Run Keyword If    ${preferences_exist}==False
    ...    Run    ${command}
    ...    ELSE    Log    File '~/.config/wireshark/preferences' contains syscom.sic_tcp_ports: 15004,15003,50846


Validate itf l2 hi cu trace radiobearerpdcpmeasdata frequency for ue and direction
    [Arguments]  ${ue_id}  ${number_of_ues_in_test}  ${direction}=dl  ${start_time}=${None}  ${traffic_duration}=${60}  ${log_filepath}=${None}
    ...  ${step}=${None}

    ${timestamps} =  get_timestamps_for_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_for_ue_and_direction
    ...  ue_id=${ue_id}  number_of_ues_in_test=${number_of_ues_in_test}  direction=${direction}  start_time=${start_time}
    ...  traffic_duration=${traffic_duration}  log_filepath=${log_filepath}  step=${step}

    check_if_no_gaps_in_messages_timestamps_for_ue  ue_id=${ue_id}  timestamps=${timestamps}


Validate itf l2 hi cu trace radiobearerpdcpmeasdata params inside
    [Arguments]  ${ue_id}  ${number_of_ues_in_test}=${2}  ${direction}=dl  ${start_time}=${None}  ${traffic_duration}=${60}  ${log_filepath}=${None}
    ...  ${step}=${None}

    validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_sumOfPdcpSduXxBytes  ue_id=${ue_id}  number_of_ues_in_test=${number_of_ues_in_test}
    ...  direction=${direction}  start_time=${start_time}  traffic_duration=${traffic_duration}  log_filepath=${log_filepath}  step=${step}

    validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_sumOfPdcpXxBytesDiscarded  ue_id=${ue_id}  number_of_ues_in_test=${number_of_ues_in_test}
    ...  direction=${direction}  start_time=${start_time}  traffic_duration=${traffic_duration}  log_filepath=${log_filepath}  step=${step}

    validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_dataCollectionDuration  ue_id=${ue_id}  number_of_ues_in_test=${number_of_ues_in_test}
    ...  direction=${direction}  start_time=${start_time}  traffic_duration=${traffic_duration}  log_filepath=${log_filepath}  step=${step}

    validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_drbId  ue_id=${ue_id}  number_of_ues_in_test=${number_of_ues_in_test}
    ...  direction=${direction}  start_time=${start_time}  traffic_duration=${traffic_duration}  log_filepath=${log_filepath}  step=${step}

    validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_isLast  ue_id=${ue_id}  number_of_ues_in_test=${number_of_ues_in_test}
    ...  direction=${direction}  start_time=${start_time}  traffic_duration=${traffic_duration}  log_filepath=${log_filepath}  step=${step}

    validate_itf_l2_hi_cu_trace_PcmdRadioBearerPdcpMeasInd_t_nrCellId_item  ue_id=${ue_id}  number_of_ues_in_test=${number_of_ues_in_test}
    ...  direction=${direction}  start_time=${start_time}  traffic_duration=${traffic_duration}  log_filepath=${log_filepath}  step=${step}

    validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_sic_length  ue_id=${ue_id}  number_of_ues_in_test=${number_of_ues_in_test}
    ...  direction=${direction}  start_time=${start_time}  traffic_duration=${traffic_duration}  log_filepath=${log_filepath}  step=${step}


Validate test C005 C006 for ue
    [Arguments]    ${ue_id}     ${time_step_1}      ${time_step_2}      ${time_step_3}
    validate_test_C005_C006_first_or_third_step_for_ue   ue_id=${ue_id}     start_time=${time_step_1}     step=1
    validate_test_C005_C006_first_or_third_step_for_ue   ue_id=${ue_id}     start_time=${time_step_3}     step=3
    validate_test_C005_C006_second_step_for_ue   ue_id=${ue_id}     start_time=${time_step_2}
    Run Keyword And Ignore Error
    ...             validate_test_C005_C006_compare_sumOfDelays_percentage_difference_between_two_given_steps_for_ue
    ...             ue_id=${ue_id}     first_step=1     second_step=2
    Run Keyword And Ignore Error
    ...             validate_test_C005_C006_compare_sumOfDelays_percentage_difference_between_two_given_steps_for_ue
    ...             ue_id=${ue_id}     first_step=2     second_step=3


Validate test D003 for ue
    [Arguments]    ${ue_id}     ${start_time}     ${traffic_duration}=60    ${log_filepath}=None
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata frequency for ue and direction
    ...             ue_id=${ue_id}   number_of_ues_in_test=${2}   start_time=${start_time}  direction=dl
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata frequency for ue and direction
    ...             ue_id=${ue_id}   number_of_ues_in_test=${2}   start_time=${start_time}  direction=ul
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}

    Validate itf l2 hi cu trace radiobearerpdcpmeasdata params inside
    ...             ue_id=${ue_id}   number_of_ues_in_test=${2}   start_time=${start_time}  direction=dl
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata params inside
    ...             ue_id=${ue_id}   number_of_ues_in_test=${2}   start_time=${start_time}  direction=ul
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}


Validate test D011 for ue
    [Arguments]    ${ue_id}     ${start_time}     ${counters_data}    ${timestamp_offset}       ${traffic_duration}=60    ${log_filepath}=None
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata frequency for ue and direction
    ...             ue_id=${ue_id}   number_of_ues_in_test=${1}   start_time=${start_time}  direction=dl
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata frequency for ue and direction
    ...             ue_id=${ue_id}   number_of_ues_in_test=${1}   start_time=${start_time}  direction=ul
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata params inside
    ...             ue_id=${ue_id}   number_of_ues_in_test=${1}   start_time=${start_time}  direction=dl
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata params inside
    ...             ue_id=${ue_id}   number_of_ues_in_test=${1}   start_time=${start_time}  direction=ul
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}

    ${sumOfPdcpSduTxBytes_values} =     get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction
    ...  ue_id=${ue_id}  number_of_ues_in_test=${1}  direction=dl  start_time=${start_time}  traffic_duration=${traffic_duration}
    ...  attribute_value=itf_l2_hi_cu_trace_DlRadioBearerPdcpMeasData.sumOfPdcpSduTxBytes  log_filepath=${log_filepath}

    ${sumOfPdcpSduRxBytes_values} =     get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction
    ...  ue_id=${ue_id}  number_of_ues_in_test=${1}  direction=ul  start_time=${start_time}  traffic_duration=${traffic_duration}
    ...  attribute_value=itf_l2_hi_cu_trace_UlRadioBearerPdcpMeasData.sumOfPdcpSduRxBytes  log_filepath=${log_filepath}

    ${sumOfPdcpSduTxBytes} =    standardized_value_of_message_throughput_over_a_specified_period_of_time
    ...                         sumOfPdcpSduXxBytes_values=${sumOfPdcpSduTxBytes_values}    traffic_duration=${traffic_duration}

    ${sumOfPdcpSduRxBytes} =    standardized_value_of_message_throughput_over_a_specified_period_of_time
    ...                         sumOfPdcpSduXxBytes_values=${sumOfPdcpSduRxBytes_values}    traffic_duration=${traffic_duration}

    pm_counters.verify_any_counters_extended   ${PDCP_SDU_DATA_VOL_DL_SLICE} > ${D011_TARGET_KB_TRANSFERRED_DL_SA_FDD} * ${SUCCESS_RATE}
    ...                                        ${PDCP_SDU_DATA_VOL_UL_SLICE} > ${D011_TARGET_KB_TRANSFERRED_UL_SA_FDD} * ${SUCCESS_RATE}
    ...                            counters_data=${counters_data}
    ...                            timestamp_offset=${timestamp_offset}

    pm_counters.verify_any_counters_extended  0.99 * ${PDCP_SDU_DATA_VOL_DL_SLICE} <\= ${sumOfPdcpSduTxBytes} <\= 1.01 * ${PDCP_SDU_DATA_VOL_DL_SLICE}
    ...                                       0.99 * ${PDCP_SDU_DATA_VOL_UL_SLICE} <\= ${sumOfPdcpSduRxBytes} <\= 1.01 * ${PDCP_SDU_DATA_VOL_UL_SLICE}
    ...                            counters_data=${counters_data}
    ...                            timestamp_offset=${timestamp_offset}


Validate test D004 for ue
    [Arguments]  ${ue_id}  ${start_time}  ${counters_data}  ${timestamp_offset}  ${traffic_duration}=60  ${log_filepath}=None  ${step}=2
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata frequency for ue and direction
    ...             ue_id=${ue_id}   number_of_ues_in_test=${2}   start_time=${start_time}  direction=dl
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}     step=${step}
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata frequency for ue and direction
    ...             ue_id=${ue_id}   number_of_ues_in_test=${2}   start_time=${start_time}  direction=ul
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}     step=${step}
    Validate itf l2 hi cu trace radiobearerpdcpmeasdata params inside
    ...             ue_id=${ue_id}   number_of_ues_in_test=${2}   start_time=${start_time}  direction=dl
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}     step=${step}

    Validate itf l2 hi cu trace radiobearerpdcpmeasdata params inside
    ...             ue_id=${ue_id}   number_of_ues_in_test=${2}   start_time=${start_time}  direction=ul
    ...             traffic_duration=${traffic_duration}   log_filepath=${log_filepath}     step=${step}

    ${sumOfPdcpSduTxBytes_values} =     get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction
    ...  ue_id=${ue_id}  number_of_ues_in_test=${2}  direction=dl  start_time=${start_time}  traffic_duration=${traffic_duration}
    ...  attribute_value=itf_l2_hi_cu_trace_DlRadioBearerPdcpMeasData.sumOfPdcpSduTxBytes  log_filepath=${log_filepath}  step=${step}

    ${sumOfPdcpSduRxBytes_values} =     get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction
    ...  ue_id=${ue_id}  number_of_ues_in_test=${2}  direction=ul  start_time=${start_time}  traffic_duration=${traffic_duration}
    ...  attribute_value=itf_l2_hi_cu_trace_UlRadioBearerPdcpMeasData.sumOfPdcpSduRxBytes  log_filepath=${log_filepath}  step=${step}

    ${sumOfPdcpSduTxBytes} =    standardized_value_of_message_throughput_over_a_specified_period_of_time
    ...                         sumOfPdcpSduXxBytes_values=${sumOfPdcpSduTxBytes_values}    traffic_duration=${traffic_duration}

    ${sumOfPdcpSduRxBytes} =    standardized_value_of_message_throughput_over_a_specified_period_of_time
    ...                         sumOfPdcpSduXxBytes_values=${sumOfPdcpSduRxBytes_values}    traffic_duration=${traffic_duration}

    ${counter_to_validate_dl} =    set_counter_by_ue_to_validate   ue_id=${ue_id}   direction=dl
    ${counter_to_validate_ul} =    set_counter_by_ue_to_validate   ue_id=${ue_id}   direction=ul
    pm_counters.verify_any_counters_extended   0.99 * ${counter_to_validate_dl} <\= ${sumOfPdcpSduTxBytes} <\= 1.01 * ${counter_to_validate_dl}
    ...                            0.99 * ${counter_to_validate_ul} <\= ${sumOfPdcpSduRxBytes} <\= 1.01 * ${counter_to_validate_ul}
    ...                            counters_data=${counters_data}
    ...                            timestamp_offset=${timestamp_offset}


Validate throughput D004
    [Arguments]     ${counters_data}    ${timestamp_offset}
    pm_counters.verify_any_counters_extended   ${PDCP_SDU_DATA_VOL_DL_SLICE} > ${D004_D005_TARGET_KB_TRANSFERRED_DL_SA} * ${SUCCESS_RATE}
    ...                                        ${PDCP_SDU_DATA_VOL_UL_SLICE} > ${D004_D005_TARGET_KB_TRANSFERRED_UL_SA} * ${SUCCESS_RATE}
    ...                                        ${DL_PDCP_VOL_RCV_F1_QoS_GRP_09} > ${D004_D005_TARGET_KB_TRANSFERRED_DL_NSA} * ${SUCCESS_RATE}
    ...                                        ${UL_PDCP_VOL_SNT_F1_QoS_GRP_09} > ${D004_D005_TARGET_KB_TRANSFERRED_UL_NSA} * ${SUCCESS_RATE}
    ...                            counters_data=${counters_data}
    ...                            timestamp_offset=${timestamp_offset}


Validate throughput C005 C006
    [Arguments]     ${counters_data}    ${timestamp_offset}
    pm_counters.verify_any_counters_extended   ${PDCP_SDU_DATA_VOL_DL_SLICE} > ${C005_C006_TARGET_KB_TRANSFERRED_DL_SA} * ${SUCCESS_RATE}
    ...                                        ${DL_PDCP_VOL_RCV_F1_QoS_GRP_09} > ${C005_C006_TARGET_KB_TRANSFERRED_DL_NSA} * ${SUCCESS_RATE}
    ...                            counters_data=${counters_data}
    ...                            timestamp_offset=${timestamp_offset}

Validate throughput C014
    [Arguments]     ${counters_data}    ${timestamp_offset}
    pm_counters.verify_any_counters_extended   ${PDCP_SDU_DATA_VOL_DL_SLICE} > ${C014_TARGET_KB_TRANSFERRED_DL_SA_FDD} * ${SUCCESS_RATE}
    ...                                        ${PDCP_SDU_DATA_VOL_UL_SLICE} > ${C014_TARGET_KB_TRANSFERRED_UL_SA_FDD} * ${SUCCESS_RATE}
    ...                            counters_data=${counters_data}
    ...                            timestamp_offset=${timestamp_offset}

Validate throughput C004
    [Arguments]     ${counters_data}    ${timestamp_offset}
    pm_counters.verify_any_counters_extended   ${DL_PDCP_VOL_RCV_F1_QoS_GRP_09} > ${C004_TARGET_KB_TRANSFERRED_DL_NSA_TDD} * ${SUCCESS_RATE}
    ...                                        ${UL_PDCP_VOL_SNT_F1_QoS_GRP_09} > ${C004_TARGET_KB_TRANSFERRED_UL_NSA_TDD} * ${SUCCESS_RATE}
    ...                            counters_data=${counters_data}
    ...                            timestamp_offset=${timestamp_offset}


Validate throughput D011
    [Arguments]     ${counters_data}    ${timestamp_offset}
    pm_counters.verify_any_counters_extended   ${PDCP_SDU_DATA_VOL_DL_SLICE} > ${D011_TARGET_KB_TRANSFERRED_DL_SA_FDD} * ${SUCCESS_RATE}
    ...                                        ${PDCP_SDU_DATA_VOL_UL_SLICE} > ${D011_TARGET_KB_TRANSFERRED_UL_SA_FDD} * ${SUCCESS_RATE}
    ...                            counters_data=${counters_data}
    ...                            timestamp_offset=${timestamp_offset}
