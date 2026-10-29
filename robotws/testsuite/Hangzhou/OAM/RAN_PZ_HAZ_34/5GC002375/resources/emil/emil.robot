*** Settings ***
Documentation
...    author: Han Ruiyu
...    contact: ruiyu.han@nokia-sbell.com
...    squad group: NSB MN 5G&SC 5G Pz Verf CN 07 SG
Library     Emil_processing_keywords.py
Library    taf.transport.ssh   WITH NAME   csn
Library            DateTime
Library            OperatingSystem
Variables    ../../../libraries/global_vars.py
Variables          ../../libraries/dcap_server_1.py
Variables          ../../libraries/sherpa_server_1.py
Resource           ../dcap.robot
Resource           ../case_steps.robot
Resource           ../coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


*** Variables ***
${sourceProfile}                                        ${CURDIR}/SourceProfile.ini
${Emil_keywords}                                        ${CURDIR}/Emil_processing_keywords.py
${msg_list}                                             ${CURDIR}/msg_name_vars.py
${tes_emil}                                             test_emil.robot
${profile_path}                                          C:\\Program Files\\Emil\\profiles\\5G
${log_path_DCAP}                              /sharedvolume/flowtracer/traces/5G_TA
${emil_log_path}       C:\\Emil_logs\\

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
    run keyword and ignore error    Dcap delete bts
    [Teardown]    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}

Gnb Operation During Flowtracer Trace
    [Arguments]    ${operation}=call    ${call_mode}=single    ${sleeptime}=30s
    run keyword if  '${operation}'=='call'    _call_operation    call_mode=${call_mode}
    ...   ELSE IF    '${operation}'=='SCF'    _scf_operation
    ...   ELSE IF    '${operation}'=='onair'    _cell_onair_operation
    ...   ELSE IF    '${operation}'=='lock'    _cell_lockunlock_operation
    ...   ELSE     sleep  ${sleeptime}

Start Dcap Basic trace
    [Arguments]    ${bts_classical}    ${gnb_custom_profile}=${gnb_custom_profile}
    Create Bts On DCAP    DCAP_host=${DCAP_host}   DCAP_port=${DCAP_port}   bts_mr_id=${bts_classical['bts_id']}    bts=${bts_classical}
    Start DCAP log    bts=${bts_classical}    gnb_custom_profile=${gnb_custom_profile}

Stop Dcap Basic trace
	Stop DCAP log
    ${downloaded_emil_file_path}    wait until keyword succeeds    20min    30s    Download log from DCAP
    [Return]   ${downloaded_emil_file_path}

_call_operation
    [Arguments]     ${call_mode}
    ${res}   Run Keyword and Ignore Error   Setup Call by mode  call_mode=${call_mode}
    Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
#    Should Be Equal   ${res[0]}   PASS
    Set Suite Variable   ${call_alias}   ${res[1]}

_scf_operation
    ${current_SCF}    Get Current SCF File On COAM    xn_gnb_ip=${xn_gnb_ip}
    ${modified_scf}    Change_Nradjgnb_AMF_Param    modify_scfpath=${current_SCF}
    Wait until keyword succeeds  10min   1min   Import SCF On COAM   IP_WEBUI=${xn_gnb_ip}   SCF_FILE=${modified_scf}
    coam.Check Cell Setup in COAM
    ${res}   Run Keyword and Ignore Error   Setup Xn Link
    Should Be Equal   ${res[0]}   PASS
    Wait until keyword succeeds  10min   1min   Import SCF On COAM   IP_WEBUI=${xn_gnb_ip}   SCF_FILE=${current_SCF}
    ${res}   Run Keyword and Ignore Error   Setup Call by mode  call_mode=single
    Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
#    Should Be Equal   ${res[0]}   PASS
    Set Suite Variable   ${call_alias}   ${res[1]}

_cell_onair_operation
    log to console    reset site and check cell
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${LMP_ADDR}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute    command=reboot    connection=gnb
    coam.Check Cell Setup in COAM
    [Teardown]     run keyword and ignore error  csn.Disconnect   connection=gnb

_cell_lockunlock_operation
    log to console    lock and unlock cell
    Cloud DU connect to gnb coam via ssl
    Perform cell lock via rest api
    Wait Until Keyword Succeeds    15 min    1 min
    ...    Cell Should Be Locked    connection=GNB_OAM
    Perform cell unlock via rest api
    Wait Until Keyword Succeeds    15 min    1 min
    ...    Cell Should Be Unlocked    connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

Download FlowTracer logs to local
    ${current_date}     Get Current Date    result_format=%Y%m%d
    ${current_time}     Get Current Date        result_format=%Y%m%d_%H%M%S
    run    command=mkdir ${OUTPUT_DIR}/${current_time}
    set Suite variable    ${log_path_local}    ${OUTPUT_DIR}/${current_time}
    csn.Connect to   hostname=${dcaps_ip}    username=${dcap_username}    password=${dcap_password}
    ...    alias=DCAP
    ${dir_name}    csn.Execute   command=ls ${log_path_DCAP}    connection=DCAP
    ${dir_name}    strip string    ${dir_name}
    ${length_dir}    get length    ${dir_name}
    run keyword if  ${length_dir}< ${2}    FAIL    [ERROR]Dcap Flowtracer trace didn't caught!
    ${log_name}     csn.Execute   command=ls ${log_path_DCAP}/${dir_name}    connection=DCAP
    ${log_name}    strip string    ${log_name}
    ${log_name}    Fetch From Right    ${log_name}   \r\n
    set suite variable    ${log_name}
    csn.Download File   remote_path=${log_path_DCAP}/${dir_name}/${logname}   local_path=${log_path_local}/${log_name}
    ...   connection=DCAP
    log to console     Download FlowTracer logs to local
    [Teardown]   csn.Disconnect     connection=DCAP

