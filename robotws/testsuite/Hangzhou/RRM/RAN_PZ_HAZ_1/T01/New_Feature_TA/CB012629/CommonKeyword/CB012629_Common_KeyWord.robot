*** Settings ***

Documentation     Keywords related to CB012629
Resource          CB012629_Common_Variables.robot

*** Variables ***
${filename_pattern}      *${CU_IP}*.lcbin
*** Keywords ***

#***Tcpdump keywords***
Start Collect Bip For GNB
    [Arguments]    ${bts_index}=${0}   ${bbmod_Index}=${1}
    ${bip_argument}   Create Dictionary   bip_options=-c ${bbmod_Index}
    ${dict_argument}   Create Dictionary   argument=${bip_argument}
    Log Collection    start    bip    product_type=gnb    bts_index=${bts_index}
    ...    dict_argument=${dict_argument}

Start Collect Wireshark For GNB
    [Arguments]     ${bts_index}=${0}
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${bts_index}    dict_argument=${dict_argument}

Stop Wireshark log For GNB
    [Arguments]     ${bts_index}=${0}
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${bts_index}
    [Return]    ${local_file_path}

Check multi tracerecords
    [Arguments]     ${tracerecords}    ${host}=10.0.1.1   ${traceId}=00:00:01    ${capture_file_path}=none
    FOR   ${tracerecords_index}   IN   @{tracerecords}
       ${tracerecord}   Check tracerecords    tracerecords=${tracerecords_index}   host=${host}   traceId=${traceId}
       ...   capture_file_path=${capture_file_path}
       Should Not Be Empty     ${tracerecord}
   END

Check multi tracerecords by traceId
    [Arguments]   ${trace_id_list_all}    ${tracerecords}    ${capture_file_path}
    FOR   ${traceId}   IN    @{trace_id_list_all}
        Check multi tracerecords    tracerecords=${tracerecords}   host=sba  traceId=${traceId}  capture_file_path=${capture_file_path}
    END

Check no tracerecords
    [Arguments]     ${tracerecords}    ${host}=mba   ${traceId}=00:00:01    ${capture_file_path}=none
    FOR   ${tracerecords_index}   IN   @{tracerecords}
       ${tracerecord}   Check tracerecords    tracerecords=${tracerecords_index}   host=${host}   traceId=${traceId}
       ...   capture_file_path=${capture_file_path}
       Should Be Empty     ${tracerecord}
   END

Check no tracerecords by traceId
    [Arguments]    ${trace_id_list_all}   ${tracerecords}    ${capture_file_path}
    FOR   ${traceId}   IN    @{trace_id_list_all}
        Check no tracerecords   tracerecords=${tracerecords}   host=sba  traceId=${traceId}  capture_file_path=${capture_file_path}
    END

Check tracerecords
    [Arguments]    ${tracerecords}    ${host}=mba   ${traceId}=00:00:01    ${capture_file_path}=none
	${traceMessage}  Set Variable    'nsetapx.traceActivationType == ${host} && ${tracerecords} && nsetapx.traceId == ${traceId}'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    [Return]     ${traceMessage_result}

Check common tracerecords
    [Arguments]    ${tracerecords}      ${capture_file_path}=none
	${traceMessage}  Set Variable    '${tracerecords}'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    Should Not Be Empty     ${traceMessage_result}

Check common tracerecords by host
    [Arguments]    ${tracerecords}     ${host}=mba    ${capture_file_path}=none
	${traceMessage}  Set Variable    'nsetapx.traceActivationType == ${host} && ${tracerecords}'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    Should Not Be Empty     ${traceMessage_result}

Check common tracerecords by host and traceId
    [Arguments]    ${tracerecords}     ${host}=sba    ${capture_file_path}=none
	${traceMessage}  Set Variable    'nsetapx.traceActivationType == ${host} && ${tracerecords} && nsetapx.traceId == ${traceId}'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    Should Not Be Empty     ${traceMessage_result}

Check common tracerecords for activate protocal
    [Arguments]    ${trace_activate_protocal}   ${capture_file_path}
    FOR   ${f1ap_trace}   IN   @{trace_activate_protocal}
        Check common tracerecords   tracerecords=${f1ap_trace}   capture_file_path=${capture_file_path}
    END

Check no common tracerecords
    [Arguments]    ${tracerecords}      ${capture_file_path}=none
	${traceMessage}  Set Variable    '${tracerecords}'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    Should Be Empty     ${traceMessage_result}

Check tracerecord by DCAP IP
    [Arguments]    ${tracerecords}    ${dcap_ip}=10.69.4.50   ${traceId}=00:00:01   ${capture_file_path}=none
	${traceMessage}  Set Variable    'ip.addr == ${dcap_ip} && nsetapx.traceId == ${traceId} && ${tracerecords}'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    [Return]     ${traceMessage_result}

Check multi tracerecords by DCAP IP
    [Arguments]     ${tracerecords}    ${dcap_ip}=10.69.4.50   ${traceId}=00:00:01   ${capture_file_path}=none
    FOR   ${tracerecords_index}   IN   @{tracerecords}
       ${tracerecord}   Check tracerecord by DCAP IP   tracerecords=${tracerecords_index}   dcap_ip=${dcap_ip}   traceId=${traceId}
       ...    capture_file_path=${capture_file_path}
       Should Not Be Empty     ${tracerecord}
   END

Check no multi tracerecords by DCAP IP
    [Arguments]     ${tracerecords}    ${dcap_ip}=10.69.4.50   ${traceId}=00:00:01   ${capture_file_path}=none
    FOR   ${tracerecords_index}   IN   @{tracerecords}
       ${tracerecord}   Check tracerecord by DCAP IP   tracerecords=${tracerecords_index}   dcap_ip=${dcap_ip}   traceId=${traceId}
       ...    capture_file_path=${capture_file_path}
       Should Be Empty     ${tracerecord}
   END

Check multi emil tracerecords
    [Arguments]     ${tracerecords}    ${file_path}=none
    FOR   ${tracerecords_index}   IN   @{tracerecords}
       ${tracerecord}   tti_analysis.Check Column In Csv   column_name=${tracerecords_index}   file_path=${file_path}
       Should Not Be Empty     ${tracerecord}
   END

