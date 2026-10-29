*** Settings ***
Documentation
...         author: yingying.li
...         contact: yingying.li@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         DCAP test


Library     taf.sw.dcap.rd		WITH NAME	DCAP
Library     robot.libraries.DateTime
Library     OperatingSystem
Library     taf.transport.ssh.interface.ssh       WITH NAME    tafssh
Library     String
Library     taf.gnb.oam.coam.admin   WITH NAME   admin_cli
Resource    ./DCAP.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/emil.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
${profiles}    5G
${docker_cmd}        docker exec -it FlowTracer /bin/bash -c \'./fcmd ${DCAP_host}:50001
${TS_CASE_LOG_PATH}    /home/ute/casetest/log_for_dcap/
${emil_txt_log}    /home/ute/casetest/log_for_dcap/Emil_log.txt

${EMIL_HOST}    ${tl.ues[0].ssh_connection_details.addr}
${EMIL_USER}    ${tl.ues[0].ssh_connection_details.username}
${EMIL_PASSWORD}    ${tl.ues[0].ssh_connection_details.password}
${profile_path}     C:\\Program Files\\Emil\\profiles\\5G
${UE_TYPE}    ${tl.ues[-1].capabilities[-1]}

${DCAP_host}    10.57.150.41
#${DCAP_host}    10.101.60.50
${DCAP_port}    443

*** Keywords ***
Debug
    DCAP.connect_to    host=${DCAP_host}     port=${DCAP_port}     username=dcapuser
	...    password=dcapadmin!    rd_version=dcapv3    secure=${True}
	${gnb_custom_profile}=    Create List    cp_5g
	DCAP.start_trace     bts=&{bts_classical}    gnb_custom_profile=${gnb_custom_profile}    control_plane_interface=${True}


Create Bts On DCAP
    [Arguments]    ${bts_mr_id}=940    ${bts}=${bts_classical}
    DCAP.connect_to    host=${DCAP_host}     port=${DCAP_port}     username=${None}
	...    password=${None}    rd_version=dcapv3    secure=${True}
#    ${bts_info}    DCAP.get_all_bts_info
#    ${bts_info_length}    get length    ${bts_info}
#    FOR    ${index}    IN RANGE    ${bts_info_length}
#        ${is_bts_exist}    set variable if    ${bts_info[${index}]['mr_bts_id']} == ${bts_mr_id}    true    false
#        Exit For Loop If    '${is_bts_exist}'=='true'
#    END
#    run keyword if    '${is_bts_exist}' != 'true'    DCAP.create_bts    host=${bts['host']}    bts_alias=${bts['alias']}
#    ...    ELSE    log to console    message=the specific bts is exist

Start DCAP log
    [Arguments]    ${bts}
	${gnb_custom_profile}=    Create List    cp_5g
	${output}    DCAP.start_trace     bts=${bts}    gnb_custom_profile=${gnb_custom_profile}    wait_for_activation=${True}
	...    control_plane_interface=${True}
	Log    ${output}[tracer_id]
    ${result_id}      Convert To Integer      ${output}[tracer_id]
    set suite variable    ${result_id}

Stop DCAP log
    log to console    \n Stop DCAP log
    #sleep    2m
    DCAP.stop_trace    trace_id=${result_id}  ### sth wrong with taf , waitting for jira close

Download log from DCAP
	log to console    Download log from DCAP
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${result_id}   target_dir=${TS_CASE_LOG_PATH}
    [Return]    ${downloaded_emil_file_path}

Start Trace On DCAP
    ${bts_info}    DCAP.get_all_trace_info

