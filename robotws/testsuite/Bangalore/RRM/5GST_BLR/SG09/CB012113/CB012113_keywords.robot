*** Settings ***
Documentation
...   author: Lekhashree S N
Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.selenium.sbts    WITH NAME    seleLib
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    pva.py
Library    ../../../../ORAN/resources/python/ta_ultracaller/
Library    taf.fdsw.rc     WITH NAME    rc
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.transport.ssh    WITH NAME    ssh
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library    taf.sw.scout    WITH NAME    scout
Library    Process
Library    CB012113_EMIL.py


*** Variables ***
${j}    0
${i}    0
${E}    0
${DCAP_host}                10.58.239.215                                               			# DCAP server IP 10.58.238.126
${port}                     443                                                         			# Port value for DCAP connection
${secure}                   True                                                        			# Secure value for DCAP connection
${rd_version}               dcapv3                                                      			# DCAP version
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${emil_path}                C:\\Emil                                                    			# Emil path in UE PC machine
${emil_profile_path}        ${emil_path}\\profiles\\5G                                  			# Emil profile path in UE PC machine
${Default_DCAP_duration}    12                                                           			# DCAP log duration
${dcap_log_timeout}         1200                                                        			# Timeout for DCAP log collection
&{BTS_INFO}                 host=${mplane_ip}	port=443    username=Nemuadmin    password=nemuuser       			# BTS details
@{gnb_custom_filters}       cp_5g         			# gnb custom filters for DCAP
@{bts_custom_filter}        immediateSnapshot    scf    ipCapture                       			# BTS custom filters for DCAP
@{collection_timing}        Immediate       TraceEnd                                    			# Snapshot collet option for DCAP
${VM_IP}    10.58.238.143
${VM_usn}    ute
${VM_pwd}    BT5l@bus3rl0g1n
${mplane_ip}    10.58.239.200
${MCG_IP}    10.45.150.205
${MCG_usn}    inbabtslabuser
${MCG_pwd}    BT5l@bus3rl0g1n
${MCG_domain}      NOKLAB
${emil}    C:\\Emil\\Emil.exe
${profile}    C:\\Emil\\profiles\\5G
${DURATION}    800s
${dt_name_dl}=    iperf_dl_test_1
${dl_name}=    iperf_dl_test_1
@{deviation_dl}=    100
@{throughput_dl}=    1000
@{direction_dl}=      dl
@{CALL_type}    TDP
${k}    0
${name}
${dt_name_v}    test_voice_call
@{adb_cmd_stop_call}    adb -s bc05f4ef shell input keyevent 6    adb -s 6266dd71 shell input keyevent 6
@{adb_cmd_voice_call}    adb -s bc05f4e7 shell am start -a android.intent.action.CALL -d tel:+123456
${ABSTRACT_LIB_CONFIG}
${dcapusr}    utfuser
${dcappwd}    utfadmin!
${timeout}    100

*** Keywords ***
Admin_setup
    Log To Console    connecting to BTS
    CoamAdmin.Teardown All Aliases For Admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console    BTS is Connected
    ${opt}    set variable    ${OUTPUT_DIR}/CB012113/
    set test variable    ${opt}
    create directory     ${opt}
    ${scf_path}    Download SCF
    set global variable    ${scf_path}
    Check BTS is OnAir
    Log to console   \n--Starting Syslogs Logs--
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
    core.set_suite_alias	btslog
    core.start_collectors      names=btslog
    ${allowed_alarms}=    Expected_alarm
    Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=oam
    Create dcap session
    Set Environment Variable    ABSTRACT_LIB_CONFIG    /home/ute/testline_configuration/7_2_UTE5GCLOUD1042/ta_ue_config.yaml
    Set_export_yml		${ABSTRACT_LIB_CONFIG}

Admin_teardown
    stop watching alarms
    #stopping syslogs
    interface.Common step trigger
    Download SCF
    Collect Snapshot
    SCF commissioning and check ONAIR    ${scf_path}
    Log to console   --Stoping Syslogs Logs--
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog    target_dir=${opt}
    core.teardown_collectors      names=btslog
    CoamAdmin.teardown    oam
    Log To Console    BTS IS Disconnected


Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${port}    rd_version=${rd_version}    secure=${secure}    username=${dcapusr}    password=${dcappwd}

Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    &{BTS_INFO}=    create dictionary   host=${mplane_ip}     port=${port}    username=Nemuadmin    password=nemuuser
    @{gnb_custom_filters}    Create List     cp_5g
    @{bts_custom_filter}     Create List     immediateSnapshot    scf    ipCapture    condor5gSyslog
    @{collection_timing}     Create List     Immediate       TraceEnd
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}    gnb_custom_profile=@{gnb_custom_filters}
    ...     wait_for_activation=True      collection_timing=@{collection_timing}
    Sleep       150      reason=Wait for DCAP start
    ${START_TRACE_ID}=      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG to console     DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Arguments]    ${testcase_name}
    [Documentation]     Stops DCAP and collect logs
    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=100
    LOG to console    DCAP logging stopped
    create directory         ${out}${testcase_name}/DCAP_logs
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${out}${testcase_name}/DCAP_logs    timeout=${dcap_log_timeout}