Decode tcpdump
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=esp.sequence == 115
    ${tshark_comd}  catenate    tshark -r ${input_file} -o ntrstr.defragment:TRUE  -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -Y ${filter_expression}
    ${filtered_packets}    Run    ${tshark_comd}
    [Return]    ${filtered_packets}

Download wireshark plugin
    sleep    5s
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    ${exist_mcshark}   Run   cd ${plugin_folder}/${ver}/epan;ls mcshark*
#    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls nsetapx*
    Run   cd ${plugin_folder}/${ver}/epan;sudo rm mcshark*
    Run   cd ${plugin_folder}/${ver}/epan;sudo rm nsetapx*
    ${mcshark_plugin_path}   Generate Mcshark path
    ${cmd_1}=    Catenate    wget -r -np -nH  ${nsetapx_plugin_addr}/ -P /home/ute/nsetapx
    ${cmd_2}=    Catenate    wget -r -np -nH  ${mcshark_plugin_path}/ -P /home/ute/mcshark
    Run Keyword If    not os.path.exists("/home/ute/nsetapx")   Run  cd /home/ute/;sudo mkdir nsetapx
    Run  cd /home/ute/;sudo chmod 777 nsetapx
    OperatingSystem.Run    command=cd /home/ute/nsetapx
    OperatingSystem.Run    command=sudo rm -rf /home/ute/nsetapx/artifactory
    OperatingSystem.Run    command=${cmd_1}
    Run Keyword If    not os.path.exists("/home/ute/mcshark")   Run  cd /home/ute/;sudo mkdir mcshark
    Run  cd /home/ute/;sudo chmod 777 mcshark
    OperatingSystem.Run    command=cd /home/ute/mcshark
    OperatingSystem.Run    command=sudo rm -rf /home/ute/mcshark/artifactory
    OperatingSystem.Run    command=${cmd_2}
    ${nsetapx_plugin_addr_local}  Replace String    ${nsetapx_plugin_addr}   https://artifactory-hz1.int.net.nokia.com
    ...  /home/ute/nsetapx
    ${nsetapx_plugin_path}=    Run Keyword If   "${ver}"=="4.2"  Catenate   ${nsetapx_plugin_addr_local}/nsetapx-${ver}-*rocky08.so
    ...   ELSE
    ...   Catenate   ${nsetapx_plugin_addr_local}/nsetapx-${ver}-*buster.so
    OperatingSystem.Run    command=sudo cp ${nsetapx_plugin_path} ${plugin_folder}/${ver}/epan
    ${nsetapx_exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    ${nsetapx_sw_list}    Split String    ${nsetapx_exist}    \n
    ${length}  Get Length   ${nsetapx_sw_list}
    Run Keyword If   ${length}>=2   Delete unused plugin   ${nsetapx_sw_list}   ${length}   ${ver}
    ${mcshark_plugin_addr_local}  Replace String    ${mcshark_plugin_path}   https://artifactory-hz1.int.net.nokia.com
    ...  /home/ute/mcshark
    ${mcshark_plugin_path}=    Run Keyword If   "${ver}"=="4.2"  Catenate   ${mcshark_plugin_addr_local}/mcshark-${ver}-*rocky8.so
    ...   ELSE
    ...   Catenate   ${mcshark_plugin_addr_local}/mcshark-${ver}-*buster.so
    OperatingSystem.Run    command=sudo cp ${mcshark_plugin_path} ${plugin_folder}/${ver}/epan
    ${mcshark_exist}   Run   cd ${plugin_folder}/${ver}/epan;ls mcshark*
    ${mcshark_sw_list}    Split String    ${mcshark_exist}    \n
    ${length}  Get Length   ${mcshark_sw_list}
    Run Keyword If   ${length}>=2   Delete unused plugin   ${mcshark_sw_list}   ${length}   ${ver}

Delete unused plugin
    [Arguments]   ${plugin_sw_list}   ${length}   ${ver}
    FOR    ${index}    IN RANGE    0    ${length}-1
        Run   cd ${plugin_folder}/${ver}/epan;sudo rm -rf ${plugin_sw_list}[${index}]
    END

Create wts folder if not exists
     Run Keyword If    not os.path.exists("${wts_folder}")   Run  cd /opt;sudo mkdir wts
     ${wts_folder}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
     ${wts_folder_list}    Split String    ${wts_folder}    /
     ${wts_up_folder}    Generate wts path
     Run  cd ${wts_up_folder};tar -czvf latest.tar ${wts_folder_list[-1]}/
     ${exist_latest}   Run   cd ${wts_up_folder};ls latest.tar
     Run keyword if  "${exist_latest}"=="latest.tar"    Run  cd ${wts_up_folder};sudo cp latest.tar /opt/wts
     Run keyword if  "${exist_latest}"=="latest.tar"    Run  cd ${wts_up_folder};sudo rm latest.tar
     Run  cd /opt/iphy;rm -f latest
     ${exist_latest}   Run   cd /opt/wts;ls latest.tar
     Run keyword if  "${exist_latest}"=="latest.tar"   Run  cd /opt/wts;sudo tar -xzvf latest.tar
     Run keyword if  "${exist_latest}"=="latest.tar"   Run  cd /opt/wts;sudo rm latest.tar
     Run  cd /opt/wts;sudo mv ${wts_folder_list[-1]}/ latest/
     Run  cd /opt/iphy;ln -s /opt/wts/latest latest

Generate Mcshark path
    ${sw_list}    Split String    ${ACTIVE_SW_VERSION}    _
    ${sw_version}  Replace String    ${ACTIVE_SW_VERSION}   ${sw_list[0]}   ${RELEASE}
    ${output}    OperatingSystem.Run    command=tshark -v |grep TShark
    ${lst}    Get Regexp Matches    ${output}    v(\\d{1,3}\.\\d{1,3})\.\\d{1,3}   1
    ${tshark_version}=    set variable    ${lst}[0]
    ${mcshark_plugin_path}    Run Keyword If   "${tshark_version}"=="4.2"
    ...   Set Variable    ${mcshark_plugin_addr}/${sw_version}
    ...   ELSE
    ...   Set Variable   ${mcshark_plugin_addr}/${sw_version}
    [Return]    ${mcshark_plugin_path}

Generate wts path
    ${wts_folder}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    ${wts_folder_list}    Split String    ${wts_folder}    /
    ${wts_folder}    Set Variable    /opt/iphy/${wts_folder_list[-2]}
    [Return]    ${wts_folder}

Start Tcpdump Log on Target gNB
    [Arguments]    ${host}=10.0.1.3
    Log To Console    start tcpdump on target gNB
    ${tcpdump_log_name_T}=    TStart tcpdump in SBTS    host=${host}
    [Return]    ${tcpdump_log_name_T}

Stop Tcpdump Log on Target gNB
    [Arguments]    ${tcpdump_log_name_T}
    Log To Console    stop tcpdump on target gNB
    ${capture_file_path_T}    ${input_file}=    TStop Tcpdump in SBTS      names=${tcpdump_log_name_T}
    [Return]     ${capture_file_path_T}

TStart tcpdump in SBTS
   [Arguments]    ${host}
   [Documentation]    this kw is used to start tcpdump in gnb
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${pcap_path}    Join Path    ${RESULT_DIR}    Wireshark_${timestamp}
    ${pcap_file_name}    Join Path    ${RESULT_DIR}    Wireshark_${timestamp}    Wireshark_${timestamp}.pcap
    set variable    ${pcap_path}
    set variable    ${pcap_file_name}
    ${tcpdump_log_name}  set variable   Wireshark_${host}_${timestamp}
    TStart tcpdump collection in SBTS    host=${host}     name=Wireshark_${host}_${timestamp}    options=-i any
    [Return]    ${tcpdump_log_name}

TStop Tcpdump in SBTS
   [Arguments]    ${names}=${tcpdump_log_name}
   [Documentation]    this kw is used to stop tcpdump in gnb
    core.stop_collectors    names=${names}
    core.Collect Collectors    names=${names}    target_dir=${TEST_LOG_DIRECTORY}
    core.Teardown Collectors    names=${names}

    ${capture_file_path} =    Set Variable    ${TEST_LOG_DIRECTORY}/${names}/${names}.pcap
    ${input_file} =    Set Variable    ${names}.pcap
    set variable    ${capture_file_path}
    set variable    ${input_file}
    [Return]    ${capture_file_path}    ${input_file}

TStart tcpdump collection in SBTS
    [Arguments]    ${host}=none    ${name}=ASIB_tcpdump    ${options}=-i any
    [Documentation]    this kw is used to create tcpdump log collection on ASIB VM
    &{ASIB}=    create dictionary    host=${host}
    ...                              user=${ASIB_USERNAME}
    ...                              password=${ASIB_PASSWORD}
    tcpdump.create_tcpdump_collector    name=${name}    options=${options}    executor=${ASIB}
    tcpdump.Set Suite Alias    ${name}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}