Mkdir for EMil script and logs on sherpa
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_vm
    csn.Execute   command=mkdir C:/robot_script     connection=sherpa_vm
    csn.Execute    command=mkdir C:/Emil_logs     connection=sherpa_vm
    ${output}    csn.Execute   command=C:/robot_script     connection=sherpa_vm
    should contain    ${output}    Is a directory
    ${output}    csn.Execute   command=C:/Emil_logs     connection=sherpa_vm
    should contain    ${output}    Is a director
    [Teardown]  csn.Disconnect    connection=sherpa_vm

Upload Emil script and logs on sherpa
    [Arguments]    ${flag}=zmq
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_vm
    csn.Upload File   local_path=${CURDIR}/msg_name_vars.py   remote_path=C:/robot_script/msg_name_vars.py  connection=sherpa_vm
    sleep    2s
    csn.Upload File   local_path=${CURDIR}/${flag}/SourceProfileUser.ini   remote_path=${profile_path}/SourceProfileUser.ini
    ...   connection=sherpa_vm
    sleep    2s
    csn.Upload File   local_path=${CURDIR}/Emil_processing_keywords.py   remote_path=C:/robot_script/Emil_processing_keywords.py
    ...    connection=sherpa_vm
    sleep    2s
    csn.Upload File   local_path=${CURDIR}/test_emil.robot   remote_path=C:/robot_script/test_emil.robot   connection=sherpa_vm
    sleep    2s
    csn.Upload File   local_path=${log_path_local}/${log_name}  remote_path=C:/Emil_logs/${log_name}   connection=sherpa_vm
    sleep    2s
    log to console     \n Upload Emil script and log
    [Teardown]    csn.Disconnect    connection=sherpa_vm

Delete Emil script and logs on sherpa
    log to console    \n  Delete Emil script and logs
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_vm
    csn.Execute   command=rm -rf C:/robot_script     connection=sherpa_vm
    csn.Execute    command=rm -rf C:/Emil_logs     connection=sherpa_vm
    [Teardown]    csn.Disconnect    connection=sherpa_vm

Remove Emil logs on DCAP
     csn.Connect to   hostname=${dcaps_ip}    username=${dcap_username}    password=${dcap_password}
    ...    alias=DCAP
    csn.execute  command=echo ${dcap_password} | sudo -S rm -rf ${log_path_DCAP}/*  connection=DCAP   timeout=1s
    [Teardown]  csn.Disconnect     connection=DCAP

Download FlowTracer Output to local
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_vm
#    ${txt_name}    csn.Execute    command=ls C:/Emil_logs/*.txt     connection=sherpa_vm
#    ${txt_name}    strip string    ${txt_name}
    csn.execute    command=cd C:/Emil_logs;tar -cvf emil_logs.tar *     connection=sherpa_vm
    csn.Download File   remote_path=C:\\Emil_logs\\emil_logs.tar   local_path=${OUTPUT_DIR}/emil_logs.tar   connection=sherpa_vm
    [Teardown]    csn.Disconnect    connection=sherpa_vm

Check emil log
    [Arguments]    ${end_file}    ${decode_case_name}
    log to console    \n start checking emil logs
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_vm
    set test variable    ${emil_out}    ${FALSE}
    ${execute}=  csn.Execute
    ...    command=robot -L trace -v end_file:*.${end_file} -t "${decode_case_name}" -d C:/Emil_logs/ C:/robot_script/test_emil.robot
    ...    connection=sherpa_vm
    Log to console    message=${execute}
    ${emil_out}=  Run keyword and return status    Should Contain    ${execute}    PASS
    run keyword if   ${emil_out}
    ...   Log to console    message=All msg are analyzed!
    ...   ELSE
    ...   Log to console    message=Some msg are not analyzed.
    run keyword if  not ${emil_out}   fail
    set suite variable    ${emil_out}
    [Teardown]  csn.Disconnect    connection=sherpa_vm

Exact Dcap log
    [Arguments]    ${downloaded_emil_file_path}
    Log To Console    Get the exact dcap log
    run keyword and ignore error   RUN    rm -rf ${OUTPUT_DIR}/dcap_tmp
    RUN   unzip ${downloaded_emil_file_path} -d ${OUTPUT_DIR}/dcap_tmp
    ${local_emil_log_path}    RUN  find ${OUTPUT_DIR}/dcap_tmp -name "*.5gm"
    ${local_emil_log_path}    strip string   ${local_emil_log_path}
    ${emil_log_file_list}    split string    ${local_emil_log_path}    \n
    ${local_sherpa_log_path}    RUN  find ${OUTPUT_DIR}/dcap_tmp -name "*.pcap"
    ${local_sherpa_log_path}    strip string   ${local_sherpa_log_path}
    ${sherpa_log_file_list}    split string    ${local_sherpa_log_path}    \n
#    ${sherpa_log_path_tmp}    fetch from right    ${sherpa_log_file_list[0]}    /
    set suite variable    ${l2ps_log_path}    ${sherpa_log_file_list[0]}
#    ${sherpa_log_path}    fetch from left    ${sherpa_log_file_list[0]}    ${sherpa_log_path_tmp}
    [Return]    ${emil_log_file_list}    ${sherpa_log_file_list}