Get the exact emil log
    [Arguments]    ${DCAP_log_path}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    log to console    \n Download DCAP log to UTE
    csn.Execute   command=find ${TS_CASE_LOG_PATH} -type f -not -name '*.zip' -delete    connection=ute
    csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    #csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp    connection=ute
    ${emil_log_name}    csn.Execute   ls -R ${TS_CASE_LOG_PATH}/dcap_tmp | grep .5gm    connection=ute
    ${emil_log_name}    strip string    ${emil_log_name}
    csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH} -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
    log to console    \n Get Emil log
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    @{emil_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
    [Return]    @{emil_log}
    [Teardown]    csn.Disconnect     connection=ute

Get the exact emil log and convert to txt
    [Arguments]    ${DCAP_log_path}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#    csn.Execute   command=find ${TS_CASE_LOG_PATH} -type f -not -name '*.zip' -delete    connection=ute
    csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    #csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp    connection=ute
    csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp | grep .5gm > ${TS_CASE_LOG_PATH}dcap_log_name.txt   connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
        ${emil_log}    convert to txt    @{emil_dcap_log}
        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}Emil_log.txt    connection=ute
        sleep    60s
    END
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    [Teardown]    csn.Disconnect     connection=ute

Get the exact emil log and filter and convert to txt
    [Arguments]    ${DCAP_log_path}    ${filter_profile}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#    csn.Execute   command=find ${TS_CASE_LOG_PATH} -type f -not -name '*.zip' -delete    connection=ute
    csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    #csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp    connection=ute
    csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp | grep .5gm > ${TS_CASE_LOG_PATH}dcap_log_name.txt   connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
        ${emil_log}    convert to txt with filter profile    @{emil_dcap_log}    ${filter_profile}
        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}Emil_log.txt    connection=ute
        sleep    60s
    END
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    [Teardown]    csn.Disconnect     connection=ute

Get the exact emil log and filter ZMQ/SCTP and convert to txt
    Log To Console    Get the exact emil log and filter ZMQ/SCTP and convert to txt
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp/    connection=ute
	#csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp    connection=ute
	csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp/ | grep .5gm > ${TS_CASE_LOG_PATH}dcap_log_name.txt   connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
        ${emil_log}    convert to txt with filter profile    @{emil_dcap_log}    filter_profile=SourceProfile_zmq.ini
        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}Emil_log.txt    connection=ute
        sleep    60s
    END
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    [Teardown]    csn.Disconnect     connection=ute

Get the exact emil log and filter ZMQ/SCTP and convert to txt for SBTS
    [Arguments]    ${DCAP_log_path}
    Log To Console    Get the exact emil log and filter ZMQ/SCTP and convert to txt
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    #csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp/    connection=ute
	csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp    connection=ute
	csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp/ | grep .5gm > ${TS_CASE_LOG_PATH}dcap_log_name.txt   connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
        ${emil_log}    convert to txt with filter profile    @{emil_dcap_log}    filter_profile=SourceProfile_zmq.ini
        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}Emil_log.txt    connection=ute
        sleep    60s
    END
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    [Teardown]    csn.Disconnect     connection=ute

Get the exact emil log and filter SYSCOM and convert to txt
    Log To Console    Get the exact emil log and filter SYSCOM and convert to txt
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
	#csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp    connection=ute
    csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp | grep .5gm > ${TS_CASE_LOG_PATH}dcap_log_name.txt   connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
        ${emil_log}    convert to txt with filter profile    @{emil_dcap_log}    filter_profile=SourceProfile_syscom.ini
        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}Emil_log.txt    connection=ute
        sleep    60s
    END
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    [Teardown]    csn.Disconnect     connection=ute

Get the exact emil log and filter SYSCOM and convert to txt for SBTS
    [Arguments]    ${DCAP_log_path}
    Log To Console    Get the exact emil log and filter SYSCOM and convert to txt
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    #csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
	csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp    connection=ute
    csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp | grep .5gm > ${TS_CASE_LOG_PATH}dcap_log_name.txt   connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
        ${emil_log}    convert to txt with filter profile    @{emil_dcap_log}    filter_profile=SourceProfile_syscom.ini
        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}Emil_log.txt    connection=ute
        sleep    60s
    END
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    [Teardown]    csn.Disconnect     connection=ute

