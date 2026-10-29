*** Settings ***
Documentation
...            Keywords for collecting logs specific to Classical deployment
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    OperatingSystem
Library    Process
Library    String
Library    Collections
Library    ute_wtssim
Library    ute_syslog
Library    ute_tshark
Library    ta5g_tshark
Library    taf.collectors.tcpdump      WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core         WITH NAME    core
Library    taf.ul.hanging_resources    WITH NAME    radio_res
Library    taf.sbts.oam.coam.admin     WITH NAME    coam_admin
Library    taf.collectors.l1l2bip      WITH NAME    l1l2_bip
Library    taf.collectors.dcap         WITH NAME    dcap
Resource    configurators.robot

*** Variables ***
&{DEFAULT_LOGS}    syslog_gnb=yes    tcpdump_gnb=yes

*** Keywords ***
Start Multiple Logs
    [Documentation]    Starts multiple continuous log collectors that have to be stopped with ``Stop All Running Logs``.
    ...                Global variable ``$\{DEFAULT_LOGS\}`` can be provided to start GNB syslog and tcpdump collection.
    ...                Tcpdump collection collects all SCTP packets on GNB which include
    ...                SYSCOM/NGAP/X2AP/XNAP/E1AP/F1AP protocols.
    ...                Sherpa streaming item has to be a dictionary with items ``nr_phy_cell_ids``, ``pci`` and ``up_sw``.
    ...                - ``logs``: Dictionary with flags for logging mechanisms.\
    ...                Valid items: syslog_gnb, syslog_ap, tcpdump_gnb, sherpa, dcap
    ...                - ``log_dir``: Directory for logs, Default: ``$\{TEST_log_dir\}/Logs/``
    [Arguments]    ${logs}    ${log_dir}=${TEST_log_dir}/Logs/
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${logs}) is dict    msg=Invalid KW parameter: logs
    Should Contain Any    ${logs}    syslog_gnb    syslog_ap    tcpdump_gnb    sherpa    bip_gnb    dcap
    ...    msg=Logs dictionary does not contain any valid item
    #---------------------------------------------------------------------------------------------------------------
    Run Keyword If    ${logs}.get('syslog_gnb') == 'yes'
    ...    Start GNB Syslog Collection    log_dir=${log_dir}/Syslog/
    Run Keyword If    ${logs}.get('syslog_ap') == 'yes'
    ...    Start AP Syslog Collection    log_dir=${log_dir}/Syslog/
    Run Keyword If    ${logs}.get('tcpdump_gnb') == 'yes'
    ...    Start GNB tcpdump Collection    log_dir=${log_dir}/Wireshark/
    Run Keyword If    'sherpa' in ${logs}
    ...    Start Sherpa Trace Streaming    @{logs.sherpa}
    Run Keyword If    ${logs}.get('bip_gnb') == 'yes'
    ...    Start GNB L1L2 BIP Trace Streaming
    Run Keyword If    'dcap' in ${logs}
    ...    Setup DCAP Trace    &{logs.dcap}

Stop All Running Logs
    [Documentation]    Stops log collectors started with ``Start Multiple Logs``.
    Teardown TAF Collectors If Running
    Stop GNB Syslog Collection
    Stop AP Syslog Collection
    Stop GNB tcpdump Collection

Teardown TAF Collectors If Running
    [Documentation]    Stops and teardowns remaining TAF collectors tracked under ``$\{SUITE_TAF_collectors\}`` variable.
    Log to Console    Stopping remaining TAF collectors
    FOR    ${name}    IN    @{SUITE_TAF_collectors}
      Run Keyword If    '${SUITE_TAF_collectors}[${name}]' == 'STARTED'    Run Keywords
      ...           core.stop_collectors    names=${name}
      ...    AND    Create Directory    ${TEST_log_dir}/TAF/${name}/
      ...    AND    core.collect_collectors    names=${name}    target_dir=${TEST_log_dir}/TAF/${name}/
      ...    AND    Set To Dictionary      ${SUITE_TAF_collectors}     ${name}=STOPPED
      Run Keyword If    '${SUITE_TAF_collectors}[${name}]' != 'DECONFIGURED'    Run Keywords
      ...           core.teardown_collectors    names=${name}
      ...    AND    Set To Dictionary      ${SUITE_TAF_collectors}     ${name}=DECONFIGURED
    END

