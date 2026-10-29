*** Settings ***
Documentation    This library provides keywords for DCAP-Lite UI interface
...              Please do not modify the file without notification to author
...              Maintainer: Mykhailo Yevchuk, mykhailo.yevchuk@nokia.com
Library          taf.sw.dcap.rd    WITH NAME    rd
Library          ./functions_dcap.py
Resource         taf/rfrl/utilities/utf_lab/utf_lab.robot

Library          Process

*** Variables ***
${DCAP_CONNECTION_ALIAS}=       UTE_UTF_LAB

*** Keywords ***
Create Dcap Session
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: Provides connection to DCAP-LITE.
    ...              param str host: IP address to proper host, e.g. `127.0.0.1`.
    ...              param str port: Port for connection to DCAP.
    ...              param str rd_version: RD version used in this library, default value is `dcapv1`
    ...              param bool secure: If set to `True`, the connection will be realized with use https prefix,
    ...              else with http, default value is `False`.
    ...              param str alias: Default `None`. If no alias is given, the instance alias will be set to `default`.
    [Arguments]      ${host}   ${port}
    ...              ${rd_version}=dcapv3   ${secure}=${None}   ${alias}=dcap_conn
    ${dcap_conn}=    rd.connect_to          host=${host}   port=${port}   username=${None}    password=${None}
    ...                                     rd_version=${rd_version}   secure=${secure}   alias=${alias}
    Set Suite Variable   ${DCAP_CONNECTION_ALIAS}      ${alias}
    &{bts_dict}=     Create Dictionary      host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                     port=443
    ...                                     username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                                     password=${tl.gnbs[0].cu.oam_http_connection_details.password}

    ${bts_info}=     Create List            ${bts_dict}
    Set Suite Variable                      ${bts_info}
    [Return]   ${dcap_conn}

Dcap Create BTS
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to create the bts under DCAP-LITE
    ...              param str host: IP address to proper host, e.g. `127.0.0.1`.
    ...              param str port: Port for connection to DCAP, default value is `443`
    ...              param str username: Username to authenticate the BTS, default value is `Nemuadmin`
    ...              param str password: Password to authenticate the BTS, default value is `nemuuser`
    ...              param str bts_alias: alias for bts, default value is `target_bts`
    ...              param str connection: (optional) Unique identifier for a certain connections.
    [Arguments]      ${host}   ${port}=443   ${username}=Nemuadmin   ${password}=nemuuser   ${bts_alias}=target_bts
    ...              ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${bts_info}=     rd.create_bts     host=${host}   port=${port}   username=${username}
    ...              password=${password}   bts_alias=${bts_alias}  connection=${connection}   timeout=${timeout}
    [Return]   ${bts_info}

Dcap Delete BTS
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to delete the bts under DCAP-LITE
    ...              param str bts_id: bts id which has to be deleted. By default bts_id will be fetched from
    ...              create_bts keyword which is called before.
    ...              In case create_bts is not called before then bts_id has to be
    ...              passed by user.
    [Arguments]      ${bts_id}=${None}   ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${status}=       rd.delete_bts    bts_id=${bts_id}   connection=${connection}   timeout=${timeout}
    [Return]   ${status}

Dcap Edit BTS
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to create the bts under DCAP-LITE
	...              param float or int bts_id: (required)
    ...              param str host: IP address to proper host, e.g. `127.0.0.1`.
    ...              param str port: Port for connection to DCAP, default value is `443`
    ...              param str username: Username to authenticate the BTS, default value is `Nemuadmin`
    ...              param str password: Password to authenticate the BTS, default value is `nemuuser`
    ...              param str bts_alias: alias for bts, default value is `target_bts`
    ...              param str lte_cells: Sets the lte_cells of this BTSLogin.
	...              param str nr_cells: Sets the nr_cells of this BTSLogin.
    [Arguments]      ${bts_id}   ${host}   ${port}=443   ${username}=Nemuadmin   ${password}=nemuuser
	...              ${bts_alias}=target_bts   ${lte_cells}=${None}   ${nr_cells}=${None}
	...              ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${status}=       rd.edit_bts      bts_id=${bts_id}   host=${host}   port=${port}   username=${username}
    ...              password=${password}   bts_alias=${bts_alias}   lte_cells=${lte_cells}   nr_cells=${nr_cells}
    ...              connection=${connection}   timeout=${timeout}
    [Return]   ${status}