SCF commissioning and check ONAIR
    [Documentation]  ... Commissiioning BTS and checking BTS status
	[Arguments]    ${scf}    ${DUR}=${DURATION}
	Log to console    BTS commissioning is Ongoing
	CoamAdmin.perform_commissioning    scf_file=${scf}    timeout=${DUR}    connection=oam
    Wait Until Keyword Succeeds    5min    20s    Check BTS is OnAir

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    [Arguments]  ${connection}=oam
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    BTS procedural state is now: ${bts_status["proceduralState"]}${\n}
    ...    ELSE    fail

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log	  ${a}
    Log To Console    UE preparation completed

Volte_Call_using_adb_command
    Log To Console    --Volte Call started--
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    ta_ultracaller._run_adbcommand    ${UE_alias}    ${adb_cmd_voice_call}
    sleep    30

Stop_Volte_Call_using_adb_command
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller._run_adbcommand    ${UE_alias}    ${adb_cmd_stop_call}
    Log To Console    --Volte call stopped--

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection
	log    ssh teardown

EMIl log validation to check priority in RRC Release for given frequency
    [Arguments]    ${frequency}    ${priority}    ${testcase_name}
    Convert Emil File To Csv    ${testcase_name}
    ${result}		Parse_Emil_Csv_File_For_Message 	 ${out}/
	...		rrcRelease:carrierFreq ${frequency},cellReselectionPriority ${priority}
	run keyword if    "${result}" != "True"
    ...    log to console    Either ${frequency} frequency is not present or this frequency is not have priority ${priority}
    ...    ELSE    log to console    ${frequency} frequency is present and this frequency is having priority ${priority}
    Run keyword And Continue On Failure		Should Be True		${result}

EMIl log validation for CNI
    [Arguments]    ${testcase_name}
    Convert Emil File To Csv    ${testcase_name}
    ${result}		Parse_Emil_Csv_File_For_Message_content_required_not_required 	 ${out}/
    ...    ueCapabilityEnquiry    rat-Type nr,    rat-Type eutra
    ${result1}		Parse_Emil_Csv_File_For_Message_content_required_not_required 	 ${out}/
    ...    ueCapabilityEnquiry    rat-Type nr,.rat-Type eutra.rat-Type eutra-nr,
    ${result2}		Parse_Emil_Csv_File_For_Message_content_required_not_required 	 ${out}/
    ...    InitialContextSetupResponse
    ${status}    compare_values    ${result}    ${result1}    ${result2}
    Run Keyword If    "${status}" == "True"    Log to console    CNI-98693 validation is done and its passed
    ...    ELSE    log to console    CNI-98693 validation is done and its failed
    Run Keyword And Continue On Failure    Should Be Equal    ${status}    ${True}

Download SCF
    [Documentation]    ... Downloading SCF
    ${timestamp}    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S
    ${filename}    SET VARIABLE    ${opt}${timestamp}_scf.xml
    CoamAdmin.get_current_scf_file    connection=oam    file_name=${filename}    timeout=60    local_dir_path=${opt}
    OperatingSystem.File Should Exist    ${filename}
    Log To Console    SCF Downloaded
    Log To Console    SCF file name is ${filename}
    [Return]    ${filename}

Collect Snapshot
    ${snapshot_file_path}    set variable    ${opt}Snapshot.zip
    CoamAdmin.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    timeout=300
    ...    connection=oam
    Log To Console    Snapshot collected and saved on path ${snapshot_file_path}

Validating_counters_for_feature_disable
    Log to console    --- Validating Counters with CB012113 Disabled ---
    sleep    5min
    ${c1}    Counter_Validation11    M55125C02501    1    NNGCC_UE_CTXT_STP_REQ_RECD
    set test variable    ${c1}
    ${c2}    Counter_Validation11    M55125C02503    1    NNGCC_UE_CTXT_STP_FAIL_SENT
    set test variable    ${c2}
    ${c3}    Counter_Validation11    M55125C02502    0    NNGCC_UE_CTXT_STP_RESP_SENT
    set test variable    ${c3}
    ${c4}    Counter_Validation22    M55124C02501    1    NR_RRC_RELEASE_REDIR_VFB_LTE
    set test variable    ${c4}
    Log to Console    --- Counters have been validated with CB012113 disabled and they are inline with expectations ---