#*** COAM operation Keywords ***
Reset Site
   wait until keyword succeeds   3x   1min    COAM_Admin.Login
   COAM_Admin.ResetSite
   [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Verify All Cells Onair
     [Arguments]     ${product_type}=gnb
     BTS Operation    operation=verify    product_type=${product_type}    bts_index=0    verify_status=SITE_ONAIR

Add or Delete A New MOC
     [Arguments]     ${moc_jason}=default.json    ${product_type}=gnb   ${folder_name}=config   ${bts_index}=${0}
     #NRSTRACEDU
     ${delta_file_path}   Set Variable   ${case_path}/${folder_name}/${moc_jason}
     ${res}   Parameter Operation    operation=delta_plan_update   product_type=${product_type}   delta_file_path=${delta_file_path}
     ...   bts_index=${bts_index}

Activate or Deactivate Trace Report
    [Arguments]       ${actPCMDReport}=true   ${actSubscriberTraceReport}=true    ${product_type}=gnb
     @{para_list}   Create List   actPCMDReport    actSubscriberTraceReport
     @{value_list}   Create List   ${actPCMDReport}   ${actSubscriberTraceReport}
     @{mo_list}   Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
     ${res}   Parameter Operation    operation=parameter_update   product_type=${product_type}   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Modify drbInactivityTimerSA
    [Arguments]       ${drbInactivityTimerSA}=60
     @{para_list}   Create List   drbInactivityTimerSA
     @{value_list}   Create List   ${drbInactivityTimerSA}
     @{mo_list}   Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
     ${res}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Activate RRC Reestabishment
    [Arguments]       ${rrcReestabTypeSA}=sameGNB  ${product_type}=gnb
     @{para_list}   Create List   rrcReestabTypeSA
     @{value_list}   Create List   ${rrcReestabTypeSA}
     @{mo_list}   Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
     ${res}   Parameter Operation    operation=parameter_update   product_type=${product_type}   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Get amfIPAddress from COAM
    [Arguments]       ${product_type}=gnb
    @{para_list}      Create List    amfIPAddress
    @{mo_list}    Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
    ${out}            Parameter Operation    operation=parameter_value_check   product_type=${product_type}
    ...                                      para_list=@{para_list}    mo_list=@{mo_list}
    [Return]     ${out['${mo_list[0]}']['amfIPAddress']}

Update ranAC
    [Arguments]       ${ranAC}=0    ${cell_id}=11
     @{para_list}   Create List   ranAC
     @{value_list}   Create List   ${ranAC}
     @{mo_list}   Create List   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
     ${res}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Full Commissioning
    [Arguments]       ${scf_name}=TC01.xml   ${product_type}=gnb
    ${scf_path}   Set Variable   ${case_path}/config/${scf_name}
    ${res}   Parameter Operation    operation=full_commission   product_type=${product_type}   scf_path=${scf_path}

Get faultid for SBTS
    [Arguments]    ${connection}=COAM     ${expect_fault_id}=8000   ${alarm_exist_flag}=${False}
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    @{alarms}     coam.get_active_alarms    connection=${connection}
#    log to console   @{alarms}
    ${flag_exist}  set variable   ${False}
    FOR    ${alarm_dict}    IN   @{alarms}
        Run Keyword If   "${alarm_dict["faultId"]}"=="${expect_fault_id}"  run keywords
       ...     Set Test Variable    ${flag_exist}   ${True}
       ...    AND    exit for loop
    END
    should be equal    ${flag_exist}   ${alarm_exist_flag}
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout


Modify AMF IP
     [Arguments]    ${product_type}=gnb
     @{para_list}   Create List  amfIPAddress
     @{value_list}   Create List   ${PC_HOST}
     @{mo_list}   Create List   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
     ${res}   Parameter Operation    operation=parameter_update   product_type=${product_type}   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Modify AMF IP to real AMF
     [Arguments]    ${product_type}=gnb
     @{para_list}   Create List  amfIPAddress
     @{value_list}   Create List   ${real_amf_host}
     @{mo_list}   Create List   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
     ${res}   Parameter Operation    operation=parameter_update   product_type=${product_type}   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Get supplAlarmInfo
    [Arguments]    ${alarm_info}
    ${items}    Get Dictionary Items    ${alarm_info}
    FOR    ${key}    ${additional_info}   IN    @{items}
       ${supplAlarmInfo}     set variable if    "${additional_info["additional_info"]["additionalFaultID"]}"=="8000"
       ...    ${additional_info["additional_info"]["supplAlarmInfo"]}    ${None}
       run keyword if    "${supplAlarmInfo}"!="${None}"    exit for loop
    END
    log to console    ${supplAlarmInfo}
    [Return]   ${supplAlarmInfo}

Compare AlarmInfo with expected info
    [Arguments]    ${expected_AlarmInfo_info}=none  ${operation}=get_active_alarms  ${product_type}=gnb  ${fautid}=8000
    ${res}    Alarm Operation   ${operation}   ${product_type}  0  0  ${fautid}
    ${AlarmInfo}  Get supplAlarmInfo   ${res}
    should be true    "${AlarmInfo}"=="${expected_AlarmInfo_info}"

Backup scf
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    alias=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}    file_name=SCF_${TEST_NAME}.xml
    ...    connection=SCF_backup
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout   connection=SCF_backup

