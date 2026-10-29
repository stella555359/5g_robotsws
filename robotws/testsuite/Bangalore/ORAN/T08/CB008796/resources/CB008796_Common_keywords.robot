*** Settings ***
Documentation
...   author: Dubey Rahul Kumar
...   contact: rahul.kumar_dubey@nokia.com
...   Description: keywords for CB008796
Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    String
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME   CoamAdmin
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    seleLib
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    Process
Library     taf.ue
Library     ute_ue
Library    ute_tshark
Library    ute_syslog
Library    Telnet
Library	   testsuite/Bangalore/ORAN/T08/resources/python/Tshark_Validation.py
Library    taf.transport.ssh    WITH NAME    ssh
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library    hran_bsc    WITH NAME    hran
Library    testsuite/Bangalore/ORAN/T08/resources/python/Emil_log_parsing.py
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.sw.scout    WITH NAME    scout
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot

*** Variables ***
@{UE_alias}=     UE1
${emil}=	     emil
@{gnb_custom_filter}       cp_5g            condor5gSyslog
@{enb_custom_filter}      cp_4g            condor4gSyslog
@{bts_custom_filter}        scf        		ipCapture
@{collection_timing}        Immediate       TraceEnd


*** Keywords ***
Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to    host=${DCAP_host}    port=${port}    rd_version=${rd_version}    secure=${secure}    username=${dcapusr}    password=${dcappwd}

Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    &{BTS_INFO}=    create dictionary   host=${mplane_ip}     port=${port}    username=Nemuadmin    password=nemuuser
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}    enb_custom_profile=@{enb_custom_filter}
    ...     bts_custom_profile=@{bts_custom_filter}	  wait_for_activation=True
    Sleep       30      reason=Wait for DCAP start
    ${START_TRACE_ID}=      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG to console     DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Arguments]    ${testcase_name}
    [Documentation]     Stops DCAP and collect logs
    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=300
    sleep    1min
    LOG to console    DCAP logging stopped
    create directory         ${out}${testcase_name}
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${out}${testcase_name}    timeout=${dcap_log_timeout}

EMIl log validation
    [Arguments]    ${message}    ${testcase_name}
    Convert Emil File To Csv    ${testcase_name}
    ${result1}    Parse_Emil_Csv_File_For_Message    ${out}
    ...    ${message}:0
    run keyword if     "${result1}" != "True"
    ...     log to console     ${message} message is not found
    ...     ELSE     log to console     ${message} message is found
    run keyword if     "${result1}" != "True"     fail

Convert Emil File To Csv
    [Arguments]    ${testcase_name}
    [Documentation]        Convert Emil logs collected from DCAP

    ${path1}     Set Variable        ${out}${testcase_name}/
    ${source_paths}    Set Variable        ${path1}Extracted/
    create directory         ${source_paths}
    ${date}    Get Current Date    result_format=%Y%m%d
    ${files}    OperatingSystem.List Files In Directory    ${path1}
    FOR    ${zip}    IN    @{files}
		Start Process		unzip    -q    ${path1}${zip}    -d    ${source_paths}
    END
	Sleep	30
    ${it}=    OperatingSystem.List Directory    ${source_paths}${date}
    ssh.Connect_to    ${MCG_IP}    ${MCG_usn}    ${MCG_pwd}    alias=mcg_vm
    FOR    ${out_index}    IN    @{it}
		${exists}    ${emil_file_name}=    Iterate and Check Emil extension file exists      ${source_paths}${date}/${out_index}
        run keyword if    "${exists}" == "True"    Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv
		...      source_path=${source_paths}${date}/${out_index}
		...      source_file=${emil_file_name}    testcase_name=${testcase_name}
    END
    ${output}    ssh.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm        timeout=30s
    LOG     ${output}

