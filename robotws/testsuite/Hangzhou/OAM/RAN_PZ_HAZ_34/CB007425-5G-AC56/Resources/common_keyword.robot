*** Settings ***
Documentation
...         author: lixia.tang
...         contact: lixia.tang@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         CB007425-5G-AC56 test

Library     taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library     taf.sw.dcap.rd		WITH NAME	DCAP
Library     robot.libraries.DateTime
Library     OperatingSystem
Library     taf.transport.ssh.interface.ssh       WITH NAME    tafssh
Library     String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/DCAP.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/emil.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
${bts_host}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${profiles}    5G
${docker_cmd}    docker exec -it FlowTracer /bin/bash -c \'./fcmd ${DCAP_host}:50001
${profile_path}     C:\\Program Files\\Emil\\profiles\\5G
${UE_TYPE}    ${tl.ues[0].capabilities[1]}

*** Keywords ***
Suite setup
    Connect to gnb coam via ssl    connection=COAM
    ...    gnb_index=${0}
    ...    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}

Suite teardown
    admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error    DCAP.stop_trace    trace_id=${output}[tracer_id]

Create Bts On DCAP
    [Arguments]    ${bts_mr_id}=925
    ${bts_info}    DCAP.get_all_bts_info
    #log to console    ${bts_info}
    ${bts_info_length}    get length    ${bts_info}
    FOR    ${index}    IN RANGE    ${bts_info_length}
        ${is_bts_exist}    set variable if    ${bts_info[${index}]['mr_bts_id']} == ${bts_mr_id}    true    false
        Exit For Loop If    '${is_bts_exist}'=='true'
    END
    run keyword if    '${is_bts_exist}' != 'true'    DCAP.create_bts    host=${bts_host}    bts_alias=${alias}
    ...    ELSE    log to console    message=the specific bts is exist

Start Trace On DCAP
    ${bts_info}    DCAP.get_all_trace_info

Get the exact emil log and convert to txt
    [Arguments]    ${DCAP_log_path}    ${txt_log_name}    ${profile_file}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    csn.Execute   command=find ${TS_CASE_LOG_PATH} -type f -not -name '*.zip' -delete    connection=ute
    #csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp/    connection=ute
    csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp/    connection=ute
    csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp/ | grep .5gm > ${TS_CASE_LOG_PATH}dcap_log_name.txt
    ...    connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt
    ...    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}
        ...    connection=ute
        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
        ${emil_log}    convert to txt    @{emil_dcap_log}    profile_file=${profile_file}
        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}${txt_log_name}    connection=ute
        sleep    60s
    END
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap*    connection=ute
    [Teardown]    csn.Disconnect     connection=ute

convert to txt
    [Arguments]    @{emil_dcap_log}    ${profile_file}
    log to console    \n Upload emil script
    Csn.Connect to   hostname=${EMIL_HOST}    username=${EMIL_USER}    password=${EMIL_PASSWORD}
    ...    alias=Emil_decode
    csn.Upload File   local_path=${CURDIR}/${profile_file}   remote_path=${profile_path}\\SourceProfileUser.ini
    ...    connection=Emil_decode
    log to console    \n convert to txt
    ${emil_log}=    Covert Emil Logs to TXT    file_list=${emil_dcap_log}   local_dir=${TS_CASE_LOG_PATH}
    ...    emil_host=${EMIL_HOST}    emil_user=${EMIL_USER}    emil_password=${EMIL_PASSWORD}
    ...    emil_protocol=${profiles}
    [Return]    ${emil_log}
    [Teardown]    csn.Disconnect    connection=Emil_decode

L3 call start
    [Arguments]    ${UE_TYPE}    ${ue_index}=${0}    ${4G_check}=${False}
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    sleep    5s

L3 Call Stop
    [Arguments]    ${UE_TYPE}    ${ue_index}=${0}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

