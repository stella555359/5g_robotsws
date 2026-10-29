*** Settings ***
Documentation    This library provides keywords for DCAP-Lite UI interface
...              Please do not modify the file without notification to author
...              Author: Rashmi R
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Library     taf.sw.dcap.rd    WITH NAME    rd
Library             taf.collectors.dcap    WITH NAME    utflab
Library     dcap.py

*** Variables ***

${labpcname}=                                            wro5grrm
${labpcpass}=                                            5gpass!1
${labpcip}=                                              10.44.72.183
${Emil_keywords}=                                        ${CURDIR}/emil.py
# ${tes_emil}=                                             ${CURDIR}/test_emil.robot
${python_path}=   /cygdrive/c/Users/wro5grrm/AppData/Local/Programs/Python/Python38/python.exe
*** Keywords ***

Prepare and start DCAP
    [Documentation]  Author: Sebastian Mikos
    ...              param str dcap_host: (optional) IP address to dcap, default IP 10.44.180.37
    ...              param str bts_mpalne: (optional) IP address to BTS MPlane.
    ...              param list nrCells: (optional) cells name separated by space e.g. NRCELL_R-1 NRCELL_R-2 NRCELL_R-3
    ...              if empty all cells will be added.
    ...              param list custom_profiles: (optional) dcap custom profiles seperated by space e.g.  cp_5g cp_4g condor5gSyslog
    ...              default 'cp_5g'
    [Arguments]  ${dcap_host}=10.44.180.37   ${bts_mpalne}=${None}  ${nrCells}=${None}  ${custom_profiles}=cp_5g  ${connection}=default
    Log to console  Prepare and start DCAP
    ${bts_mpalne}   Get MPlane from BTS configuration
    @{cells}    create_cell_list   ${nrCells}
    &{bts_key} =    Create Dictionary    host=${bts_mpalne}  port=443  username=Nemuadmin  password=nemuuser  nrCells=@{cells}
    @{custom_profile}    create_custom_profile_list   ${custom_profiles}
    ${labpcip}    Get UEPC IP address
    Log  ${labpcip}
    Create dcap session    host=${dcap_host}   port=443   secure=True  alias=${connection}
    Run keyword and ignore error    Delete active DCAP trace for BTS   host=${bts_mpalne}  connection=${connection}
    Get dcap bts id by IP   host=${bts_mpalne}  connection=${connection}
    Dcap create bts    host=${bts_mpalne}  connection=${connection}
    Dcap start trace   bts=&{bts_key}   gnb_custom_profile=@{custom_profile}  connection=default
    Dcap get trace status   trace_status=running   connection=${connection}
    Log to Console    UTF started.

Prepare and start new DCAP
    [Documentation]  Author: Sebastian Mikos
    ...              param str dcap_host: (optional) IP address to dcap, default IP 10.44.180.37
    ...              param str bts_mpalne: (optional) IP address to BTS MPlane.
    ...              param list nrCells: (optional) cells name separated by space e.g. NRCELL_R-1 NRCELL_R-2 NRCELL_R-3
    ...              if empty all cells will be added.
    ...              param list custom_profiles: (optional) dcap custom profiles seperated by space e.g.  cp_5g cp_4g condor5gSyslog
    ...              default 'cp_5g'
    [Arguments]  ${dcap_host}=10.44.180.37   ${bts_mplane}=${None}  ${nrCells}=${None}  ${custom_profiles}=cp_5g
    ...          ${connection}=default    ${timeout}=30    ${username}=Nemuadmin     ${password}=nemuuser
    ...          ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
    Log to console  Prepare and start DCAP
    # ${bts_mplane}   Get MPlane from BTS configuration
    @{cells}    create_cell_list   ${nrCells}
    &{bts_key} =    Create Dictionary    host=${bts_mplane}  port=443  username=${username}  password=${password}  nrCells=@{cells}
    IF    '${vdu_custom_profile}' != '${None}'
        Set Variable    ${custom_profiles}    ${None}
        @{vdu_custom_profile}    create_custom_profile_list   ${vdu_custom_profile}
    END
    @{custom_profile}    create_custom_profile_list   ${custom_profiles}
    IF    '${vcu_custom_profile}' != '${None}'
        Set Variable    ${custom_profiles}    ${None}
        @{vcu_custom_profile}    create_custom_profile_list   ${vcu_custom_profile}
    END
    @{custom_profile}    create_custom_profile_list   ${custom_profiles}
    Create dcap session    host=${dcap_host}   port=443   secure=True  alias=${connection}
    Run keyword and ignore error    Delete active DCAP trace for BTS   host=${bts_mplane}  connection=${connection}
    Get dcap bts id by IP   host=${bts_mplane}  connection=${connection}
    Dcap create bts    host=${bts_mplane}  connection=${connection}   timeout=${timeout}  username=${username}  password=${password}
    Dcap start trace   bts=&{bts_key}
    ...    vdu_custom_profile=${vdu_custom_profile}
    ...    vcu_custom_profile=${vcu_custom_profile}
    ...    gnb_custom_profile=@{custom_profile}
    ...    connection=${connection}
    Dcap get trace status   trace_status=running  connection=${connection}