Get BTS Cell Info
    [Arguments]    ${product_type}=gnb
    ${connection}     _bts.login    product_type=${product_type}    gnb_index=${0}     alias=COAM
    ${cell_info}    COAM_Admin.getcellinfo    cell_type=nr    connection=${connection}
    ${barring_Status}    set variable    ${cell_info[${0}]["status"]["barringStatus"]}
    log to console    ${barring_Status}
    Run Keyword And Ignore Error     coam.teardown    connection=${connection}
    [Return]   ${barring_Status}

Add NRMTRACECU
    [Arguments]    ${param_dict}=${NRMTRACECU_param_dict_1}    ${json_file_name}=NRMTRACECU-2.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=NRMTRACECU.json
    Add or Delete A New MOC   moc_jason=NRMTRACECU.json

Add NRMTRACECUUP
    [Arguments]    ${param_dict}=${NRMTRACECUUP_param_dict_1}   ${json_file_name}=NRMTRACECUUP-2.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=NRMTRACECUUP.json
    Add or Delete A New MOC   moc_jason=NRMTRACECUUP.json

Add NRSTRACECU
    [Arguments]    ${param_dict}=${NRSTRACECU_param_dict_2}   ${json_file_name}=NRSTRACECU-1.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=NRSTRACECU.json
    Add or Delete A New MOC   moc_jason=NRSTRACECU.json

Add NRSTRACECUUP
    [Arguments]    ${param_dict}=${NRSTRACECUUP_param_dict_4}   ${json_file_name}=NRSTRACECUUP-1.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=NRSTRACECUUP.json
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json

Add NRMTRACEDU
    [Arguments]    ${param_dict}=${NRMTRACEDU_param_dict_1}   ${json_file_name}=NRMTRACEDU-5.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=NRMTRACEDU.json
    Add or Delete A New MOC   moc_jason=NRMTRACEDU.json

Add NRSTRACEDU
    [Arguments]    ${param_dict}=${NRSTRACEDU_param_dict_4}   ${json_file_name}=NRSTRACEDU-1.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=NRSTRACEDU.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU.json

Add target NRSTRACEDU
    [Arguments]    ${param_dict}=${NRSTRACEDU_param_dict_4}   ${json_file_name}=NRSTRACEDU-1.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=NRSTRACEDU.json   new_distname=MRBTS-5505/NRBTS-5505
    Add or Delete A New MOC   moc_jason=NRSTRACEDU.json   bts_index=${1}

Add A TCE
    [Arguments]    ${param_dict}=${TCE_param_dict_1}   ${json_file_name}=TCE-10.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=TCE.json
    Add or Delete A New MOC   moc_jason=TCE.json

Delete NRMTRACECU
    [Arguments]    ${param_dict}=${NRMTRACECU_param_dict_1}
    Modify json file value    param_dict=${param_dict}   json_file_name=NRMTRACECU-2.json
    ...   new_file_name=NRMTRACECU.json  target_operation=delete
    Add or Delete A New MOC   moc_jason=NRMTRACECU.json

Delete NRSTRACECU
    [Arguments]    ${param_dict}=${NRSTRACECU_param_dict_2}
    Modify json file value    param_dict=${param_dict}   json_file_name=NRSTRACECU-1.json
    ...   new_file_name=NRSTRACECU.json  target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACECU.json

Delete NRSTRACECUUP
    [Arguments]    ${param_dict}=${NRSTRACECUUP_param_dict_4}
    Modify json file value    param_dict=${param_dict}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json

Delete NRSTRACEDU
    [Arguments]    ${param_dict}=${NRSTRACEDU_param_dict_4}
    Modify json file value    param_dict=${param_dict}   json_file_name=NRSTRACEDU-1.json
    ...   new_file_name=NRSTRACEDU.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACEDU.json

Delete target NRSTRACEDU
    [Arguments]    ${param_dict}=${NRSTRACEDU_param_dict_4}
    Modify json file value    param_dict=${param_dict}   json_file_name=NRSTRACEDU-1.json
    ...   new_file_name=NRSTRACEDU.json   target_operation=delete  new_distname=MRBTS-5505/NRBTS-5505
    Add or Delete A New MOC   moc_jason=NRSTRACEDU.json   bts_index=${1}

