*** Settings ***
Documentation
...   author: Mohan
...   contact: VRF_T11
...   Description: keywords for CB014844


Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    ute_fsmaccess
Library    taf.sw.scout    WITH NAME    scout
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.sbts.oam.coam.admin     WITH NAME    coam
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump   WITH NAME   tcpdump
Library    pva.py
Library    ta5g_pm_counters
Library    emillogwithseq.py
Library    testsuite/Bangalore/ORAN/resources/python/SysValidation.py  WITH NAME  Validation
Library    testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library             taf.hw.rf_attenuator    WITH NAME    at
Library    taf.fdsw.rc     WITH NAME    rc
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.transport.ssh    WITH NAME    ssh
Library    Process
Variables   ta5g_global_var
Resource    ../../../../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot

*** Variables ***
#${voice_call_TC}=    VONR_Server_Call
@{data_transfer_protocol}=    TCP
${j}    0
${i}    0
${E}    0
${DCAP_host}                10.58.239.215                                               			# DCAP server IP 10.58.238.126
${port}                     443                                                         			# Port value for DCAP connection
${secure}                   True                                                        			# Secure value for DCAP connection
${rd_version}               dcapv3                                                      			# DCAP version
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${emil_path}                C://Emil                                                    			# Emil path in UE PC machine
${emil_profile_path}        ${emil_path}//profiles//5G                                  			# Emil profile path in UE PC machine
${Default_DCAP_duration}    12                                                           			# DCAP log duration
${dcap_log_timeout}         1200                                                        			# Timeout for DCAP log collection
&{BTS_INFO}                 host=${mplane_ip}	port=443                        			# BTS details
@{gnb_custom_filters}       cp_5g    condor5gSyslog         			# gnb custom filters for DCAP
@{bts_custom_filter}        condor5gSyslog                #immediateSnapshot    scf    ipCapture         			# BTS custom filters for DCAP
@{collection_timing}        Immediate       TraceEnd                                    			# Snapshot collet option for DCAP
@{counter_values}
${msg1}    UEContextSetupRequest:-DRXCycle,longDRXCycleLength ms10
${msg2}    UEContextSetupResponse:-drx-Config setup,drx-onDurationTimer milliSeconds : ms10,drx-InactivityTimer ms100,drx-LongCycleStartOffset ms160
${dcapusr}    utfuser
${dcappwd}    utfadmin!
${int}
${attenuator_host}              10.53.164.219
${attenuator_port}              3001    # Attenuator Port
@{pva_ports}                    ${11}    ${12}    ${13}
@{port_values1}                  70dB    70dB    70dB
@{port_values2}                  0dB    0dB    0dB
${at_vendor}                    TOPYOUNG    # PVA vendor name
${at_model}                     TAS_16T16_0_2G6_90_1S_DEJS    # PVA model number
@{PATTERNS1}    ueContextId.*Number of DRBs to be released:.* hoType:EHandoverType_NoHandover
@{PATTERNS2}    ueContextId.*Trigger for InterRat handover received.* UEC_REPORT_CONFIG_QCIX_NR_SB_HO


*** Keywords ***
Set_export_yml
	[Arguments]    ${yml_filepath}
	ssh.Connect_to    ${VM_IP}    ${VM_usn}    ${VM_pwd}    alias=vm
	ssh.Execute     command=${yml_filepath}      connection=vm		timeout=30s
	ssh.Disconnect    connection=vm

Test Setup
    Log To Console    connecting to BTS
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console    BTS is Connected
    ${opt}    set variable    ${OUTPUT_DIR}/Pre/
    set test variable    ${opt}
    create directory     ${opt}
    ${scf_path}    Download SCF    ${opt}
    set global variable    ${scf_path}
    Check BTS is OnAir
    Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    Set_export_yml		${ABSTRACT_LIB_CONFIG}

start Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: “/tmp/btslog2”
    [Arguments]    ${log_alias}
    btslog.create_btslog_collector    ${log_alias}
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias}
    core.Set Suite Alias    ${log_alias}

Stops Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: “/tmp/btslog2”
    [Arguments]    ${log_alias}
    Run Keyword And Continue On Failure     core.stop_collectors      names=${log_alias}
    Run Keyword And Continue On Failure     core.collect_collectors      names=${log_alias}
    Run Keyword And Continue On Failure    core.teardown_collectors      names=${log_alias}

Download SCF
    [Documentation]    ... Downloading SCF
    [Arguments]    ${path}
    ${timestamp}    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S
    ${filename}    SET VARIABLE    ${path}${timestamp}_scf.xml
    CoamAdmin.get_current_scf_file    connection=oam    file_name=${filename}    timeout=60    local_dir_path=${path}
    OperatingSystem.File Should Exist    ${filename}
    Log To Console    SCF Downloaded
    Log To Console    SCF file name is ${filename}
    [Return]    ${filename}