#----- Syslog collection -------------------------------------------------------------------------------------------
Start GNB Syslog Collection
    [Documentation]    Starts collecting GNB syslog stream and saves filepath to test variable TEST_syslog_gnb_path.
    ...                - ``log_dir``: Log directory, Default: ``$\{TEST_log_dir\}/Syslog/``
    [Arguments]    ${log_dir}=${TEST_log_dir}/Syslog/
    ${state}    Get Variable Value    ${TEST_syslog_gnb_state}    STOPPED
    Should Be True    '${state}' == 'STOPPED'    msg=GNB Syslog Collection is already started.
    Start Syslog Collection   side=GNB    log_dir=${log_dir}
    Set Test Variable    ${TEST_syslog_gnb_path}    ${log_dir}/GNB_syslog.log
    Set Test Variable    ${TEST_syslog_gnb_state}    STARTED

Start AP Syslog Collection
    [Documentation]    Starts collecting AP syslog stream and saves filepath to test variable TEST_syslog_ap_path.
    ...                - ``log_dir``: Log directory, Default: ``$\{TEST_log_dir\}/Syslog/``
    [Arguments]    ${log_dir}=${TEST_log_dir}/Syslog/
    ${state}    Get Variable Value    ${TEST_syslog_ap_state}    STOPPED
    Should Be True    '${state}' == 'STOPPED'    msg=AP Syslog Collection is already started.
    Start Syslog Collection   side=AP    log_dir=${log_dir}
    Set Test Variable    ${TEST_syslog_ap_path}    ${log_dir}/AP_syslog.log
    Set Test Variable    ${TEST_syslog_ap_state}    STARTED

Stop GNB Syslog Collection
    [Documentation]    Stops collecting GNB syslog stream. Returns path to collected syslog.
    ${state}    Get Variable Value    ${TEST_syslog_gnb_state}    STOPPED
    Return From Keyword If    '${state}' == 'STOPPED'
    Stop Syslog Collection   side=GNB    filepath=${TEST_syslog_gnb_path}
    Display Syslog Logs As Robot Warnings    ${TEST_syslog_gnb_path}
    [Return]    ${TEST_syslog_gnb_path}

Stop AP Syslog Collection
    [Documentation]    Stops collecting AP syslog stream. Returns path to collected syslog.
    ${state}    Get Variable Value    ${TEST_syslog_ap_state}    STOPPED
    Return From Keyword If    '${state}' == 'STOPPED'
    Stop Syslog Collection   side=AP    filepath=${TEST_syslog_ap_path}
    [Return]    ${TEST_syslog_ap_path}

Start Syslog Collection
    [Documentation]    Starts collecting syslog stream from specified node.
    ...                - ``side``: GNB or AP
    ...                - ``log_dir``: Log directory, Default: ``$\{TEST_log_dir\}/Syslog/``
    [Arguments]    ${side}    ${log_dir}=${TEST_log_dir}/Syslog/
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${side}' in ('GNB','AP')    msg=Invalid KW parameter: side
    #---------------------------------------------------------------------------------------------------------------
    &{if_ip}    Create Dictionary    AP=192.168.200.126    GNB=192.168.255.126
    Log to Console    Starting ${side} Syslog Collection
    ute_syslog.start_syslog
    ...    log_dir=${log_dir}
    ...    log_name=${side}_syslog.log
    ...    ip=${if_ip}[${side}]
    ...    alias=${side}_syslog

Stop Syslog Collection
    [Documentation]    Stops collecting syslog stream from specified node and creates an additional file just for
    ...                extracted Errors and Warnings.
    ...                - ``side``: GNB or AP
    ...                - ``filepath``: Path to collected syslog file
    [Arguments]    ${side}    ${filepath}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${side}' in ('GNB','AP')    msg=Invalid KW parameter: side
    #---------------------------------------------------------------------------------------------------------------
    Log to Console    Stopping ${side} Syslog Collection
    ute_syslog.collect_syslog_results    alias=${side}_syslog
    ${size}    Get File Size    ${filepath}
    Should Be True    ${size} > 0
    ...    msg=Collected ${side} syslog file is empty. Check swconfig if syslog streaming is configured correctly.
    ${errors_filepath}    Replace String    ${filepath}    _syslog    _syslog_err_and_warn
    ${result}    Run Process    grep    'ERR/\\|WRN/'    ${filepath}    stdout=${errors_filepath}    shell=${True}
    File Should Exist    ${errors_filepath}

