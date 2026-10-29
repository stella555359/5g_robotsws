*** Settings ***
Documentation
...    author: Han Ruiyu
...    contact: ruiyu.han@nokia-sbell.com
...    squad group: NSB MN 5G&SC 5G Pz Verf CN 07 SG
Library     Emil_processing_keywords.py
Library    taf.transport.ssh   WITH NAME   csn
Library            DateTime
Library            OperatingSystem
Variables          ../../../libraries/global_vars.py
Variables          ../../libraries/dcap_server_1.py
Variables          ../../libraries/sherpa_server_1.py
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/DCAP.robot
Resource           ../dcap.robot
Resource           ../case_steps.robot
Resource           ../coam.robot
Resource           ../common.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/emil.robot

*** Variables ***
${sourceProfile}                                        ${CURDIR}/SourceProfile.ini
${Emil_keywords}                                        ${CURDIR}/Emil_processing_keywords.py
${msg_list}                           Gnb Operation During Flowtracer Trace                  ${CURDIR}/msg_name_vars.py
${tes_emil}                                             test_emil.robot
${profile_path}                                          C:\\Program Files\\Emil\\profiles\\5G
${log_path_DCAP}                              /sharedvolume/flowtracer/traces/5G_TA
# ${DCAP_HOST}   ${tl.test_pcs[2].connection_details.addr}
${DCAP_HOST}   ${tl.gnbs[0].dcap.connection_details.addr}
${DCAP_port}    ${EMPTY}

&{bts_classical}      alias=gnb_dcap    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=${tl.gnbs[0].global_bts_id}

@{gnb_custom_profile}    cp_5g   L2Ps_Sherpa    L2Lo_Sherpa    L2HiRlc_Sherpa    L2HiPdcp_Sherpa

*** Keywords ***
Flowtracer Trace Setup
    [Arguments]    ${operation}=call    ${call_mode}=single
    log to console   \n Start dcap basic cplane trace
#    run keyword and ignore error    Remove Emil logs on DCAP    trace_host=${dcap_ip}
#    ...    trace_user=${dcap_username}    trace_password=${dcap_password}    log_path_DCAP=${log_path_DCAP}
    run keyword and ignore error    Delete Emil script and logs on sherpa
    Start Dcap Basic trace
    Gnb Operation During Flowtracer Trace    operation=${operation}    call_mode=${call_mode}
    sleep    30s
    ${downloaded_emil_file_path}    Stop Dcap Basic trace
    ${log_file_list}    Exact Dcap log    downloaded_emil_file_path=${downloaded_emil_file_path}
    Upload Emil script and logs on sherpa
#    ${log_path_list}   Download FlowTracer logs to local 1808
#    Set Suite Variable   ${log_path_list}
    Mkdir for EMil script and logs on sherpa
#    Upload Emil script and logs on sherpa
    Convert emil log at sherpa   log_path_list=${log_file_list}    end_file=5gm
#    Remove Emil logs on DCAP    trace_host=${dcap_ip}
#    ...    trace_user=${dcap_username}    trace_password=${dcap_password}    log_path_DCAP=${log_path_DCAP}
    Delete Emil script and logs on sherpa
    Dcap delete bts

Flowtracer Trace Teardown
    log to console   \n Flowtracer Trace Teardown
#    Stop Flowtracer
#    ...   trace_host=${dcap_ip}    trace_user=${dcap_username}    trace_password=${dcap_password}
#    Remove Emil logs on DCAP    trace_host=${dcap_ip}
#    ...    trace_user=${dcap_username}    trace_password=${dcap_password}    log_path_DCAP=${log_path_DCAP}
    Delete Emil script and logs on sherpa
    run keyword and ignore error    Dcap delete bts    bts_id=${dcap_create_id}
    [Teardown]    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}

Gnb Operation During Flowtracer Trace
    [Arguments]    ${operation}=call    ${call_mode}=single    ${sleeptime}=30s
    run keyword if  '${operation}'=='call'    _call_operation    call_mode=${call_mode}
    ...   ELSE IF    '${operation}'=='SCF'    _scf_operation
    ...   ELSE IF    '${operation}'=='onair'    _cell_onair_operation
    ...   ELSE IF    '${operation}'=='resetrat'    _reset_rat_operation
    ...   ELSE   sleep   ${sleeptime}

_call_operation
    [Arguments]     ${call_mode}
    ${res}   Run Keyword and Ignore Error   Setup Call by mode  call_mode=${call_mode}
    Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
#    Should Be Equal   ${res[0]}   PASS
    Set Suite Variable   ${call_alias}   ${res[1]}