Get the exact 4G emil log and convert to txt
    [Arguments]    ${DCAP_log_path}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#    csn.Execute   command=find ${TS_CASE_LOG_PATH} -type f -not -name '*.zip' -delete    connection=ute
    csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    #csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp    connection=ute
    csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp | grep .emil > ${TS_CASE_LOG_PATH}dcap_log_name.txt   connection=ute
    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
        ${emil_log}    convert to txt 4G    @{emil_dcap_log}
        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}Emil_log_4G.txt    connection=ute
#        sleep    60s
    END
    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    [Teardown]    csn.Disconnect     connection=ute

Prepare UE and attach UE
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start UE traffic
    [Arguments]    ${dl_data}=50M    ${ul_data}=50M
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${dl_data}    duration=120s
    #power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=${ul_data}    duration=120s

Stop traffic and detach UE
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

convert to txt with filter profile
    [Arguments]    @{emil_dcap_log}    ${filter_profile}
    log to console    \n Upload emil script
    Csn.Connect to   hostname=${EMIL_HOST}    username=${EMIL_USER}    password=${EMIL_PASSWORD}
    ...    alias=Emil_decode
    csn.Upload File   local_path=${CURDIR}/${filter_profile}  remote_path=${profile_path}\\SourceProfileUser.ini  connection=Emil_decode
    log to console    \n convert to txt
    ${emil_log}=    Covert Emil Logs to TXT    file_list=${emil_dcap_log}   local_dir=${TS_CASE_LOG_PATH}
    ...    emil_host=${EMIL_HOST}    emil_user=${EMIL_USER}    emil_password=${EMIL_PASSWORD}    emil_protocol=${profiles}
    [Return]    ${emil_log}
    [Teardown]    csn.Disconnect    connection=Emil_decode



Stop DCAP log and convert to txt type
    log to console    \n Manual Stop log on DCAP Web
    #sleep    2m
    #DCAP.stop_trace    trace_id=${result_id}  ### sth wrong with taf , waitting for jira close
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${result_id}   target_dir=${TS_CASE_LOG_PATH}
    Get the exact emil log and convert to txt    DCAP_log_path=${downloaded_emil_file_path}
    #@{emil_log}    Get the exact emil log      DCAP_log_path=${downloaded_emil_file_path}
    #${emil_txt_log}    convert to txt    @{emil_log}
    #set test variable    ${emil_txt_log}

Check ZMQ/SCTP message
    [Arguments]    ${emil_txt_log}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    ${SCTPRequest}    csn.Execute   command=cat ${emil_txt_log} | grep -i SCTPRequest | tail -n 5    connection=ute
    ${SctpReply}    csn.Execute   command=cat ${emil_txt_log} | grep -i SctpReply | tail -n 5    connection=ute
    ${CpIf}    csn.Execute   command=cat ${emil_txt_log} | grep -i CpIf | tail -n 5    connection=ute
    ${CpUe}    csn.Execute   command=cat ${emil_txt_log} | grep -i CpUe | tail -n 5    connection=ute
    ${CpCell}    csn.Execute   command=cat ${emil_txt_log} | grep -i CpCell | tail -n 5    connection=ute
    ${CpNb}    csn.Execute   command=cat ${emil_txt_log} | grep -i CpNb | tail -n 5    connection=ute
    ${CpIf}    Fetch From Left    ${CpIf}    \r\n
	${CpUe}    Fetch From Left    ${CpUe}    \r\n
    ${CpCell}    Fetch From Left    ${CpCell}    \r\n
	${CpNb}    Fetch From Left    ${CpNb}    \r\n
    ${SCTPRequest}    Fetch From Left    ${SCTPRequest}    \r\n
	${SctpReply}    Fetch From Left    ${SctpReply}    \r\n
    should contain    ${SCTPRequest}    SCTPRequest
	should contain    ${SctpReply}    SctpReply
    should contain    ${CpIf}    CpIf
	should contain    ${CpUe}    CPUE     ignore_case=true
    should contain    ${CpCell}    CpCell
	should contain    ${CpNb}    CpNb
    [Return]

