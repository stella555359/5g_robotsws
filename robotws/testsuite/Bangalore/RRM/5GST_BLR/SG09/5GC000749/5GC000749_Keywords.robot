*** Settings ***
Documentation
...   author: Ajay K Sofat
...   contact: ajay.k.sofat@nokia.com
...   Description: keywords for 5GC000749
Library    Process
Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    seleLib
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.transport.ssh    WITH NAME    ssh
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library    testsuite/Bangalore/RRM/5GST_BLR/SG09/5GC000749/5GC000749_EMIL.py
Library    testsuite/Bangalore/RRM/5GST_BLR/SG09/5GC000749/5GC000749_pva.py
Library    taf.sw.scout    WITH NAME    scout


*** Keywords ***
Admin Setup
    Log To Console    \n--- Connecting to BTS ---\n
    log to console    ${CURDIR}
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console    \n--- BTS is Connected ---\n
    Check BTS is OnAir
    ${opt}    set variable    ${OUTPUT_DIR}/5GC000749/
    set test variable    ${opt}
    create directory     ${opt}
    Log to console   \n--- Starting Syslogs Logs --- \n
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
    Log to Console    \n --- Syslogs started, Alarms watchdog started --- \n
    Create dcap session
	Set Environment Variable    ABSTRACT_LIB_CONFIG    ../../../testline_configuration/7_2_UTE5GCLOUD1042/ta_ue_config.yaml
    Prepare UE    UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}

Admin Teardown
    stop watching alarms
    interface.Common step trigger
    Download SCF
    Collect Snapshot
    Log to console   \n--- Stoping Syslogs Logs --- \n
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog    target_dir=${opt}
    core.teardown_collectors      names=btslog
	Link SCOUT SCF to Configuration ID for Reporting
    CoamAdmin.teardown    oam
    Log To Console    \n--- BTS is Disconnected --- \n
	

Precondition_5GC000749_VoNR_Disable
    ${scf_path}    Download SCF
    set global variable    ${scf_path}
    SCF commissioning and check ONAIR    ${scf_VoNR_disabled}
	log to console		\n------ Attenuate NRcell 0 and NRcell 1 to maximum ------------\n
	5GC000749_pva.PVA_Attenuate_Max_NR_Cell_0		${pva_ip}
	5GC000749_pva.PVA_Attenuate_Max_NR_Cell_1		${pva_ip}


Precondition_VoNR_Enable
    ${scf_path}    Download SCF
    set global variable    ${scf_path}
    SCF commissioning and check ONAIR    ${scf_VoNR_Enable}
	log to console		\n------ Attenuate NRcell 0 and NRcell 1 to maximum ------------\n
	5GC000749_pva.PVA_Attenuate_Max_NR_Cell_0		${pva_ip}
	5GC000749_pva.PVA_Attenuate_Max_NR_Cell_1		${pva_ip}

Enable feature
    [Documentation]    ... Enabling 5GC000749 feature
	CoamAdmin.perform_parameter_recommissioning
    ...    connection=oam
    ...    dist_name=MRBTS-1402/NRBTS-1402    
    ...    parameter=actNormVCFallback   
    ...    operation=update    
    ...    value=true
    ...    should_activate=true    
    ...    timeout=100
    Log To Console    \n---- 5GC000749 Feature has been Enabled ----\n

5GC000749_Feature_Disabled_And_PDUModificationRequest_5QI1
    [Tags]    Split_A    VoNR_Disable
    [Arguments]    ${dcap_file_name}
	5GC000749_pva.PVA_Attenuate_Max_NR_Cell_2    ${pva_ip}
    5GC000749_pva.PVA_Attenuate_Min_NR_Cell_2    ${pva_ip}
    ${out}    set variable
    ...    ${OUTPUT_DIR}/5GC000749/5GC000749_Feature_Disabled_And_PDUModificationRequest_5QI1/
    set test variable    ${out}
    create directory     ${out}
    Log to console    \n --- Verifying gNB behavior when 5GC000749 is disabled and PDU Modification  Request from AMF contains 5QI1 --- \n
    Log to Console    \n --- Logging DCAP Server --- \n
    Dcap Start Trace SA
	Detach and Attach UE	 UE_alias=${UE_alias}
    Volte_Call_using_adb_command
    5GC000749_pva.PVA_Attenuate_Max_NR_Cell_2    ${pva_ip}
    Stop_Volte_Call_using_adb_command
    Dcap Stop Trace and Get results SA    ${dcap_file_name}

