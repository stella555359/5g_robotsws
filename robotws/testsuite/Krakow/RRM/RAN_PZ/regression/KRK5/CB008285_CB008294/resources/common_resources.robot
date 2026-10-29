*** Settings ***
Documentation
...   Regression testing of CB008285 and CB008294
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/procedures/resources/robot/SwconfigOperations.robot
Resource     taf/rfrl/bts/robot/common/gnb_log.robot
Resource     taf/rfrl/utilities/utf_lab/utf_lab.robot
Library      Collections
Library      taf.sw.dcap.rd                                                       WITH NAME    dcap
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms           WITH NAME    alarm
Library      ./resources.py                                                       WITH NAME    local_resources
Library      ./wireshark_logs.py                                                  WITH NAME    wireshark_logs
Library      ./call_procedure/ue_proxy.py                                         WITH NAME    ue_proxy
Library      ./call_procedure/ue_operations.py
Library      ./call_procedure/bts_operations.py
Library      ./call_procedure/html_thput_table.py
Library      ./call_procedure/common_operations.py
Library      ./call_procedure/attenuator_operations.py

*** Keywords ***
Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}


Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    local_resources.clear_btslog_dir
    Common Preconditions With Watching Alarms
    local_resources.upload_swconfig_to_bts


Actions after test
    [Arguments]    ${stop_dcap}=${False}
    Run keyword if    ${stop_dcap}!=${False}    Stop DCAP
    Perform Full Commissioning and Wait for onAir    prefix_tag=${None}
    Remove custom allowed alarms if defined
    Common Postconditions With Watching Alarms


Call To Selected Cells
    [Arguments]     ${cell_list}     ${deviation}     ${duration}     ${tc_name}     ${alias}=UE     ${run_num}=1
    ...             ${additional_action}=${None}      ${additional_action_params}=${None}
    ue_proxy.Restart UE Proxy On UE PC
    Call Procedure      cell_list=${cell_list}      alias=${alias}      raise_errors=${False}       run_num=${run_num}
    ...                 deviation=${deviation}      duration=${duration}        tc_name=${tc_name}
    ...                 additional_action=${additional_action}      additional_action_params=${additional_action_params}
    ${recall}=         Check If Need Recall
    ${failed_cells}=         Get Failed Cells List
    Run Keyword If     ${recall}==${True}     logger.log_info_to_console
    ...                                       Performing data call for previously failed cells: ${failed_cells}
    Run Keyword If     ${recall}==${True}     ue_proxy.restart_ue_proxy_on_ue_pc
    Run Keyword If     ${recall}==${True}     Call Procedure        cell_list=${failed_cells}     alias=${alias}
    ...                                       deviation=${deviation}      duration=${duration}        tc_name=${tc_name}
    ...                                       run_num=Prepare Num Run Before Recall    run_num=${run_num}    rerun=${True}
    ...                                       additional_action=${additional_action}
    ...                                       additional_action_params=${additional_action_params}
    html_thput_table.Generate Html Thput Table      run_num=${run_num}


Call Procedure
    [Arguments]     ${cell_list}     ${deviation}     ${duration}     ${tc_name}     ${alias}=UE     ${run_num}=1
    ...             ${raise_errors}=${True}     ${rerun}=${False}     ${additional_action}=${None}
    ...             ${additional_action_params}=${None}
    Prepare UE For Test     alias=${alias}        capabilities=${capabilities}
    ${auto_deviation}=    Set Variable    False
    FOR     ${cell}     IN      @{cell_list}
        logger.log_info_to_console      *** Call for cell: ${cell} ***
        ${attach_status}=       Run Keyword And Return Status       Try To Make Attach      expected_cell=${cell}
        ...                     alias=${alias}
        ${tput_dl}      Set Variable    ${TPUT_MATRIX}[${tc_name}][${cell}][tput_dl]
        ${tput_ul}      Set Variable    ${TPUT_MATRIX}[${tc_name}][${cell}][tput_ul]
        ${protocol}     Set Variable    ${TPUT_MATRIX}[${tc_name}][${cell}][protocol]
        ${parallel_streams}      Set Variable    ${TPUT_MATRIX}[${tc_name}][${cell}][parallel_streams]
        ${linux_congestion}      Set Variable    ${TPUT_MATRIX}[${tc_name}][${cell}][linux_congestion]
        ${action}=       Get Additional Action During Call    action_name=${additional_action}
        ${deviation}      ${auto_deviation}      Get Proper Deviation    deviation=${deviation}     cell=${cell}
        ...                                      auto_dev=${auto_deviation}

        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=dl    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}    tput=${tput_dl}
        ...                                                 deviation=${deviation}    cell_name=${cell}
        ...                                                 raise_errors=${raise_errors}        run_num=${run_num}
        ...                                                 rerun=${rerun}     linux_congestion=${linux_congestion}
        ...                                                 additional_action=${action}
        ...                                                 additional_action_params=${additional_action_params}

        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=ul    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}    tput=${tput_ul}
        ...                                                 deviation=${deviation}    cell_name=${cell}
        ...                                                 raise_errors=${raise_errors}    run_num=${run_num}
        ...                                                 rerun=${rerun}    linux_congestion=${linux_congestion}
        ...                                                 additional_action=${action}
        ...                                                 additional_action_params=${additional_action_params}


        Wait Until Keyword Succeeds     5x      10s        Try To Make Detach      alias=${alias}
    END
    [Teardown]      Release Resources      ${alias}