_scf_operation
#    ${current_SCF}    Get Current SCF File On COAM    xn_gnb_ip=${xn_gnb_ip}
#    ${modified_scf}    Change_Nradjgnb_AMF_Param    modify_scfpath=${current_SCF}
#    Wait until keyword succeeds  10min   1min   Import SCF On COAM   IP_WEBUI=${xn_gnb_ip}   SCF_FILE=${modified_scf}
#    coam.Check Cell Setup in COAM
    ${res}   Run Keyword and Ignore Error   Setup Xn Link
    Should Be Equal   ${res[0]}   PASS
#    Wait until keyword succeeds  10min   1min   Import SCF On COAM   IP_WEBUI=${xn_gnb_ip}   SCF_FILE=${current_SCF}
    ${res}   Run Keyword and Ignore Error   Setup Call by mode  call_mode=single
    Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
#    Should Be Equal   ${res[0]}   PASS
    Set Suite Variable   ${call_alias}   ${res[1]}

_cell_onair_operation
    log to console    reset site and check cell
    run keyword and ignore error   COAM Login
    run keyword and ignore error   COAM Reset Site
#    Wait Until Keyword Succeeds    15 min    1 min
#    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
#    csn.execute    command=reboot    connection=gnb
#    coam.Check Cell Setup in COAM
    Wait Until Keyword Succeeds   20 min   1 min  COAM Check BTS OnAir
    [Teardown]     run keyword and ignore error  COAM Logout

_reset_rat_operation
    log to console  reset rat and check cell
    COAM Reset RAT    connection=${coam_alias}
    Wait Until Keyword Succeeds    15 min    1 min     coam.Check Cell Setup in COAM

Download FlowTracer logs to local 1808
    log to console     Download FlowTracer logs to local
    ${current_date}     Get Current Date    result_format=%Y%m%d
    ${current_time}     Get Current Date        result_format=%Y%m%d_%H%M%S
    ${file_list}   Create List
    run    command=mkdir ${OUTPUT_DIR}/${current_time}
    set Suite variable    ${log_path_local}    ${OUTPUT_DIR}/${current_time}
    csn.Connect to   hostname=${dcap_ip}    username=${dcap_username}    password=${dcap_password}
    ...    alias=DCAP
    ${dir_name}    csn.Execute   command=ls ${log_path_DCAP}    connection=DCAP
    ${dir_name}    strip string    ${dir_name}
    ${length_dir}    get length    ${dir_name}
    run keyword if  ${length_dir}< ${2}    FAIL    [ERROR]Dcap Flowtracer trace didn't caught!
    ${dir_date_name}     csn.Execute   command=ls ${log_path_DCAP}/${dir_name}    connection=DCAP
    ${dir_date_name}    replace string    ${dir_date_name}   \r    ${SPACE}
    ${dir_date_name}    replace string    ${dir_date_name}   \n    ${SPACE}
    ${dir_date_name}    replace string    ${dir_date_name}   \t    ${SPACE}
    ${dir_date_name}    Split string    ${dir_date_name}    ${SPACE}
    Sort List    ${dir_date_name}
    FOR    ${item}    IN    @{dir_date_name}
           continue for loop if    '${item}'=='${empty}'
           ${log_name}     csn.Execute   command=ls ${log_path_DCAP}/${dir_name}/${item}    connection=DCAP
           ${log_name}    strip string    ${log_name}
           ${log_name}    Fetch From Right    ${log_name}   \r\n
           set suite variable    ${log_name}
           csn.Download File   remote_path=${log_path_DCAP}/${dir_name}/${item}  local_path=${OUTPUT_DIR}/${item}
           ...   connection=DCAP
           Append To List   ${file_list}   ${OUTPUT_DIR}/${item}
    END
    [Return]   ${file_list}
    [Teardown]   csn.Disconnect     connection=DCAP

Mkdir for EMil script and logs on sherpa
    wait until keyword succeeds  10min   20s   Csn.Connect to   hostname=${sherpa_server_ip}
    ...   username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_vm
    csn.Execute   command=mkdir -p /cygdrive/c/temp/emil_logs     connection=sherpa_vm
    ${output}    csn.Execute   command=/cygdrive/c/temp/emil_logs      connection=sherpa_vm
    should contain    ${output}    Is a director
    [Teardown]  csn.Disconnect    connection=sherpa_vm

Upload Emil script and logs on sherpa
    log to console     \n Upload Emil script and log
    wait until keyword succeeds  10min   20s    Csn.Connect to   hostname=${sherpa_server_ip}
    ...   username=${sherpa_server_username}    password=${sherpa_server_password}    alias=sherpa_vm
    csn.Upload File   local_path=${CURDIR}/SourceProfileUser.ini   remote_path=${profile_path}/SourceProfileUser.ini
    ...   connection=sherpa_vm
    sleep    2s
    [Teardown]    csn.Disconnect    connection=sherpa_vm