Reboot_UE_using_adb_command
    Log To Console    \n--Volte Call started--\n
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${reboot_UE}
    sleep   100

Volte_Call_using_adb_command
    Log To Console    \n--Volte Call started--\n
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${adb_cmd_voice_call}
    sleep   10

Stop_Volte_Call_using_adb_command 
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${adb_cmd_stop_call}
    Log To Console    \n--Volte call stopped--\n

5GC000749_Feature_Enabled_And_PDUModificationRequest_5QI1
    [Tags]    Split_A    VoNR_Disable
    [Arguments]    ${dcap_file_name}
	5GC000749_pva.PVA_Attenuate_Max_NR_Cell_2    ${pva_ip}
    5GC000749_pva.PVA_Attenuate_Min_NR_Cell_2    ${pva_ip}
    ${out}    set variable
    ...    ${OUTPUT_DIR}/5GC000749/5GC000749_Feature_Enabled_And_PDUModificationRequest_5QI1/
    set test variable    ${out}
    create directory     ${out}
    Log to console    \n --- Verifying gNB behavior when 5GC000749 is enabled and PDU Modification  Request from AMF contains 5QI1 --- \n
    Log to Console    \n --- Logging DCAP Server --- \n
    Dcap Start Trace SA
	Detach and Attach UE	 UE_alias=${UE_alias}
    Volte_Call_using_adb_command
    5GC000749_pva.PVA_Attenuate_Max_NR_Cell_2    ${pva_ip}
    Stop_Volte_Call_using_adb_command
    Dcap Stop Trace and Get results SA    ${dcap_file_name}


Create dcap session
    [Documentation]    Establish DCAP session
	Start DCAP Containers
    Log to Console    \n--- Starting DCAP Session --- \n 
    rd.connect_to    host=${DCAP_host}    port=${port}    rd_version=${rd_version}    secure=${secure}

Start DCAP Containers
    Log to Console    \n--- Starting DCAPlite containers --- \n 
    ${result}=         Run Process     /dcap_basic_config/hotfix/DCAP_Basic_controller.sh         start
	sleep     60
    Log to console     ${result.stdout}
	
Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}    gnb_custom_profile=@{gnb_custom_filters}
    ...     wait_for_activation=True      collection_timing=@{collection_timing}
    Sleep       120      reason=Wait for DCAP start
    ${START_TRACE_ID}=      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG to console     \n --- DCAP log collection has been started in the gNB --- \n

Dcap Stop Trace and Get results SA
    [Arguments]    ${testcase_name}
    [Documentation]     Stops DCAP and collect logs
    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=100
    sleep    1min
    LOG to console    \n --- DCAP logging stopped --- \n
    create directory         ${out}${testcase_name}
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${out}${testcase_name}/DCAP_logs    timeout=${dcap_log_timeout}

SCF commissioning and check ONAIR
    [Documentation]  ... Commissiioning BTS and checking BTS status
	[Arguments]    ${scf}    ${DUR}=${DURATION}
	Log to console    \n--- BTS commissioning is Ongoing with 5GC000749 Disabed --- \n
	${status}=    CoamAdmin.perform_commissioning    scf_file=${scf}    timeout=${DUR}    connection=oam
	Sleep    5min
    Check BTS is OnAir
	Log to console    \n--- BTS commissioning is completed with 5GC000749 Disabed --- \n

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    [Arguments]  ${connection}=oam
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \n--- BTS procedural state is now: ${bts_status["proceduralState"]}${\n}
    ...    ELSE    fail

EMIL_Log_Validation
    [Arguments]    ${OUTPUT}    ${message}    ${testcase_name}
    Convert Emil File To Csv    ${testcase_name}
    ${result}		Parse_Emil_Csv_File_For_Message_content 	 ${OUTPUT}/${testcase_name}/    ${message}
    log to console    ${result}
    run keyword if    ${result} != True
    ...    log to console    Either Msg and IE's are not present or Messages are not in order
    ...    ELSE    log to console    Messages and IE's are present and they are in order
    run keyword if    ${result} != True    Fail

