*** Settings ***
Documentation    keywords for 501 feature

Library     Collections
Library     taf.ue
Library     taf.transport.ssh       WITH NAME    ssh
Library     taf.ul.oam.selenium_megazone    WITH NAME    selenium
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library     testsuite/Wroclaw/RRM/resources/common/file_helper.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/test_specific_keywords_501.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/test_specific_keywords_501.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot


*** Variables ***
${BTS_LOGS_DIR}    /tmp/btslog2/
${UE_ALIAS}        UE_1
${MRBTS_ID}        ${tl.gnbs[0].instance_id}
&{RMODS_PASS}      AHCA=${None}


*** Keywords ***
# TODO: THE BELOW KEYWORDS ARE USED IN A24 TC AFTER EDA FIX
Graceful Comissioning
    Log to console                Performing commissioning for graceful shutdown test
    graceful_delta_commissioning  ${MRBTS_ID}  ${nrbts_id}  ${SHUTDOWN_WINDOW}  ${SHUTDOWN_STEP_AMOUNT}
    Log to console                Locking cells
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${GCS_CELL_ID}


Set Test Variables
    Log to console            Setting test variables
    ${gcs_cell_dist_name}     AdminUtils.get_cell_dist_name_by_nr_cell_id_param   cell_id=${GCS_CELL_ID}
    ${gcs_cell_rmod_id}       AdminUtils.get_rmod_id_by_nr_cell_dist_name         ${gcs_cell_dist_name}
    ${antls_dist_names}       AdminUtils.get_antl_distnames_by_nr_cell_dist_name  ${gcs_cell_dist_name}
    ${gcs_cell_rmod_ip}       AdminUtils.get_rmod_ip_by_rmod_id                   rmod_id=${gcs_cell_rmod_id}
    ${rmod_models_mapping}    AdminUtils.get_rmod_models_mapping_by_rmod_id
    ${gcs_cell_rmod_model}    Set Variable  ${rmod_models_mapping}[${gcs_cell_rmod_id}]
    ${step_duration}          Evaluate  ${SHUTDOWN_WINDOW}/${SHUTDOWN_STEP_AMOUNT}
    ${antl_connection}        coam.connect to  name=antl_connection
    ${nrbts_id}               get_nr_bts_id
    ${naa_rsrp_key}           Set Variable  ${RSRP_KEY_MAP}[${DEPLOYMENT_MODE}]
    Set Test Variable         ${naa_rsrp_key}
    Set Test Variable         ${nrbts_id}
    Set Test Variable         ${antl_connection}
    Set Test Variable         ${step_duration}
    Set Test Variable         ${gcs_cell_dist_name}
    Set Test Variable         ${gcs_cell_rmod_id}
    Set Test Variable         ${gcs_cell_rmod_ip}
    Set Test Variable         ${antls_dist_names}
    Set Test Variable         ${rmod_models_mapping}
    Set Test Variable         ${gcs_cell_rmod_model}


Start graceful shutdown procedure
    ${alias}  Set Variable  admin_api
    Connect with runtime release  ${alias}
    coam.perform_parameter_recommissioning
    ...  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${GCS_CELL_ID}   administrativeState  update  Shutting Down
    ...  ${True}  ${True}  240  ${alias}
    coam.teardown      connection=${alias}


Check cell state after graceful shutdown procedure
    log to console  Checking cell state after graceful shutdown procedure
    ${alias}  Set Variable  admin_api
    Connect with runtime release  ${alias}
    ${cell_info}    coam.Get cell specific info  ${gcs_cell_dist_name}  connection=${alias}
    ${cell_status}  Get from dictionary  ${cell_info}  status
    Dictionary should contain item  ${cell_status}  administrativeState  Locked
    coam.teardown      connection=${alias}


Connect to target rmod
    Log to console      Connecting to RMOD
    ${ru_connection}    Connect To RMOD  ${gcs_cell_rmod_ip}  &{RMODS_PASS}[${gcs_cell_rmod_model}]
    Set Test Variable   ${ru_connection}