#----- PCAP collection ---------------------------------------------------------------------------------------------
Start GNB tcpdump Collection
    [Documentation]    Starts tcpdump collection of SCTP packets on GNB
    ...                which includes SYSCOM/NGAP/X2AP/XnAP/E1AP/F1AP protocols.
    ...                Saves filepath to test variable TEST_tcpdump_gnb_path.
    ...                - ``log_dir``: Directory for PCAP, Default: ``$\{TEST_log_dir\}/Wireshark/``
    [Arguments]    ${log_dir}=${TEST_log_dir}/Wireshark/
    ${state}    Get Variable Value    ${TEST_tcpdump_gnb_state}    STOPPED
    Should Be True    '${state}' == 'STOPPED'    msg=GNB tcpdump is already started.
    Log to Console    Starting SCTP packet capture on GNB
    ${proc}    ${filepath}    ${alias}    ta5g_tshark.start_tcpdump_on_remote_interface
    ...    log_dirpath=${log_dir}
    ...    log_filename_prefix=tcpdump_SYSCOM_NG_X2_Xn_E1_F1
    ...    alias=tshark_gnb_sctp
    Set Test Variable    ${TEST_tcpdump_gnb_path}    ${filepath}
    Set Test Variable    ${TEST_tcpdump_gnb_state}    STARTED

Stop GNB tcpdump Collection
    [Documentation]    Stops tcpdump collection of SCTP packets on GNB. Returns path to collected PCAP file.
    ${state}    Get Variable Value    ${TEST_tcpdump_gnb_state}    STOPPED
    Return From Keyword If    '${state}' == 'STOPPED'
    Log to Console    Stopping SCTP packet capture on GNB
    ta5g_tshark.stop_tcpdump_on_remote_interface
    ta5g_tshark.stop_tshark    alias=tshark_gnb_sctp
    Set Test Variable    ${TEST_tcpdump_gnb_state}    STOPPED
    File Should Exist    ${TEST_tcpdump_gnb_path}
    [Return]    ${TEST_tcpdump_gnb_path}

Start GNB L1L2 BIP Trace Streaming
    [Documentation]        Starts streaming of L1L2 BIP messages on GNB
    ${state}    Get Variable Value    ${SUITE_TAF_collectors.l1l2bip}    DECONFIGURED
    Should Be Equal    ${state}    DECONFIGURED    msg=GNB L1L2 BIP streaming already started
    ${webservice}=  Create Dictionary
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  port=443
    l1l2_bip.create_interface_mirroring_l1l2bip_collector
    ...  name=l1l2bip
    ...  webservice=${webservice}
    ...  timeout=150
    Log to console       Starting GNB L1L2 trace streaming
    core.setup_collectors    names=l1l2bip
    core.set_suite_alias    l1l2bip
    Set To Dictionary      ${SUITE_TAF_collectors}     l1l2bip=CONFIGURED

Start GNB L1L2 BIP Trace Collection
    [Documentation]    Starts capturing L1L2 BIP trace
    ...                L1L2 BIP stream needs to be started on GNB with ``Start L1L2 BIP Trace Streaming``.
    Should Contain Any    ${SUITE_TAF_collectors}[l1l2bip]    CONFIGURED    STOPPED
    ...    msg=GNB L1L2 BIP Trace streaming was not started
    Log to Console    Starting capture of L1L2 BIP Trace
    core.start_collectors    names=l1l2bip
    Set To Dictionary      ${SUITE_TAF_collectors}     l1l2bip=STARTED