Iterate and Check Emil extension file exists
	[Arguments]    ${folder_path}
	${files}=    OperatingSystem.List Files In Directory    ${folder_path}
	${status}=    Set Variable     False
	FOR    ${file}    IN    @{files}
		${rest}    ${last}=    Split String From Right    ${file}    .    1
		log    ${rest}
		log    ${last}
		${status}=    Run Keyword And Return Status    Should Contain    ${last}     emil
		log		${status}
		IF    "${last}" == "${emil}"
		    ${status}=    Set Variable     ${True}
		END
		Exit For Loop IF    "${last}" == "${emil}"
	END
	[Return]    ${status}     ${file}

Start Emil To Convert Emil File To Csv
    [Arguments]    ${source_path}     ${source_file}    ${testcase_name}
    [Documentation]         Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}=    OperatingSystem.List Directory    ${source_path}
    ssh.Connect_to    ${MCG_IP}    ${MCG_usn}    ${MCG_pwd}    alias=mcg_vm
    ssh.upload_file    local_path=${source_path}/${source_file}    remote_path=${uepc_Log_path}//${source_file}    connection=mcg_vm
    ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f      connection=mcg_vm     timeout=30s
    ssh.disconnect    connection=mcg_vm

    ${src_file}     Set Variable        ${uepc_Log_path}//${source_file}
    ssh.Connect_to    ${MCG_IP}    ${MCG_usn}    ${MCG_pwd}    alias=mcg_vm
    ${cyg_cmd}    Set Variable      cygstart /cygdrive//c//PSTools//PsExec -u "${MCG_domain}\\${MCG_usn}" -p "${MCG_pwd}" -d -i 2
    ${run_command}    Set Variable
    ...     ${cyg_cmd} "${emil_path}\\Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile_path}"
    LOG    ${run_command}
    sleep    1min
    ${output}    ssh.Execute    command=${run_command}      connection=mcg_vm        timeout=50s
    LOG    ${output}
    sleep    2min
    ${csvfile}=    String.Replace String    string=${source_file}       search_for=.emil    replace_with=.csv
    ssh.download_file    remote_path=${uepc_Log_path}//${csvfile}       local_path=${out}${testcase_name}/${csvfile}     connection=mcg_vm

Check Number Of Processes Running
    [Arguments]    ${process_name}=Emil.exe    ${number_of_processes}=0
    [Documentation]     Check whether Emil process is running in MCG machine
    ${output}       ssh.Execute    echo -n NumberOfProcesess:&&ps -W | grep -cw ${process_name}       connection=mcg_vm
    Should Contain    ${output}    NumberOfProcesess:${number_of_processes}
    [Return]    ${output}


Perform Parameter value change
    [Documentation]    this keyword is used to change parameter value in WebEM
    [Arguments]  ${dist_name}    ${parameter}    ${abbrevation}    ${value}
    seleLib.login    url=https://192.168.255.129      username=Nemuadmin     password=BT5l@bus3rl0g1n    browser=Firefox    alias=connection
    ${curr_value}    seleLib.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=${parameter}    abbr=${abbrevation}    coam=connection
    set test variable    ${curr_value}
    Run Keyword If    "${curr_value}" == "${value}"
    ...    log to console    Value of '${parameter}' -> '${abbrevation}' is "${curr_value}", so there is no need of parameter change
    ...    ELSE    parameter update    ${dist_name}    ${parameter}    ${abbrevation}    ${value}
    seleLib.logout    coam=connection


parameter update
    [Documentation]     This keyword is part of above keyword (Perform Parameter value change) -> can not use it alone.
    [Arguments]  ${dist_name}    ${parameter}    ${abbrevation}    ${value}
	Log    ${parameter}
    Log to console    Changing the parameter configuration...${\n}
    CoamAdmin.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=${abbrevation}    value=${value}    operation=update
    ...    skip_parameter_relation_errors=False    connection=oam