Measure TX power on rmod before shutdown
    Connect to target rmod
    ${measurement_duration}  ${17}    #TAKEN FROM EMPIRICAL TEST, CHANGE IF NEEDED (Used only in rmod test)
    ${buffer_interval}       Evaluate  ((${SHUTDOWN_WINDOW}/${SHUTDOWN_STEP_AMOUNT})-${measurement_duration})/2
    Should Be True           ${buffer_interval} > ${5}  #To make sure that measurements will not overlap
    Set Test Variable        ${buffer_interval}
    ${before_shutdown}       Get Avg Cell TX Power On RMOD  ${ru_connection}  ${buffer_interval}  ${step_duration}
    Log to console           Avg TX power before graceful shutdown: ${before_shutdown}
    Set Test Variable        ${before_shutdown}


Measure TX power on rmod while shutdown
    ${while_shutdown}   Get Avg Cell TX Power On RMOD While Graceful Shutdown
    ...                 ${ru_connection}  ${buffer_interval}  ${step_duration}  ${SHUTDOWN_STEP_AMOUNT}
    Log to console      Avg TX power for each graceful shutdown step: ${while_shutdown}
    Set Test Variable   ${while_shutdown}


Measure RX power on UE before shutdown
    ${before_shutdown}  Get Ue Info   ${UE_ALIAS}  CELL_INFO
    ${before_shutdown}  Set Variable  ${before_shutdown}[${naa_rsrp_key}]
    Log to console      Avg RX power on UE (NAA app) before graceful shutdown: ${before_shutdown}
    Set Test Variable   ${before_shutdown}


Measure RX power on UE while shutdown
    #${2} in the below line is for compensation of connection teardown duration of "Start graceful shutdown procedure"
    ${secs_from_end}    Evaluate    ${2} + ${step_duration} * ${0.5}
    ${measure_point}    Evaluate    ${step_duration} - ${secs_from_end}
    BuiltIn.Sleep               ${measure_point}
    ${while_shutdown}   Create list
    FOR  ${_}  IN RANGE  ${SHUTDOWN_STEP_AMOUNT}
      ${cell_info}    Get Ue Info        ${UE_ALIAS}  CELL_INFO
      append to list  ${while_shutdown}  ${cell_info}[${naa_rsrp_key}]
      BuiltIn.Sleep    ${step_duration}
    END
    Log to console     Avg RX power on UE (NAA app) for each graceful shutdown step: ${while_shutdown}
    Set Test Variable  ${while_shutdown}


Start Power Measurement in Webem
    start_measuring_tx_power_in_webem  ${antls_dist_names}  ${antl_connection}
    Log to console  Power Measurement in Webem has started


Stop Power Measurement in Webem
    ${wait_for_graceful_finish}  Evaluate  ${SHUTDOWN_WINDOW} + ${step_duration}
    BuiltIn.Sleep  ${wait_for_graceful_finish}
    ${before_shutdown}  ${while_shutdown}  stop_measuring_tx_power_in_webem
    ...  ${GCS_CELL_ID}  ${SHUTDOWN_STEP_AMOUNT}  ${antl_connection}
    Log to console      Avg TX power before graceful shutdown: ${before_shutdown}
    Log to console      Avg TX power for each graceful shutdown step: ${while_shutdown}
    Set Test Variable   ${before_shutdown}
    Set Test Variable   ${while_shutdown}


Attach
    Log to console  Start using UE, test without call
    Detach Ue  ${UE_ALIAS}
    BuiltIn.Sleep  5s
    Attach Ue  ${UE_ALIAS}
    BuiltIn.Sleep  10s


Detach
    BuiltIn.Sleep  10s
    Detach Ue  ${UE_ALIAS}