Delete NRMTRACEDU
    [Arguments]    ${param_dict}=${NRMTRACEDU_param_dict_1}
    Modify json file value    param_dict=${param_dict}   json_file_name=NRMTRACEDU-5.json
    ...   new_file_name=NRMTRACEDU.json  target_operation=delete
    Add or Delete A New MOC   moc_jason=NRMTRACEDU.json

Delete NRMTRACECUUP
    [Arguments]    ${param_dict}=${NRMTRACECUUP_param_dict_1}
    Modify json file value    param_dict=${param_dict}   json_file_name=NRMTRACECUUP-2.json
    ...   new_file_name=NRMTRACECUUP.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRMTRACECUUP.json

Delete A TCE
    [Arguments]    ${param_dict}=${TCE_param_dict_1}
    Modify json file value    param_dict=${param_dict}   json_file_name=TCE-10.json
    ...   new_file_name=TCE.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=TCE.json

#*** WTS Keywords ***
Case Precondition for ST
    [Arguments]    ${product_type}=gnb
    log to console    Case Precondition
    Download wireshark plugin
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    WTS Edaemon Egate Setup
    Module Airphone Config Cfg  call_type=none  tag=${PC_HOST}
    Execute Egate Command      cmd=start
    OperatingSystem.Run    sudo iptables -F
    ${amfIP_origin}   Get amfIPAddress From COAM   product_type=${product_type}
    Run Keyword If   "${amfIP_origin}"!="${PC_HOST}"  Modify AMF IP  product_type=${product_type}
    sleep   60s
    ${barring_Status}  Get BTS Cell Info   product_type=${product_type}
    Run Keyword If   "${barring_Status}"=="barred"  Reset Site
    wait until keyword succeeds  5 min  30 sec  Verify All Cells Onair   product_type=${product_type}
    OperatingSystem.Run    cd /usr/local/bin
    OperatingSystem.Run    DCAP_Basic_controller start

Case Postcondition for ST
    [Arguments]    ${product_type}=gnb
    ${amfIP_origin}   Get amfIPAddress From COAM   product_type=${product_type}
    Run Keyword If   "${amfIP_origin}"=="${PC_HOST}"  Modify AMF IP to real AMF   product_type=${product_type}
    sleep   60s
    ${barring_Status}  Get BTS Cell Info   product_type=${product_type}
    Run Keyword If   "${barring_Status}"=="barred"  Reset Site


WTS Edaemon Egate Setup
    [Arguments]    ${edaemon_port}=22222    ${egate_port}=20000
    ...     ${save_egate}=${SAVE_EGATE_AFTER_DOWN}    ${alias}=default
    airphone_setup    edaemon_port=${edaemon_port}    egate_port=${egate_port}
    ...    alias=${alias}    save_egate=${save_egate}
    ute_wtssim.setup_egate    egate_port=${egate_port}    alias=${alias}
    ...    save_egate=${save_egate}
    _airphone get WTS version

TCE server action
    [Arguments]     ${sudo_password}    ${dcap_server_ssh_info}   ${dcap_action}   ${tce_host}
     Set Test Variable    ${dcap_alias}    nongui_dcap_${tce_host}
     basic.connect_to_server_with_key    ${dcap_alias}    ${dcap_server_ssh_info}
     Log to console    tce action
     ${cmd}  timed_file_downloader.tce_action    ${dcap_alias}    ${dcap_action}   ${CU_IP}    ${sudo_password}
     Log to console   ${cmd}

Start Subscriber Trace
    [Arguments]    ${ue_id}=1   ${tce_ip}=10.0.1.1
    ...            ${trace_depth}=minimum
    ...            ${ifaces_to_trace}=Uu,NG-C,Xn-C,F1-C,E1
    ...            ${trace_plmn}=311:489
    ...            ${trace_rec_session_ref_id}=1
    ...            ${trace_ref_id}=1
    ${command} =  catenate  SEPARATOR=
    ...           ng_ue_trace_start id=${ue_id}
    ...           \ tce_ip=${tce_ip}
    ...           \ trace_depth=${trace_depth}
    ...           \ ifaces_to_trace=${ifaces_to_trace}
    ...           \ trace_plmn=${trace_plmn}
    ...           \ trace_rec_session_ref_id=${trace_rec_session_ref_id}
    ...           \ trace_ref_id=${trace_ref_id}
    Execute Egate Command      cmd=${command}

Stop Subscriber Trace
    [Arguments]    ${ue_id}=1   ${trace_plmn}=311:489   ${trace_rec_session_ref_id}=1    ${trace_ref_id}=1
    ${command} =  catenate  SEPARATOR=
    ...           ng_ue_trace_stop id=${ue_id} trace_plmn=${trace_plmn}
    ...           \ trace_rec_session_ref_id=${trace_rec_session_ref_id}
    ...           \ trace_ref_id=${trace_ref_id}
    Execute Egate Command      cmd=${command}

Trigger ICS With Trace Start
    [Arguments]    ${ue_id}=1  ${trace_ref_id}=1
    ...            ${trace_rec_session_ref_id}=1
    ...            ${trace_depth}=minimum
    ...            ${ifaces_to_trace}=Uu,NG-C,Xn-C,F1-C,E1
    ...            ${tce_ip}=10.0.1.1
    ...            ${trace_plmn}=311:489
    ${command} =  catenate   SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on trace_plmn=${trace_plmn}
    ...           \ trace_ref_id=${trace_ref_id}
    ...           \ trace_rec_session_ref_id=${trace_rec_session_ref_id}
    ...           \ trace_depth=${trace_depth}
    ...           \ ifaces_to_trace=${ifaces_to_trace}
    ...           \ tce_ip=${tce_ip}
    Execute Egate Command      cmd=${command}

Trigger ICS With Trace Stop
    [Arguments]    ${ue_id}=1
    ${command_off} =  catenate   SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=off
    Execute Egate Command    cmd=${command_off}

Multi UE ICS With Trace Stop
   [Arguments]    ${ue_id}=1   ${num}=6
   sleep  2s
   FOR  ${ue_id}    IN RANGE    1    ${num}
        Trigger ICS With Trace Stop    ue_id=${ue_id}
   END