Admin_setup
    Log To Console    connecting to BTS
    CoamAdmin.teardown_all_aliases_for_admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console    BTS is Connected
    Check BTS is OnAir    oam
    Log to console   \n--Starting Syslogs Logs--\n
    Run     killall btslog
    ${executor_test_vm}=  Create Dictionary
    ...  host=${VM_IP}
    ...  user=ute
    ...  password=BT5l@bus3rl0g1n
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_test_vm}
    ...   log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias    btslog
    core.start_collectors      names=btslog
	Create dcap session

Admin_teardown
    Link SCOUT SCF to Configuration ID for Reporting
    Download SCF    ${out}
    Collect Snapshot
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog    target_dir=${out}
    core.teardown_collectors      names=btslog
    CoamAdmin.teardown    oam
    Log To Console    BTS IS Disconnected

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}    ${timeout}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
	log   ${timeout}
    Log To Console    UE preparation completed


Detach and Attach UE
    [Arguments]     ${UE_alias}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Sleep    60
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep    60
    Log To Console    UE Attach Successful


Download SCF
    [Documentation]    ... Downloading SCF
    [Arguments]    ${path}
    ${timestamp}    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S
    ${filename}    SET VARIABLE    ${path}${timestamp}_scf.xml
    CoamAdmin.get_current_scf_file    connection=oam    file_name=${filename}    timeout=60    local_dir_path=${path}
    OperatingSystem.File Should Exist    ${filename}
    Log To Console    \n--SCF Downloaded--
    Log To Console    --SCF file name is ${filename}--\n
    [Return]    ${filename}

Collect Snapshot
    ${snapshot_file_path}    set variable    ${out}Snapshot.zip
    CoamAdmin.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    timeout=300
    ...    connection=oam
    Log To Console    Snapshot collected and saved on path ${snapshot_file_path}


Get TcpdumpLogs from Remote machine
    [Documentation]    this keyword is used to capture wireshark log in wireshark PC
    [Arguments]    ${host_ip}    ${connection}
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...    name=${connection}
    ...    options=-i any
    ...    executor=${executor_oam_vm}
    core.setup_collectors    names=${connection}
    core.set_suite_alias    ${connection}
    core.start_collectors    names=${connection}

stop tcpdumplogs
    [Arguments]    ${connection}
    core.stop_collectors    names=${connection}
    core.collect_collectors    names=${connection}
    core.teardown_collectors    names=${connection}


Convert pcap file
    [Arguments]    ${filter1}    ${connection}
    ${command}=    set variable    tshark -r ${out}${connection}/${connection}.pcap -Y "${filter1}" > ${out}${connection}/${connection}.txt
    Run     ${command}
    sleep    120s
    ${filepath}    set variable    ${out}${connection}/${connection}.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    [Return]    ${file}

Multiple Attach ue and run throughput
    [Arguments]     ${UE_alias}    ${dt_name}    ${direction}    ${throughput}    ${deviation}    ${timeout}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Sleep    60
	log   ${dt_name}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep    60
    Log To Console    UE Attach Successful
    ta_ultracaller.start_datatransfer  ${UE_alias}    "TCP"    direction=${direction}
    ta_ultracaller.start data traffic    ${UE_alias_1}    call_type=${call_type_1}
	...    direction=${direction_dl}  throughput=${throughput_dl}  deviation=${deviation_dl}   timeout=${timeout}
    @{datauealias1}    create list    ${UE_alias[0]}
    @{datauealias2}    create list    ${UE_alias[1]}
    ta_ultracaller.start_datatransfer  ${datauealias1}    ${CALL_type}    direction=${direction}
    ta_ultracaller.start_datatransfer  ${datauealias2}    ${CALL_type}    direction=${direction}
    sleep    120
    ta_ultracaller.start_datatransfer  ${UE_alias}    ${CALL_type}    direction=${direction}
    sleep    30
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
    Log To Console    UE Data Transfer Successful
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    20
    Run Keyword And Continue On Failure  ta_ultracaller.calculate_thrughtput    ue_alias=${datauealias}
	...    direction=${direction}   thrughtput=${throughput}    deviation=${deviation}

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