Stop GNB L1L2 BIP Trace Streaming
    [Documentation]    Stops L1L2 BIP Trace streaming on GNB
    Should Not Be Equal    ${SUITE_TAF_collectors}[l1l2bip]    DECONFIGURED
    ...    msg=GNB L1L2 BIP Trace streaming was not started
    Log to Console    Stopping L1L2 Trace streaming
    core.teardown_collectors    names=l1l2bip
    Set To Dictionary      ${SUITE_TAF_collectors}     l1l2bip=DECONFIGURED

Stop GNB L1L2 BIP Trace Collection
    [Documentation]      Stops gNB L1L2 Traces
    ...                - ``log_dir``: Directory for BIP PCAPs, Default: ``$\{TEST_log_dir\}/Wireshark/``
    [Arguments]    ${log_dir}=${TEST_log_dir}/Wireshark/
    Should Be Equal    ${SUITE_TAF_collectors}[l1l2bip]    STARTED
    ...    msg=GNB L1L2 BIP Trace collection was not started
    Create Directory    ${log_dir}
    Log to console       Stopping capture and collect l1l2 BIP traces
    core.stop_collectors        names=l1l2bip
    core.collect_collectors     names=l1l2bip     target_dir=${log_dir}
    Set To Dictionary      ${SUITE_TAF_collectors}     l1l2bip=STOPPED

#----- AaShell radio resources collection --------------------------------------------------------------------------
Get and Save Radio Resources
    [Documentation]    Gets allocated radio resources on GNB via Aashell and returns them.
    ...                Optionally saves the result to a JSON file.
    ...                - ``output_file``: Filepath to output results in JSON format, Default: No file created
    [Arguments]    ${output_file}=${Empty}
    Log To Console    Collecting radio resources via Aashell
    ${resources}    radio_res.get_resources_usage
    Run Keyword If    '${output_file}' != ''    Save Data as JSON File    data=${resources}    filepath=${output_file}
    [Return]    ${resources}

Get and Compare Radio Resources
    [Documentation]    Gets allocated radio resources on GNB via Aashell and returns them.
    ...                Optionally saves the result to a JSON file and allows to compare them with previous data.
    ...                - ``output_file``: Filepath to output results in JSON format, Default: No file created
    ...                - ``compare_with``: Filepath to JSON with data to compare, Default: No comparison
    [Arguments]    ${output_file}=${Empty}    ${compare_with}=${Empty}
    Sleep    3s    Wait for all late resources to deallocate
    ${resources}    Get and Save Radio Resources    output_file=${output_file}
    ${compare_data}    Run Keyword If    '${compare_with}' != ''    Get JSON File Content    filepath=${compare_with}
    Run Keyword If    '${compare_with}' != ''    Run Keywords
    ...    Log To Console    Comparing current and previous radio resources
    ...    AND    radio_res.resources_should_be_equal   ${compare_data}   ${resources}
    [Return]    ${resources}