Delete Emil script and logs on sherpa
    log to console    \n  Delete Emil script and logs
    wait until keyword succeeds  10min   20s    Csn.Connect to   hostname=${sherpa_server_ip}
    ...   username=${sherpa_server_username}    password=${sherpa_server_password}    alias=sherpa_vm
    csn.Execute    command=rm -rf /cygdrive/c/temp/emil_logs     connection=sherpa_vm
    [Teardown]    csn.Disconnect    connection=sherpa_vm

#Remove Emil logs on DCAP
#     csn.Connect to   hostname=${dcap_ip}    username=${dcap_username}    password=${dcap_password}
#    ...    alias=DCAP
#    csn.execute  command=echo ${dcap_password} | sudo -S rm -rf ${log_path_DCAP}/*  connection=DCAP   timeout=1s
#    [Teardown]  csn.Disconnect     connection=DCAP

Download FlowTracer Output to local
    wait until keyword succeeds  10min   20s    Csn.Connect to   hostname=${sherpa_server_ip}
    ...   username=${sherpa_server_username}    password=${sherpa_server_password}    alias=sherpa_vm
#    ${txt_name}    csn.Execute    command=ls C:/Emil_logs/*.txt     connection=sherpa_vm
#    ${txt_name}    strip string    ${txt_name}
    csn.execute    command=cd C:/Emil_logs;tar -cvf emil_logs.tar *     connection=sherpa_vm
    csn.Download File   remote_path=C:\\Emil_logs\\emil_logs.tar   local_path=${OUTPUT_DIR}/emil_logs.tar   connection=sherpa_vm
    [Teardown]    csn.Disconnect    connection=sherpa_vm

Convert emil log at sherpa
    [Arguments]    ${log_path_list}   ${end_file}
    log to console    \n start checking emil logs
    wait until keyword succeeds  10min   20s    Csn.Connect to   hostname=${sherpa_server_ip}
    ...   username=${sherpa_server_username}    password=${sherpa_server_password}    alias=sherpa_vm
    ${output_txt_path}    Covert Emil Logs to TXT    file_list=${log_path_list}   local_dir=${OUTPUT_DIR}
    ...  emil_host=${sherpa_server_ip}   emil_user=${sherpa_server_username}   emil_password=${sherpa_server_password}
    ...   emil_protocol=5G    connection=sherpa_vm
    set suite variable    ${output_txt_path}
    [Teardown]  run keyword and ignore error   csn.Disconnect    connection=sherpa_vm

Convert emil log at sherpa PMI
    [Arguments]    ${log_path_list}   ${end_file}
    log to console    \n start checking emil logs
    wait until keyword succeeds  10min   20s    Csn.Connect to   hostname=${sherpa_server_ip}
    ...   username=${sherpa_server_username}    password=${sherpa_server_password}    alias=sherpa_vm
    ${output_txt_path}    Covert Emil Logs to TXT PMI   file_list=${log_path_list}   local_dir=${OUTPUT_DIR}
    ...  emil_host=${sherpa_server_ip}   emil_user=${sherpa_server_username}   emil_password=${sherpa_server_password}
    ...   emil_protocol=5G    connection=sherpa_vm
    set suite variable    ${output_txt_path}
    [Teardown]  run keyword and ignore error   csn.Disconnect    connection=sherpa_vm

Covert Emil Logs to TXT PMI
    [Arguments]   ${file_list}   ${local_dir}   ${emil_host}    ${emil_user}    ${emil_password}
    ...    ${emil_protocol}    ${connection}=emil
    [Documentation]    Convert Emil log to txt format, and download to UTE VM
    ...    ${emil_host} should be one UE CTRL PC which install emil software
    ...    ${emil_protocol}    can be "5G" or "5G Cell Trace", one of folder name in C:\Program Files\Emil\profiles
    ${emil_param}    Catenate    -AutoClose -Profile SourceProfileUser.ini
    ...                          -ProfilePath "${emil_win_path}\\profiles\\${emil_protocol}" -Variable OutPath
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    ${emil_list}   Create List
    csn.Connect to   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=${connection}
    csn.Execute   command=rm -rf \"${emil_path}/get_emil.bat\"   connection=${connection}
    ${emil_files}   Create List
    FOR   ${emil_file}   IN   @{file_list}
       ${file_name}   Convert Emil Log PMI   emil_file=${emil_file}    emil_param=${emil_param}    connection=${connection}
       Append To List   ${emil_list}   ${file_name}
    END
    ${emil_list_str}   Evaluate   ' '.join(${emil_list})
    csn.Execute   cat ${emil_list_str} > ${emil_log_dir}/Emil_${curr_date}.txt   connection=${connection}
    csn.Download File   remote_path=${emil_log_dir}/Emil_${curr_date}.txt
    ...   local_path=${local_dir}/Emil_${curr_date}.txt   connection=${connection}
    [Return]   ${local_dir}/Emil_${curr_date}.txt
    [Teardown]   csn.Disconnect   connection=${connection}