Perform Data Transfer On UE
    [Documentation]     Parameters mapping for their aliases:
    ...                 duration                -t
    ...                 parallel_streams        -P - CLIENT
    ...                 size_packet             -l (for UDP) - CLIENT; -M (for TCP) - CLIENT
    ...                 buffer_(client/server)  -w
    ...                 interval                -i - CLIENT&SERVER
    ...                 linux_congestion        -Z - CLIENT
    [Arguments]     ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}           ${cell_name}
    ...             ${parallel_streams}     ${linux_congestion}    ${size_packet}=1320B   ${buffer_client}=${None}
    ...             ${buffer_server}=${None}    ${run_num}=1        ${interval}=1          ${alias}=UE
    ...             ${raise_errors}=${True}     ${rerun}=${False}       ${additional_action}=${None}
    ...             ${additional_action_params}=${None}

    Perform Data Transfer In Specific Direction     direction=${direction}      duration=${duration}    tput=${tput}
    ...                                             protocol=${protocol}        deviation=${deviation}
    ...                                             cell_name=${cell_name}      run_num=${run_num}
    ...                                             buffer_client=${buffer_client}      buffer_server=${buffer_server}
    ...                                             parallel_streams=${parallel_streams}    size_packet=${size_packet}
    ...                                             interval=${interval}        linux_congestion=${linux_congestion}
    ...                                             alias=${alias}      raise_errors=${raise_errors}    rerun=${rerun}
    ...                                             additional_action=${additional_action}
    ...                                             additional_action_params=${additional_action_params}


Enable OSI and create mismatch
    local_resources.load_gnb_delta_from_file     delta_json_file=enable_osi_create_mismatch.json
    logger.log_info to console     Enable OSI and create mismatch    log_hierarchy=${2}


Disable OSI and remove mismatch
    local_resources.load_gnb_delta_from_file     delta_json_file=disable_osi_remove_mismatch.json
    logger.log_info to console     Disable OSI and remove mismatch    log_hierarchy=${2}


Check All AMF ngLinkStatus
    [Arguments]     ${status}
    local_resources.check_amf_nglink_status    status=${status}


Check Only Default AMF ngLinkStatus
    [Arguments]     ${status}
    local_resources.check_amf_nglink_status    status=${status}    only_default=${True}


Lock default AMF
    local_resources.load_gnb_delta_from_file     delta_json_file=locking_amf.json
    logger.log_info to console     Default AMF is locked    log_hierarchy=${2}


Unlock default AMF
    local_resources.load_gnb_delta_from_file     delta_json_file=unlocking_amf.json
    logger.log_info to console     Default AMF is unlocked    log_hierarchy=${2}


Create directory for additional logs
     ${log_dir}=    local_resources.create_dir_for_additional_logs
     [Return]    ${log_dir}


Start_collect_backhaul_pcap
    [Arguments]     ${capture_file}    ${filter}=${None}
    logger.log_info to console     Starting bachhaul pcap collection    log_hierarchy=${2}
    wireshark_logs.start_collect_bh_pcap     capture_file=${capture_file}    additional_options=${filter}


Stop_collect_backhaul_pcap
    [Arguments]     ${capture_file}    ${log_dir}=None
    wireshark_logs.stop_collect_bh_pcap     capture_file=${capture_file}    log_dir=${log_dir}
    logger.log_info to console     Bachhaul pcap collection is stopped    log_hierarchy=${2}