Stop DCAP trace and download logs
    Dcap stop trace
    sleep  10s
    Dcap get trace status   trace_status=ready   connection=${connection}
    ${filepath} =   Dcap get results
    Send Emil script    ${filepath}
    Unpack and prepare DCAP 5gm file to verify
#    Unpack and prepare new DCAP 5gm file to verify

Create dcap session
    [Documentation]  Author: Rashmi R
    ...              Description: Provides connection to DCAP-LITE.
    ...              param str host: IP address to proper host, e.g. `127.0.0.1`.
    ...              param str port: Port for connection to DCAP.
    ...              param str rd_version: RD version used in this library, default value is `dcapv1`
    ...              param bool secure: If set to `True`, the connection will be realized with use https prefix,
    ...              else with http, default value is `False`.
    ...              param str alias: Default `None`. If no alias is given, the instance alias will be set to `default`.
    [Arguments]      ${host}      ${port}   ${rd_version}=dcapv3    ${secure}=${None}   ${alias}=${None}
    ...              ${username}=utfuser  ${password}=utfadmin!
    rd.connect_to    host=${host}     port=${port}    rd_version=${rd_version}  username=${username}  password=${password}
    ...              secure=${secure}     alias=${alias}
    Log  Session created


Dcap create bts
    [Documentation]  Author: Sebastian Mikos
    ...              Description: This method is used to create the bts under DCAP-LITE
    ...              param str host: IP address to proper host, e.g. `127.0.0.1`.
    ...              param str port: Port for connection to DCAP, default value is `443`
    ...              param str username: Username to authenticate the BTS, default value is `Nemuadmin`
    ...              param str password: Password to authenticate the BTS, default value is `nemuuser`
    ...              param str bts_alias: alias for bts, default value is `target_bts`
    ...              param str connection: (optional) Unique identifier for a certain connections.
    [Arguments]      ${host}      ${port}=443   ${username}=Nemuadmin   ${password}=nemuuser   ${bts_alias}=target_bts
    ...              ${connection}=default    ${timeout}=60
    ${retry_count}   Set Variable    0
    ${max_retries}   Set Variable    5
    FOR
    ...    ${retry}    IN RANGE    ${max_retries}
           TRY
               ${bts_alias}      Get TL hostname
                    rd.create_bts   host=${host}     port=${port}    username=${username}
                    ...   password=${password}   bts_alias=${bts_alias}  connection=${connection}  timeout=${timeout}

               Log    BTS created successfully on attempt ${retry + 1}
               Exit For Loop
           EXCEPT
               Log    Connection failed on attempt ${retry + 1}. Retrying...
               ${retry_count}   Set Variable    ${retry + 1}
               Run Keyword If  ${retry_count} == ${max_retries}  Fail  Unable to create BTS after ${max_retries} attempts
           END
    END

Dcap delete bts
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to delete the bts under DCAP-LITE
    ...              param str bts_id: bts id which has to be deleted. By default bts_id will be fetched from
    ...               create_bts keyword which is called before.
    ...              In case create_bts is not called before then bts_id has to be
    ...              passed by user.
    [Arguments]      ${bts_id}=${None}  ${connection}=default
    rd.delete_bts      bts_id=${bts_id}  connection=${connection}
    Log  Bts deleted

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
    Log  BTS edited