#----- Sherpa Traces collection ------------------------------------------------------------------------------------
Start Sherpa Trace Streaming
    [Documentation]    Configures and starts Sherpa Trace/TTI Trace streaming on GNB for specified cells PCI
    ...                via COAM (In WebEM: Diagnostic/Debug Tracing).
    ...                Cells have to be in Enabled state.
    ...                - ``l2_stream_configs``: List of L2 stream configs where each config has to be a dictionary\
    ...                with items:
    ...                - ``nr_phy_cell_ids``: Comma-separated list of cells PCI, not used for L2HiPdcp data flow
    ...                - ``up_sw``: L2 Data Flow: L2Ps/L2Lo/L2HiPdcp/L2HiRlc
    ...                - ``trace_type``: L2 Trace Type: Sherpa/Component
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | &\{SHERPA_STREAM\} | nr_phy_cell_ids=50,51 | up_sw=L2Ps | trace_type=Sherpa |
    ...                | &\{TTI_TRACE_STREAM\} | nr_phy_cell_ids=50,51 | up_sw=L2Ps | trace_type=Component |
    ...                | &\{L2HIPDCP_STREAM\} | up_sw=L2HiPdcp | trace_type=Sherpa |
    ...                | @\{L2_STREAM_CONFIGS\} | $\{SHERPA_STREAM\} | $\{TTI_TRACE_STREAM\} | $\{L2HIPDCP_STREAM\} |
    ...                | ***** Test Cases ***** |
    ...                | Example_test_with_both_Sherpa_and_TTI |
    ...                |  | Start Sherpa Trace Streaming | @\{L2_STREAM_CONFIGS\} |
    [Arguments]    @{l2_stream_configs}
    #--------- Param check -----------------------------------------------------------------------------------------
    FOR    ${config}    IN    @{l2_stream_configs}
      Should Contain    ${config}    up_sw    msg=Missing L2 config parameter: up_sw
      Should Contain    ${config}    trace_type    msg=Missing L2 config parameter: trace_type
      Should Be True    '${config.up_sw}' in ('L2Ps','L2Lo','L2HiPdcp','L2HiRlc')
      ...    msg=Invalid L2 config parameter: up_sw
      Should Be True    '${config.trace_type}' in ('Sherpa','Component')    msg=Invalid L2 config parameter: trace_type
      Should Be True    '${config.up_sw}' == 'L2HiPdcp' or 'nr_phy_cell_ids' in ${config}
      ...    msg=Missing L2 config parameter: nr_phy_cell_ids
    END
    #---------------------------------------------------------------------------------------------------------------
    ${state}    Get Variable Value    ${SUITE_TAF_collectors.l2stream3}    DECONFIGURED
    Should Be Equal    ${state}    DECONFIGURED    msg=Sherpa Trace streaming already started
    ${src_ip_addr}    Set Variable    10.0.1.2
    ${dst_ip_addr}    Set Variable    10.0.1.1
    ${webservice}    Create Dictionary
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  port=443
    tcpdump.create_tcpdump_collector
    ...  name=tcpdump
    ...  options=-i eth3 udp and src ${src_ip_addr} and dst ${dst_ip_addr} and dst port 5678
    ...  target_file_name=tcpdump_l2stream3.pcap
    l2stream3.create_sbts_l2stream_collector
    ...  name=l2stream3
    ...  webservice=${webservice}
    ...  source_ip_addr=${src_ip_addr}
    ...  destination_ip_addr=${dst_ip_addr}
    ...  dscp=15
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configs}
    Log to Console    Starting Sherpa Trace streaming
    core.setup_collectors    names=l2stream3
    core.set_suite_alias    l2stream3
    Set To Dictionary      ${SUITE_TAF_collectors}     l2stream3=CONFIGURED

Stop Sherpa Trace Streaming
    [Documentation]    Stops Sherpa Trace streaming on GNB
    Should Not Be Equal    ${SUITE_TAF_collectors}[l2stream3]    DECONFIGURED
    ...    msg=Sherpa Trace streaming was not started
    Log to Console    Stopping Sherpa Trace streaming
    core.teardown_collectors    names=l2stream3
    Set To Dictionary      ${SUITE_TAF_collectors}     l2stream3=DECONFIGURED

Start Sherpa Trace Collection
    [Documentation]    Starts capturing Sherpa Trace stream with tcpdump on VM.
    ...                Sherpa Trace stream needs to be started on GNB with ``Start Sherpa Trace Streaming``.
    Should Contain Any    ${SUITE_TAF_collectors}[l2stream3]    CONFIGURED    STOPPED
    ...    msg=Sherpa Trace streaming was not started
    Log to Console    Starting capture of Sherpa Trace
    core.start_collectors    names=l2stream3
    Set To Dictionary      ${SUITE_TAF_collectors}     l2stream3=STARTED

Stop and Collect Sherpa Trace
    [Documentation]    Stops capturing Sherpa Trace stream with tcpdump and saves PCAP file to specified path.
    ...                Returns path to collected PCAP file.
    ...                - ``log_dir``: Directory for PCAP, Default: ``$\{TEST_log_dir\}/Wireshark/``
    [Arguments]    ${log_dir}=${TEST_log_dir}/Wireshark/
    Should Be Equal    ${SUITE_TAF_collectors}[l2stream3]    STARTED
    ...    msg=Sherpa Trace collection was not started
    Log to Console    Stopping capture and collecting Sherpa Trace
    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3    target_dir=${log_dir}
    Set To Dictionary      ${SUITE_TAF_collectors}     l2stream3=STOPPED
    ${result}    Run Process    find    ${log_dir}/l2stream3/tcpdump/    -name    *.pcap    shell=${True}
    ${filepath}    Set Variable    ${result.stdout}
    File Should Exist    ${filepath}
    [Return]    ${filepath}