EMIL_Log_Validation_msg_notpresent
    [Arguments]    ${OUTPUT}    ${message}    ${testcase_name}
    ${result}           Parse_Emil_Csv_File_For_Message_content          ${OUTPUT}/${testcase_name}/    ${message}
    log to console    ${result}
    run keyword if    ${result} == True
    ...    log to console    \n --- ${message} is present when feature is disabled --- \n
    ...    ELSE    log to console    \n --- ${message} is not present when 5GC000749 feature is disabled --- \n
    run keyword if    ${result} == True    Fail


Validating_counters_for_feature_disable
    Log to console    \n --- Validating Counters with 5GC000749 Disabled --- \n
    sleep    5min
    ${c1}    Counter_Validation11    M55125C03501    1    NNGCC_PDUSESMODREQ_RECD
	set test variable    ${c1}
    ${c2}    Counter_Validation11    M55125C03503    1    NNGCC_PDUSESMODRSP_FAIL_SENT
	set test variable    ${c2}
    ${c3}    Counter_Validation11    M55125C09517    1    NG_FLOW_SETUP_ATT_TOT_5QI1
	set test variable    ${c3}
    ${c3}    Counter_Validation11    M55125C09519    0    NG_FLOW_STP_FAIL_FALBACK_5QI1
    set test variable    ${c4}
    Log to Console    \n --- Counters have been validated with 5GC000749 disabled and they are inline with expectations --- \n
	
Validating_counters_for_feature_enable
    Log to console    \n --- Validating Counters with 5GC000749 Enabled --- \
    sleep    5min
    Counter_Validation1    M55125C03501    ${c1}    1    NNGCC_PDUSESMODREQ_RECD
    Counter_Validation1    M55125C03503    ${c2}    1    NNGCC_PDUSESMODRSP_FAIL_SENT
    Counter_Validation1    M55125C09517    ${c3}    1    NG_FLOW_SETUP_ATT_TOT_5QI
    Counter_Validation1    M55125C09519    ${c4}    1    NG_FLOW_STP_FAIL_FALBACK_5QI1
    Counter_Validation2    M55124C02501    1    NRRCC_RRC_RELEASE_REDIR_LTE
    Counter_Validation2    M55124C02501    1    NR_RRC_RELEASE_REDIR_VFB_LTE
    Log to Console    \n --- Counters have been validated with 5GC000749 enabled and they are inline with expectations --- \n

Counter_Validation1
    [Arguments]    ${counter}    ${previous_occurence}    ${present_occurence}    ${name}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-2']['NNGCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
	${total}    Evaluate    ${Total_Count} - ${previous_occurence}
    Log to Console    ${name} -> ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    ${total}!=${present_occurence}
    ...    log to console    ${name} -> ${counter} counter is getting pegged ${total} times where it shouled be greater than ${present_occurence}
    Run Keyword if    ${total}!=${present_occurence}    fail
    [Return]    ${total}

Counter_Validation11
    [Arguments]    ${counter}    ${occurence}    ${name}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-2']['NNGCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${name} -> ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    ${Total_Count}!=${occurence}
    ...    log to console    ${name} -> ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if    ${Total_Count}!=${occurence}    fail
    [Return]    ${Total_Count}

Counter_Validation2
    [Arguments]    ${counter}    ${occurence}    ${name}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-2']['NRRCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${name} -> ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    ${Total_Count}!=${occurence}
    ...    log to console    ${name} -> ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg greater than ${occurence}
    Run Keyword if    ${Total_Count}!=${occurence}    fail
    [Return]    ${Total_Count}

Counter validation22
    [Arguments]    ${counter}    ${occurence}    ${name}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1402']['NRBTS-1402']['NRCELL-2']['NRRCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${name} -> ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    ${Total_Count}!=${occurence}
    ...    log to console    ${name} -> ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg greater than ${occurence}
    Run Keyword if    ${Total_Count}!=${occurence}    fail
    [Return]    ${Total_Count}

Get_value_of_Counter
    [Arguments]    ${Counter_value}
    FOR    ${a}    IN    @{Counter_value}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}


Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}    ${timeout}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log	  ${a}