Convert Emil Log PMI
    [Arguments]   ${emil_file}   ${emil_param}    ${connection}=emil
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${local_dir}   ${file_name}   Split Path   ${emil_file}
    ${cmd}   Set Variable   ${emil_cmd_pre} \"${emil_win_dir}${file_name}\" ${emil_param} \"${emil_win_dir}Emil_${curr_date}.txt\"
    OperatingSystem.Create File   path=${OUTPUT_DIR}/get_emil.bat   content=${cmd}
    csn.Execute   command=cd \"${emil_log_dir}\";rm -f Emil_${curr_date}.txt   connection=${connection}
    csn.Upload File   local_path=${emil_file}   remote_path=${emil_log_dir}/${file_name}   connection=${connection}
    csn.Upload File   local_path=${OUTPUT_DIR}/get_emil.bat   remote_path=${emil_log_dir}/get_emil.bat   connection=${connection}
    csn.Execute   command=mv \"${emil_log_dir}/get_emil.bat\" \"${emil_path}\"   connection=${connection}
    csn.Execute   command=cd \"${emil_path}\";cmd /c get_emil.bat   connection=${connection}
    Wait Until Keyword Succeeds   3x   15s   Emil TXT convert done PMI
    ...   file_path=${emil_log_dir}/Emil_${curr_date}.txt   connection=${connection}
    [Return]   ${emil_log_dir}/Emil_${curr_date}.txt

Emil TXT convert done PMI
    [Arguments]   ${file_path}   ${connection}
    ${file_exist}   csn.File Exists   remote_path=${file_path}   connection=${connection}
    Should Be True   ${file_exist}

Start Dcap Basic trace
    [Arguments]    ${gnb_custom_profile}=${gnb_custom_profile}
    Create Bts On DCAP    DCAP_host=${DCAP_host}   DCAP_host_bak=${DCAP_host_bak}
    ...   DCAP_port=${DCAP_port}   bts_mr_id=${bts_classical['bts_id']}    bts=${bts_classical}
    Start DCAP log    bts=${bts_classical}    gnb_custom_profile=${gnb_custom_profile}

Stop Dcap Basic trace
	Stop DCAP log
    ${downloaded_emil_file_path}    wait until keyword succeeds    20min    30s    Download log from DCAP
    [Return]   ${downloaded_emil_file_path}


Exact Dcap log
    [Arguments]    ${downloaded_emil_file_path}
    Log To Console    Get the exact dcap log
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    RUN   unzip ${downloaded_emil_file_path} -d ${OUTPUT_DIR}/dcap_tmp_${curr_data}
    ${local_emil_log_path}    RUN  find ${OUTPUT_DIR}/dcap_tmp_${curr_data} -name "*.5gm"
    ${local_emil_log_path}    strip string   ${local_emil_log_path}
    ${emil_log_file_list}    split string    ${local_emil_log_path}    \n
    ${local_sherpa_log_path}    RUN  find ${OUTPUT_DIR}/dcap_tmp_${curr_data} -name "*.pcap"
    ${local_sherpa_log_path}    strip string   ${local_sherpa_log_path}
    ${sherpa_log_file_list}    split string    ${local_sherpa_log_path}    \n
#    ${sherpa_log_path_tmp}    fetch from right    ${sherpa_log_file_list[0]}    /
    set suite variable    ${l2ps_log_path}    ${sherpa_log_file_list[0]}
#    ${sherpa_log_path}    fetch from left    ${sherpa_log_file_list[0]}    ${sherpa_log_path_tmp}
    [Return]    ${emil_log_file_list}    ${sherpa_log_file_list}
#    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
#    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
#    ${range}    Convert To Integer    ${range}
#    ${range}=    Evaluate    ${range}+1
#    FOR    ${i}    IN RANGE    1    ${range}
#        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
#        ${emil_log_name}    strip string    ${emil_log_name}
#        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
#        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
#        ${emil_log}    convert to txt with filter profile    @{emil_dcap_log}    filter_profile=SourceProfile_syscom.ini
#        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}Emil_log.txt    connection=ute
#        sleep    60s
#    END
#    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
#    [Teardown]    csn.Disconnect     connection=ute