#----- DCAP collection ---------------------------------------------------------------------------------------------
Setup DCAP Trace
    [Documentation]    Configures DCAP Trace for GNB. Starts DCAP Basic service if not running.
    ...                - ``gnb_custom_profile``: List logging modules to enable in GNB custom profile, Default: None
    ...                - ``bts_custom_profile``: List logging modules to enable in BTS custom profile, Default: None
    ...                - ``start``: Starts DCAP Trace after setup, Default: no
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | @\{DCAP_GNB\} | cp_5g | condor5gSyslog |
    ...                | @\{DCAP_BTS\} | scf | pmFiles |
    ...                | ***** Test Cases ***** |
    ...                | Setup DCAP Trace | gnb_custom_profile=$\{DCAP_GNB\} | bts_custom_profile=$\{DCAP_BTS\} |
    [Arguments]    ${gnb_custom_profile}=@{Empty}    ${bts_custom_profile}=@{Empty}    ${start}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${start}' in ('yes','no')    msg=Invalid KW parameter: start
    @{gnb_allowed_elements}    Create List
    ...    cp_5g    immediateSnapshot_5g    pmFiles5g    condor5gSyslog    SCF5g    L2Ps_Component    L2Lo_Component
    ...    L2HiRlc_Component    L2HiPdcp_Component    L2Ps_Sherpa    L2Lo_Sherpa    L2HiRlc_Sherpa    L2HiPdcp_Sherpa
    ...    bip_interface_mirroring    L1stream
    @{bts_allowed_elements}    Create List
    ...    immediateSnapshot    scf    pmFiles    ipCapture
    ${msg}    Catenate    SEPARATOR=\n
    ...    Invalid KW parameter: gnb_custom_profile
    ...    Received elements: ${gnb_custom_profile}${\n}Allowed elements:${gnb_allowed_elements}
    Should Be True    set(${gnb_custom_profile}).issubset(set(${gnb_allowed_elements}))    msg=${msg}
    ${msg}    Catenate    SEPARATOR=\n
    ...    Invalid KW parameter: bts_custom_profile
    ...    Received elements: ${bts_custom_profile}${\n}Allowed elements:${bts_allowed_elements}
    Should Be True    set(${bts_custom_profile}).issubset(set(${bts_allowed_elements}))    msg=${msg}
    #---------------------------------------------------------------------------------------------------------------
    ${state}    Get Variable Value    ${SUITE_TAF_collectors.dcap}    DECONFIGURED
    Should Be Equal    ${state}    DECONFIGURED    msg=DCAP Trace already configured
    DCAP Basic Control    action=start
    &{bts}    Create Dictionary
    ...  host=10.0.1.2
    ...  port=443
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    &{trace}    Create Dictionary
    ...  bts=${bts}
    ...  gnb_custom_profile=${gnb_custom_profile}
    ...  bts_custom_profile=${bts_custom_profile}
    dcap.create_dcap_trace_collector
    ...  name=dcap
    ...  trace=${trace}
    Wait Until Keyword Succeeds    60s    10s    core.setup_collectors    names=dcap
    core.set_suite_alias    dcap
    Set To Dictionary      ${SUITE_TAF_collectors}     dcap=CONFIGURED
    Run Keyword If    '${start}' == 'yes'    Start DCAP Trace

Teardown DCAP Trace
    [Documentation]    Deconfigures DCAP Trace
    Should Not Be Equal    ${SUITE_TAF_collectors}[dcap]    DECONFIGURED
    ...    msg=DCAP Trace was not configured
    core.teardown_collectors    names=dcap
    Set To Dictionary      ${SUITE_TAF_collectors}     dcap=DECONFIGURED