Collect Snapshot
    [Arguments]    ${path}
    ${snapshot_file_path}    set variable    ${path}Snapshot.zip
    CoamAdmin.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    detailed_output=True
    ...    timeout=300
    ...    connection=oam
    Log To Console    Snapshot collected and saved on path ${snapshot_file_path}


Test Teardown
    ${opt}    set variable    ${OUTPUT_DIR}/Post/
    set test variable    ${opt}
    create directory     ${opt}
    stop watching alarms
    Download SCF    ${opt}
    #Link SCOUT SCF to Configuration ID for Reporting   ${TL_Name}=${tl_name}
    CoamAdmin.teardown    oam
    Log To Console    BTS IS Disconnected

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=gnb    ${tl_name_only}=${tl_name}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only} ${node_id}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=oam
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail

Get TcpdumpLogs from gNB
    [Documentation]    this keyword is used to capture wireshark log in wireshark PC
    log to console    \nStarting Wireshark Logs
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.53.203.223
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-n -X -tt -i any
    ...    executor=${executor_oam_vm}
    core.setup_collectors    names=tcpdump
    core.set_suite_alias   tcpdump
    core.start_collectors    names=tcpdump

stop tcpdumplogs
    [Arguments]    ${connection}
    core.stop_collectors    names=${connection}
    core.collect_collectors    names=${connection}
    core.teardown_collectors    names=${connection}

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

Prepare UE
    operatingsystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log	  ${a}
    Log To Console    UE preparation completed

Start UE detach attach and start throughput
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log      ${a}
    log to console  Detaching UE
    ta_ultracaller.Detach_UE     ue_alias=${UE_alias}
    log to console  Attaching UE
    ta_ultracaller.Attach_UE     ue_alias=${UE_alias}
    sleep     10s
    log to console  Starting BTSlog
    start Btslogs from Local machine   btslog
    ta_ultracaller.start_datatransfer    ue_alias=${UE_alias}    direction=${direction_dl}
    ...   protocoltype=${data_transfer_protocol}
    sleep    5s
    set attenuator   ${pva_ports}   ${port_values2}
    sleep     20s
    log to console  Stoping BTSlog
    Stops Btslogs from Local machine   btslog
    log to console  Waiting data transfer to finish
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    ${timeout}

Stop Data Transfer
    log to console    \nStop data transfer
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    ${timeout}
    Log To Console    \nUE Data Transfer Successful
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}

Verify syslog for successful Handover
    ${dir_path}   set variable   /tmp/btslog2
    ${files}=    OperatingSystem.List Files In Directory    ${dir_path}
    ${match_found_files1}=    Create List
    ${match_found_files2}=    Create List
    FOR    ${file}    IN    @{files}
        FOR    ${pattern}    IN    @{PATTERNS1}
            ${result}=    Run Process    grep    -i    ${pattern}    ${dir_path}/${file}    shell=True    stderr=ignore
            ${output}=    Set Variable    ${result.stdout}
            Run Keyword If    '${output}' != ''    Log To Console   Match found for pattern "${pattern}" in file: ${file} with line(s): ${output}
            Run Keyword If    '${output}' != ''    Append To List    ${match_found_files1}    ${file}
            Run Keyword If    '${output}' == ''    Log    Pattern "${pattern}" not found in file: ${file}    WARN
        END
        FOR    ${pattern}    IN    @{PATTERNS2}
            ${result}=    Run Process    grep    -i    ${pattern}    ${dir_path}/${file}    shell=True    stderr=ignore
            ${output}=    Set Variable    ${result.stdout}
            Run Keyword If    '${output}' != ''    Log To Console   Match found for pattern "${pattern}" in file: ${file} with line(s): ${output}
            Run Keyword If    '${output}' != ''    Append To List    ${match_found_files2}    ${file}
            Run Keyword If    '${output}' == ''    Log    Pattern "${pattern}" not found in file: ${file}    WARN
        END
    END
    # Check if any files had a match, otherwise fail the test
    Run Keyword If    ${match_found_files1} == []    Fail    No patterns were found in any files
    Log    Patterns found in files: ${match_found_files1}
    # Check if any files had a match, otherwise fail the test
    Run Keyword If    ${match_found_files2} == []    Fail    No patterns were found in any files
    Log    Patterns found in files: ${match_found_files2}

Verify DRXcycle in F1AP_UEContextSetupRequest
    [Arguments]    ${pcap_path}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${pcap_path}/tcpdump.pcap   itf_cp_cpue_cprt_cprt_receivefromcpue
    analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.longDRXCycleLength
    ...                             kind=showname
    ...                             value=longDRXCycleLength: ms10 (0)

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None     ${filterName}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterName}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