Dcap delete trace
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to delete the bts trace under DCAP-LITE
    ...              param str trace_id: trace id which has to be deleted. By default trace_id will be
    ...              fetched from create_bts keyword which is called before. In case create_bts is not called
    ...              before then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}
    rd.delete_trace      trace_id=${trace_id}
    Log  Trace deleted

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
	...              ${gnb_custom_profile}=${None}    ${enb_custom_profile}=${None}  ${connection}=default
	...              ${vdu_custom_profile}=${None}  ${vcu_custom_profile}=${None}
    rd.start_trace     tag=${tag}      duration=${duration}     force=${force}    bts=${bts}  connection=${connection}
    ...               gnb_custom_profile=${gnb_custom_profile}  gnb_trace_profile=${gnb_trace_profile}
    ...               enb_trace_profile=${enb_trace_profile}  custom_filter_file=${custom_filter_file}  enb_custom_profile=${enb_custom_profile}
    ...               vdu_custom_profile=${vdu_custom_profile}  vcu_custom_profile=${vcu_custom_profile}
    Log  Trace started

Dcap stop trace
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to stop trace under DCAP-LITE
    ...              param str trace_id: trace id which has to be stopped. By default trace_id will be fetched
    ...              from create_bts keyword which is called before. In case create_bts is not called before
    ...              then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}  ${connection}=default
    rd.stop_trace      trace_id=${trace_id}  connection=${connection}
    Log  Trace stopped

Dcap get results
    [Documentation]  Author: Sebastian Mikos
    ...              Description: This method is used to download the trace file under DCAP-LITE
    ...              param str result_id: result id to get the trace downloaded path. By default result_id will be
    ...              fetched from create_bts keyword which is called before. In case start_trace is not called
    ...              before then result_id has to be passed by user.
    [Arguments]      ${result_id}=${None}   ${target_dir}=${OUTPUT DIR}/DCAPs/  ${connection}=default  ${subdir}=${None}
    Run    command=mkdir -p '${LOG_PATH}/DCAPs'
    IF    '${subdir}' != '${None}'
    Set Variable If    '${subdir}' != '${None}'   ${target_dir}    ${OUTPUT_DIR}/DCAPs/${subdir}
    ${target_dir}=    Set Variable    ${OUTPUT_DIR}/DCAPs/${subdir}
    Run    command=mkdir -p '${LOG_PATH}/DCAPs/${subdir}'
    ${filepath} =    rd.get_results      result_id=${result_id}  target_dir=${target_dir}  connection=${connection}
    ELSE
    ${target_dir}=    Set Variable    ${OUTPUT_DIR}/DCAPs/
    Run    command=mkdir -p '${LOG_PATH}/DCAPs/'
    ${filepath} =    rd.get_results      result_id=${result_id}  target_dir=${target_dir}  connection=${connection}
    END
    [Return]  ${filepath}

Dcap get result file contents
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get result file contents under DCAP-LITE
    ...              param str result_id: result id to get the trace contents. By default result_id will be
    ...              fetched from create_bts keyword which is called before. In case start_trace is not called
    ...              before then result_id has to be passed by user.
    [Arguments]      ${result_id}=${None}
    rd.get_result_file_contents      result_id=${result_id}
    Log  Dcap get result file contents success

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
    Log  Dcap get result file success

Dcap get trace info by id
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get the trace info under DCAP-LITE
    ...              param str trace_id: trace id to get the info by id. By default trace_id will be fetched
    ...              from start_trace keyword which is called before. In case start_trace is not called before
    ...              then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}    ${state}=${None}  ${connection}=default
    ${res} =         rd.get_trace_info_by_id      trace_id=${trace_id}  connection=${connection}
    ${res_status}    check_dcap_logs_status  ${res}
    should be equal as strings   ${res_status}    ${state}

Dcap get trace status
    [Documentation]  Author: Sebastian Mikos
    [Arguments]      ${trace_id}=${None}   ${trace_status}=${None}  ${connection}=default
    Log  Dcap get trace status waiting
    wait until keyword succeeds    5 min    5s   Dcap get trace info by id  trace_id=${trace_id}  state=${trace_status}
    ...  connection=${connection}