Start DCAP Trace
    [Documentation]    Starts DCAP Trace collection
    Should Contain Any    ${SUITE_TAF_collectors}[dcap]    CONFIGURED    STOPPED
    ...    msg=DCAP Trace was not configured
    Log to Console    Starting capture of DCAP Trace
    core.start_collectors    names=dcap
    Set To Dictionary      ${SUITE_TAF_collectors}     dcap=STARTED

Stop and Collect DCAP Trace
    [Documentation]    Stops DCAP Trace collection, saves and unzips logs to specified directory.
    ...                Returns dictonary with paths to collected log files.
    ...                - ``log_dir``: Directory for DCAP logs, Default: ``$\{TEST_log_dir\}/DCAP/``
    [Arguments]    ${log_dir}=${TEST_log_dir}/DCAP/
    Should Be Equal    ${SUITE_TAF_collectors}[dcap]    STARTED
    ...    msg=DCAP Trace was not started
    Create Directory    ${log_dir}
    Log to Console    Stopping capture of DCAP Trace
    core.stop_collectors    names=dcap
    core.collect_collectors    names=dcap    target_dir=${log_dir}
    Set To Dictionary      ${SUITE_TAF_collectors}     dcap=STOPPED
    Unzip File    file_path=${log_dir}/dcap/dcap.zip    dest_dir=${log_dir}
    @{ipCapture}    Find Files    ${log_dir}    -iname    '*ipCapture*.pcap'
    @{syslog}    Find Files    ${log_dir}    -iname    '*Syslog*.LOG'
    &{files}    Create Dictionary
    Set To Dictionary    ${files}    ipCapture=${ipCapture}
    Set To Dictionary    ${files}    syslog=${syslog}
    Display Syslog Logs As Robot Warnings    @{syslog}
    [Return]    ${files}

#----- COAM Logs collection ----------------------------------------------------------------------------------------
Collect COAM Logs
    [Documentation]    Collects Active alarms, SCF and Snapshot from GNB in CLASSICAL deployment via COAM API.
    ...                Supports independent user flags ``skip:alarms,scf,snapshot`` for skipping collection steps.
    ...                - ``log_dir``: Directory for COAM data, Default: ``$\{TEST_log_dir\}/``
    ...                Example:
    ...                | robot -v skip:snapshot test_suite.robot
    ...                | robot -v skip:alarms,scf,snapshot test_suite.robot
    [Arguments]    ${log_dir}=${TEST_log_dir}
    ${flags}    Get Variable Value    ${skip}
    ${skip_alarms}    Set Variable If    'alarms' in '${flags}'    ${True}    ${False}
    ${skip_scf}    Set Variable If    'scf' in '${flags}'    ${True}    ${False}
    ${skip_snapshot}    Set Variable If    'snapshot' in '${flags}'    ${True}    ${False}
    ${connection}    coam_admin.setup_admin
    Run Keyword If    not ${skip_alarms}
    ...    Collect SCF From GNB    log_dir=${log_dir}/SCF/    connection=${connection}
    ...    ELSE    Log to Console    Skipping SCF collection
    Run Keyword If    not ${skip_scf}
    ...    Collect Active Alarms From GNB    log_dir=${log_dir}/Alarms/    connection=${connection}
    ...    ELSE    Log to Console    Skipping Active alarms collection
    Run Keyword If    not ${skip_snapshot}
    ...    Collect Snapshot From GNB    log_dir=${log_dir}/Snapshot/    connection=${connection}
    ...    ELSE    Log to Console    Skipping Snapshot collection
    [Teardown]    coam_admin.teardown_admin    connection=${connection}

Collect SCF From GNB
    [Documentation]    Collects SCF from GNB via COAM API.
    ...                Without provided connection COAM setup and teardown will happen internally.
    ...                - ``log_dir``: Directory for SCF, Default: ``$\{TEST_log_dir\}/SCF/``
    ...                - ``file_prefix``: Prefix for SCF, Default: None
    ...                - ``connection``: Existing connection to COAM managed externally, Default: None
    [Arguments]    ${log_dir}=${TEST_log_dir}/SCF/
    ...    ${file_prefix}=${Empty}    ${connection}=${Empty}
    ${local_connection}    Run Keyword If    '${connection}' == ''    coam_admin.setup_admin
    ...    ELSE    Set Variable    ${connection}
    Log to Console    Collecting SCF
    coam_admin.get_current_scf_file    local_dir_path=${log_dir}    file_name=${file_prefix}SCF.xml
    ...    connection=${local_connection}
    [Teardown]    Run Keyword If    '${connection}' == ''    coam_admin.teardown_admin    connection=${local_connection}