Start call
    [Arguments]      ${protocol}=udp
    ...              ${ue_alias}=${UE_ALIAS}
    ...              ${tput_duration}=300s
    ...              ${tput_DL_bandwidth}=200 Mbits/sec
    ...              ${packet_size}=1400
    Log to console   Start using UE, test with call
    Detach Ue        ${UE_ALIAS}
    BuiltIn.Sleep  5s
    Attach Ue        ${UE_ALIAS}
    BuiltIn.Sleep  10s
    Start Data Transfer  dt_name=DT_DL  ue_alias=${UE_ALIAS}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}  protocol=${protocol}  packet_size=${packet_size}
    BuiltIn.Sleep  5s


Stop call
    BuiltIn.Sleep  10s
    Stop Data Transfer  dt_name=DT_DL
    Detach Ue  ${UE_ALIAS}


# TODO: THE BELOW KEYWORDS ARE NOT USED IN A24 TC
Prepare UE and check attach logs
    TcpdumpSmod.start_tcpdump_on_smod    filename=L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Prepare UE AT
    BuiltIn.Sleep   30
    ${pcap_path}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    BuiltIn.Sleep   30
    Check event a2 in pcap log     ${pcap_path}


Prepare UE AT
    Detach Ue   ${UE_ALIAS}
    BuiltIn.Sleep    10s
    Attach Ue    ${UE_ALIAS}
    ${CELL_ID}=    Get Ue Info    ${UE_ALIAS}    CELL_ID
    log to console    ${CELL_ID}


Check messages in sys log
    ${syslog_files_paths}=   Get Files Filepaths    path=${BTS_LOGS_DIR}    pattern=*
    check a2 meas in bts log    bts_log_file=${syslog_files_paths}


Check shutdown message in bts log
    ${syslog_files_paths}=   Get Files Filepaths    path=${BTS_LOGS_DIR}    pattern=*
    check shutdown msg in bts log   bts_log_file=${syslog_files_paths}


Check HO related messages
    ${syslog_files_paths}=   Get Files Filepaths    path=${BTS_LOGS_DIR}    pattern=*
    Check HO related msg in bts log   bts_log_file=${syslog_files_paths}


Get attached cell
    [Arguments]     ${pcap_path}
    ${cell_id}=   get_attached_cell_from_pcap    ${pcap_path}
    [Return]    ${cell_id}


Graceful Cell shutdown for concurrent mode NSA and SA configuration invalid parameters values handling
    [Arguments]     ${nrcell_numer}
    AdminUtils.wait_for_all_cells_on_air_state
    scf_verifier.Setup and check preconditions in scf    ${test_preconditions_scf_2}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


    Run Keyword And Expect Error    *    set_parameters_above_range
    ${feature_value_1}=    test_specific_keywords_501.Check feature value
    Should be true    False==${feature_value_1}


    Run Keyword And Expect Error    *    set_parameters_below_range
    ${feature_value_2}=    test_specific_keywords_501.Check feature value
    Should be true    False==${feature_value_2}


    scf_verifier.Setup and check preconditions in scf    ${test_preconditions_scf_1}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    ${feature_value_3}=    test_specific_keywords_501.Check feature value
    Should be true    True==${feature_value_3}


    Set_actGrflShdn_to_false
    Perform_shutting_down       ${nrcell_numer}
    ${cell_status}=   Check if cell is locked immediately    ${nrcell_numer}
    Log to console    ${cell_status}
    Should be equal     Locked   ${cell_status}


    Cell unlock after shutdown  ${nrcell_numer}
    AdminUtils.wait_for_all_cells_on_air_state


Graceful Cell shutdown for concurrent mode NSA and SA configuration operators parameters check
    [Arguments]     ${nrcell_number}
    AdminUtils.wait_for_all_cells_on_air_state
    scf_verifier.Setup and check preconditions in scf    ${test_preconditions_scf_1}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.wait_for_all_cells_on_air_state
    Perform shutting down       ${nrcell_number}
    BuiltIn.Sleep   100
    Cell unlock after shutdown  ${nrcell_number}
    AdminUtils.wait_for_all_cells_on_air_state
    Check shutdown message in bts log