Attach ue and run throughput
    [Arguments]     ${UE_alias}    ${dt_name}    ${direction}    ${throughput}    ${deviation}    ${timeout}
    ta_ultracaller.DetachUE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep     10
    Log To Console    UE Attach Successful
    ta_ultracaller.start_datatransfer  ${UE_alias}  ${dt_name}  direction=${direction}
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
    Log To Console    UE Data Transfer Successful
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    20
    ${tput}    Run Keyword And Continue On Failure  ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction}   thrughtput=${throughput}    deviation=${deviation}
    log to console    Throughput is ${tput}


SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

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


Convert Emil File To Csv
    [Arguments]    ${testcase_name}
    [Documentation]        Convert Emil logs collected from DCAP
    Log to Console    \n --- Conversion of EMIL Started --- \n
    ${path1}     Set Variable        ${out}${testcase_name}/
    ${extracted_path}    Set Variable        ${path1}Extracted/
    create directory         ${extracted_path}
	${date}    Get Current Date    result_format=%Y%m%d
    ${files}    OperatingSystem.List Files In Directory    ${path1}
	Log to console    \n --- Starting to Unzip DCAP log files --- \n
	FOR    ${zip}    IN    @{files}
		${flag}=		File Should Have Extension		${path1}${zip}		zip
		Start Process		unzip    -q    ${path1}${zip}    -d    ${extracted_path}
		sleep     5
	END
	Log to console    \n --- Unzipping is Completed --- \n
	${it}=    OperatingSystem.List Directory    ${extracted_path}/${date}
    ssh.Connect_to    ${MCG_IP}    ${MCG_usn}    ${MCG_pwd}    alias=mcg_vm
    sleep    10s
    FOR    ${out_index}    IN    @{it}
		Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${extracted_path}/${date}
        ...     source_file=${out_index}/5g/controlPlane    testcase_name=${testcase_name}
    END
    ${output}		ssh.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm		timeout=30s

Start Emil To Convert Emil File To Csv
    [Arguments]    ${source_path}     ${source_file}    ${testcase_name}
    [Documentation]         Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}=    OperatingSystem.List Directory    ${source_path}/${source_file}
	ssh.upload_file    local_path=${source_path}/${source_file}/${source_emil_file}[0]    remote_path=${uepc_Log_path}//${source_emil_file}[0]
    ...     connection=mcg_vm
    ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f      connection=mcg_vm		timeout=30s
    ${cyg_cmd}    Set Variable      cygstart PsExec -u "${MCG_domain}\\${MCG_usn}" -p "${MCG_pwd}" -d -i 2
    ${src_file}     Set Variable        ${uepc_Log_path}//${source_emil_file}[0]
	${run_command}    Set Variable
    ...     ${cyg_cmd} "${emil_path}\\Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile_path}"
	LOG	${run_command}
	${output}		ssh.Execute    command=${run_command}      connection=mcg_vm		timeout=30s
	LOG		${output}
	${result}=    Wait Until Keyword Succeeds    4min    1s    Check Number Of Processes Running    process_name=Emil.exe    number_of_processes=1
	${result}=    Wait Until Keyword Succeeds    4min    1s    Check Number Of Processes Running    process_name=Emil.exe    number_of_processes=0
	${csvfile}=    String.Replace String    string=${source_emil_file}[0]    search_for=.5gm    replace_with=.csv
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

    [Arguments]    ${node_id}=${0}    ${node_type}=gnb    ${tl_name_only}=7_2_UTE5GCLOUD1042
	
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


Detach and Attach UE
    [Arguments]     ${UE_alias}    
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep     5
    Log To Console    UE Attach Successful

Set_export_yml
   [Arguments]    ${yml_filepath}
   SSHLibrary.Open Connection    host=${VM_IP}
   SSHLibrary.Login    ute    password=ute    delay=10
   SSHLibrary.write    ${yml_filepath}
   SSHLibrary.Close All Connections
   
File Should Have Extension
    [Arguments]    ${FILE_PATH}    ${EXTENSION}
	${filename}		${ext}		Split Extension 		${FILE_PATH}
	log to console		${ext}
	[Return]		${ext}