Validating_counters_for_feature_enable
    Log to console    --- Validating Counters with CB012113 Enabled ---
    sleep    5min
    Counter_Validation1    M55125C02501    ${c1}    1    NNGCC_UE_CTXT_STP_REQ_RECD
    Counter_Validation1    M55125C02503    ${c2}    0    NNGCC_UE_CTXT_STP_FAIL_SENT
    Counter_Validation1    M55125C02502    ${c3}    1    NNGCC_UE_CTXT_STP_RESP_SENT
    Counter_Validation2    M55124C02501    ${c4}    1    NR_RRC_RELEASE_REDIR_VFB_LTE
    Log to Console    --- Counters have been validated with CB012113 enabled and they are inline with expectations ---

Counter_Validation1
    [Arguments]    ${counter}    ${previous_occurence}    ${present_occurence}    ${name}
    ${result}=    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-1']['NNGCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    ${total}    Evaluate    ${Total_Count} - ${previous_occurence}
    Log to Console    ${name} -> ${counter} counter is pegging : ${total} times
    Run Keyword if    '${total}'!='${present_occurence}'
    ...    log to console    ${name} -> ${counter} counter is getting pegged ${total} times where it suppose to peg greater than ${present_occurence}
    Run Keyword if    '${total}'!='${present_occurence}'    fail
    [Return]    ${Total}

Counter_Validation11
    [Arguments]    ${counter}    ${occurence}    ${name}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-1']['NNGCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${name} -> ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'!='${occurence}'
    ...    log to console    ${name} -> ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if    '${Total_Count}'!='${occurence}'    fail
    [Return]    ${Total_Count}

Counter validation2
    [Arguments]    ${counter}    ${previous_occurence}    ${present_occurence}    ${name}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-1']['NRRCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    ${total}    Evaluate    ${Total_Count} - ${previous_occurence}
    Log to Console    ${name} -> ${counter} counter is pegging : ${total} times
    Run Keyword if    '${total}'!='${present_occurence}'
    ...    log to console    ${name} -> ${counter} counter is getting pegged ${total} times where it suppose to peg greater than ${present_occurence}
    Run Keyword if    '${total}'!='${present_occurence}'    fail
    [Return]    ${Total}

Counter validation22
    [Arguments]    ${counter}    ${occurence}    ${name}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-1']['NRRCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${name} -> ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'!='${occurence}'
    ...    log to console    ${name} -> ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg greater than ${occurence}
    Run Keyword if    '${Total_Count}'!='${occurence}'    fail
    [Return]    ${Total_Count}

Counter
	[Arguments]    ${counter}
	${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
	log to console    ${result}

Get_value_of_Counter
    [Arguments]    ${Counter_value}
    FOR    ${a}    IN    @{Counter_value}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}

rename file
    [Arguments]    ${src_path}    ${old_filename}    ${tar_path}    ${new_filename}
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    ${command}    set variable    mv ${src_path}${old_filename} ${tar_path}${new_filename}
    SSHLibrary.write    ${command}
    SSH_teardown

EMIL_Log_Validation
    [Arguments]    ${OUTPUT}    ${message}    ${testcase_name}
    Convert Emil File To Csv    ${testcase_name}
    ${result}		Parse_Emil_Csv_File_For_Message_content 	 ${OUTPUT}/${testcase_name}/    ${message}
    run keyword if    "${result}" != "True"
    ...    log to console    Either Msg and IE's are not present or Messages are not in order
    ...    ELSE    log to console    Messages and IE's are present and its in order
    run keyword if    "${result}" != "True"    Fail

EMIL_Log_Validation_msg_notpresent
    [Arguments]    ${OUTPUT}    ${message}    ${testcase_name}
    ${result}		Parse_Emil_Csv_File_For_Message_content 	 ${OUTPUT}/${testcase_name}/    ${message}
    run keyword if    "${result}" == "True"
    ...    log to console    --- ${message} is present when feature is disabled ---
    ...    ELSE    log to console    --- ${message} is not present which signifies NAS PDU isn't forwarded to UE when CB012113 feature is disabled ---
    run keyword if    "${result}" == "True"    Fail