Dcap Delete Trace
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to delete the bts trace under DCAP-LITE
    ...              param str trace_id: trace id which has to be deleted. By default trace_id will be
    ...              fetched from create_bts keyword which is called before. In case create_bts is not called
    ...              before then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}   ${connection}=${None}   ${timeout}=30
    ${status}=  rd.delete_trace      trace_id=${trace_id}   connection=${connection}   timeout=${timeout}
    [Return]   ${status}

Dcap Abort Trace
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to abort trace under DCAP-LITE
    ...              param str trace_id:  trace id which has to be aborted. By default trace_id will be
    ...              fetched from start_trace keyword which is called before. In case start_trace is not
    ...              called before then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}   ${connection}=${None}   ${timeout}=30
    ${status}=       rd.abort_trace      trace_id=${trace_id}   connection=${connection}   timeout=${timeout}
    [Return]         ${status}

Dcap Start Trace
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to start trace under DCAP-LITE
	...              param str tag: the tag of this StartTraceBody. default 'start_trace'
    ...              param float duration: The duration of this StartTraceBody duration in minutes.
    ...              default infinite duration
    ...              param bool force: signifying whether the trace should force a shutdown of any previously
    ...              running traces.
    ...              Defaults to true. If the trace startup finds an ongoing trace and 'force' is set to false,
    ...              the startup fails due to ongoing traces error. If the 'force' flag is set to true,
    ...              the startup first shuts down any ongoing traces and then continues with the startup
    ...              param list[BTSLogin] bts: The list of bts details containing host, username, password
    ...              and port number to start the trace. If this keyword is followed by `create_bts` keyword
    ...              then bts list info will be taken from here, else user has to provide the list of bts info.
    ...              param str gnb_trace_profile: the id or name of the gNB (5G) start trace. user can
    ...              get the gNB trace profile id or name details from `get_5g_profiles`.
    ...              param str enb_trace_profile: the id or name of the LTE (ENB) start trace. user can
    ...              get the LTE trace profile id or name details from  `get_LTE_profiles`.
    ...              param str custom_filter_file: The custom_filter_file to start the trace.
    ...              param list gnb_custom_profile: The gNB (5G) custom profile name list of the start trace to be
    ...              started. e.g : [cp_5g, syslog_5g, immediateSnapshot_5g, L2Ps-Component, L2Lo-Component, SCF5g]
    ...              param list enb_custom_profile: The LTE (ENB) custom profile name list of the start trace to be
    ...              started. e.g : [lteTracer_4g, tti_4g, aa_4g, syslog_4g, immediateSnapshot_4g, scf4g]
	[Arguments]       &{args_dict}
    ${status}=      rd.start_trace   &{args_dict}   connection=${DCAP_CONNECTION_ALIAS}
    [Return]   ${status}

Dcap Stop Trace
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to stop trace under DCAP-LITE
    ...              param str trace_id: trace id which has to be stopped. By default trace_id will be fetched
    ...              from create_bts keyword which is called before. In case create_bts is not called before
    ...              then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}   ${connection}=${DCAP_CONNECTION_ALIAS}    ${timeout}=30
    ${status}=       rd.stop_trace    trace_id=${trace_id}   connection=${connection}  timeout=${timeout}
    [Return]   ${status}

Dcap Get Results
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to download the trace file under DCAP-LITE
    ...              param str result_id: result id to get the trace downloaded path. By default result_id will be
    ...              fetched from create_bts keyword which is called before. In case start_trace is not called
    ...              before then result_id has to be passed by user.
    [Arguments]      ${result_id}=${None}   ${target_dir}=${None}   ${connection}=${DCAP_CONNECTION_ALIAS}    ${timeout}=100
    ${filepath}=     rd.get_results      result_id=${result_id}   target_dir=${target_dir}
    ...                                  connection=${connection}  timeout=${timeout}
    [Return]   ${filepath}

Dcap Get Result File Contents
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get result file contents under DCAP-LITE
    ...              param str result_id: result id to get the trace contents. By default result_id will be
    ...              fetched from create_bts keyword which is called before. In case start_trace is not called
    ...              before then result_id has to be passed by user.
    [Arguments]      ${result_id}=${None}   ${target_dir}=${None}   ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=100
    ${filepath}=     rd.get_result_file_contents   result_id=${result_id}   target_dir=${target_dir}
    ...                                           connection=${connection}  timeout=${timeout}
    [Return]   ${filepath}