#***Dcap keywords***
Get dcap collection time
    [Arguments]     ${dcap_server}    ${host}
    [Documentation]
    ...    end time is 22:30, if interval number is 1; get 22:45; if interval number is 2;22:45 and 22:30
     Set Test Variable    ${dcap_alias}    nongui_dcap_${host}
     basic.connect_to_server_with_key    ${dcap_alias}    ${dcap_server}
     ${log_collection_end_time}=    timed_file_downloader.get_remote_server_datetime    ${dcap_alias}
    [Return]    ${log_collection_end_time}     ${dcap_alias}

Get dcap collection time for current time
    [Arguments]     ${dcap_server}    ${host}
    [Documentation]
    ...    end time is 22:30, if interval number is 1; get 22:30; if interval nubmer is 2; 22:30 and 22:15
     Set Test Variable    ${dcap_alias}    nongui_dcap_${host}
     basic.connect_to_server_with_key    ${dcap_alias}    ${dcap_server}
     ${log_collection_end_time}=    timed_file_downloader.get_remote_server_rounded_datetime    ${dcap_alias}
    [Return]    ${log_collection_end_time}     ${dcap_alias}

Download dcap log to local
    [Arguments]     ${log_collection_end_time}=none     ${dcap_data_log}=none     ${dcap_alias}=none    ${interval_num}=2
    ...   ${remote_dir}=none   ${filename_pattern}=none
     ${dcap_data_log_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
     ...                 directory_name=${dcap_data_log}
     ${dcap_data_log_path_list}    timed_file_downloader.wait_and_download_timed_remote_files
       ...    ${dcap_alias}
       ...    ${dcap_data_log_path}
       ...    ${remote_dir}
       ...    ${filename_pattern}
       ...    ${log_collection_end_time}
       ...    ${interval_num}
    [Return]    @{dcap_data_log_path_list}

Convert Emil Log list
    [Arguments]     ${dcap_data_log_path_list}
     FOR   ${dcap_log_index}   IN   @{dcap_data_log_path_list}
          ${dcap_log_index_new}=    convert_to_cross_platform_filename    ${dcap_log_index}
          Rename File    ${dcap_log_index}    ${dcap_log_index_new}
          ${file_paths}=    Convert Emil Log to Ascii
           ...    ${dcap_log_index_new}
           ...    profile_path=5G Cell Trace
           ...    emil_host=${emil_host}
           ...    emil_user=${emil_user}
           ...    emil_password=${emil_password}
     END

Convert Emil to CSV
    [Arguments]     ${local_host}   ${file_name}
     Connect To DCAP     ${local_host}  9443  ${None}  ${None}  dcapv3  ${TRUE}  dcap-master
     ${output_file_name_list}   Get Emil Data In CSV Via Webemil   file_name=${file_name}   connection=dcap-master
     [Return]    ${output_file_name_list}

Download dcap and covert to ascii
   [Arguments]     ${log_collection_end_time}    ${dcap_host}   ${dcap_alias}   ${remote_dir}
      ...   ${filename_pattern}   ${interval_num}
     @{dcap_data_log_path_list}   Download dcap log to local     log_collection_end_time=${log_collection_end_time}
        ...    dcap_data_log=${dcap_host}    dcap_alias=${dcap_alias}  remote_dir=${remote_dir}
        ...    filename_pattern=${filename_pattern}   interval_num=${interval_num}
     Convert Emil Log list     ${dcap_data_log_path_list}

Rename File
    [Arguments]    ${old_filename}    ${new_filename}
    Move File    ${old_filename}    ${new_filename}

Start attenuator
    [Documentation]   BTS4294967293 and BTS10069 attenuator
    ...  A1,A9 for UE1; A2,A10 for UE2; A3,A11 for UE3; A4,A12 for UE4; A5,A13 for UE5;
    ...  A6,A14 for UE6; A7,A15 for UE7; A8,A16 for UE8
    ...  UE1-UE4 for cell456
    ...  UE5 A5 for cell456 and A13 for cell556
    ...  UE6 A6 for cell456 and A14 for cell556
    ...  UE7 for cell669
    ...  UE8 A8 for cell456  and A16 for cell669
    [Arguments]    ${value1}=${0}    ${value2}=${20}  ${value3}=${20}    ${value4}=${20}
    ...  ${value5}=${10}    ${value6}=${10}  ${value7}=${20}    ${value8}=${20}
    ...  ${value9}=${0}    ${value10}=${20}  ${value11}=${20}    ${value12}=${20}
    ...  ${value13}=${20}    ${value14}=${40}  ${value15}=${40}    ${value16}=${25}
    Run keyword if    "${PC_HOST}"=="10.56.198.15"    Set attenuator
    ...   ${value1}  ${value2}   ${value3}   ${value4}   ${value5}    ${value6}   ${value7}  ${value8}
    ...   ${value9}  ${value10}  ${value11}  ${value12}  ${value13}   ${value14}  ${value15}  ${value16}


Set attenuator
    [Arguments]    ${value1}=${120}    ${value2}=${120}  ${value3}=${120}    ${value4}=${120}
    ...  ${value5}=${120}    ${value6}=${120}  ${value7}=${120}    ${value8}=${120}
    ...  ${value9}=${120}    ${value10}=${120}  ${value11}=${120}    ${value12}=${120}
    ...  ${value13}=${120}    ${value14}=${120}  ${value15}=${120}    ${value16}=${120}
    Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=TOPYOUNG    gnb_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=${value1}    ${attenuation_channels[1]}=${value2}
    ...    ${attenuation_channels[2]}=${value3}    ${attenuation_channels[3]}=${value4}
    ...    ${attenuation_channels[4]}=${value5}    ${attenuation_channels[5]}=${value6}
    ...    ${attenuation_channels[6]}=${value7}    ${attenuation_channels[7]}=${value8}
    ...    ${attenuation_channels[8]}=${value9}    ${attenuation_channels[9]}=${value10}
    ...    ${attenuation_channels[10]}=${value11}    ${attenuation_channels[11]}=${value12}
    ...    ${attenuation_channels[12]}=${value13}    ${attenuation_channels[13]}=${value14}
    ...    ${attenuation_channels[14]}=${value15}    ${attenuation_channels[15]}=${value16}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    attenuation change complete

Check emil logs for sba tls
    [Arguments]    ${tracerecords}=${emil_cuup_tracerecords}
    @{dcap_data_log_path_list_sba}   Download dcap log to local
                             ...    log_collection_end_time=${log_collection_end_time_sba_tls}
                             ...    dcap_data_log=${sba_host_tls}
                             ...    dcap_alias=${dcap_alias_tls}
                             ...    remote_dir=${remote_dir}
                             ...    filename_pattern=${filename_pattern}
                             ...    interval_num=1
    ${output_file_name_list_sba}   Convert Emil to CSV    ${PC_HOST}    ${dcap_data_log_path_list_sba}
    ${lenth}  Get Length   ${output_file_name_list_sba}
    Run keyword if  "${lenth}"=="1"
    ...        Check multi emil tracerecords   tracerecords=${tracerecords}  file_path=${output_file_name_list_sba[0]}
    Run keyword if  "${lenth}"=="2"
     ...       Check multi emil tracerecords   tracerecords=${tracerecords}  file_path=${output_file_name_list_sba[1]}

Check emil logs for sba tls twice
    [Arguments]    ${tracerecords_1}=${emil_cuup_tracerecords}   ${tracerecords_2}=${emil_cuup_tracerecords}
    @{dcap_data_log_path_list_sba}   Download dcap log to local
                             ...    log_collection_end_time=${log_collection_end_time_sba_tls}
                             ...    dcap_data_log=${sba_host_tls}
                             ...    dcap_alias=${dcap_alias_tls}
                             ...    remote_dir=${remote_dir}
                             ...    filename_pattern=${filename_pattern}
                             ...    interval_num=1
    ${output_file_name_list_sba}   Convert Emil to CSV    ${PC_HOST}    ${dcap_data_log_path_list_sba}
    ${lenth}  Get Length   ${output_file_name_list_sba}
    Run keyword if  "${lenth}"=="2"   run keywords
     ...       Check multi emil tracerecords   tracerecords=${tracerecords_1}  file_path=${output_file_name_list_sba[0]}
     ...   AND    Check multi emil tracerecords   tracerecords=${tracerecords_2}  file_path=${output_file_name_list_sba[1]}

Check emil logs for sba
    [Arguments]    ${tracerecords}=${emil_cuup_tracerecords}
    @{dcap_data_log_path_list_sba}   Download dcap log to local
                                 ...    log_collection_end_time=${log_collection_end_time_sba}
                                 ...    dcap_data_log=${sba_host}
                                 ...    dcap_alias=${dcap_alias_sba}
                                 ...    remote_dir=${remote_dir}
                                 ...    filename_pattern=${filename_pattern}
                                 ...    interval_num=1
    ${output_file_name_list_sba}   Convert Emil to CSV    ${PC_HOST}    ${dcap_data_log_path_list_sba}
    ${lenth}  Get Length   ${output_file_name_list_sba}
    Run keyword if  "${lenth}"=="1"
    ...        Check multi emil tracerecords   tracerecords=${tracerecords}  file_path=${output_file_name_list_sba[0]}
    Run keyword if  "${lenth}"=="2"
     ...       Check multi emil tracerecords   tracerecords=${tracerecords}  file_path=${output_file_name_list_sba[1]}

Check emil logs for mba
    [Arguments]    ${tracerecords}=${emil_ducp_duup_tracerecords}
   @{dcap_data_log_path_list_mba}   Download dcap log to local
                             ...    log_collection_end_time=${log_collection_end_time_mba}
                             ...    dcap_data_log=${mba_host}
                             ...    dcap_alias=${dcap_alias_mba}
                             ...    remote_dir=${remote_dir}
                             ...    filename_pattern=${filename_pattern}
                             ...    interval_num=1
   ${output_file_name_list_mba}   Convert Emil to CSV    ${PC_HOST}    ${dcap_data_log_path_list_mba}
   ${lenth}  Get Length   ${output_file_name_list_mba}
    Run keyword if  "${lenth}"=="1"
    ...        Check multi emil tracerecords   tracerecords=${tracerecords}  file_path=${output_file_name_list_mba[0]}
    Run keyword if  "${lenth}"=="2"
     ...       Check multi emil tracerecords   tracerecords=${tracerecords}  file_path=${output_file_name_list_mba[1]}

Download Dcap log to local sba
    [Arguments]    ${interval_num}=2
    @{dcap_data_log_path_list}  Download dcap log to local
    ...    log_collection_end_time=${log_collection_end_time_sba}
    ...    dcap_data_log=${sba_host}
    ...    dcap_alias=${dcap_alias_sba}
    ...    remote_dir=${remote_dir}
    ...    filename_pattern=${filename_pattern}
    ...    interval_num=${interval_num}
    [Return]      ${dcap_data_log_path_list}

Download Dcap log to local mba
    [Arguments]    ${interval_num}=2
    @{dcap_data_log_path_list}  Download dcap log to local
    ...    log_collection_end_time=${log_collection_end_time_mba}
    ...    dcap_data_log=${mba_host}
    ...    dcap_alias=${dcap_alias_mba}
    ...    remote_dir=${remote_dir}
    ...    filename_pattern=${filename_pattern}
    ...    interval_num=${interval_num}
    [Return]      ${dcap_data_log_path_list}

Download Dcap log to local sba tls
    [Arguments]    ${interval_num}=2
    @{dcap_data_log_path_list}  Download dcap log to local
    ...    log_collection_end_time=${log_collection_end_time_sba_tls}
    ...    dcap_data_log=${sba_host_tls}
    ...    dcap_alias=${dcap_alias_tls}
    ...    remote_dir=${remote_dir}
    ...    filename_pattern=${filename_pattern}
    ...    interval_num=${interval_num}
    [Return]      ${dcap_data_log_path_list}

#*** log collection Keywords ***
Get Required Logs
   [Arguments]    ${operation}=start  ${log_type}=syslog  ${product_type}=gnb  ${bts_index}=${0}
   ${local_file_path}   Log Collection    operation=${operation}   log_type=${log_type}
   ...   product_type=${product_type}    bts_index=${bts_index}    cudu_index=${0}
   [Return]      ${local_file_path}

#*** UE Keywords***
Prepare UE For commercial or Spark
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Run Keyword If   "${ue_type}"=="commercial"    Prepare UE   ue_type=commercial   ue_index=${ue_index}  ui_version=MATE30PROUI1.0
    Run Keyword If   "${ue_type}"=="spark"  Connect All UEs For Spark

Disconnet UEs
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Run Keyword If   "${ue_type}"=="spark"  Disconnect All UEs For Spark

Attach single UE
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Run Keyword If   "${ue_type}"=="commercial"    Attach single UE For commercial    ue_index=${ue_index}
    Run Keyword If   "${ue_type}"=="spark"  Attach single UE For Spark    ue_index=${ue_index}

Start single UE traffic
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Run Keyword If   "${ue_type}"=="commercial"   Start DL Traffic For commercial local   ue_index=${ue_index}
    Run Keyword If   "${ue_type}"=="spark"   Start DL Traffic For Spark    ue_index=${ue_index}
    Run Keyword If   "${ue_type}"=="spark"   Start UL Traffic For Spark    ue_index=${ue_index}

Stop single UE
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Run Keyword If   "${ue_type}"=="commercial"   Stop single UE For commercial   ue_index=${ue_index}
    Run Keyword If   "${ue_type}"=="spark"   Stop single UE For Spark    ue_index=${ue_index}

Attach single UE For Spark
    [Arguments]    ${ue_index}=${0}
    FOR    ${index}    IN RANGE    3
        ${res_bool}   Run Keyword And Return Status     Attach UE For Spark   ue_index=${ue_index}
		Run Keyword If    '${res_bool}' == 'False'   Stop single UE  ue_index=${ue_index}
        Run Keyword If    '${res_bool}' == 'True'    Exit For Loop
    END

Attach UE For Spark
   [Arguments]    ${ue_index}=${0}
   Log    Start power on and Prepare UE   console=True
   spark.Prepare UE    ue_alias=UE_${ue_index}    ue_index=${ue_index}
   spark.UE power off    ue_alias=UE_${ue_index}
   spark.UE power on    ue_alias=UE_${ue_index}

Detach UE For Spark
    [Arguments]    ${ue_index}=${0}
    spark.UE Detach    ue_alias=UE_${ue_index}

Disconnect All UEs For Spark
    [Arguments]    ${ue_alias}=UE_connection
    SigSpark.Require Platform    ue_alias=${ue_alias}
    SigSpark.disconnect_ues    ue_alias=${ue_alias}

Connect All UEs For Spark
    [Arguments]     ${ue_alias}=UE_connection
    Log    connect UEs for spark   console=True
    SigSpark.Require Platform    ue_alias=${ue_alias}
    SigSpark.disconnect_ues    ue_alias=${ue_alias}
    SigSpark.delete_ues    ue_alias=${ue_alias}
    SigSpark.connect_ues    ue_alias=${ue_alias}

Start DL Traffic For Spark
    [Arguments]     ${ue_index}=${0}    ${duration}=360
    Log    Start dl traffic for all UEs   console=True
	spark.Start traffic    direction=dl    duration=${duration}    throughput=10Mbits/sec    ue_alias=UE_${ue_index}
	...                    dt_name=download   iperf_port=8018   EQIndex=${-1}
    Sleep    10
    ${tput}    spark.Check throughput    ue_alias=UE_${ue_index}   ue_index=${ue_index}    direction=dl
    ...                                  expected_throughput=1
    sleep   5

Stop DL Traffic For Spark
    [Arguments]     ${ue_index}=${0}
    spark.Stop traffic   direction=dl    ue_alias=UE_${ue_index}    ue_index=${ue_index}     EQIndex=${-1}

Start UL Traffic For Spark
    [Arguments]     ${ue_index}=${0}    ${duration}=18000
    Log    Start ul traffic for all UEs   console=True
    spark.Start traffic    direction=ul    duration=${duration}    throughput=10Mbits/sec    ue_index=${ue_index}
    ...   ue_alias=UE_${ue_index}    dt_name=download
    Sleep    10
    ${tput}    spark.Check throughput    ue_alias=UE_${ue_index}   ue_index=${ue_index}    direction=ul
    ...                                  expected_throughput=1
    sleep   5

Stop UL Traffic For Spark
    [Arguments]     ${ue_index}=${0}
    spark.Stop traffic   direction=ul    ue_alias=UE_${ue_index}    ue_index=${ue_index}

Stop single UE For Spark
    [Arguments]     ${ue_index}=${0}
    Run Keyword And Ignore Error  Stop DL Traffic For Spark    ue_index=${ue_index}
    Run Keyword And Ignore Error  Stop UL Traffic For Spark    ue_index=${ue_index}
    Run Keyword And Ignore Error  Detach UE For Spark    ue_index=${ue_index}

Stop single UE For commercial
     [Arguments]     ${ue_index}=${0}
     Detach UE For commercial   ue_index=${ue_index}

Attach single UE For commercial
    [Arguments]    ${ue_index}=${0}
    Log to Console    \n***UE Attach***
    UE Attach    commercial    ue_index=${ue_index}
    sleep    10s

Detach UE For commercial
    [Arguments]     ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    UE Detach    ue_type=${ue_type}    ue_index=${0}

Start DL Traffic For commercial local
    [Arguments]     ${ue_index}=${0}
    Start traffic    ue_type=commercial    ue_index=${ue_index}    direction=dl    dt_index=${0}
    ...              throughput=100M    duration=120

Modify json file value
     [Arguments]    ${param_dict}=none   ${json_file_name}=NRSTRACEDU_origin.json    ${new_file_name}=NRSTRACEDU.json
     ...   ${target_operation}=create   ${new_distname}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
     basic.modify_json_file   json_file_path=${case_path}/config/${json_file_name}
     ...     new_distname=${new_distname}
     ...     param_updates=${param_dict}    new_file_name=${new_file_name}   target_operation=${target_operation}