Check Event for all PMI Ticket
    [Arguments]    ${txt_log_name}    ${event}    ${trigger_check}    ${event_type}    ${interval}=0    ${trigger_expect}=0
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}number*    connection=ute
    csn.Execute
    ...    command=awk '/${event_type}/{print NR}' ${TS_CASE_LOG_PATH}${txt_log_name} > ${TS_CASE_LOG_PATH}numberfirst.txt
    ...    connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}numberfirst.txt >> ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${interval}    Convert To Integer    ${interval}
    ${Turerange}=    Evaluate    ${range}+2
    ${Failrange}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${Failrange}
        ${numberfirst}    csn.Execute   command=sed -n ${i}p ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
        ${numberlast}    Get numberlast     ${txt_log_name}    ${numberfirst}
        csn.Execute   command=echo ${numberlast} >> ${TS_CASE_LOG_PATH}numberlast.txt    connection=ute
    END
    Log To Console    \n ### Check ${event} in ${range} PMI Tickets ###
    FOR    ${i}    IN RANGE    1    ${Turerange}
        should be True    ${i}!=${Failrange}
        Log To Console    \n ### Number ${i} is being checked ###
        ${flag}    run keyword and return status     Check PMI Ticket Event    i=${i}    txt_log_name=${txt_log_name}    event=${event}
        continue for loop if    ${flag}==False
        ${flag}    Run Keyword If    ${trigger_check} == ${True}
        ...    Check Event trigger
        ...    txt_log_name=${txt_log_name}    event=${event}    trigger_expect=${trigger_expect}    interval=${interval}
        ...    ELSE    set variable    ${flag}
        Log To Console    ${flag}
        exit for loop if    ${flag}==True
    END

Get number of ProcedureDone
    [Arguments]    ${numberfirst}    ${txt_log_name}    ${j}=1
    ${numberfirst}    Fetch From Left    ${numberfirst}    \r\n
    ${numberlast}=    Evaluate    ${numberfirst}+${j}
    ${last}    csn.Execute   command=awk 'NR==${numberlast}{print $1}' ${TS_CASE_LOG_PATH}${txt_log_name}    connection=ute
    ${last}    Fetch From Left    ${last}    \r\n
    ${flag}    run keyword and return status     should be equal    ${last}    ProcedureDone
    [Return]    ${numberlast}    ${flag}

Get numberlast
    [Arguments]    ${txt_log_name}    ${numberfirst}
    FOR    ${j}    IN RANGE    1    300
        ${numberfirst}    Fetch From Left    ${numberfirst}    \r\n
        ${numberlast}    ${flag}    Get number of ProcedureDone    j=${j}    txt_log_name=${txt_log_name}    numberfirst=${numberfirst}
        continue for loop if    ${flag}==False
        exit for loop if     ${flag}==True
    END
    [Return]    ${numberlast}

Check PMI Ticket Event
    [Arguments]    ${txt_log_name}    ${event}    ${i}=1
    ${numberlast}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}numberlast.txt    connection=ute
    ${numberfirst}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
    ${numberlast}    Fetch From Left    ${numberlast}    \r\n
    ${numberfirst}    Fetch From Left    ${numberfirst}    \r\n
    csn.Execute
    ...    command=cat ${TS_CASE_LOG_PATH}${txt_log_name} | head -n ${numberlast} | tail -n +${numberfirst} > ${TS_CASE_LOG_PATH}pmi.txt
    ...    connection=ute
    ${value}    csn.Execute
    ...    command=cat ${TS_CASE_LOG_PATH}pmi.txt | grep ${event}    connection=ute
    should not be empty    ${value}

Check Event trigger
    [Arguments]    ${event}    ${txt_log_name}    ${interval}    ${trigger_expect}
    ${trigger}    csn.Execute    command=awk '/${event}/{print NR}' ${TS_CASE_LOG_PATH}pmi.txt    connection=ute
    ${trigger}    Convert To Integer    ${trigger}
    ${trigger}=    Evaluate    ${trigger}+${interval}
    ${trigger}    csn.Execute    command=awk 'NR==${trigger}{print $3}' ${TS_CASE_LOG_PATH}pmi.txt    connection=ute
    ${trigger}    Fetch From Left    ${trigger}    \r\n
    Log To Console    \n trigger=${trigger}
    ${flag}    run keyword and return status     Should Be True    '${trigger}' == '${trigger_expect}'
    [Return]    ${flag}

Teardown
    log to console    \n In Teardown Step
    run keyword and ignore error    L3 Call Stop    UE_TYPE=${UE_TYPE}
    run keyword and ignore error    CI_interface.Common Case Teardown
