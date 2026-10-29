#*** Settings ***
#Documentation
#...         author: shangyu.xu
#...         contact: shangyu.xu@nokia-sbell.com
#...         squad group: 5G_PZ_MMW_HZ_3_SG
#...         DCAP test
#
#Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
#Library     taf.sw.dcap.rd		WITH NAME	DCAP
#Library     robot.libraries.DateTime
#Library     OperatingSystem
#Library     taf.transport.ssh.interface.ssh       WITH NAME    tafssh
#Library     String
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/DCAP.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/emil.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#
#*** Variables ***
#${ute_host}           ${tl.test_pc.default_ssh_connection_details.addr}
#${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
#${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
##${bts_host}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#${bts_host}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
#${profiles}    5G
#${docker_cmd}    docker exec -it FlowTracer /bin/bash -c \'./fcmd ${DCAP_host}:50001
#
#${profile_path}     C:\\Program Files\\Emil\\profiles\\5G
#
#
#*** Keywords ***
#Suite setup
#    admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=COAM
#
#Suite teardown
#    admin_cli.teardown    connection=COAM
#    Run Keyword And Ignore Error    DCAP.stop_trace    trace_id=&{output1}[id]
#    Run Keyword And Ignore Error    COAM WEBUI Logout    display=${true}
#
#Create Bts On DCAP
#    [Arguments]    ${bts_mr_id}=925
#    ${bts_info}    DCAP.get_all_bts_info
#    #log to console    ${bts_info}
#    ${bts_info_length}    get length    ${bts_info}
#    FOR    ${index}    IN RANGE    ${bts_info_length}
#        ${is_bts_exist}    set variable if    ${bts_info[${index}]['mr_bts_id']} == ${bts_mr_id}    true    false
#        Exit For Loop If    '${is_bts_exist}'=='true'
#    END
#    run keyword if    '${is_bts_exist}' != 'true'    DCAP.create_bts    host=${bts_host}    bts_alias=${alias}
#    ...    ELSE    log to console    message=the specific bts is exist
#
#Start Trace On DCAP
#    ${bts_info}    DCAP.get_all_trace_info
#
#Get the exact emil log and convert to txt
#    [Arguments]    ${DCAP_log_path}    ${txt_log_name}    ${profile_file}
#    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#    csn.Execute   command=find ${TS_CASE_LOG_PATH} -type f -not -name '*.zip' -delete    connection=ute
#    #csn.Execute   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp/    connection=ute
#    csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp/    connection=ute
#    csn.Execute   command=ls -R ${TS_CASE_LOG_PATH}dcap_tmp/ | grep .5gm > ${TS_CASE_LOG_PATH}dcap_log_name.txt
#    ...    connection=ute
#    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}dcap_log_name.txt >> ${TS_CASE_LOG_PATH}dcap_log_name.txt
#    ...    connection=ute
#    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
#    ${range}    Convert To Integer    ${range}
#    ${range}=    Evaluate    ${range}+1
#    FOR    ${i}    IN RANGE    1    ${range}
#        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}dcap_log_name.txt    connection=ute
#        ${emil_log_name}    strip string    ${emil_log_name}
#        csn.Execute   command=cp $(find ${TS_CASE_LOG_PATH}/ -name ${emil_log_name}) ${TS_CASE_LOG_PATH}
#        ...    connection=ute
#        @{emil_dcap_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
#        ${emil_log}    convert to txt    @{emil_dcap_log}    profile_file=${profile_file}
#        csn.Execute   command=cat ${emil_log} >> ${TS_CASE_LOG_PATH}${txt_log_name}    connection=ute
#        sleep    60s
#    END
#    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}dcap*    connection=ute
#    [Teardown]    csn.Disconnect     connection=ute
#
#convert to txt
#    [Arguments]    @{emil_dcap_log}    ${profile_file}
#    log to console    \n Upload emil script
#    Csn.Connect to   hostname=${EMIL_HOST}    username=${EMIL_USER}    password=${EMIL_PASSWORD}
#    ...    alias=Emil_decode
#    csn.Upload File   local_path=${CURDIR}/${profile_file}   remote_path=${profile_path}\\SourceProfileUser.ini
#    ...    connection=Emil_decode
#    log to console    \n convert to txt
#    ${emil_log}=    Covert Emil Logs to TXT    file_list=${emil_dcap_log}   local_dir=${TS_CASE_LOG_PATH}
#    ...    emil_host=${EMIL_HOST}    emil_user=${EMIL_USER}    emil_password=${EMIL_PASSWORD}
#    ...    emil_protocol=${profiles}
#    [Return]    ${emil_log}
#    [Teardown]    csn.Disconnect    connection=Emil_decode
#
#Reboot UE for NSA
#    _Prepare Variables    ue_index=${0}
#     csn.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
#    ...    timeout=120    alias=cpc_${0}
#    _Reboot_UE    connection=cpc_${0}
#    csn.disconnect      connection=cpc_${0}
#
#L3 call setup for NSA
#    [Arguments]    ${UE_TYPE}=askey
#    log to console    L3 call setup and check
#    Log To Console    \n ### Prepare UE ###
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
#    Log To Console    \n ### UE Attach ###
#    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
#    Log To Console    \n ### verify UE Attach ###
#    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
#    Log To Console    \n ###UE Start traffic and check TP ###
#    #Get Askey UE Ipef Port    ue_index=${0}
#    power_ue.Start traffic   ue_type=${UE_TYPE}    direction=ul   throughput=70M    duration=600    iperf_type=via_command
#    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=200M    duration=600    iperf_type=via_command
#
#Stop traffic and UE detach
#    [Arguments]    ${UE_TYPE}=askey
#    Log To Console    \n ###UE Stop traffic and check TP ###
#    #Get Askey UE Ipef Port    ue_index=${0}
#    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
#    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
#    Log To Console    \n ### UE Detach ###
#    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
#
#L3 call start
#    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${4G_check}=${False}    ${reset_sol}=ue_reboot
#    log to console    L3 call setup and check
#    Log To Console    \n ### Prepare UE ###
#    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${UE_TYPE}    reset_sol=${reset_sol}
#    Log To Console    \n ### UE Attach ###
#    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
#    Log To Console    \n ### verify UE Attach ###
#    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
#
#L3 Call Stop
#    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50
#    Log To Console    \n ### UE Detach ###
#    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}
#
#Start Device traffic
#    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${direction}=dl    ${throughput}=1M    ${reset_sol}=${True}
#    ...    ${iperf_port}=default
#    Log To Console    \n ###UE Start traffic ###
#    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throughput}    duration=900
#    ...    iperf_port=${iperf_port}
#
#Stop Device traffic
#    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${direction}=dl    ${iperf_port}=default
#    Log To Console    \n ###UE Stop traffic###
#    power_ue.Stop traffic    direction=${direction}    ue_index=${ue_index}    ue_type=${UE_TYPE}    iperf_port=${iperf_port}
#
####################################################PMI Ticket###################################################################
#Check SA Event from Email log
#    [Arguments]    ${txt_log_name}
#    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#    ${UeSetup}    csn.Execute   command=cat ${TS_CASE_LOG_PATH}${txt_log_name} | grep -o UeSetup | tail -n 1    connection=ute
#    ${PduSessionInformation}
#    ...    csn.Execute   command=cat ${TS_CASE_LOG_PATH}${txt_log_name} | grep -o PduSessionInformation | tail -n 1
#    ...    connection=ute
#    ${UeDuConnectivity}    csn.Execute   command=cat ${TS_CASE_LOG_PATH}${txt_log_name} | grep -o UeDuConnectivity | tail -n 1
#    ...    connection=ute
#    ${UeSetup}    Fetch From Left    ${UeSetup}    \r\n
#    ${PduSessionInformation}    Fetch From Left    ${PduSessionInformation}    \r\n
#    ${UeDuConnectivity}    Fetch From Left    ${UeDuConnectivity}    \r\n
##    ${Number_of_UeSetup}    csn.Execute   command=cat ${emil_txt_log} | grep -c UeSetup    connection=ute
##    ${Number_of_UeSetup}    Convert To Integer    ${Number_of_UeSetup}
#    [Return]    ${UeSetup}    ${PduSessionInformation}    ${UeDuConnectivity}    #${Number_of_UeSetup}
#
#Check NSA Event from Email log
#    [Arguments]    ${txt_log_name}
#    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#    ${SgNbAddition}    csn.Execute   command=cat ${TS_CASE_LOG_PATH}${txt_log_name} | grep -o SgNbAddition | tail -n 1
#    ...    connection=ute
#    ${CuUeRelease}    csn.Execute   command=cat ${TS_CASE_LOG_PATH}${txt_log_name} | grep -o CuUeRelease | tail -n 1
#    ...    connection=ute
#    ${SgNbRelease}    csn.Execute   command=cat ${TS_CASE_LOG_PATH}${txt_log_name} | grep -o SgNbRelease | tail -n 1
#    ...    connection=ute
#    ${SgNbAddition}    Fetch From Left    ${SgNbAddition}    \r\n
#    ${CuUeRelease}    Fetch From Left    ${CuUeRelease}    \r\n
#    ${SgNbRelease}    Fetch From Left    ${SgNbRelease}    \r\n
#    [Return]    ${SgNbAddition}    ${CuUeRelease}    ${SgNbRelease}
#
#Check Event for all PMI Ticket
#    [Arguments]    ${txt_log_name}    ${event}
#    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#    csn.Execute
#    ...    command=awk '/CpUePmiTicket/{print NR}' ${TS_CASE_LOG_PATH}${txt_log_name} > ${TS_CASE_LOG_PATH}numberfirst.txt
#    ...    connection=ute
#    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}numberfirst.txt >> ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
#    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
#    ${range}    Convert To Integer    ${range}
#    ${Turerange}=    Evaluate    ${range}+2
#    ${Failrange}=    Evaluate    ${range}+1
#    FOR    ${i}    IN RANGE    1    ${Failrange}
#        ${numberfirst}    csn.Execute   command=sed -n ${i}p ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
#        ${numberlast}    Get numberlast     ${txt_log_name}    ${numberfirst}
#        csn.Execute   command=echo ${numberlast} >> ${TS_CASE_LOG_PATH}numberlast.txt    connection=ute
#    END
#    Log To Console    \n ### Check ${event} in ${range} PMI Tickets ###
#    FOR    ${i}    IN RANGE    1    ${Turerange}
#        should be True    ${i}!=${Failrange}
#        Log To Console    \n ### Number ${i} is being checked ###
#        ${flag}    run keyword and return status     Check PMI Ticket Event    i=${i}    txt_log_name=${txt_log_name}
#        ...    event=${event}
#        exit for loop if    ${flag}==True
#    END
#    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}number*    connection=ute
#
#Check CP-UE Event for all PMI Ticket
#    [Arguments]    ${txt_log_name}    ${event}    ${trigger_check}    ${interval}=0    ${trigger_expect}=0
#    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#    csn.Execute
#    ...    command=awk '/CpUePmiTicket/{print NR}' ${TS_CASE_LOG_PATH}${txt_log_name} > ${TS_CASE_LOG_PATH}numberfirst.txt
#    ...    connection=ute
#    csn.Execute   command=wc -l ${TS_CASE_LOG_PATH}numberfirst.txt >> ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
#    ${range}    csn.Execute   command=awk 'END{print $1}' ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
#    ${range}    Convert To Integer    ${range}
#    ${Turerange}=    Evaluate    ${range}+2
#    ${Failrange}=    Evaluate    ${range}+1
#    FOR    ${i}    IN RANGE    1    ${Failrange}
#        ${numberfirst}    csn.Execute   command=sed -n ${i}p ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
#        ${numberlast}    Get numberlast     ${txt_log_name}    ${numberfirst}
#        csn.Execute   command=echo ${numberlast} >> ${TS_CASE_LOG_PATH}numberlast.txt    connection=ute
#    END
#    Log To Console    \n ### Check ${event} in ${range} PMI Tickets ###
#    FOR    ${i}    IN RANGE    1    ${Turerange}
#        should be True    ${i}!=${Failrange}
#        Log To Console    \n ### Number ${i} is being checked ###
#        ${flag}    run keyword and return status     Check PMI Ticket Event    i=${i}    txt_log_name=${txt_log_name}
#        ...    event=${event}
#        continue for loop if    ${flag}==False
#        run keyword if    ${trigger_check} == ${True}
#        ...    Check Event trigger
#        ...    txt_log_name=${txt_log_name}    event=${event}    trigger_expect=${trigger_expect}    interval=${interval}
#        exit for loop if    ${flag}==True
#    END
#    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}number*    connection=ute
#    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}pmi.txt    connection=ute
#
#Check PMI Ticket Event
#    [Arguments]    ${txt_log_name}    ${event}    ${i}=1
#    ${numberlast}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}numberlast.txt    connection=ute
#    ${numberfirst}    csn.Execute    command=sed -n ${i}p ${TS_CASE_LOG_PATH}numberfirst.txt    connection=ute
#    ${numberlast}    Fetch From Left    ${numberlast}    \r\n
#    ${numberfirst}    Fetch From Left    ${numberfirst}    \r\n
#    csn.Execute
#    ...    command=cat ${TS_CASE_LOG_PATH}${txt_log_name} | head -n ${numberlast} | tail -n +${numberfirst} > ${TS_CASE_LOG_PATH}pmi.txt
#    ...    connection=ute
#    ${value}    csn.Execute
#    ...    command=cat ${TS_CASE_LOG_PATH}pmi.txt | grep ${event}    connection=ute
#    should not be empty    ${value}
#
#Get numberlast
#    [Arguments]    ${txt_log_name}    ${numberfirst}
#    FOR    ${j}    IN RANGE    1    200
#        ${numberfirst}    Fetch From Left    ${numberfirst}    \r\n
#        ${numberlast}    ${flag}    Get number of ProcedureDone    j=${j}    txt_log_name=${txt_log_name}    numberfirst=${numberfirst}
#        continue for loop if    ${flag}==False
#        exit for loop if     ${flag}==True
#    END
#    [Return]    ${numberlast}
#
#Get number of ProcedureDone
#    [Arguments]    ${numberfirst}    ${txt_log_name}    ${j}=1
#    ${numberfirst}    Fetch From Left    ${numberfirst}    \r\n
#    ${numberlast}=    Evaluate    ${numberfirst}+${j}
#    ${last}    csn.Execute   command=awk 'NR==${numberlast}{print $1}' ${TS_CASE_LOG_PATH}${txt_log_name}    connection=ute
#    ${last}    Fetch From Left    ${last}    \r\n
#    ${flag}    run keyword and return status     should be equal    ${last}    ProcedureDone
#    [Return]    ${numberlast}    ${flag}
#
#Check Event trigger
#    [Arguments]    ${event}    ${txt_log_name}    ${interval}    ${trigger_expect}
#    ${trigger}    csn.Execute    command=awk '/${event}/{print NR}' ${TS_CASE_LOG_PATH}pmi.txt    connection=ute
#    ${trigger}    Convert To Integer    ${trigger}
#    ${trigger}=    Evaluate    ${trigger}+${interval}
#    ${trigger}    csn.Execute    command=awk 'NR==${trigger}{print $3}' ${TS_CASE_LOG_PATH}pmi.txt    connection=ute
#    ${trigger}    Fetch From Left    ${trigger}    \r\n
#    Log To Console    \n trigger=${trigger}
#    Should Be True    '${trigger}' == '${trigger_expect}'
#
####################################################PCMD##################################################################
#Input PCMD search value
#    [Arguments]    ${offset}    ${length}    ${all_length}
#    ${length}=    Evaluate    ${length}+${offset}
#    ${all_length}    Convert To Integer    ${all_length}
#    ${all_length}    get_pcmd_line_nu    ${all_length}
#    ${all_length}    Convert To Integer    ${all_length}
#    ${all_length}=    Evaluate    ${all_length}+1
#    [Return]    ${offset}    ${length}    ${all_length}
#
#Check PCMD Event
#    [Arguments]    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
#    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#    csn.Execute   command=awk '/${pcmd_event_name}/{print NR}' ${pcmd_log_path}/${txt_log_name} > ${pcmd_log_path}/pcmd_line_nu.txt
#    ...    connection=ute
#    csn.Execute   command=wc -l ${pcmd_log_path}/pcmd_line_nu.txt >> ${pcmd_log_path}/pcmd_line_nu.txt    connection=ute
#    ${range}    csn.Execute   command=awk 'END{print $1}' ${pcmd_log_path}/pcmd_line_nu.txt    connection=ute
#    ${range}    Convert To Integer    ${range}
#    Log To Console    \n ### There are ${range} of ${pcmd_event_name} PCMD Event ###
#    ${Turerange}=    Evaluate    ${range}+2
#    ${Failrange}=    Evaluate    ${range}+1
#    FOR    ${i}    IN RANGE    1    ${Turerange}
#        should be True    ${i}!=${Failrange}
#        Log To Console    \n ### NO.${i} of ${pcmd_event_name} is being checked ###
#        ${flag}    run keyword and return status
#        ...    Get PCMD dec data    i=${i}    offset=${offset}    length=${length}    all_length=${all_length}
#        ...    conditions=${conditions}
#        exit for loop if    ${flag}==True
#    END
#    csn.Execute   command=rm -rf ${pcmd_log_path}/pcmd*    connection=ute
#
#Get PCMD dec data
#    [Arguments]    ${offset}    ${length}    ${all_length}    ${conditions}    ${i}=1
#    csn.Execute   command=${CURDIR}/pcmd.sh '${pcmd_log_path}' ${all_length} ${i}    connection=ute
#    ${pcmd_list}    get_pcmd_list    ${pcmd_log_path}/pcmd
#    ${pcmd_data}    Get Slice From List    ${pcmd_list}    ${offset}    ${length}
#    Reverse List    ${pcmd_data}
#    ${pcmd_hex}    get_pcmd_str_hex    ${pcmd_data}
#    ${pcmd_dec}    hex_to_dec    ${pcmd_hex}
#    Log To Console    \n ${pcmd_dec}
#    Run Keyword If    ${conditions}==0    should be true    ${pcmd_dec}>0
#    Run Keyword If    ${conditions}==1    should be true    ${pcmd_dec}>=0
#
#Teardown
#	run keyword and ignore error    csn.Execute   command=rm -rf ${TS_CASE_LOG_PATH}number*    connection=ute
#    run keyword and ignore error    admin_cli.teardown    connection=${connection}
#    run keyword and ignore error    csn.Disconnect	connection=ASIB
#    run keyword and ignore error    Stop Device traffic    UE_TYPE=${UE_TYPE}    direction=dl
#    run keyword and ignore error    Stop Device traffic    UE_TYPE=${UE_TYPE}    direction=ul
#    run keyword and ignore error    L3 Call Stop    UE_TYPE=${UE_TYPE}
#    run keyword and ignore error    CI_interface.Common Case Teardown
#