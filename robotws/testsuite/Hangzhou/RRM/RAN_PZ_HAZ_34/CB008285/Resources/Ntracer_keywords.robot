*** Settings ***
Documentation    Suite description
...   author: Jing Chen
...   contact: chen.1.jing@nokia-sbell.com
...   squad group: MMW_SG1
Resource    ./../Resources/CB008285_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/emil.robot
Library     ../Resources/check_msg.py

*** Keywords ***
Ntrace setup preparation
    [Documentation]    Author: Jing Chen
    ...     Stop nTrace process and start nTrace
    ...     Get the emil log from DCAP server
    ...     Transfer the emil log to control PC and modify file name
    ...     Convert the emil log to .txt format
    ...     Check the log
    [Arguments]  ${trace_host}    ${trace_user}    ${trace_password}    ${emil_host}   ${emil_user}    ${emil_password}
    ...
    log to console   \n Ntrace Setup
    Remove Ntrace Log By BTS ID   trace_host=${trace_host}  trace_user=${trace_user}  trace_password=${trace_password}
    ...                                             bts_id=${GLOBAL_BTS_ID}
    Start Ntracer     trace_host=${trace_host}  trace_user=${trace_user}  trace_password=${trace_password}

Get Ntrace Files By BTSID
    [Arguments]   ${trace_host}   ${trace_user}   ${trace_password}    ${bts_id}    ${local_dir}   ${trace_folder}
    ...    ${connection}=ltetracer
    [Documentation]    ${trace_folder}   can be  /sharedvolume/ntracer/_data/  or  /sharedvolume/ltetracer/traces/CellTrace/
    ${file_list}   Create List
    csn.Connect to   hostname=${trace_host}   username=${trace_user}   password=${trace_password}   alias=${connection}
    ${trace_files}   csn.Execute   command=find ${trace_folder} -name \"ne${bts_id}\*\"   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==1 and '${trace_files[0]}'==''    ${EMPTY}
    ${total_files}   Get Length   ${trace_files}
    FOR   ${index}    IN RANGE    ${total_files}
          ${trace_dir}   ${trace_file_name}   Split Path   ${trace_files[${index}]}
          ${trace_file_name}   Set Variable   ${trace_file_name.replace(":", "")}
          csn.Download File   remote_path=${trace_files[${index}]}   local_path=${local_dir}/${trace_file_name}   connection=${connection}
          Append To List   ${file_list}   ${local_dir}/${trace_file_name}
    END
    [Return]   ${file_list}
    [Teardown]   csn.Disconnect   connection=${connection}

Download Ntrace log to local
    [Documentation]    Author: Jing Chen
    [Arguments]  ${trace_host}    ${trace_user}    ${trace_password}    ${emil_host}   ${emil_user}    ${emil_password}

    ${current_time}     Get Current Date        result_format=%Y%m%d_%H%M%S
    run    command=mkdir ${TS_CASE_LOG_PATH}/ntrace_${current_time}
    set Suite variable    ${ntrace_log_path_local}    ${TS_CASE_LOG_PATH}/ntrace_${current_time}
    ${file_list}    Get Ntrace Files By BTSID   trace_host=${trace_host}   trace_user=${trace_user}  trace_password=${trace_password}
    ...                                trace_folder=${TRACE_FOLDER}    bts_id=${GLOBAL_BTS_ID}     local_dir=${ntrace_log_path_local}
    [Return]   ${file_list}

Remove Ntrace Logs From Remote PC
    [Arguments]   ${emil_host}    ${emil_user}    ${emil_password}    ${connection}=emil
    csn.Connect to   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=${connection}
    csn.Execute   command=cd \"${EMIL_LOG_DIR}\";rm -f Emil_*.txt;rm -f ne*.lcbin   connection=${connection}
    [Teardown]   csn.Disconnect   connection=${connection}

Convert Ntrace logs
    [Documentation]    Author: Jing Chen
    [Arguments]  ${trace_host}    ${trace_user}    ${trace_password}    ${emil_host}   ${emil_user}    ${emil_password}
    ${file_list}    Download Ntrace log to local    trace_host=${TRACE_HOST}    trace_user=${TRACE_USER}    trace_password=${TRACE_PASSWORD}
    ...                    emil_host=${EMIL_HOST}      emil_user=${EMIL_USER}      emil_password=${EMIL_PASSWORKD}

    Upload file to remote host      emil_host=${EMIL_HOST}      emil_user=${EMIL_USER}      emil_password=${EMIL_PASSWORKD}
    ...     local_filepath=${CURDIR}/../Resources/SourceProfileUser.ini
    ...     remote_filepath=${EMIL_PATH}/profiles/${EMIL_PROTOCOL}/SourceProfileUser.ini

    ${coverted_emil_file}    Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${ntrace_log_path_local}    emil_host=${EMIL_HOST}
    ...       emil_user=${EMIL_USER}    emil_password=${EMIL_PASSWORKD}    emil_protocol=${EMIL_PROTOCOL}
    check_emil_msg    msg_file=${CURDIR}/../Resources/${CHECK_MESSAGE_FILE}   emil_file=${coverted_emil_file}

Remove Ntrace Log By BTS ID
    [Documentation]    Author: Jing Chen
    ...     Stop nTracer process
    [Arguments]  ${trace_host}    ${trace_user}    ${trace_password}    ${bts_id}
    log to console   \n remove ntrace log by BTS ID
    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${trace_host}   username=${trace_user}   password=${trace_password}
    ...    alias=DCAP
    csn.Execute   command=find ${TRACE_FOLDER} -name \"ne${bts_id}\*\" | xargs rm -rf   connection=DCAP
    [Teardown]  csn.Disconnect     connection=DCAP

Start Ntracer
    [Documentation]    Author: Jing Chen
    ...     Start nTracer process
    [Arguments]  ${trace_host}    ${trace_user}    ${trace_password}
    log to console   \n start and check ntrace process
    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${trace_host}   username=${trace_user}   password=${trace_password}
    ...    alias=DCAP
    csn.Execute   command=docker start ${nTracer_name}   connection=DCAP
    sleep    5s
    ${Ntrace_status}    csn.Execute    command=docker ps -a | grep ${nTracer_name} | grep -i up   connection=DCAP
    should contain    ${Ntrace_status}       Up
    [Teardown]  csn.Disconnect     connection=DCAP

Stop Ntracer
    [Documentation]    Author: Jing Chen
    ...     Stop nTrace process
    [Arguments]  ${trace_host}    ${trace_user}    ${trace_password}
    log to console   \n stop ntrace process
    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${trace_host}   username=${trace_user}   password=${trace_password}
    ...    alias=DCAP
    sleep    13s
    csn.Execute   command=docker stop ${nTracer_name}   connection=DCAP
    [Teardown]   csn.Disconnect     connection=DCAP

Ntracer Teardown
    log to console   \n nTracer Teardown
    COAM selenium logout
    Remove Ntrace Logs From Remote PC     emil_host=${EMIL_HOST}      emil_user=${EMIL_USER}      emil_password=${EMIL_PASSWORKD}
    8285 case teardown
