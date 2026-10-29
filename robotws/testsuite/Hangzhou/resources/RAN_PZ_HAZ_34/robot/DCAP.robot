*** Settings ***
Documentation    This library provides keywords for DCAP-Lite UI interface
...              Please do not modify the file without notification to author
...              Author: Rashmi R
Library     taf.sw.dcap.rd   WITH NAME   rd

*** Keywords ***
Create dcap session
    [Documentation]  Author: Rashmi R
    ...              Description: Provides connection to DCAP-LITE.
    ...              param str host: IP address to proper host, e.g. `127.0.0.1`.
    ...              param str port: Port for connection to DCAP.
    ...              param str rd_version: RD version used in this library, default value is `dcapv1`
    ...              param bool secure: If set to `True`, the connection will be realized with use https prefix,
    ...              else with http, default value is `False`.
    ...              param str alias: Default `None`. If no alias is given, the instance alias will be set to `default`.
    [Arguments]      ${host}      ${port}   ${rd_version}=dcapv1    ${secure}=${None}   ${alias}=${None}
    rd.connect_to     host=${host}     port=${port}    rd_version=${rd_version}
    ...               secure=${secure}     alias=${alias}


Dcap create bts
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to create the bts under DCAP-LITE
    ...              param str host: IP address to proper host, e.g. `127.0.0.1`.
    ...              param str port: Port for connection to DCAP, default value is `443`
    ...              param str username: Username to authenticate the BTS, default value is `Nemuadmin`
    ...              param str password: Password to authenticate the BTS, default value is `nemuuser`
    ...              param str bts_alias: alias for bts, default value is `target_bts`
    ...              param str connection: (optional) Unique identifier for a certain connections.
    [Arguments]      ${host}      ${port}=443   ${username}=Nemuadmin   ${password}=nemuuser   ${bts_alias}=target_bts
    rd.create_bts     host=${host}     port=${port}    username=${username}
    ...               password=${password}     bts_alias=${bts_alias}

Dcap delete bts
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to delete the bts under DCAP-LITE
    ...              param str bts_id: bts id which has to be deleted. By default bts_id will be fetched from
    ...              create_bts keyword which is called before.
    ...              In case create_bts is not called before then bts_id has to be
    ...              passed by user.
    [Arguments]      ${bts_id}=${None}
    rd.delete_bts      bts_id=${bts_id}

Dcap edit bts
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to create the bts under DCAP-LITE
	...              param float or int bts_id: (required)
    ...              param str host: IP address to proper host, e.g. `127.0.0.1`.
    ...              param str port: Port for connection to DCAP, default value is `443`
    ...              param str username: Username to authenticate the BTS, default value is `Nemuadmin`
    ...              param str password: Password to authenticate the BTS, default value is `nemuuser`
    ...              param str bts_alias: alias for bts, default value is `target_bts`
    ...              param str lte_cells: Sets the lte_cells of this BTSLogin.
	...              param str nr_cells: Sets the nr_cells of this BTSLogin.
    [Arguments]      ${bts_id}      ${host}    ${port}=443   ${username}=Nemuadmin   ${password}=nemuuser
	...              ${bts_alias}=target_bts    ${lte_cells}=${None}     ${nr_cells}=${None}
    rd.create_bts     bts_id=${bts_id}      host=${host}     port=${port}    username=${username}
    ...               password=${password}     bts_alias=${bts_alias}     lte_cells=${lte_cells}
    ...               nr_cells=${nr_cells}

Dcap delete trace
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to delete the bts trace under DCAP-LITE
    ...              param str trace_id: trace id which has to be deleted. By default trace_id will be
    ...              fetched from create_bts keyword which is called before. In case create_bts is not called
    ...              before then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}
    rd.delete_trace      trace_id=${trace_id}

Dcap start trace
    [Documentation]  Author: Rashmi R
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
    [Arguments]      ${tag}=start_trace      ${duration}=-1    ${force}=True   ${bts}=${None}
	...              ${gnb_trace_profile}=${None}    ${enb_trace_profile}=${None}    ${custom_filter_file}=${None}
	...              ${gnb_custom_profile}=${None}    ${enb_custom_profile}=${None}
    rd.start_trace     tag=${tag}      duration=${duration}     force=${force}    bts=${bts}
    ...               gnb_trace_profile=${gnb_trace_profile}     enb_trace_profile=${enb_trace_profile}
    ...               custom_filter_file=${custom_filter_file}     gnb_custom_profile=${gnb_custom_profile}
	...               enb_custom_profile=${enb_custom_profile}

Dcap stop trace
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to stop trace under DCAP-LITE
    ...              param str trace_id: trace id which has to be stopped. By default trace_id will be fetched
    ...              from create_bts keyword which is called before. In case create_bts is not called before
    ...              then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}
    rd.stop_trace      trace_id=${trace_id}

Dcap get results
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to download the trace file under DCAP-LITE
    ...              param str result_id: result id to get the trace downloaded path. By default result_id will be
    ...              fetched from create_bts keyword which is called before. In case start_trace is not called
    ...              before then result_id has to be passed by user.
    [Arguments]      ${result_id}=${None}
    rd.get_results      result_id=${result_id}

Dcap get result file contents
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get result file contents under DCAP-LITE
    ...              param str result_id: result id to get the trace contents. By default result_id will be
    ...              fetched from create_bts keyword which is called before. In case start_trace is not called
    ...              before then result_id has to be passed by user.
    [Arguments]      ${result_id}=${None}
    rd.get_result_file_contents      result_id=${result_id}

Dcap get result file
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get result file contents under DCAP-LITE
    ...              param str file_path_in_zip: user can get the file_path_in_zip path name from
    ...              `get_result_file_contents` keyword e.g. "logs/dcap-lite-kong.log"
    ...              param str result_id: result id to get the trace contents as per the file_path_in_zip arg.
    ...              By default result_id will be fetched from create_bts keyword which is called before.
    ...              In case start_trace is not called before then result_id has to be passed by user.
    [Arguments]       ${file_path_in_zip}     ${result_id}=${None}
    rd.get_result_file      file_path_in_zip=${file_path_in_zip}    result_id=${result_id}

Dcap get trace info by id
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get the trace info under DCAP-LITE
    ...              param str trace_id: trace id to get the info by id. By default trace_id will be fetched
    ...              from start_trace keyword which is called before. In case start_trace is not called before
    ...              then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}
    rd.get_trace_info_by_id      trace_id=${trace_id}

Dcap get all trace info
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get all the trace info under DCAP-LITE
    rd.get_all_trace_info

Dcap get all bts info
    [Documentation]  Author: Rashmi R
    ...              Description: Provides basic information about BTS in connected DCAP-LITE.
    ...              Supported in `dcapv1` only.
    rd.get_all_bts_info


Dcap get bts by id
    [Documentation]  Author: Rashmi R
	...              Description: Provides basic information about BTS in connected DCAP-LITE.
    ...              Supported in `dcapv1` only.
    ...              param str bts_id: bts id to get the info by id. By default bts_id will be fetched from start_trace
    ...              keyword which is called before. In case create_bts is not called before then bts_id
    ...              has to be passed by user.
    [Arguments]      ${bts_id}=${None}
    rd.get_bts_by_id      bts_id=${bts_id}


Dcap get 5g profiles
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get all 5G profiles info under DCAP-LITE
    rd.get_5g_profiles

Dcap get lte profiles
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get all lte profiles info under DCAP-LITE
    rd.get_lte_profiles

Dcap get tracers
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get the traces info under DCAP-LITE
    rd.get_tracers