Dcap Get Result File
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get result file contents under DCAP-LITE
    ...              param str file_path_in_zip: user can get the file_path_in_zip path name from
    ...              `get_result_file_contents` keyword e.g. "logs/dcap-lite-kong.log"
    ...              param str result_id: result id to get the trace contents as per the file_path_in_zip arg.
    ...              By default result_id will be fetched from create_bts keyword which is called before.
    ...              In case start_trace is not called before then result_id has to be passed by user.
    [Arguments]      ${file_path_in_zip}   ${result_id}=${None}   ${target_dir}=${None}   ${connection}=${DCAP_CONNECTION_ALIAS}
    ...              ${timeout}=100
    ${filepath}=     rd.get_result_file   file_path_in_zip=${file_path_in_zip}    result_id=${result_id}
    ...                                   target_dir=${target_dir}   connection=${connection}  timeout=${timeout}
    [Return]   ${filepath}

Dcap Get Trace Info By id
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get the trace info under DCAP-LITE
    ...              param str trace_id: trace id to get the info by id. By default trace_id will be fetched
    ...              from start_trace keyword which is called before. In case start_trace is not called before
    ...              then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}   ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${status}=       rd.get_trace_info_by_id      trace_id=${trace_id}   connection=${connection}  timeout=${timeout}
    [Return]   ${status}

Dcap Create Multiple BTS
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to create multiple bts under DCAP-LITE
    [Arguments]      ${bts_info}   ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${status}=  rd.create_multiple_bts   bts_info=${bts_info}   connection=${connection}  timeout=${timeout}
    [Return]   ${status}

Dcap Get BTS Profiles
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get all bts profiles info under DCAP-LITE
    [Arguments]      ${connection}=${DCAP_CONNECTION_ALIAS}  ${timeout}=30
    ${status}=  rd.get_bts_profiles   connection=${connection}  timeout=${timeout}
    [Return]   ${status}

Dcap Get VCU Profiles
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get all vcu profiles info under DCAP-LITE
    [Arguments]      ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${status}=  rd.get_vcu_profiles   connection=${connection}  timeout=${timeout}
    [Return]   ${status}

Dcap Get VDU Profiles
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get all vdu profiles info under DCAP-LITE
    [Arguments]      ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${status}=  rd.get_vdu_profiles   connection=${connection}  timeout=${timeout}
    [Return]   ${status}

Dcap Get All Trace Info
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get all the trace info under DCAP-LITE
    [Arguments]      ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${trace_info}=  rd.get_all_trace_info   connection=${connection}  timeout=${timeout}
    [Return]   ${trace_info}

Dcap Get All BTS Info
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: Provides basic information about BTS in connected DCAP-LITE.
    ...              Supported in `dcapv1` only.
    [Arguments]      ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${get_all_bts_info}=   rd.get_all_bts_info  connection=${connection}  timeout=${timeout}
    [Return]   ${get_all_bts_info}

Dcap Get BTS By id
    [Documentation]  Maintainer: Mykhailo Yevchuk
	...              Description: Provides basic information about BTS in connected DCAP-LITE.
    ...              Supported in `dcapv1` only.
    ...              param str bts_id: bts id to get the info by id. By default bts_id will be fetched from start_trace
    ...              keyword which is called before. In case create_bts is not called before then bts_id
    ...              has to be passed by user.
    [Arguments]      ${bts_id}=${None}   ${connection}=${DCAP_CONNECTION_ALIAS}   ${timeout}=30
    ${bts_by_id}=  rd.get_bts_by_id      bts_id=${bts_id}  connection=${connection}  timeout=${timeout}
    [Return]   ${bts_by_id}

Dcap Get 5G Profiles
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get all 5G profiles info under DCAP-LITE
    [Arguments]      ${connection}=${None}   ${timeout}=${None}
    ${5g_profiles}=  rd.get_5g_profiles  connection=${connection}    timeout=${timeout}
    [Return]   ${5g_profiles}

Dcap Get LTE Profiles
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get all lte profiles info under DCAP-LITE
    [Arguments]      ${connection}=${None}    ${timeout}=${None}
    ${lte_profiles}=  rd.get_lte_profiles  connection=${connection}    timeout=${timeout}
    [Return]   ${lte_profiles}

Dcap Get Tracers
    [Documentation]  Maintainer: Mykhailo Yevchuk
    ...              Description: This method is used to get the traces info under DCAP-LITE
    [Arguments]      ${connection}=${None}    ${timeout}=${None}
    ${tracers}=  rd.get_tracers  connection=${connection}    timeout=${timeout}
    [Return]   ${tracers}

