*** Settings ***
Documentation    This library provides keywords for DCAP-Lite UI interface
...              Please do not modify the file without notification to author
...              Author: Andrei Maria

Library         taf.sw.dcap.rd    WITH NAME    rd
Library         ta5g_dcap
Library         DateTime
Library         Process
Library         ta5g_testline_management
Library         SSHLibrary
Library         BuiltIn
Library         Collections
Library         OperatingSystem
Library         taf.transport.ssh      WITH NAME   ssh
Library         taf.sbts.oam.coam.admin  WITH NAME  coam

*** Variables ***

${labpcname}=                                            NOKLAB\\rfsharing
${labpcpass}=                                            Nokia2022!@1
${labpcip}=                                              10.5.53.88
${alias}=                                                sshpc
${UTE_SSH_IP}=                                           ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_SSH_USER_NAME}=                                    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_SSH_PASSWORD}=                                     ${tl.test_pc.default_ssh_connection_details.password}
${IPCAPTURE_TO_TXT}=   tshark -r ${OUTPUT DIR}/ipcaptureExtracted/* -Y 'nr-rrc.c1 == 0' -T text -o ntrstr.port:49148 -o
...  ntrstr.defragment:TRUE > ${OUTPUT DIR}/ipcaptureExtracted/ipcapture_to_txt.txt
${destination}       C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\

*** Keywords ***

Get TL hostname
    ${result} = 	Run   uname -a|awk '{print $2}'
    [Return]  ${result}

Mkdir for EMil script
    ${tl_name}      Get TL hostname
    SSHLibrary.Open Connection   host=${labpcip}
    SSHLibrary.Login  username=${labpcname}    password=${labpcpass}
#    ${cmd}  Set Variable  cd C:\\Users\\rfsharing\\Documents\\Logs\\ & del /S /Q * & for /D %p in (*) do rmdir /S /Q "%p"
    ${cmd}  Set Variable  cd C:\\Users\\rfsharing\\Documents\\Logs\\ & rmdir /S /Q robot_script_${tl_name}
    SSHLibrary.execute_command  command=${cmd}
    sleep  3s
    SSHLibrary.execute_command  command=mkdir C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}
    SSHLibrary.execute_command  command=mkdir C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\TXT
    [Teardown]  SSHLibrary.Close Connection

Cleanup EMil dir
    ${tl_name}      Get TL hostname
    SSHLibrary.Open Connection   host=${labpcip}
    SSHLibrary.Login  username=${labpcname}    password=${labpcpass}
    ${list}  Set Variable  dir C:\\Users\\rfsharing\\Documents\\Logs\\
    ${cmd}  Set Variable  cd C:\\Users\\rfsharing\\Documents\\Logs\\ & rmdir /S /Q robot_script_${tl_name}
    SSHLibrary.execute_command  command=${cmd}&${list}
    sleep  3s
    [Teardown]  SSHLibrary.Close Connection

Split String Clean
    [Arguments]    ${input_string}    ${separator}
    ${input_string}=    Remove String    ${input_string}    \r
    ${result}=    Split String    ${input_string}    ${separator}
    [Return]    ${result}

SYSTEM Open SSH Connection To PC

    SYSTEM Open SSH Connection    host=${labpcip}
    ...                           port=22
    ...                           username=${labpcname}
    ...                           password=${labpcpass}
    ...                           alias=${alias}

SYSTEM Open SSH Connection
    SSHLibrary.Open Connection    host=${labpcip}    port=22    timeout=20    alias=${alias}
    SSHLibrary.Login    username=${labpcname}    password=${labpcpass}    delay=1s

Prepare and start DCAP
    [Documentation]  Author: Sebastian Mikos
    ...              param str dcap_host: (optional) IP address to dcap, default IP 10.42.54.132
    ...              param str bts_mplane: (optional) IP address to BTS MPlane.
    ...              param list nrCells: (optional) cells name separated by space e.g. NRCELL_R-1 NRCELL_R-2 NRCELL_R-3
    ...              if empty all cells will be added.
    ...              param list custom_profiles: (optional) dcap custom profiles seperated by space e.g.  cp_5g cp_4g condor5gSyslog
    ...              default 'cp_5g'
    [Arguments]  ${bts_mplane}=${None}
    Run keyword and ignore error    Delete active DCAP trace for BTS   host=${bts_mplane}
    Wait until keyword succeeds  300  30  Start Dcap   bts_trace_profile=Full tracing profile
    Log to console   create Emil dir on UEPC
    Mkdir for EMil script

Stop DCAP trace and download logs
    Stop And Revert Dcap
    sleep  10s
    Dcap get trace status   trace_status=ready
    ${filepath} =   Dcap get results
    Extract ipcapture from DCAP   ${filepath}
    Extract bts_syslog from DCAP   ${filepath}
    Send Emil script    ${filepath}
    Unpack and prepare DCAP files to verify

Extract ipcapture from DCAP
    [Documentation]  Author: R Turcu
    ...              Description: extract syslog from DCAP and save it in result\ipcapture
    ...
    [Arguments]      ${zippath}
    ${year}    Get Current Date    result_format=%Y
    ${month}    Get Current Date    result_format=%m
    ${day}    Get Current Date    result_format=%d
    ${date}    Set Variable    ${year}${month}${day}
    Log to console  Unpack and extract ipcapture DCAP file
    run     command=mkdir -p ${OUTPUT DIR}/ipcaptureDCAP
    run     command=mkdir -p ${OUTPUT DIR}/ipcaptureExtracted
    run    command=unzip -d ${OUTPUT DIR}/ipcaptureDCAP ${zippath}
    ${folders}=  run    command=ls ${OUTPUT DIR}/ipcaptureDCAP/${date}
    @{folders_list}=    Split String Clean    ${folders}    \n
    FOR    ${log_folder}    IN    @{folders_list}
        run  command=cp ${OUTPUT DIR}/ipcaptureDCAP/${date}/${log_folder}/bts/ipcapture/* ${OUTPUT DIR}/ipcaptureExtracted
    END
    run    command=${IPCAPTURE_TO_TXT}

Extract bts_syslog from DCAP
    [Documentation]  Author: R Turcu
    ...              Description: extract syslog from DCAP and save it in result\syslog
    ...
    [Arguments]      ${zippath}
    ${year}    Get Current Date    result_format=%Y
    ${month}    Get Current Date    result_format=%m
    ${day}    Get Current Date    result_format=%d
    ${date}    Set Variable    ${year}${month}${day}
    Log to console  Unpack and extract syslog DCAP file
    run     command=mkdir -p ${OUTPUT DIR}/syslogDCAP
    run     command=mkdir -p ${OUTPUT DIR}/syslogExtracted
    run    command=unzip -d ${OUTPUT DIR}/syslogDCAP ${zippath}
    ${folders}=  run    command=ls ${OUTPUT DIR}/syslogDCAP/${date}
    @{folders_list}=    Split String Clean    ${folders}    \n
    FOR    ${log_folder}    IN    @{folders_list}
        run  command=cp ${OUTPUT DIR}/syslogDCAP/${date}/${log_folder}/bts/syslog/* ${OUTPUT DIR}/syslogExtracted
    END
    run    command=cat ${OUTPUT DIR}/syslogExtracted/* > ${OUTPUT DIR}/syslogExtracted/full_syslog.log

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
    ${bts_alias}      Get TL hostname
    rd.create_bts     host=${host}     port=${port}    username=${username}
    ...               password=${password}     bts_alias=${bts_alias}

Dcap delete bts
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to delete the bts under DCAP-LITE
    ...              param str bts_id: bts id which has to be deleted. By default bts_id will be fetched from
    ...               create_bts keyword which is called before.
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
    ...               gnb_custom_profile=${gnb_custom_profile}

Dcap stop trace
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to stop trace under DCAP-LITE
    ...              param str trace_id: trace id which has to be stopped. By default trace_id will be fetched
    ...              from create_bts keyword which is called before. In case create_bts is not called before
    ...              then trace_id has to be passed by user.
    [Arguments]      ${trace_id}=${None}
    rd.stop_trace      trace_id=${trace_id}

Dcap get results
    [Documentation]  Author: Sebastian Mikos
    ...              Description: This method is used to download the trace file under DCAP-LITE
    ...              param str result_id: result id to get the trace downloaded path. By default result_id will be
    ...              fetched from create_bts keyword which is called before. In case start_trace is not called
    ...              before then result_id has to be passed by user.
    [Arguments]      ${result_id}=${None}   ${target_dir}=${OUTPUT DIR}/${test_name}.zip
    rd.get_results      result_id=${result_id}  target_dir=${target_dir}
    [Return]  ${target_dir}

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
    ...              `get_result_file_contents` keyword e.g. "logs\\dcap-lite-kong.log"
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
    [Arguments]      ${trace_id}=${None}    ${state}=${None}
    ${res} =         rd.get_trace_info_by_id      trace_id=${trace_id}
    ${res_status}    check_dcap_logs_status  ${res}
    should be equal as strings   ${res_status}    ${state}

Dcap get trace status
    [Documentation]  Author: Sebastian Mikos
    [Arguments]      ${trace_id}=${None}   ${trace_status}=${None}
    wait until keyword succeeds    5 min    5s   Dcap get trace info by id  trace_id=${trace_id}  state=${trace_status}

Dcap get all trace info
    [Documentation]  Author: Rashmi R
    ...              Description: This method is used to get all the trace info under DCAP-LITE
    rd.get_all_trace_info

Dcap get all bts info
    [Documentation]  Author: Rashmi R
    ...              Description: Provides basic information about BTS in connected DCAP-LITE.
    ...              Supported in `dcapv1` only.
    ${get_all_bts_info}=   rd.get_all_bts_info
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

Delete active DCAP trace for BTS
    [Arguments]    ${host}=${None}
#    ${host}   Get MPlane from BTS configuration
    ${dcap_bts_info}   Dcap get all bts info
    ${bts_id}      get dcap bts id   ${dcap_bts_info}   ${host}
    ${tr_id}    get_dcap_trace_id  ${dcap_bts_info}   ${host}
    ${is_running}=   Run Keyword And Return Status  Dcap get trace info by id  trace_id=${tr_id}  state=running
    ${is_failed}=   Run Keyword And Return Status  Dcap get trace info by id  trace_id=${tr_id}  state=failed
    Run keyword if   ${is_running} is True    Dcap stop trace   ${tr_id}
    Run keyword if   ${is_running} is True    Dcap get trace status  trace_id=${tr_id}  trace_status=ready
    Run keyword if   ${is_failed} is True    Dcap delete bts   ${bts_id}


Get dcap bts id by IP
    [Arguments]    ${host}
    ${dcap_bts_info}   Dcap get all bts info
    ${bts_id}      get dcap bts id   ${dcap_bts_info}   ${host}
    ${tr_id}    get_dcap_trace_id  ${dcap_bts_info}   ${host}
    ${is_running}=   Run Keyword And Return Status  Dcap get trace info by id  trace_id=${tr_id}  state=running
    Run keyword if   ${is_running} is True    Dcap stop trace   ${tr_id}
    Run keyword if   ${bts_id} is not None    Dcap get trace status  trace_id=${tr_id}  trace_status=ready
    Run keyword if   ${bts_id} is not None    Dcap delete bts   ${bts_id}
    [Return]   ${bts_id}

Send Emil script
    [Arguments]    ${dcap_filepath}
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable         ${destination}robot_script_${tl_name}\\\\
    SYSTEM Open SSH Connection
    ${cmdcopy}    set variable    echo y | pscp -pw ${UTE_SSH_PASSWORD} ${UTE_SSH_USER_NAME}@${UTE_SSH_IP}:${dcap_filepath} ${log_path}
    FOR  ${i}  IN RANGE  0  3
                ${output}    SSHLibrary.Execute Command    ${cmdcopy}
                ${msgout}  run keyword and ignore error    Should contain    ${output}    100%
                log to console    ${msgout}
                Run Keyword If   '${msgout}[0]' == 'PASS'
                ...     Exit For Loop
                ...    ELSE IF     ${i} == 2
                ...     Fail     msg=Copy logs not ok!
                ${i}    Evaluate    ${i}+1
    END



    SSHLibrary.Close All Connections

Unpack and prepare DCAP files to verify
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
    Log to console  Unpack and prepare DCAP 5gm file to verify
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    ssh.execute   7z.exe x "${log_path}*.zip" -o"${log_path}"  timeout=150s  connection=LabPC
    ssh.Disconnect    connection=LabPC
#    Convert 5gm Files To Csv
#    Convert lcbin Files To Csv

Convert 5gm Files To Csv
    [Documentation]        Convert 5G Control Plane logs collected from DCAP
    Log to console      \nConverting 5G Control Plane logs and verifying
    Run  rm -rf ${OUTPUT_DIR}/5gm
    Run  mkdir ${OUTPUT_DIR}/5gm
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
    ${year}    Get Current Date    result_format=%Y
    ${month}    Get Current Date    result_format=%m
    ${day}    Get Current Date    result_format=%d
    ${date}    Set Variable    ${year}${month}${day}
    SYSTEM Open SSH Connection
    ${it}=           SSHLibrary.Execute Command   cd ${log_path}${date} & cmd /c "dir /b /ad"
    @{all_log_folders}=    Split String Clean    ${it}    \n
    FOR    ${log_folder}    IN    @{all_log_folders}
        Run keyword And Ignore Error    Start Emil To Convert 5gm Files To Csv    source_path=${log_path}${date}
        ...     source_file=${log_folder}\\5g\\controlPlane
    END
	SSHLibrary.Close All Connections

Convert lcbin Files To Csv
    [Documentation]        Convert Cell Trace logs collected from DCAP
    Log to console      \nConverting Cell Trace logs and verifying
    Run  rm -rf ${OUTPUT_DIR}/lcbin
    Run  mkdir ${OUTPUT_DIR}/lcbin
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
    ${year}    Get Current Date    result_format=%Y
    ${month}    Get Current Date    result_format=%m
    ${day}    Get Current Date    result_format=%d
    ${date}    Set Variable    ${year}${month}${day}
    SYSTEM Open SSH Connection
    ${it}=           SSHLibrary.Execute Command   cd ${log_path}${date} & cmd /c "dir /b /ad"
    @{all_log_folders}=    Split String Clean    ${it}    \n
    FOR    ${log_folder}    IN    @{all_log_folders}
        Run keyword And Ignore Error    Start Emil To Convert lcbin Files To Csv    source_path=${log_path}${date}
        ...     source_file=${log_folder}\\5g\\ntracer5g
    END
	SSHLibrary.Close All Connections

Start Emil To Convert 5gm Files To Csv
    [Arguments]    ${source_path}     ${source_file}
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable      C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
    ${source_emil_file}=    SSHLibrary.Execute Command   cd ${source_path}\\${source_file} & dir /A-D /B
    ${log_file_name}=     Remove String    ${source_emil_file}    \r    \n
    Log to console  ${log_file_name}
    ${src_file}     Set Variable     ${source_path}\\${source_file}\\${log_file_name}
    ${src_file}=    Replace String    ${src_file}    \\    \\\\
    ${cmd_part1}  Set Variable  start /wait Emil.exe "${src_file}" -tocsv -autoclose -destination "${destination}robot_script_${tl_name}\\\\"
    ${cmd_part2}  Set Variable  -Profile SourceProfileUser.ini -ProfilePath "C:\\\\Program Files\\\\Emil\\\\profiles\\\\5G"
	${cmd} 	        Set Variable	 ${cmd_part1} ${cmd_part2}
	LOG	    ${cmd}
	${output}      SSHLibrary.Execute Command   ${cmd}
	LOG		${output}
	${log_file_name}=    Replace String    ${log_file_name}    .5gm    .csv
	${csv_vm}  Set Variable  echo y | pscp -pw ${UTE_SSH_PASSWORD} ${log_path}${log_file_name} ${UTE_SSH_USER_NAME}@${UTE_SSH_IP}:${OUTPUT_DIR}/5gm
    SSHLibrary.Execute Command   ${csv_vm}

Start Emil To Convert lcbin Files To Csv
    [Arguments]    ${source_path}     ${source_file}
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable      C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
    ${source_emil_file}=    SSHLibrary.Execute Command   cd ${source_path}\\${source_file} & dir /A-D /B
    ${log_file_name}=     Remove String    ${source_emil_file}    \r    \n
    Log to console  ${log_file_name}
    ${src_file}     Set Variable     ${source_path}\\${source_file}\\${log_file_name}
    ${src_file}=    Replace String    ${src_file}    \\    \\\\
    ${cmd_part1}  Set Variable  start /wait Emil.exe "${src_file}" -tocsv -autoclose -destination "${destination}robot_script_${tl_name}\\\\"
    ${cmd_part2}  Set Variable  -Profile SourceProfileUser.ini -ProfilePath "C:\\\\Program Files\\\\Emil\\\\profiles\\\\5G Cell Trace"
	${cmd} 	        Set Variable	 ${cmd_part1} ${cmd_part2}
	LOG	    ${cmd}
	${output}      SSHLibrary.Execute Command   ${cmd}
	LOG		${output}
	${log_file_name}=    Replace String    ${log_file_name}    .lcbin    .csv
	${csv_vm}  Set Variable  echo y | pscp -pw ${UTE_SSH_PASSWORD} ${log_path}${log_file_name} ${UTE_SSH_USER_NAME}@${UTE_SSH_IP}:${OUTPUT_DIR}/lcbin
    SSHLibrary.Execute Command   ${csv_vm}