Convert Emil File To Csv
    [Arguments]    ${testcase_name}
    [Documentation]        Convert Emil logs collected from DCAP
    Log to Console     --- Conversion of EMIL Started ---
    ${path1}     Set Variable        ${out}${testcase_name}/DCAP_logs/
    ${extracted_path}    Set Variable        ${path1}Extracted/
    create directory         ${extracted_path}
	${date}    Get Current Date    result_format=%Y%m%d
    ${files}    OperatingSystem.List Files In Directory    ${path1}
	Log to console    --- Starting to Unzip DCAP log files ---
	FOR    ${zip}    IN    @{files}
		File Should Have Extension		${path1}${zip}
		Start Process		unzip    -q    ${path1}${zip}    -d    ${extracted_path}
		sleep     5
	END
	Log to console    --- Unzipping is Completed ---
	${it}=    OperatingSystem.List Directory    ${extracted_path}/${date}
    ssh.Connect_to    ${MCG_IP}    ${MCG_usn}    ${MCG_pwd}    alias=mcg_vm
    sleep    10s
    FOR    ${out_index}    IN    @{it}
		Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${extracted_path}/${date}
        ...     source_file=${out_index}    testcase_name=${testcase_name}
    END
    ssh.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm		timeout=30s

File Should Have Extension
    [Arguments]    ${FILE_PATH}
	${ext}		Split Extension 		${FILE_PATH}
	log to console		${ext}
	[Return]		${ext}

Start Emil To Convert Emil File To Csv
    [Arguments]    ${source_path}     ${source_file}    ${testcase_name}
    [Documentation]         Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}=    OperatingSystem.List Directory    ${source_path}/${source_file}
	FOR    ${i}    ${a}    IN ENUMERATE   @{source_emil_file}
		${status}=    Run Keyword And Ignore Error    should contain    ${a}    .5gm
		${int}    run keyword if    '${status}[0]'=='PASS'    set variable    ${i}
		run keyword if    '${status}[0]'=='PASS'    exit for loop
	END
	${int}    Convert To Integer    ${int}
	ssh.upload_file    local_path=${source_path}/${source_file}/${source_emil_file}[${int}]
    ...    remote_path=${uepc_Log_path}//${source_emil_file}[${int}]
    ...     connection=mcg_vm
    ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f      connection=mcg_vm		timeout=30s
    ${cyg_cmd}    Set Variable      cygstart PsExec -u "${MCG_domain}\\${MCG_usn}" -p "${MCG_pwd}" -d -i 2
    ${src_file}     Set Variable        ${uepc_Log_path}//${source_emil_file}[${int}]
	${run_command}    Set Variable
    ...     ${cyg_cmd} "${emil_path}\\Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile_path}"
	LOG	${run_command}
	${output}		ssh.Execute    command=${run_command}      connection=mcg_vm		timeout=30s
	LOG		${output}
	Wait Until Keyword Succeeds    4min    1s    Check Number Of Processes Running    process_name=Emil.exe    number_of_processes=1
	Wait Until Keyword Succeeds    4min    1s    Check Number Of Processes Running    process_name=Emil.exe    number_of_processes=0
	${csvfile}=    String.Replace String    string=${source_emil_file}[${int}]    search_for=.5gm    replace_with=.csv
	ssh.download_file    remote_path=${uepc_Log_path}//${csvfile}		local_path=${out}${testcase_name}/${csvfile}     connection=mcg_vm

Check Number Of Processes Running
    [Arguments]    ${process_name}=Emil.exe    ${number_of_processes}=0
    [Documentation]     Check whether Emil process is running in MCG machine
    ${output}       ssh.Execute    echo -n NumberOfProcesess:&&ps -W | grep -cw ${process_name}       connection=mcg_vm
    Should Contain    ${output}    NumberOfProcesess:${number_of_processes}
    [Return]    ${output}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=    Wait Until Keyword Succeeds    4min    10s    scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_type}=gnb    ${tl_name_only}=7_2_UTE5GCLOUD1042
    Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Enable feature
    [Documentation]    ... Enabling CB012113 feature
	CoamAdmin.perform_parameter_recommissioning
    ...    connection=oam
    ...    dist_name=MRBTS-1402/NRBTS-1402
    ...    parameter=actNormVCFallbackEnh
    ...    operation=update
    ...    value=true
    ...    should_activate=true
    ...    timeout=90
    Log To Console    --- CB012113 Feature has been Enabled ---

Set_export_yml
	[Arguments]    ${yml_filepath}
	SSHLibrary.Open Connection    host=${VM_IP}
	SSHLibrary.Login    ute    password=BT5l@bus3rl0g1n    delay=10
	SSHLibrary.write    ${yml_filepath}
	SSHLibrary.Close All Connections