Dcap get all trace info
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get all the trace info under DCAP-LITE
    rd.get_all_trace_info
    Log  Dcap get all trace info success

Dcap get all bts info
    [Documentation]  Author: Rashmi R
    ...              Description: Provides basic information about BTS in connected DCAP-LITE.
    ...              Supported in `dcapv1` only.
    [Arguments]  ${connection}=default
    ${get_all_bts_info}=   rd.get_all_bts_info  connection=${connection}
    [Return]   ${get_all_bts_info}

Dcap get bts by id
    [Documentation]  Author: Rashmi R
	...              Description: Provides basic information about BTS in connected DCAP-LITE.
    ...              Supported in `dcapv1` only.
    ...              param str bts_id: bts id to get the info by id. By default bts_id will be fetched from start_trace
    ...              keyword which is called before. In case create_bts is not called before then bts_id
    ...              has to be passed by user.
    [Arguments]      ${bts_id}=${None}
    rd.get_bts_by_id      bts_id=${bts_id}
    Log  Dcap get bts by id success

Dcap get 5g profiles
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get all 5G profiles info under DCAP-LITE
    rd.get_5g_profiles
    Log  Dcap get 5g profiles success

Dcap get lte profiles
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get all lte profiles info under DCAP-LITE
    rd.get_lte_profiles
    Log  Dcap get lte profiles success

Dcap get tracers
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get the traces info under DCAP-LITE
    rd.get_tracers
    Log  Dcap get tracers success

Delete active DCAP trace for BTS
    [Arguments]    ${host}=${None}  ${connection}=default
    # ${host}   Get MPlane from BTS configuration
    ${dcap_bts_info}   Dcap get all bts info  connection=${connection}
    ${bts_id}      get dcap bts id   ${dcap_bts_info}   ${host}
    ${tr_id}    get_dcap_trace_id  ${dcap_bts_info}   ${host}
    ${is_running}=   Run Keyword And Return Status  Dcap get trace info by id  trace_id=${tr_id}  state=running  connection=${connection}
    ${is_failed}=   Run Keyword And Return Status  Dcap get trace info by id  trace_id=${tr_id}  state=failed  connection=${connection}
    Run keyword if   ${is_running} is True    Dcap stop trace   ${tr_id}  connection=${connection}
    Run keyword if   ${is_running} is True    Dcap get trace status  trace_id=${tr_id}  trace_status=ready  connection=${connection}
    Run keyword if   ${is_failed} is True    Dcap delete bts   ${bts_id}  connection=${connection}

Get dcap bts id by IP
    [Arguments]    ${host}  ${connection}=default
    ${dcap_bts_info}   Dcap get all bts info  connection=${connection}
    ${bts_id}      get dcap bts id   ${dcap_bts_info}   ${host}
    ${tr_id}    get_dcap_trace_id  ${dcap_bts_info}   ${host}
    ${is_running}=   Run Keyword And Return Status  Dcap get trace info by id  trace_id=${tr_id}  state=running  connection=${connection}
    Run keyword if   ${is_running} is True    Dcap stop trace   ${tr_id}  connection=${connection}
    Run keyword if   '${bts_id}' != '${None}'    Dcap get trace status  trace_id=${tr_id}  trace_status=ready  connection=${connection}
    Run keyword if   '${bts_id}' != '${None}'    Dcap delete bts   ${bts_id}  connection=${connection}
    [Return]   ${bts_id}

Send Emil script
    [Arguments]    ${dcap_filepath}
    ${tl_name}      Get TL hostname
    Run   sshpass -p '${labpcpass}' scp ${dcap_filepath} ${labpcname}@${labpcip}:C:/robot_script_${tl_name}/
    Run   sshpass -p '${labpcpass}' scp ${Emil_keywords} ${labpcname}@${labpcip}:C:/robot_script_${tl_name}
    # Run   sshpass -p '${labpcpass}' scp ${tes_emil} ${labpcname}@${labpcip}:C:/robot_script