validate wireshark logs
    [Documentation]    this keyword is used to validate wireshark logs
    [Arguments]    ${logfile}    ${message}
    @{log}    Split to lines    ${logfile}
    FOR    ${a}    IN    @{log}
        ${status}    run keyword and return status    should contain    ${a}    ${message}
        run keyword if    '''${status}'''=='''True'''    exit for loop
    END
    Run Keyword if    '''${status}'''=='''True'''    Log to console    ${message} message is found in wireshark log
    ...    ELSE    Log to console     ${message} message is not found in wireshark log
    Run Keyword if    '''${status}'''!='''True'''    fail

Get_value_of_Counter
    [Arguments]    ${Counter_value}
    FOR    ${a}    IN    @{Counter_value}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}

Start_Volte_Call_using_adb_command
    [Arguments]    ${UE_alias}    ${capabilities}    ${ADB_cmd_Start_Voice_Call}
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${ADB_cmd_Start_Voice_Call}
    Log To Console    \n--Voice Call Started--\n
    sleep   30

Stop_Volte_Call_using_adb_command
    [Arguments]    ${UE_alias}    ${capabilities}    ${ADB_cmd_Stop_Voice_Call}
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${ADB_cmd_Stop_Voice_Call}
    Log To Console    \n--Voice Call Stopped--\n
    sleep   30


Start_And_Stop_Volte_Call_using_adb_command
    [Arguments]    ${UE_alias}    ${capabilities}    ${ADB_cmd_Start_Voice_Call}    ${ADB_cmd_Stop_Voice_Call}
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${ADB_cmd_Start_Voice_Call}
    Log To Console    \n--Voice Call Started--\n
    sleep   30
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${ADB_cmd_Stop_Voice_Call}
    Log To Console    \n--Voice Call Stopped--\n

rename file
    [Arguments]    ${path}    ${old_filename}    ${new_filename}
    ${command}    set variable    mv ${path}${old_filename} ${path}${new_filename}
    Run     ${command}

Site_reset
    [Documentation]  ... Doing Site Reset
    CoamAdmin.reset_site    timeout=300    connection=oam    wait_for_reconnection=True    detailed_output=False
    log to console    .....--Site Reset Completed--.....

Lock_Cell_precondition
    [Documentation]  ... Locking_source_cells
    CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-0    timeout=60    connection=oam
    sleep    30s
    CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-1    timeout=60    connection=oam
    sleep    30s
    CoamAdmin.lock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-1    timeout=60    connection=oam
    sleep    30s
    CoamAdmin.unlock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-0    timeout=60    connection=oam
    sleep    30s
    CoamAdmin.unlock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-2    timeout=60    connection=oam
    sleep    30s
    log to console    ----All other cells are locked----

Unlock_Cell_postcondition
    [Documentation]  ... unlocking_source_cells
    CoamAdmin.unlock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-0    timeout=60    connection=oam
    sleep    30s
    CoamAdmin.unlock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-1    timeout=60    connection=oam
    sleep    30s
    CoamAdmin.unlock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-1    timeout=60    connection=oam
    sleep    30s
    CoamAdmin.unlock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-0    timeout=60    connection=oam
    sleep    30s
    CoamAdmin.unlock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-2    timeout=60    connection=oam
    sleep    30s
    log to console    ----All other cells are unlocked----


TearDown_all_alias
    log to console    ---Close All Alias for admin---

Get_Pre_Active_alarms
    [Documentation]    Active Alarms
    ${Pre_Active_Alarm}    Coamadmin.get_active_alarms    timeout=10    connection=oam

Get_Post_Active_alarms
    [Documentation]    Active Alarms
    ${Post_Active_Alarm}   Coamadmin.get_active_alarms    timeout=10    connection=oam

Get Date
    [Documentation]     Get date to create testcase folder
    ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}