Find pattern in syslog
    [Arguments]     ${pattern}     ${syslog_dir}
    logger.log_info to console     Verify pattern in syslog    log_hierarchy=${2}
    ${syslog_line}=    Get matching string from syslog    string_to_find=${pattern}    syslog_dir=${syslog_dir}
    logger.log_info to console     ${syslog_line}    log_hierarchy=${3}


Setup DCAP
    utf_lab.Update UTF Lab on UTE VM
    utf_lab.Start UTF Lab On UTE VM    timeout=${600}
    utf_lab.Connect     username=${None}    password=${None}
    utf_lab.Add Gnb     gnb_ip=10.84.164.118    gnb_port=${443}
    logger.log_info to console    DCAP is started


Start Emil Collection
    ${cplane_custom_profile} =    Create List    cp_5g
    ${trace_id} =    utf_lab.Start Trace Gnb
    ...    gnb_ip=10.84.164.118
    ...    gnb_port=${443}
    ...    gnb_custom_profile=${cplane_custom_profile}
    ...    control_plane_interface=${True}
    utf_lab.wait_for_trace_running
    [Return]    ${trace_id}


Stop Emil Collection
    [Arguments]    ${trace_id}    ${log_dir}    ${filename}=emil
    UTF Lab Stop Tracing and Collect Results    trace_id=${trace_id}    log_dir=${log_dir}    with_name=${filename}


Stop DCAP
    Stop UTF Lab on UTE VM    timeout=${300}
    logger.log_info to console    DCAP is stopped


Convert 5gm to json
    [Arguments]    ${dcap_log}    ${emil_log}=emil_log.json
    logger.log_info to console    ${dcap_log}
    Run    unzip -j ${dcap_log}.zip -d ${dcap_log} '*.5gm'
    ${5gm_filename}=    local_resources.get_5gm_file    fivegm_filename=${dcap_log}
    dcap.connect_to     host=127.0.0.1    port=9443    secure=${True}
    ${upload_result}=    dcap.upload_encoded_file    file_name=${dcap_log}/${5gm_filename}
    logger.log_info to console    ${upload_result}
    ${operation_status}    Get from Dictionary    ${upload_result}    operation_status
    ${session_id}    Get from Dictionary    ${upload_result}    session_id
    ${grid_id}    Set Variable    ${upload_result['grid_ids'][0]}
    ${source_id}    Set Variable    ${upload_result['file_ids'][0]}
    ${decoded_content}=    dcap.get_decoded_file_contents_in_json    session_id=${session_id}
    ...                                                              data_source_id=${source_id}
    ...                                                              what=source    filter="Message name"="SctpMessage"
    ${decoded_emil_log}=    local_resources.dcap_save_to_json    decoded_content=${decoded_content}
    ...                                                          filename=${dcap_log}/${emil_log}
    [Return]    ${decoded_emil_log}


Check call flow
   [Arguments]    ${emil_json_file}
   local_resources.check_call_flow    emil_json_file=${emil_json_file}


Verify counters
    [Arguments]    ${test_case}
    ${counters}=    local_resources.verify_counters    test_case=${test_case}
    [Return]    ${counters}


Verify error slogan
   [Arguments]    ${error}
    local_resources.verify_error_slogan   error=${error}


Change sCellOnlyFr2Sa params
    local_resources.load_gnb_delta_from_file     delta_json_file=change_sCellOnlyFr2Sa.json


Remove prevent list
    local_resources.load_gnb_delta_from_file     delta_json_file=remove_prevent_list.json


Check time to next PM period
    [Arguments]     ${time_buffer}    ${interval}=${15}
    local_resources.check_time_to_next_pm_period    time_buffer=${time_buffer}    interval=${interval}

Check NO CA in tcpdump log
    [Arguments]     ${capture_file}
    wireshark_logs.check_no_ca    capture_file=${capture_file}

Act CA
    logger.log_info to console    Activate CA for FR2    log_hierarchy=${2}
    local_resources.load_gnb_delta_from_file     delta_json_file=act_ca.json

Act CA 4CC DL 4CC UL
    logger.log_info to console    Activate 4CC DL 4CC UL    log_hierarchy=${2}
    local_resources.load_gnb_delta_from_file     delta_json_file=ca_4ccdl_4ccul.json

