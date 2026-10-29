*** Settings ***
Documentation    This suite verifies CB011074
...  author: Sanjeev K Anand
...  contact: sanjeev.kumar_anand@nokia.com
...  Description: keywords for CB011074
Library  BuiltIn
Library  Collections
Library  String
Library  OperatingSystem
Library  SSHLibrary
Library  SeleniumLibrary
Library  DateTime
Library  taf.sbts.oam.coam.admin  WITH NAME  CoamAdmin
Library  taf.selenium.sbts  WITH NAME  seleLib
Library  taf.collectors.btslog  WITH NAME  btslog
Library  taf.collectors.core  WITH NAME  core
Library  taf.collectors.tcpdump  WITH NAME  tcpdump
Library  taf.collectors.tcpdump  WITH NAME  tcpdump1
Library  emillogwithseq.py
Library  ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library  taf.fdsw.rc  WITH NAME  rc
Library  taf.sw.dcap.rd  WITH NAME  rd
Library  taf.transport.ssh  WITH NAME  ssh
Library  Process

*** Variables ***
${j}  0
${i}  0
${E}  0
${DCAP_host}  10.58.239.215  # DCAP server IP 10.58.238.126
${port}  443  # Port value for DCAP connection
${secure}  True  # Secure value for DCAP connection
${rd_version}  dcapv3  # DCAP version
${uepc_Log_path}  C://Users//inbabtslabuser//Documents//Automation_logs
${emil_path}  C:\\Emil  # Emil path in UE PC machine
${emil_profile_path}  ${emil_path}\\profiles\\5G  # Emil profile path in UE PC machine
${Default_DCAP_duration}  12  # DCAP log duration
${dcap_log_timeout}  1200  # Timeout for DCAP log collection
&{BTS_INFO}  host=${mplane_ip}  port=443  # BTS details
@{gnb_custom_filters}  cp_5g  condor5gSyslog  # gnb custom filters for DCAP
@{bts_custom_filter}  condor5gSyslog  #immediateSnapshot  scf  ipCapture  # BTS custom filters for DCAP
@{collection_timing}  Immediate  TraceEnd  # Snapshot collet option for DCAP
@{counter_values}
${msg71}  ueCapabilityEnquiry:-rat-Type nr
${msg72}  ueCapabilityEnquiry:-rat-Type eutra
${msg1}  InitialContextSetupRequest:-0  #ICS
${msg2}  rrcReconfiguration:-reportConfigToAddModList,a2-Threshold rsrp : 71,a3-Offset rsrp : 7,
...    a5-Threshold1 rsrp : 81,a5-Threshold2 rsrp : 61
${msg3}  measurementReport:-measId 1
${msg4}  rrcReconfiguration:-reportConfigToAddModList,a1-Threshold rsrp : 76,a5-Threshold1 rsrp : 81,
...    a5-Threshold2 rsrp : 56,b2-Threshold1 rsrp : 80,b2-Threshold2EUTRA rsrp : 97
${msg5}  measurementReport:-measId 5
${msg6}  rrcReconfiguration:-reportConfigToAddModList,a2-Threshold rsrp : 71
${msg7}  measurementReport:-measResultNeighCells measResultListNR :,physCellId 123,
${msg8}  BearerContextModificationRequest:-nG-RAN-BearerContextModificationRequest :
${msg9}  BearerContextModificationResponse:-nG-RAN-BearerContextModificationResponse :,dRB-Modified-List-NG-RAN {
${msg10}  rrcReconfiguration:-reconfigurationWithSync
${msg11}  rrcReconfiguration:-reportConfigToAddModList,a2-Threshold rsrp : 0,a3-Offset rsrp : 8
${msg12}  rrcReestablishment:-criticalExtensions rrcReestablishment : {
${msg13}  rrcReestablishmentComplete:-criticalExtensions rrcReestablishmentComplete : {
${msg14}  rrcReconfiguration:-reportConfigToAddModList,a2-Threshold rsrp : 14,a3-Offset rsrp : 6,
...    a5-Threshold1 rsrp : 80,a5-Threshold2 rsrp : 60
${msg15}  PDUSessionResourceModifyRequest:-qosFlowIdentifier 3
${msg16}  PDUSessionResourceModifyResponse:-qosFlowIdentifier 3
${msg17}  rrcReconfiguration:-reportConfigToAddModList,a1-Threshold rsrp : 76,a5-Threshold1 rsrp : 81,
...    a5-Threshold2 rsrp : 56,b2-Threshold1 rsrp : 56,b2-Threshold2EUTRA rsrp : 50
${msg18}  PDUSessionResourceModifyRequest:-qosFlowIdentifier 1,cause nas : normal-release
${msg19}  rrcReconfiguration:-reportConfigToAddModList,a1-Threshold rsrp : 61,a5-Threshold1 rsrp : 60,
...    a5-Threshold2 rsrp : 56,b2-Threshold1 rsrp : 35,b2-Threshold2EUTRA rsrp : 18
${msg20}  rrcReconfiguration:-reportConfigToAddModList,a2-Threshold rsrp : 55
${dcapusr}  utfuser
${dcappwd}  utfadmin!
${int}

*** Keywords ***


Test Setup
    Log To Console  connecting to BTS
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    CoamAdmin.Setup_Admin  bts_host=10.58.239.200  alias=oam
    Log To Console  BTS is Connected
    ${opt}  set variable  ${OUTPUT_DIR}/Pre/
    set test variable  ${opt}
    create directory  ${opt}
    ${scf_path}  Download SCF  ${opt}
    set global variable  ${scf_path}
    Check BTS is OnAir
    Log to console  \n--Starting Syslogs Logs--
    Run  killall btslog
    ${executor_test_vm}=  Create Dictionary
    ...  host=${VM_IP}
    ...  user=ute
    ...  password=BT5l@bus3rl0g1n
    btslog.create_btslog_collector
    ...  name=btslog
    ...  btslog_path=/opt/btslog/btslog
    ...  btslog_launcher_path=/opt/btslog/btslog_launcher
    ...  executor=${executor_test_vm}
    ...  log_dir=/tmp/btslog2
    core.setup_collectors  names=btslog
    core.set_suite_alias  btslog
    core.start_collectors  names=btslog
    ${allowed_alarms}=  Expected_alarm
    Watch alarms  allowed_alarms=${allowed_alarms}  connection_kwargs=oam
    Create dcap session
    Set Environment Variable  ABSTRACT_LIB_CONFIG  /home/ute/testline_configuration/7_2_UTE5GCLOUD1042/ta_ue_config.yaml
    Set_export_yml  ${ABSTRACT_LIB_CONFIG}

Download SCF
    [Documentation]  ... Downloading SCF
    [Arguments]  ${path}
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S
    ${filename}  SET VARIABLE  ${path}${timestamp}_scf.xml
    CoamAdmin.get_current_scf_file  connection=oam  file_name=${filename}  timeout=60  local_dir_path=${path}
    OperatingSystem.File Should Exist  ${filename}
    Log To Console  SCF Downloaded
    Log To Console  SCF file name is ${filename}
    [Return]  ${filename}

Collect Snapshot
    [Arguments]  ${path}
    ${snapshot_file_path}  set variable  ${path}Snapshot.zip
    CoamAdmin.collect_snapshot
    ...  target_file_name=${snapshot_file_path}
    ...  coverage=Full
    ...  detailed_output=True
    ...  timeout=300
    ...  connection=oam
    Log To Console  Snapshot collected and saved on path ${snapshot_file_path}


Test Teardown
    ${opt}  set variable  ${OUTPUT_DIR}/Post/
    set test variable  ${opt}
    create directory  ${opt}
    stop watching alarms
    Download SCF  ${opt}
    Collect Snapshot  ${opt}
    Log to console  --Stoping Syslogs Logs--
    core.stop_collectors  names=btslog
    core.collect_collectors  names=btslog  target_dir=${opt}
    core.teardown_collectors  names=btslog
    CoamAdmin.teardown  oam
    Log To Console  BTS IS Disconnected


SCF commissioning and check ONAIR
    [Documentation]  ... Commissiioning BTS and checking BTS status
    [Arguments]  ${scf}  ${DUR}=${DURATION}
    Log to console  *//.....BTS commissioning is Ongoing.....//*
    ${status}=  CoamAdmin.perform_commissioning  scf_file=${scf}  timeout=${DUR}  connection=oam
    Wait Until Keyword Succeeds  5min  10s  Check BTS is OnAir


Check BTS is OnAir
    [Documentation]  ... checking BTS status
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=oam
    Should Be Equal As Strings  ${bts_status["proceduralState"]}  OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...  Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    ...  ELSE  fail

Create dcap session
    [Documentation]  Establish DCAP session
    rd.connect_to  host=${DCAP_host}  port=${port}  rd_version=${rd_version}  secure=${secure}
    ...    username=${dcapusr}  password=${dcappwd}

Dcap Start Trace SA
    [Documentation]  Start DCAP logs with custom filter
    &{BTS_INFO}=  create dictionary  host=${mplane_ip}  port=${port}  username=Nemuadmin  password=nemuuser
    @{gnb_custom_filters}  Create List  cp_5g
    @{bts_custom_filter}  Create List  immediateSnapshot  scf  ipCapture  condor5gSyslog
    @{collection_timing}  Create List  Immediate  TraceEnd
    ${output}  rd.start_trace  duration=${Default_DCAP_duration}  bts=${BTS_INFO}  gnb_custom_profile=@{gnb_custom_filters}
    ...  wait_for_activation=True  collection_timing=@{collection_timing}
    Sleep  150  reason=Wait for DCAP start
    ${START_TRACE_ID}=  Get from Dictionary  ${output}  tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG to console  DCAP log collection has been started in the gNB

Get TcpdumpLogs from Remote machine
    [Documentation]  this keyword is used to capture wireshark log in wireshark PC
    log to console  \nStarting Wireshark Logs
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.239.200
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...  name=tcpdump
    ...  options=-i any
    ...  executor=${executor_oam_vm}
    core.setup_collectors  names=tcpdump
    core.set_suite_alias  tcpdump
    core.start_collectors  names=tcpdump

Convert pcap file
    [Arguments]  ${filter}
    log to console  \nStopping Wireshark Logs
    core.stop_collectors  names=tcpdump
    core.collect_collectors  names=tcpdump  target_dir=${out}
    core.teardown_collectors  names=tcpdump
    SSH_connection  ${VM_IP}  ute  BT5l@bus3rl0g1n
    SSHLibrary.write  cd /home/ute
    ${command}=  set variable  tshark -r ${out}tcpdump/tcpdump.pcap -Y "${filter}" > ${out}tcpdump/tcpdump.txt
    SSHLibrary.write  ${command}
    sleep  30s
    ${filepath}  set variable  ${out}tcpdump/tcpdump.txt
    ${file}=  OperatingSystem.Get file  ${filepath}
    SSH_teardown
    [Return]  ${file}

SSH_connection
    [Arguments]  ${IP}  ${username}  ${pwd}
    SSHLibrary.Open Connection  ${IP}  port=22
    SSHLibrary.Login  ${username}  ${pwd}

SSH_teardown
    sshlibrary.close connection

Check 129 connection
    [Arguments]  ${message}
    SSH_connection  ${VM_IP}  ${VM_usn}  ${VM_pwd}
    SSHLibrary.write  cd /home/ute
    SSHLibrary.write  script download.txt
    SSHLibrary.write  ping 10.58.239.200
    sleep  60s
    ${ctrl_c}  Evaluate  chr(int(3))
    SSHLibrary.Write Bare  ${ctrl_c}
    SSHLibrary.Write  exit
    sleep  2s
    ${screen_log}  OperatingSystem.get file  /home/ute/download.txt
    log  ${screen_log}
    operatingsystem.remove file  /home/ute/download.txt
    SSH_teardown
    should contain  ${screen_log}  ${message}

#validate wireshark logs
#    [Documentation]    this keyword is used to validate wireshark logs
#    [Arguments]    ${log}    ${message}
#    @{log}    Split to lines    ${log}
#    FOR    ${a}    IN    @{log}
#        ${status}    run keyword and return status    should contain    ${a}    ${message}
#        run keyword if    '''${status}'''=='''True'''    Log to console    \n${message} message is found in wireshark log

Prepare UE
    ${a}=  ta_ultracaller.Require UE  ue_alias=${UE_alias}  capabilities=${capabilities}
    log  ${a}
    Log To Console  UE preparation completed

Start UE detach attach and start throughput
    ${a}=  ta_ultracaller.Require UE  ue_alias=${UE_alias}  capabilities=${capabilities}
    log  ${a}
    log to console  --UE AP mode turning OFF
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_Off}
    Sleep  1min
    Log To Console  UE Attach Successful
    Log To Console  \nstarting data transfer
    ${ip}  ta_ultracaller.validate_ue_info  ue_alias=${UE_alias}  info=IP  expected_value=${EMPTY}
    log to console  ${ip}
    log  ${ip}
    Set To Dictionary  ${a${UE_alias}}  ueip=${ip['UE1']['interfaceList']['rmnet_data1'][0]}
    ta_ultracaller.start_data_transfer  ${UE_alias}  ${CALL_type}  direction=${direction_dl}


Stop Data Transfer
    log to console  \nStop data transfer
    ta_ultracaller.await_data_transfer_finish  ${UE_alias}  ${direction_dl}  ${timeout}
    Log To Console  \nUE Data Transfer Successful
    ta_ultracaller.Detach UE  ue_alias=${UE_alias}

Dcap Stop Trace and Get results SA
    [Arguments]  ${testcase_name}
    [Documentation]  Stops DCAP and collect logs
    rd.stop_trace  trace_id=${START_TRACE_ID}  timeout=100
    LOG to console  DCAP logging stopped
    create directory  ${out}${testcase_name}/DCAP_logs
    rd.get_results  result_id=${START_TRACE_ID}  target_dir=${out}${testcase_name}/DCAP_logs  timeout=${dcap_log_timeout}

EMIl log validation
    [Arguments]  ${OUTPUT}  ${message}
    Convert Emil File To Csv  ${OUTPUT}
    ${result}  Parse_Emil_Csv_File_For_Message_content  ${out}${OUTPUT}/  ${message}
    run keyword if  "${result}" != "True"
    ...  log to console  Either Msg and IE's are not present or Messages are not in order
    ...  ELSE  log to console  Messages and IE's are present and its in order
    Run keyword And Continue On Failure  Should Be True  ${result}
    run keyword if  "${result}" != "True"  Fail


Counter validation1
#    [Arguments]    ${counter}    ${occurence}     ${name}
    ${result} =  CoamAdmin.get_pm_counters  counter_ids=${counter}  timeout=100  connection=oam
    ${values}=  Get Dictionary Values  ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-1']['NRMASA-2']['MASA']['${counter}']}
    ${Total_Count}=  Get_value_of_Counter  ${values}
    Log to Console  ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if  '${Total_Count}'!='${occurence}'
    ...  log to console  ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if  '${Total_Count}'!='${occurence}'  fail

Counter validation2
#    [Arguments]    ${counter}    ${occurence}       ${name}
    ${result} =  CoamAdmin.get_pm_counters  counter_ids=${counter}  timeout=100  connection=oam
    ${values}=  Get Dictionary Values  ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-1']['NRMIAF-2']['MIAF']['${counter}']}
    ${Total_Count}=  Get_value_of_Counter  ${values}
    Log to Console  ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if  '${Total_Count}'!='${occurence}'
    ...  log to console  ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if  '${Total_Count}'!='${occurence}'  fail

Counter validation3
#    [Arguments]    ${counter}     ${occurence}    ${name}
    ${result} =  CoamAdmin.get_pm_counters  counter_ids=${counter}  timeout=100  connection=oam
    ${values}=  Get Dictionary Values  ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-1']['NRMIEF-2']['MIEF']['${counter}']}
    ${Total_Count}=  Get_value_of_Counter  ${values}
    Log to Console  ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if  '${Total_Count}'!='${occurence}'
    ...  log to console  ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if  '${Total_Count}'!='${occurence}'  fail

Counter validation4
#    [Arguments]    ${counter}         ${occurence}    ${name}
    ${result} =  CoamAdmin.get_pm_counters  counter_ids=${counter}  timeout=100  connection=oam
    ${values}=  Get Dictionary Values  ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-1']['NRMIRF-1']['MIRF']['${counter}']}
    ${Total_Count}=  Get_value_of_Counter  ${values}
    Log to Console  ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if  '${Total_Count}'!='${occurence}'
    ...  log to console  ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if  '${Total_Count}'!='${occurence}'  fail

Counter validation5
#    [Arguments]    ${counter}    ${occurence}     ${name}
    ${result} =  CoamAdmin.get_pm_counters  counter_ids=${counter}  timeout=100  connection=oam
    ${values}=  Get Dictionary Values  ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-0']['NRMASA-5']['MASA']['${counter}']}
    ${Total_Count}=  Get_value_of_Counter  ${values}
    Log to Console  ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if  '${Total_Count}'!='${occurence}'
    ...  log to console  ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if  '${Total_Count}'!='${occurence}'  fail

Counter validation6
#    [Arguments]    ${counter}    ${occurence}       ${name}
    ${result} =  CoamAdmin.get_pm_counters  counter_ids=${counter}  timeout=100  connection=oam
    ${values}=  Get Dictionary Values  ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-0']['NRMIAF-3']['MIAF']['${counter}']}
    ${Total_Count}=  Get_value_of_Counter  ${values}
    Log to Console  ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if  '${Total_Count}'!='${occurence}'
    ...  log to console  ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if  '${Total_Count}'!='${occurence}'  fail

Get_value_of_Counter
    [Arguments]  ${Counter_value}
    FOR  ${a}  IN  @{Counter_value}
        ${k}  Evaluate  ${k} + ${a}
    END
    [Return]  ${k}

Perform Parameter value change
    [Documentation]  this keyword is used to change parameter value in WebEM
    [Arguments]  ${dist_name}  ${parameter}  ${abbrevation}  ${value}
    ${curr_value}  seleLib.get_parameter_value  dist_name=${dist_name}
    ...  filter_param=${parameter}  abbr=${abbrevation}  coam=connection
    set test variable  ${curr_value}
    Run Keyword If  "${curr_value}" == "${value}"
    ...  log to console  Value of '${parameter}'->'${abbrevation}' is "${curr_value}", so there is no need of parameter change
    ...  ELSE  parameter update  ${dist_name}  ${parameter}  ${abbrevation}  ${value}  #keyword

parameter update
    [Documentation]  This keyword is part of above keyword (Perform Parameter value change) -> can not use it alone.
    [Arguments]  ${dist_name}  ${parameter}  ${abbrevation}  ${value}
    Log to console  Current value of '${parameter}' -> '${abbrevation}' is "${curr_value}"
    Log to console  Changing the parameter configuration-
    CoamAdmin.perform_parameter_recommissioning  dist_name=${dist_name}
    ...  parameter=${abbrevation}  value=${value}  operation=update
    ...  skip_parameter_relation_errors=False  connection=oam
    ${new_value}  seleLib.get_parameter_value  dist_name=${dist_name}
    ...  filter_param=${parameter}  abbr=${abbrevation}  coam=connection
    Log to console  New value of '${parameter}' -> '${abbrevation}' is "${new_value}"

Starting VONR Call
    ta_ultracaller.start voice call  ue_alias=${UE_alias}  testcasename=${dt_name_v}
    Log To Console  UE voice call Successfully started

Stopping VONR Call
    ta_ultracaller.stop voice call  ue_alias=${UE_alias}
    Log To Console  UE voice call Successfully stopped


Convert Emil File To Csv
    [Arguments]  ${testcase_name}
    [Documentation]  Convert Emil logs collected from DCAP
    Log to Console  --- Conversion of EMIL Started ---
    ${path1}  Set Variable  ${out}${testcase_name}/DCAP_logs/
    ${extracted_path}  Set Variable  ${path1}Extracted/
    create directory  ${extracted_path}
    ${date}  Get Current Date  result_format=%Y%m%d
    ${files}  OperatingSystem.List Files In Directory  ${path1}
    Log to console  --- Starting to Unzip DCAP log files ---
    FOR  ${zip}  IN  @{files}
        File Should Have Extension  ${path1}${zip}
        Start Process  unzip  -q  ${path1}${zip}  -d  ${extracted_path}
        sleep  5
    END
    Log to console  --- Unzipping is Completed ---
    ${it}=  OperatingSystem.List Directory  ${extracted_path}/${date}
    ssh.Connect_to  ${MCG_IP}  ${MCG_usn}  ${MCG_pwd}  alias=mcg_vm
    sleep  10s
    FOR  ${out_index}  IN  @{it}
        Run keyword And Ignore Error  Start Emil To Convert Emil File To Csv  source_path=${extracted_path}/${date}
        ...  source_file=${out_index}  testcase_name=${testcase_name}
    END
    ssh.Execute  command=rm -v -f ${uepc_Log_path}//*  connection=mcg_vm  timeout=30s

File Should Have Extension
    [Arguments]  ${FILE_PATH}
    ${ext}  Split Extension  ${FILE_PATH}
    log to console  ${ext}
    [Return]  ${ext}

Start Emil To Convert Emil File To Csv
    [Arguments]  ${source_path}  ${source_file}  ${testcase_name}
    [Documentation]  Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}=  OperatingSystem.List Directory  ${source_path}/${source_file}
    FOR  ${i}  ${a}  IN ENUMERATE  @{source_emil_file}
        ${status}=  Run Keyword And Ignore Error  should contain  ${a}  .5gm
        ${int}  run keyword if  '${status}[0]'=='PASS'  set variable  ${i}
        run keyword if  '${status}[0]'=='PASS'  exit for loop
    END
    ${int}  Convert To Integer  ${int}
    ssh.upload_file  local_path=${source_path}/${source_file}/${source_emil_file}[${int}]  remote_path=${uepc_Log_path}//${source_emil_file}[${int}]
    ...  connection=mcg_vm
    ssh.Execute  command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f  connection=mcg_vm  timeout=30s
    ${cyg_cmd}  Set Variable  cygstart PsExec -u "${MCG_domain}\\${MCG_usn}" -p "${MCG_pwd}" -d -i 2
    ${src_file}  Set Variable  ${uepc_Log_path}//${source_emil_file}[${int}]
    ${run_command}  Set Variable
    ...  ${cyg_cmd} "${emil_path}\\Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile_path}"
    LOG  ${run_command}
    ${output}  ssh.Execute  command=${run_command}  connection=mcg_vm  timeout=30s
    LOG  ${output}
    Wait Until Keyword Succeeds  4min  1s  Check Number Of Processes Running  process_name=Emil.exe  number_of_processes=1
    Wait Until Keyword Succeeds  4min  1s  Check Number Of Processes Running  process_name=Emil.exe  number_of_processes=0
    ${csvfile}=  String.Replace String  string=${source_emil_file}[${int}]  search_for=.5gm  replace_with=.csv
    ssh.download_file  remote_path=${uepc_Log_path}//${csvfile}  local_path=${out}${testcase_name}/${csvfile}  connection=mcg_vm


Start Emil To Convert Emil File To Csv1
    [Arguments]  ${source_path}  ${source_file}  ${testcase_name}
    [Documentation]  Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}=  OperatingSystem.List Directory  ${source_path}/${source_file}
    FOR  ${i}  ${a}  IN ENUMERATE  @{source_emil_file}
        ${status}=  Run Keyword And Ignore Error  should contain  ${a}  .5gm
        ${int}  run keyword if  '${status}[0]'=='PASS'  set variable  ${i}
        run keyword if  '${status}[0]'=='PASS'  exit for loop
    END
    ${int}  Convert To Integer  ${int}
    ssh.upload_file  local_path=${source_path}/${source_file}/${source_emil_file}[${int}]  remote_path=${uepc_Log_path}//${source_emil_file}[${int}]
    ...  connection=mcg_vm
    ssh.Execute  command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f  connection=mcg_vm  timeout=30s
    ${cyg_cmd}  Set Variable  cygstart PsExec -u "${MCG_domain}\\${MCG_usn}" -p "${MCG_pwd}" -d -i 2
    ${src_file}  Set Variable  ${uepc_Log_path}//${source_emil_file}[${int}]
    ${run_command}  Set Variable
    ...  ${cyg_cmd} "${emil_path}\\Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile_path}"
    LOG  ${run_command}
    ${output}  ssh.Execute  command=${run_command}  connection=mcg_vm  timeout=30s
    LOG  ${output}
    Wait Until Keyword Succeeds  4min  1s  Check Number Of Processes Running  process_name=Emil.exe  number_of_processes=1
    Wait Until Keyword Succeeds  4min  1s  Check Number Of Processes Running  process_name=Emil.exe  number_of_processes=0
    ${csvfile}=  String.Replace String  string=${source_emil_file}[${int}]  search_for=.5gm  replace_with=.csv
    ssh.download_file  remote_path=${uepc_Log_path}//${csvfile}  local_path=${out}${testcase_name}/${csvfile}  connection=mcg_vm

Check Number Of Processes Running
    [Arguments]  ${process_name}=Emil.exe  ${number_of_processes}=0
    [Documentation]  Check whether Emil process is running in MCG machine
    ${output}  ssh.Execute  echo -n NumberOfProcesess:&&ps -W | grep -cw ${process_name}  connection=mcg_vm
    Should Contain  ${output}  NumberOfProcesess:${number_of_processes}
    [Return]  ${output}