Check SYSCOM message
    [Arguments]    ${emil_txt_log}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    ${ITF_L2_HI_DU_MEAS_LOADMEASUREMENTREPIND_ID}    csn.Execute
	...    command=cat ${emil_txt_log} | grep -i ITF_L2_HI_DU_MEAS_LOADMEASUREMENTREPIND_ID | tail -n 1    connection=ute
    ${API_BBB_EAXC_STATUS_IND_MSG}    csn.Execute   command=cat ${emil_txt_log} | grep -i API_BBB_EAXC_STATUS_IND_MSG | tail -n 1    connection=ute
    ${FAULT_ACK_MSG}    csn.Execute
	...    command=cat ${emil_txt_log} | grep -i FAULT_ACK_MSG | tail -n 1    connection=ute
    ${API_INET_COUNTERS_IND_MSG}    csn.Execute
	...    command=cat ${emil_txt_log} | grep -i API_INET_COUNTERS_IND_MSG | tail -n 1    connection=ute
    ${ITF_L2_HI_DU_MEAS_LOADMEASUREMENTREPIND_ID}    Fetch From Left    ${ITF_L2_HI_DU_MEAS_LOADMEASUREMENTREPIND_ID}    \r\n
    ${API_BBB_EAXC_STATUS_IND_MSG}    Fetch From Left    ${API_BBB_EAXC_STATUS_IND_MSG}    \r\n
    ${FAULT_ACK_MSG}    Fetch From Left    ${FAULT_ACK_MSG}    \r\n
    ${API_INET_COUNTERS_IND_MSG}    Fetch From Left    ${API_INET_COUNTERS_IND_MSG}    \r\n
    run keyword and ignore error    should contain    ${ITF_L2_HI_DU_MEAS_LOADMEASUREMENTREPIND_ID}    ITF_L2_HI_DU_MEAS_LOADMEASUREMENTREPIND_ID
    run keyword and ignore error    should contain    ${API_BBB_EAXC_STATUS_IND_MSG}    API_BBB_EAXC_STATUS_IND_MSG
    run keyword and ignore error    should contain    ${FAULT_ACK_MSG}    FAULT_ACK_MSG
    run keyword and ignore error    should contain    ${API_INET_COUNTERS_IND_MSG}    API_INET_COUNTERS_IND_MSG
    [Return]

Lock cell
    log to console    Lock cell
    coam.lock    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    timeout=60s    connection=default

Unlock cell
    log to console    unlock cell
    coam.unlock    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    timeout=60s    connection=default

Suite setup
    #coam.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
	Connect to gnb coam via ssl    connection=default
	robot_common_operations.Common Suite Setup

Suite teardown
    #Run Keyword and Ignore Error    coam.teardown
	COAM Teardown gnb connections    connection=default
	robot_common_operations.Common Suite Teardown

Get BTSId
	#Connect to gnb coam via ssl    connection=default
    ${bts_info}=  coam.get_bts_info    connection=default
    set suite variable    ${mrbts_id}    ${bts_info["mrbtsID"]}
    set suite variable    ${nrbts_id}    ${bts_info['nrBtsId']}

DU Suite setup
    Cloud DU connect to gnb coam via ssl    connection=default

DU Suite teardown
	COAM Teardown gnb connections    connection=default
    run keyword and ignore error    Stop traffic and detach UE

Check DU SCTP message
    [Arguments]    ${emil_txt_log}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    ${F1AP-PDU}    csn.Execute   command=cat ${emil_txt_log} | grep -i F1AP-PDU | tail -n 5    connection=ute
    ${F1AP-PDU}    Fetch From Left    ${F1AP-PDU}    \r\n
    should contain    ${F1AP-PDU}    F1AP-PDU
    [Return]