Install DCAP on UTE VM
    [Arguments]     ${vm_ip}=${tl.test_pc.default_ssh_connection_details.addr}    ${version}=None
    functions_dcap.Install DCAP    vm_ip=${vm_ip}   version=${version}

Collect SCF from BTS DCAP
    [Documentation]  Maintainer: Ivan Shamilov
    ...              Description: Collects SCF from BTS
    [Arguments]      ${path}
    Log                         Start collecting SCF with DCAP     console=True
    ${bts_custom_profile}=      Create List     scf
    Create Dcap Session         host=${tl.test_pc.default_ssh_connection_details.addr}     port=9443
    ...                         secure=True
    DCAP Start Trace            bts=${bts_info}                 bts_custom_profile=${bts_custom_profile}
    ...                         wait_for_activation=True
    DCAP Get Results            timeout=480                     target_dir=${path}.zip
    ${new_filepath}=            functions_dcap.DCAP Extract Logs     log_name=scf          path=${path}
    [Return]                    ${new_filepath}

Collect Snapshot from BTS DCAP
    [Documentation]  Maintainer: Ivan Shamilov
    ...              Description: Collects Snapshot from BTS
    [Arguments]      ${path}
    Log                         Start collecting Snapshot with DCAP     console=True
    ${bts_custom_profile}=      Create List     immediateSnapshot
    ${collection_timing}=       Set Variable     Immediate
    Create Dcap Session         host=${tl.test_pc.default_ssh_connection_details.addr}     port=9443
    ...                         secure=True
    DCAP Start Trace            bts=${bts_info}                 bts_custom_profile=${bts_custom_profile}
    ...                         wait_for_activation=${TRUE}     collection_timing=${collection_timing}
    DCAP Get Results            timeout=480                     target_dir=${path}.zip
    ${new_filepath}=            functions_dcap.DCAP Extract Logs     log_name=snapshot          path=${path}
    [Return]                    ${new_filepath}

Collect ims2 file from Snapshot DCAP
    [Documentation]  Maintainer: Ivan Shamilov
    ...              Description: Extracts ims2 file from previously collected snapshot
    [Arguments]      ${snapshot_path}
    functions_dcap.Extract ims2      snapshot_path=${snapshot_path}

Start Collecting syslog from BTS DCAP
    [Documentation]     Maintainer: Ivan Shamilov
    ...                 Description:    Starts syslog tracing
    [Arguments]         ${dir_path}
    Log                         Start tracing syslog with DCAP   console=True
    ${gnb_custom_profile}=      Create List     condor5gSyslog
    Create Dcap Session         host=${tl.test_pc.default_ssh_connection_details.addr}     port=9443
    ...                         secure=True
    ${dcap_syslog_trace_id}=    DCAP Start Trace     bts=${bts_info}    gnb_custom_profile=${gnb_custom_profile}
    ...                         wait_for_activation=${TRUE}
    ${dcap_syslog_trace_id}=    Set Variable                            ${dcap_syslog_trace_id}[tracer_id]
    Set Suite Variable          ${${dir_path}_dcap_syslog_trace_id}     ${dcap_syslog_trace_id}

Stop Collecting Syslog from BTS DCAP
    [Documentation]     Maintainer: Ivan Shamilov
    ...                 Description:    Collects syslog tracing
    [Arguments]         ${path}    ${dir_path}
    Log                         Collecting syslog with DCAP  console=True
    Create Dcap Session         host=${tl.test_pc.default_ssh_connection_details.addr}     port=9443
    ...                         secure=True
    DCAP Stop Trace             trace_id=${${dir_path}_dcap_syslog_trace_id}
    DCAP Get Results            timeout=480     result_id=${${dir_path}_dcap_syslog_trace_id}   target_dir=${path}.zip
    ${new_filepath}=            functions_dcap.DCAP Extract Logs          log_name=Syslog            path=${path}
    [Return]                    ${new_filepath}

Wait until DCAP is active
    Wait until Keyword Succeeds    20x    3s   Create dcap session   ${tl.test_pc.default_ssh_connection_details.addr}
    ...                                        9443  secure=True

Start DCAP Containers
    Start Process      DCAP_Basic_controller   start          alias=start_dcap
    ${result}=         Wait For Process        start_dcap
    Log to console     ${result.stdout}
    Should contain     ${result.stdout}        All DCAP Basic containers started successfully
    Wait until DCAP is active