Collect Active Alarms From GNB
    [Documentation]    Collects active alarms from GNB via COAM API.
    ...                Without provided connection COAM setup and teardown will happen internally.
    ...                Major and Critical alarms are printed to log.html
    ...                - ``log_dir``: Directory for alarms file, Default: ``$\{TEST_log_dir\}/Alarms/``
    ...                - ``file_prefix``: Prefix for alarms file, Default: None
    ...                - ``connection``: Existing connection to COAM managed externally, Default: None
    [Arguments]    ${log_dir}=${TEST_log_dir}/Alarms/
    ...    ${file_prefix}=${Empty}    ${connection}=${Empty}
    ${local_connection}    Run Keyword If    '${connection}' == ''    coam_admin.setup_admin
    ...    ELSE    Set Variable    ${connection}
    Log to Console    Collecting Active Alarms
    ${out}    coam_admin.get_active_alarms    connection=${local_connection}
    ${alarm_list}    Set Variable    ${Empty}
    FOR    ${alarm}    IN    @{out}
      ${msg}    Set Variable
      ...    \[${alarm}[severity]\] ${alarm}[alarmName]: ${alarm}[alarmDetail] --> ${alarm}[configObjectName]
      ${alarm_list}    Catenate    ${alarm_list}    ${msg}${\n}
      Run Keyword If    '${alarm}[severity]' in ('Major','Critical')    Log    ${TEST NAME}: ${msg}    level=WARN
    END
    Create File    ${log_dir}${file_prefix}active_alarms_short.log    ${alarm_list}
    Save Data as JSON File    data=${out}    filepath=${log_dir}${file_prefix}active_alarms_full.json
    [Teardown]    Run Keyword If    '${connection}' == ''    coam_admin.teardown_admin    connection=${local_connection}

Collect Snapshot From GNB
    [Documentation]    Collects Snapshot from GNB via COAM API.
    ...                Without provided connection COAM setup and teardown will happen internally.
    ...                - ``log_dir``: Directory for Snapshot, Default: ``$\{TEST_log_dir\}/Snapshot/``
    ...                - ``file_prefix``: Prefix for Snapshot file, Default: None
    ...                - ``connection``: Existing connection to COAM managed externally, Default: None
    [Arguments]    ${log_dir}=${TEST_log_dir}/Snapshot/
    ...    ${file_prefix}=${Empty}    ${connection}=${Empty}
    ${local_connection}    Run Keyword If    '${connection}' == ''    coam_admin.setup_admin
    ...    ELSE    Set Variable    ${connection}
    Log to Console    Collecting Snapshot
    ${sw_ver}    coam_admin.get_sw_version    connection=${local_connection}
    coam_admin.get_snapshot    target_file_name=${log_dir}/${file_prefix}Snapshot_${sw_ver}.zip    timeout=900
    ...    connection=${local_connection}
    [Teardown]    Run Keyword If    '${connection}' == ''    coam_admin.teardown_admin    connection=${local_connection}
    [Return]    ${log_dir}/${file_prefix}Snapshot_${sw_ver}.zip

Display Syslog Logs As Robot Warnings
    [Documentation]    Filters provided syslog files for a pattern and displays them as Robot warnings.
    ...                Looks for a pattern:
    ...                - containing "please contact" phrase
    ...                - errors and warnings originating from C-Plane but omitting CP-IF and CP-SCTP warnings
    [Arguments]    @{files}
    ${pattern}    Set Variable    please contact|-cp[-_r][^is].*(ERR/|WRN/)|-cp_[is].*ERR/
    ${result}    Run Process    grep    -iP    ${pattern}    @{files}    shell=${True}
    ${lines}    Split To Lines    ${result.stdout}
    FOR    ${line}    IN    @{lines}
      Log    ${TEST NAME} Syslog: ${line}    level=WARN
    END