Unpack and prepare DCAP 5gm file to verify
    [Arguments]     ${csv_filepath}=${OUTPUT_DIR}/DCAPs/${test_name}.csv
    ${tl_name}      Get TL hostname
    Log to console  Unpack and prepare DCAP 5gm file to verify
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    set test variable  ${emil_out}  ${FALSE}
    ssh.execute   unzip C:/robot_script_${tl_name}/*.zip -d C:/robot_script_${tl_name}/  timeout=180s  connection=LabPC
    # ssh.execute   find C:/robot_script_${tl_name}/ -iname *.5gm -exec mv {} C:/robot_script_${tl_name} \;    connection=LabPC
    ssh.execute   cd C:/robot_script_${tl_name}/ && ${python_path} emil.py C:/robot_script_${tl_name}/  timeout=180s  connection=LabPC
    Run   sshpass -p '${labpcpass}' scp ${labpcname}@${labpcip}:C:/robot_script_${tl_name}/merged.csv ${csv_filepath}
    [Teardown]  ssh.Disconnect    connection=LabPC

Verify if message exist
    [Arguments]    ${msg_to_find}
    ${tl_name}      Get TL hostname
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    ${emil_out}=  ssh.execute   cd C:/robot_script_${tl_name}/ && ${python_path} emil.py C:/robot_script_${tl_name}/ ${msg_to_find}  connection=LabPC
    should not contain    ${emil_out}    No_message_found_error
    [Teardown]  ssh.Disconnect    connection=LabPC

Unpack and prepare new DCAP 5gm file to verify
    [Arguments]     ${zip_filepath}=${OUTPUT_DIR}/DCAPs/${test_name}
    Run    unzip -j ${zip_filepath}.zip -d ${zip_filepath} '*.5gm'
    ${5gm_filename}=    get_5gm_file    fivegm_filename=${zip_filepath}
    ${upload_result}=    rd.upload_encoded_file    file_name=${zip_filepath}/${5gm_filename}
    rd.get_encoded_files_info
    # ${operation_status}    Get from Dictionary    ${upload_result}    operation_status
    ${session_id}    Get from Dictionary    ${upload_result}    session_id
    # ${grid_id}    Set Variable    ${upload_result['grid_ids'][0]}
    ${source_id}    Set Variable    ${upload_result['file_ids'][0]}  # ${upload_result['source_ids'][0]} in FB2403
    ${decoded_content}    get_decoded_file_contents    session_id=${session_id}    id_value=${source_id}    what=source
#    Create File    ${zip_filepath}/${test_name}/C_Plane_${test_name}.json    ${decoded_content}
    dcap_save_to_json    decoded_content=${decoded_content}
    ...                  filename=${zip_filepath}/C_Plane_${test_name}.json
    Run    rm ${zip_filepath}/*.5gm

Stop new DCAP trace and download logs
    [Arguments]     ${zip_filepath}=${OUTPUT_DIR}/DCAPs/${test_name}  ${suffix}=${None}
    ${zip_filepath}=  Set Variable If    '${suffix}' != '${None}'  ${zip_filepath}_${suffix}  ${zip_filepath}
    Dcap stop trace
    sleep  10s
    Dcap get trace status   trace_status=ready
    ${filepath} =   Dcap get results  target_dir=${zip_filepath}.zip
    Log  ${filepath}
    Unpack and prepare new DCAP 5gm file to verify  zip_filepath=${zip_filepath}

Unpack and prepare new DCAP 5gm files to verify json
    [Arguments]     ${zip_filepath}=${OUTPUT_DIR}/DCAPs/  ${filter}=${None}  ${tree}=n  ${connection}=default  ${subdir}=${None}
    ${zip_filepath}=    Set Variable If    '${subdir}' != '${None}'    ${OUTPUT_DIR}/DCAPs/${subdir}${/}    ${zip_filepath}
    Run    unzip -j ${zip_filepath}'*.zip' -d ${zip_filepath} '*.5gm'
    ${5gm_filenames}=    get_5gm_file    fivegm_filename=${zip_filepath}
    ${index}=    Set Variable    1
    FOR  ${5gm_filename}  IN  @{5gm_filenames}
      Unpack and prepare new DCAP 5gm file to verify json  ${5gm_filename}  ${index}  ${zip_filepath}  ${filter}  ${tree}  connection=${connection}
      ${index}=    Evaluate    ${index} + 1
    END
    Run    rm ${zip_filepath}/*.5gm

Unpack and prepare new DCAP 5gm file to verify json
    [Arguments]     ${5gm_filename}  ${index}  ${zip_filepath}  ${filter}  ${tree}  ${connection}=default
    ${upload_result}=    rd.upload_encoded_file    file_name=${zip_filepath}/${5gm_filename}  connection=${connection}
    rd.get_encoded_files_info  connection=${connection}
    ${session_id}    Get from Dictionary    ${upload_result}    session_id
    ${source_id}    Set Variable    ${upload_result['file_ids'][0]}  # ${upload_result['source_ids'][0]} in FB2403
    Run keyword if  '${filter}' != '${None}'
    ...  Decode and save session 5gm file json  ${zip_filepath}/C_Plane_${test_name}_filtered_part_${index}.json
    ...  ${session_id}  ${source_id}  connection=${connection}  filter=${filter}  tree=${tree}
    Decode and save session 5gm file json  ${zip_filepath}/C_Plane_${test_name}_full_part_${index}.json
    ...  ${session_id}  ${source_id}  connection=${connection}  filter=${None}  tree=${tree}

Decode and save session 5gm file json
    [Arguments]  ${filename}  ${session_id}  ${source_id}  ${connection}=default  &{kwargs}
    ${decoded_content_full}    get_decoded_file_contents_in_json    session_id=${session_id}    data_source_id=${source_id}    what=source
    ...  connection=${connection}  timeout=80  filter=${kwargs['filter']}  tree=${kwargs['tree']}
    dcap_save_to_json    decoded_content=${decoded_content_full}
    ...                  filename=${filename}

Stop new DCAP trace and download logs json
    [Arguments]     ${zip_filepath}=${OUTPUT_DIR}/DCAPs/  ${filter}=${None}  ${tree}=n  ${suffix}=${None}  ${connection}=default
    ...    ${subdir}=${None}
    ${zip_filepath}=  Set Variable If    '${suffix}' != '${None}'  ${zip_filepath}_${suffix}  ${zip_filepath}
    Dcap stop trace  connection=${connection}
    sleep  10s
    Dcap get trace status   trace_status=ready  connection=${connection}
    ${filepath} =   Dcap get results  connection=${connection}  subdir=${subdir}
    Log  ${filepath}
    Unpack and prepare new DCAP 5gm files to verify json
        ...       ${zip_filepath}  filter=${filter}  tree=${tree}  connection=${connection}  subdir=${subdir}
    Log to console  DCAP logs collected

Start UTF Lab Tracing
    [Documentation]    This keyword is collecting a user-defined set of logs from the selected cells using UTF Lab.
    ...    Arguments:
    ...    param str utflab_ipaddr: IPv4 address of UTF Lab application
    ...    param str gnb_id: gNB instance ID defined in testline_configuration file
    ...    param list bts_custom_profile: BTS level trace profile, e.g.: immediateSnapshot, scf, pmFiles
    ...    param list gnb_custom_profile: gNB level trace profile, e.g.: condor5gsyslog, cp_5g
    ...    param list cells: Runtime NRCELL object where tracing will be started, e.g.: NRCELL_R-101
    [Arguments]    ${utflab_ipaddr}=${tl.gnbs[0].dcap.connection_details.addr}
    ...    ${gnb_id}=0
    ...    ${bts_custom_profile}=${None}
    ...    ${gnb_custom_profile}=${None}
    ...    ${cells}=${None}
    ...    ${alias}=utflab

    @{bts_default_profile}=    Create List    immediateSnapshot    scf    pmFiles    ipCapture
    ${bts_custom_profile}=    Set Variable If    ${bts_custom_profile} is None    ${bts_default_profile}
    ...    ${bts_custom_profile}

    @{gnb_default_profile}=    Create List    condor5gSyslog    cp_5g
    ${gnb_custom_profile}=    Set Variable If    ${gnb_custom_profile} is None    ${gnb_default_profile}
    ...    ${gnb_custom_profile}

    &{bts}=    Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].cu.backhaul_site_oam_ip.v4}
    ...    port=443
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    nrCells=@{cells}

    &{utflab}=    Create Dictionary
    ...    host=${utflab_ipaddr}
    ...    port=443
    ...    username=${tl.gnbs[0].dcap.connection_details.username}
    ...    password=${tl.gnbs[0].dcap.connection_details.password}

    &{trace}=    Create Dictionary
    ...    bts=${bts}
    ...    bts_custom_profile=${bts_custom_profile}
    ...    gnb_custom_profile=${gnb_custom_profile}

    utflab.Create DCAP Trace Collector
    ...    name=${alias}
    ...    dcap=${utflab}
    ...    trace=${trace}

    utflab.Setup Collectors    names=${alias}
    utflab.Set Suite Alias    ${alias}
    utflab.Start Collectors    names=${alias}


Stop UTF Lab Tracing
    [Documentation]    This keyword stop the active UTF Lab trace and collects the logs.
    ...    Arguments:
    ...    param str alias: The instance alias
    [Arguments]    ${alias}=utflab

    utflab.Stop Collectors    names=${alias}
    utflab.Collect Collectors    names=${alias}

Convert Control Plane Trace To Json
    [Documentation]    This keyword uploads Control Plane traces into Web Emil in UTF Lab for postprocessing.
    ...    The logs are filtered out to match only Sctp and Zmq messages and converted into json format.
    ...    Arguments:
    ...    param list file_list: The filepath(s) of Control Plane trace(s)
    ...    param str target_dir: The target directory for the output files.
    [Arguments]    ${file_list}    ${target_dir}  ${filter}

    rd.Connect to    host=${tl.gnbs[0].dcap.connection_details.addr}
    ...    port=443
    ...    username=utfuser
    ...    password=utfadmin!
    ...    rd_version=dcapv3
    ...    secure=True
    ${testresults}=    Set Variable    ${OUTPUT DIR}
    ${dir}=    Catenate    SEPARATOR=/    ${testresults}    ${SUITE_NAME}    ${TEST_NAME}    ${target_dir}    CP_FILES
    FOR    ${file}    IN    @{file_list}
        ${trace}=    rd.Upload Encoded File    file_name=${file}
        ${result}=    rd.Get Decoded File Contents In Json
        ...    session_id=${trace['session_id']}
        ...    data_source_id=${trace['source_ids'][0]}
        ...    what=source
        ...    filter=${filter}
        ${json}=    Evaluate    json.dumps(${result})    json
        Create File    ${dir}/${trace['file_names'][0][:-4]}.json    ${json}
    END



Prepare Logs For Analysis
    [Documentation]    This keyword prepares the logs collected from UTF Lab for analysis. Depends on a log type
    ...    a various operations are executed f.e. extraction, merge or file type conversion.
    ...    Arguments:
    ...    param list requested_logs: The log types to be prepared. Only cp_5g and/or pmFiles are supported.
    ...    param str source_dir: The source directory of the logs collected via UTF Lab
    ...    param str target_dir: The target directory for the output files.
    ...    Return:
    ...    param str cp_5g: The filepath of merged Control Plane traces
    [Arguments]    ${requested_logs}    ${source_dir}    ${target_dir}
    ...    ${filter}="Message name"="SctpMessage";"Message name"="ZmqMessage"

    ${controlPlane5g_json}=    Set Variable
    FOR    ${log_type}    IN    @{requested_logs}
        @{cp_5g}=    Run Keyword If
        ...    '${log_type}' == 'cp_5g'
        ...    Extract Files From Zip    file_pattern=.*5gm    source_dir=${source_dir}
        Run Keyword If    '${log_type}' == 'cp_5g'
        ...    Convert Control Plane Trace To Json        ${cp_5g}     ${target_dir}  ${filter}
        ${cp_5g_json}=   Run Keyword If
        ...    '${log_type}' == 'cp_5g'
        ...    Merge Json Files    ${target_dir}
        ${controlPlane5g_json}=    Set Variable If
        ...    '${cp_5g_json}' != '${None}'
        ...    ${cp_5g_json}
        ...    ${controlPlane5g_json}
        Run Keyword If    '${log_type}' == 'pmFiles'
        ...    Extract Zip With Nested Gz    nested_zip_pattern=.*pm-files.*   source_dir=${source_dir}
    END

    [Return]    ${controlPlane5g_json}