Dcap Setup
    ${DCAP_STATUS}=      Run Keyword and Ignore Error
    ...                  Wait Until Keyword Succeeds         2x    15 min     DCAP Setup Container
    Run Keyword and Ignore Error
    ...   Run Keyword If       """${DCAP_STATUS[0]}""" == """FAIL"""
    ...                        functions_dcap.Send DCAP Logs

DCAP Setup Container
#    Install DCAP on UTE VM        # DCAP is preinstalled to all UTE VMs starting from 24.01.2023
    Start DCAP Containers
    Create dcap session   ${tl.test_pc.default_ssh_connection_details.addr}
    ...                   9443  secure=True
    Dcap Create BTS       host=${tl.gnbs[0].cu.oam_http_connection_details.addr}

############## RFRL testing ##############
RFRL Start DCAP Containers
    utf_lab.Start UTF Lab on UTE VM      timeout=600

RFRL Create DCAP Connection
    [Arguments]     ${alias}=${DCAP_CONNECTION_ALIAS}
    utf_lab.connect    alias=${alias}

RFRL Start Trace
    [Arguments]    &{args_dict}
    RFRL Create DCAP Connection
    ${trace_id}=   utf_lab.start_trace_gnb     &{args_dict}
    [Return]       ${trace_id}

RFRL Stop Trace And Collect Results
    [Arguments]    ${trace_id}      ${log_dir}      ${with_name}
    RFRL Create DCAP Connection
    utf_lab.UTF Lab Stop Tracing and Collect Results      trace_id=${trace_id}   log_dir=${log_dir}  with_name=${with_name}

RFRL Add GNB
    [Arguments]     ${gnb_ip}=${NONE}
    utf_lab.add_gnb    gnb_ip=${gnb_ip}

RFRL Delete gNB By Host Address
    [Arguments]          ${host_ip}      ${connection}=${DCAP_CONNECTION_ALIAS}
    ${all_bts_info}=     Dcap Get All BTS Info
    ${bts_id}=           find_bts_id_by_host_address    host_ip=${host_ip}    all_bts_info=${all_bts_info}
    Dcap Delete BTS      bts_id=${bts_id}               connection=${connection}

RFRL DCAP Setup
    [Arguments]     ${gnb_ip}=${NONE}
    RFRL Start DCAP Containers
    RFRL Create DCAP Connection
    RFRL Add GNB    gnb_ip=${gnb_ip}

RFRL Collect SCF from BTS DCAP
    [Arguments]     ${log_dir}      ${with_name}    ${gnb_ip}=${NONE}
    Log             Collecting SCF from BTS           console=True
    ${path}=        utf_lab.UTF Lab Collect SCF from BTS    gnb_ip=${gnb_ip}
    ...                                               log_dir=${log_dir}      with_name=${with_name}
    [Return]        ${path}

RFRL Collect Snapshot from BTS DCAP
    [Arguments]     ${log_dir}      ${with_name}    ${gnb_ip}=${NONE}
    Log             Collecting Snapshot from BTS       console=True
    ${path}=        utf_lab.UTF Lab Collect Snapshot from BTS    gnb_ip=${gnb_ip}
    ...                                                    log_dir=${log_dir}      with_name=${with_name}
    [Return]        ${path}

RFRL Start Collecting Syslog from BTS DCAP
    [Documentation]     Maintainer: Ivan Shamilov
    ...                 Description:    Starts syslog tracing
    [Arguments]         ${dir_path}     ${gnb_ip}=${NONE}
    Log                         Start tracing syslog with DCAP   console=True
    ${gnb_custom_profile}=      Create List     condor5gSyslog
    ${dcap_syslog_trace_id}=    RFRL Start Trace     gnb_ip=${gnb_ip}   gnb_custom_profile=${gnb_custom_profile}
    ${dcap_syslog_trace_id}=    Set Variable                            ${dcap_syslog_trace_id}[tracer_id]
    Set Suite Variable          ${${dir_path}_dcap_syslog_trace_id}     ${dcap_syslog_trace_id}

RFRL Stop Collecting Syslog from BTS DCAP
    [Documentation]     Maintainer: Ivan Shamilov
    ...                 Description:    Collects syslog tracing
    [Arguments]         ${dir_path}    ${log_dir}    ${with_name}
    Log                         Collecting syslog with DCAP  console=True
    RFRL Stop Trace And Collect Results     trace_id=${${dir_path}_dcap_syslog_trace_id}
    ...                                     log_dir=${log_dir}      with_name=${with_name}
    ${filepath}=    utf_lab.extract_logfile_from_zip           path=${log_dir}/${with_name}     log_name=Syslog
    [Return]                    ${filepath}