Act CA 8CC DL 4CC UL
    logger.log_info to console    Activate 8CC DL 4CC UL    log_hierarchy=${2}
    local_resources.load_gnb_delta_from_file     delta_json_file=ca_8ccdl_4ccul.json

Check DL and UL CA in tcpdump log
    [Arguments]     ${capture_file}    ${dl_cc}    ${ul_cc}
    wireshark_logs.check_dl_and_ul_ca    capture_file=${capture_file}    dl_cc=${dl_cc}    ul_cc=${ul_cc}

Change qrxlevmin for cell
    logger.log_info to console    Change qrxlevmin for cell    log_hierarchy=${2}
    local_resources.load_gnb_delta_from_file     delta_json_file=qrxlevmin.json

Attach UE
    [Arguments]     ${cell}    ${alias}=UE
    Prepare UE For Test     alias=${alias}        capabilities=${capabilities}
    ${attach_status}=       Run Keyword And Return Status       Try To Make Attach      expected_cell=${cell}
    ...                     alias=${alias}
    [Return]    ${attach_status}

Detach UE
    [Arguments]     ${alias}=UE
    Wait Until Keyword Succeeds     5x      10s        Try To Make Detach      alias=${alias}
    [Teardown]      Release Resources      ${alias}

Trigger SI Modification Paging
    [Arguments]     ${cell}    ${alias}=UE
    ${attach_status}=    Attach UE    cell=${cell}    alias=${alias}
    Run Keyword If      ${attach_status}==${True}    Change qrxlevmin for cell
    BuiltIn.Sleep    120s
    Detach UE    alias=${alias}

Add new AMF
    local_resources.load_gnb_delta_from_file     delta_json_file=add_amf.json
    logger.log_info to console    New AMF is added    log_hierarchy=${2}


Delete AMF
    local_resources.load_gnb_delta_from_file     delta_json_file=delete_amf.json
    logger.log_info to console    One AMF is deleted    log_hierarchy=${2}


Activate PCMD trace in BTS
    ${release}=    Get gNB Sw Release Name
    ${release}=    Set Variable If    '${release}' == 'SBTS25R3'    ${release}    SBTS00
    local_resources.load_gnb_delta_from_file    delta_json_file=activate_pcmd_${release}.json
    logger.log_info to console    PCMD trace is actiavted in BTS    log_hierarchy=${2}


Deactivate PCMD trace in BTS
    local_resources.load_gnb_delta_from_file     delta_json_file=deactivate_pcmd.json
    logger.log_info to console    PCMD trace is deactiavted in BTS    log_hierarchy=${2}


Perform Serving Cell Lock Unlock
    [Arguments]     ${cell_id}
    gnbcell.lock_cell    cell_id=${cell_id}
    Wait Until Keyword Succeeds     5x      5s        gnbcell.verify_cell_is_locked    cell_id=${cell_id}
    logger.log_info to console    NRCELL-${cell_id} is locked    log_hierarchy=${2}
    gnbcell.unlock_cell    cell_id=${cell_id}
    Wait Until Keyword Succeeds     5x      5s        gnbcell.verify_cell_is_unlocked    cell_id=${cell_id}
    logger.log_info to console    NRCELL-${cell_id} is unlocked    log_hierarchy=${2}


Change sCellActivationMethod
    local_resources.load_gnb_delta_from_file     delta_json_file=scell_act_method.json
    logger.log_info to console   Change sCellActivationMethod to blind   log_hierarchy=${2}


Verify PMI
    [Arguments]     ${counters}
    local_resources.verify_pmi    counters=${counters}


Verify RRC SETUP configuring BWP using initial BWP profile
    [Arguments]     ${capture_file}    ${initial_bwp}=${False}
    wireshark_logs.verify_rrc_setup    capture_file=${capture_file}    initial_bwp=${initial_bwp}


Enable CNI94156
    local_resources.load_gnb_delta_from_file    delta_json_file=enable_cni94156.json
    logger.log_info to console    CNI-94156 is enabled    log_hierarchy=${2}


Check csi report
    [Arguments]     ${capture_file}    ${exp_cqi}    ${exp_beam_report}
    wireshark_logs.check_csi_report    capture_file=${capture_file}    exp_cqi=${exp_cqi}    exp_beam_report=${exp_beam_report}


Change pucchF2MaxCodeRate
    local_resources.load_gnb_delta_from_file     delta_json_file=pucchF2MaxCodeRate.json
    logger.log_info to console    PucchF2MaxCodeRate set to zeroDot25    log_hierarchy=${2}