Start UE proxy in UE PC
    ssh.Connect_to    ${MCG_IP}    ${MCG_usn}    ${MCG_pwd}    alias=mcg_vm
    Run keyword and ignore error   ssh.Execute    command=sudo ps -ef|grep proxy|grep -v grep|awk '{print "kill -9 " $2}' |sh
                                   ...     connection=mcg_vm    timeout=30s
    ${cmd}	Set Variable	cd /home/ute/Downloads/ultracaller/;sh ue_proxy.sh
	LOG	${cmd}
	${output}    ssh.Execute    command=${cmd}    connection=mcg_vm    timeout=5m
	LOG		${output}

Stop UE proxy in UE PC
    Run keyword and ignore error   ssh.Execute    command=sudo ps -ef|grep btslog|grep -v grep|awk '{print "kill -9 " $2}' |sh
                                   ...     connection=mcg_vm    timeout=30s

Starting VONR Call
	#[Arguments]     ${UE_alias}    ${Test_name}
    ta_ultracaller.start voice call    ue_alias=${UE_alias}    testcasename=${dt_name_v}
    Log To Console    UE voice call Successfully started

Stopping VONR Call
	#[Arguments]     ${UE_alias}
    ta_ultracaller.stop voice call    ue_alias=${UE_alias}
    Log To Console    UE voice call Successfully stopped

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
	...    remote_path=${uepc_Log_path}//${source_emil_file}[${int}]     connection=mcg_vm
    BuiltIn.sleep     3s
    Run keyword and ignore error	ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f
                                        ...      connection=mcg_vm		timeout=30s
    ${src_file}     Set Variable        ${uepc_Log_path}/${source_emil_file}[${int}]
	${cmd}	Set Variable	${emil_path}//Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile_path}
	LOG	${cmd}
	${output}		ssh.Execute    command=${cmd}      connection=mcg_vm		timeout=5m
	LOG		${output}
	${csvfile}    String.Replace String    string=${source_emil_file}[${int}]    search_for=.5gm    replace_with=.csv
	ssh.download_file    remote_path=${uepc_Log_path}//${csvfile}		local_path=${out}${testcase_name}/${csvfile}     connection=mcg_vm


Start Emil To Convert Emil File To Csv1
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
	...    remote_path=${uepc_Log_path}//${source_emil_file}[${int}]     connection=mcg_vm
    ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f      connection=mcg_vm		timeout=30s
    ${cyg_cmd}    Set Variable      cygstart PsExec -u "${MCG_domain}\\${MCG_usn}" -p "${MCG_pwd}" -d -i 2
    ${src_file}     Set Variable        ${uepc_Log_path}//${source_emil_file}[${int}]
	${run_command}    Set Variable
    ...     ${cyg_cmd} "${emil_path}\\Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile_path}"
	LOG	${run_command}
	${output}		ssh.Execute    command=${run_command}      connection=mcg_vm		timeout=30s
	LOG		${output}
	#sleep    3min
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

set attenuator
    [Arguments]    ${pva_port}   ${port_values}
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${pva_port}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${pva_port}
    at.set_ports_attenuation    ports=${pva_port}    values=${port_values}    confirm=True    confirmation_delay=10s
    sleep    10s

check PM counters
    Log To Console    \n Counter Validation check ongoing
    coam.Connect_to   bts_host=192.168.255.129   bts_port=443      name=admin1
    ${log_entry} =    coam.Get Pm Counters    counter_ids=M8006C354,M8006C258,M8013C104,M8013C13,M8013C54,M8006C254
	...    timeout=300    connection=admin1
    @{counter_list}=    create List    M8006C354  M8006C258  M8013C104  M8013C13  M8013C54  M8006C254
    FOR    ${pi_id}    IN    @{counter_list}
    log    ${pi_id}
    ${count}=    set variable    ${log_entry ['BTS']['MRBTS-30328']['LNBTS-30328']['LNCEL-12']['MCC-001']['MNC-01']['LTE_EPS_Bearer']['${pi_id}']}
    ${a}=    get dictionary values    ${count}
    ${pi_value}=    Set Variable    ${a[-1]}
    Log    ${pi_value}
    ${value}=    evaluate    ${pi_value}!=0
    Run Keyword IF    '${value}' != '0'    Log    ${counter_List}    ELSE    Log    '${value}' is equal to 0
    END

Get Latest Counter Value
    ${latest_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...  M8006C354  > 0  ERAB_REL_ENB_RNL_RED_SB_IRAT
    ...  M8006C258  > 0  ERAB_REL_ENB_RNL_RED
    ...  M8013C104  > 0  UE_CTX_REL_ENB_IRAT_RD
    ...  M8013C13  > 0  ENB_INIT_TO_IDLE_NORM_REL
    ...  M8013C54  > 0  UE_CTX_REL_ENB
    ...  M8006C254  > 0  ERAB_REL_ENB
    ...  local_moid=${lncel_source_cell}
    ...  file_path=${latest_counter_file}
