*** Settings ***
Documentation
...   Description: Test Suite for RJIO CNI
Library    ../../../../../ORAN/resources/python/ta_ultracaller/
Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin  WITH NAME   CoamAdmin
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    seleLib
Library    DateTime
Library    Process
Library    String
Library    ute_ue
Library    Telnet
Library    taf.transport.ssh  WITH NAME  SSH
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    ute_tshark
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.collectors.pmcounters
Library    taf.analyzer.pmcounter    WITH NAME    pm_analyser
Library    ute_syslog
Library    SSHLibrary
Library    SeleniumLibrary
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.collectors.core   WITH NAME   core
#Library    RJIO.py
Library    pva_target_to_source.py
Library    pva_source_to_target.py
#Library    hran_extract


*** Variables ***

${info}
${expected_value}
@{allowed_custom_alarms}    4655  61649  61524  4654  61652  6150  8000  4681  7312  7304  7313

${source_BTS_IP_Mplane}    10.58.239.157
#${target_BTS_IP_Mplane}    10.58.239.65
${OUTPUT_DIR1}    /home/ute/
${DCAP_host}                10.58.238.157                                                           # DCAP server IP 10.41.209.110
${port}                     9443                                                                    # Port value for DCAP connection
${secure}                   True                                                                    # Secure value for DCAP connection
${rd_version}               dcapv3                                                                  # DCAP version
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
#${emil_path}                C://Emil                                                                # Emil path in UE PC machine
#${emil_profile_path}        ${emil_path}//profiles//5G                                             # Emil profile path in UE PC machine
${emil_path}                C:\\Emil                                                                # Emil path in UE PC machine
${emil_profile_path}        ${emil_path}\\profiles\\5G
${Default_DCAP_duration}    12                                                                      # DCAP log duration
${dcap_log_timeout}         1200                                                                    # Timeout for DCAP log collection

&{BTS_INFO_source}                 host=${source_BTS_IP_Mplane}   port=443                                    # BTS details
&{BTS_INFO_target}                 host=${target_BTS_IP_Mplane}   port=443                                    # BTS details

@{enb_custom_filters}       cp_4g                   # gnb custom filters for DCAP
#@{gnb_custom_filters}       cp_5g                   # gnb custom filters for DCAP
@{bts_custom_filter}        immediateSnapshot    scf    ipCapture                                   # BTS custom filters for DCAP
@{collection_timing}        Immediate       TraceEnd                                                # Snapshot collet option for DCAP


*** Keywords ***
Create_Folder_Structure
    [Arguments]    ${out}
    ${tcpdump}    set variable     ${out}/Wireshark_log/
    ${syslog}    set variable    ${out}/Syslog/
    ${Snapshot}    set variable    ${out}/Snapshot/
    ${EMIL}    set variable    ${out}/EMIL_Logs/
    set test variable    ${tcpdump}
    create directory     ${tcpdump}
    set test variable    ${syslog}
    create directory     ${syslog}
    set test variable    ${Snapshot}
    create directory     ${Snapshot}
    set test variable    ${EMIL}
    create directory     ${EMIL}

PVA_STARTUP_SOURCE_TO_TARGET
    pva_source_to_target.PVA_Attenuator_startup

PVA_TRIGGER_SOURCE_TO_TARGET
    pva_source_to_target.PVA_Attenuator_Trigger

PVA_TRIGGER_SOURCE_TO_TARGET_IRAT
    pva_source_to_target.PVA_Attenuator_Trigger_IRAT
PVA_TRIGGER_TARGET_TO_SOURCE
    pva_target_to_source.PVA_Attenuator_Trigger

Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${port}    rd_version=${rd_version}        secure=${secure}

Start_EMIL_USING_DCAP
    [Documentation]     Start DCAP logs with custom filter
    @{gnb_custom_filter}     Create List     cp_5g    immediateSnapshot    condor5gSyslog
    ${source_output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO_source}
    ...     gnb_custom_profile=@{gnb_custom_filters}    wait_for_activation=True      collection_timing=@{collection_timing}
    Sleep       120      reason=Wait for DCAP start
    ${START_TRACE_ID_source}=      Get from Dictionary    ${source_output}    id
    Set Suite Variable  ${START_TRACE_ID_source}

    ${target_output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO_source}
    ...     gnb_custom_profile=@{gnb_custom_filters}    wait_for_activation=True      collection_timing=@{collection_timing}
    Sleep       120      reason=Wait for DCAP start
    ${START_TRACE_ID_target}=      Get from Dictionary    ${target_output}    id
    Set Suite Variable  ${START_TRACE_ID_target}

    LOG to console     DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Arguments]    ${DCAP_BTS_source}    ${DCAP_BTS_target}
    [Documentation]     Stops DCAP and collect logs
    rd.stop_trace    trace_id=${START_TRACE_ID_source}    timeout=100
    LOG to console    DCAP logging stopped for source
    create directory         ${out}${testcase_name}
    rd.get_results    result_id=${START_TRACE_ID_source}    target_dir=${EMIL}${DCAP_BTS_source}/DCAP_logs
    ...    timeout=${dcap_log_timeout}
    rd.stop_trace    trace_id=${START_TRACE_ID_target}    timeout=100
    LOG to console    DCAP logging stopped for target
    create directory         ${out}${testcase_name}
    rd.get_results    result_id=${START_TRACE_ID_target}    target_dir=${EMIL}${DCAP_BTS_target}/DCAP_logs
    ...    timeout=${dcap_log_timeout}

    #target_dir=${out}DCAP_Logs

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
    #${date}    Get Current Date    result_format=%Y%m%d
    ${date}    Set Variable    20230201
    ${files}    OperatingSystem.List Files In Directory    ${path1}
    FOR    ${zip}    IN    @{files}
        hran_extract.unzip        ${path1}${zip}        path_to_unpacked=${source_paths}
    END
    ${it}=    OperatingSystem.List Directory    ${source_paths}${date}
    ssh.Connect_to    ${MCG_IP}    ${MCG_usn}    ${MCG_pwd}    alias=mcg_vm
    ssh.Execute    command=cd /cygdrive//c//PSTools    connection=mcg_vm    timeout=30s
    FOR    ${out_index}    IN    @{it}
        Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}${date}
        ...     source_file=${out_index}/5g/controlPlane    testcase_name=${testcase_name}
    END
    ${output}       ssh.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm        timeout=30s
    LOG     ${output}

Start Emil To Convert Emil File To Csv
    [Arguments]    ${source_path}     ${source_file}    ${testcase_name}
    [Documentation]         Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}=    OperatingSystem.List Directory    ${source_path}/${source_file}
    ssh.upload_file    local_path=${source_path}/${source_file}/${source_emil_file}[0]
    ...    remote_path=${uepc_Log_path}//${source_emil_file}[0]    connection=mcg_vm
    ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f      connection=mcg_vm     timeout=30s
    ${cyg_cmd}    Set Variable      cygstart /cygdrive//c//PSTools//PsExec -u "${MCG_domain}\\${MCG_usn}" -p "${MCG_pwd}" -d -i 2
    ${src_file}     Set Variable        ${uepc_Log_path}//${source_emil_file}[0]
    ${run_command}    Set Variable
    ...     ${cyg_cmd} "${emil_path}\\Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile_path}"
    LOG    ${run_command}
    ${output}       ssh.Execute    command=${run_command}      connection=mcg_vm        timeout=30s
    LOG     ${output}
    #sleep    3min
    ${result}=    Wait Until Keyword Succeeds    4min    1s    Check Number Of Processes Running
    ...    process_name=Emil.exe    number_of_processes=1
    ${result}=    Wait Until Keyword Succeeds    4min    1s    Check Number Of Processes Running
    ...    process_name=Emil.exe    number_of_processes=0
    ${csvfile}=    String.Replace String    string=${source_emil_file}[0]    search_for=.5gm    replace_with=.csv
    ssh.download_file    remote_path=${uepc_Log_path}//${csvfile}       local_path=${out}${testcase_name}/${csvfile}
    ... 	connection=mcg_vm

Check Number Of Processes Running
    [Arguments]    ${process_name}=Emil.exe    ${number_of_processes}=0
    [Documentation]     Check whether Emil process is running in MCG machine
    ${output}       ssh.Execute    echo -n NumberOfProcesess:&&ps -W | grep -cw ${process_name}       connection=mcg_vm
    Should Contain    ${output}    NumberOfProcesess:${number_of_processes}
    [Return]    ${output}



Common_Test_Setup
    Log To Console    connecting to BTS
    CoamAdmin.teardown_all_aliases_for_admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    CoamAdmin.setup_admin    bts_host=10.58.239.155    alias=oam1
    Log To Console    BTS is Connected
    Start_Syslog
    Check BTS is OnAir
    #Create dcap session

Start_Syslog
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
    core.set_suite_alias    btslog
    core.start_collectors      names=btslog

Stop_syslog
    Log to console   --Stoping Syslogs Logs--
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog    target_dir=${Syslog}
    core.teardown_collectors      names=btslog

Junk_Keyword
    #Log to console   \n--Starting Syslogs Logs--
    #Run     killall btslog
    #${executor_test_vm}=  Create Dictionary
    #...  host=${VM_IP}
    ##...  user=ute
    #...  password=BT5l@bus3rl0g1n
    #btslog.create_btslog_collector
    #...   name=btslog
    #...   btslog_path=/opt/btslog/btslog
    #...   btslog_launcher_path=/opt/btslog/btslog_launcher
    #...   executor=${executor_test_vm}
    ...   log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias	btslog
    core.start_collectors      names=btslog
    #${allowed_alarms}=    Expected_alarm
    #Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=oam
    #Create dcap session
    ${opt}    set variable    ${OUTPUT_DIR1}/Test8796/
    set test variable    ${opt}
    create directory     ${opt}
    ${scf_path}    Download SCF
    set global variable    ${scf_path}

Common_Test_Teardown
    #Download SCF
    #Collect Snapshot
    Stop_syslog
    CoamAdmin.teardown    oam
    CoamAdmin.teardown    oam1
    Log To Console    BTS IS Disconnected

Download SCF
    [Documentation]    ... Downloading SCF
    ${timestamp}    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S
    ${filename}    SET VARIABLE    ${opt}${timestamp}_scf.xml
    CoamAdmin.get_current_scf_file    connection=oam    file_name=${filename}    timeout=60    local_dir_path=${opt}
    OperatingSystem.File Should Exist    ${filename}
    Log To Console    SCF Downloaded
    Log To Console    SCF file name is ${filename}
    [Return]    ${filename}

Check latest BTS Faults
    ${alarm_list}    CoamAdmin.get_alarms    connection=oam
    FOR  ${alarm}  IN  @{alarm_list}
       ${alarm_str}    convert to string  ${alarm}
       ${fault_id_matches}    get regexp matches  ${alarm_str}  faultId':\\s(\\d+)  1
       ${status}    Evaluate  str("""${fault_id_matches[0]}""") in @{allowed_custom_alarms}
       runkeyword if   "${status}"=="True"  Log    Alarm ${fault_id_matches[0]} In Allowed List ${allowed_custom_alarms}
       ...     ELSE    runkeywords    Collect gNB Snapshot    AND
       ...	   log to console    Alarm ${fault_id_matches[0]} Not In Allowed List ${allowed_custom_alarms}
    END

Collect gNB Snapshot
    CoamAdmin.Collect snapshot    ${OUTPUT_DIR1}/Snapshot.zip    force=True    timeout=700    connection=oam

Collect Snapshot
    ${snapshot_file_path}    set variable    ${opt}/Snapshot.zip
    CoamAdmin.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    timeout=300
    ...    connection=oam
    Log To Console    Snapshot collected and saved on path ${snapshot_file_path}

SCF commissioning and check ONAIR
    [Documentation]  ... Commissiioning BTS and checking BTS status
	[Arguments]    ${scf}    ${DUR}=${DURATION}
	Log to console    BTS commissioning is Ongoing
	${status}=    CoamAdmin.perform_commissioning    scf_file=${scf}    timeout=${DUR}    connection=oam
	Sleep    5min
    Check BTS is OnAir

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    [Arguments]  ${connection}=oam
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    BTS procedural state is now: ${bts_status["proceduralState"]}${\n}
    ...    ELSE    fail



Get TcpdumpLogs from Remote machine
    Log to console   \n--Starting Wireshark Logs--\n
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.239.157
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-i any
#    ...    options=-i eth1 host 10.58.239.192 -f x2ap
    ...    executor=${executor_oam_vm}
    core.setup_collectors    names=tcpdump
    core.set_suite_alias    tcpdump
    core.start_collectors    names=tcpdump

Get_target TcpdumpLogs from Remote machine
    Log to console   \n--Starting Wireshark Logs--\n
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.239.155
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump1
    ...    options=-i any
#    ...    options=-i eth1 host 10.58.239.192 -f x2ap
    ...    executor=${executor_oam_vm}
    core.setup_collectors    names=tcpdump1
    core.set_suite_alias    tcpdump1
    core.start_collectors    names=tcpdump1

stop tcpdumplogs
    [Arguments]    ${connection}
    #stopping tcpdump
    core.stop_collectors    names=${connection}
    core.collect_collectors    names=${connection}
    core.teardown_collectors    names=${connection}

Convert pcap file
    [Documentation]  this keyword will stop wireshark log collection and convert pcap file to .txt format.
    [Arguments]    ${filter}    ${tc_name}
    #stopping tcpdump
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump
    core.teardown_collectors    names=tcpdump
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${out}/HORJIOTCNGHO/${tc_name}/tcpdump/tcpdump.pcap -Y "${filter}" >
	...    ${out}/HORJIOTCNGHO/${tc_name}/tcpdump/tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    60s
    ${filepath}    set variable    ${out}/HORJIOTCNGHO/${tc_name}/tcpdump/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    [Return]    ${file}

Convert1 pcap file
    [Documentation]  this keyword will stop wireshark log collection and convert pcap file to .txt format.
    [Arguments]    ${filter}    ${tc_name}
    #stopping tcpdump
    core.stop_collectors    names=tcpdump1
    core.collect_collectors    names=tcpdump1
    core.teardown_collectors    names=tcpdump1
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${out}/HORJIOTCNGHO/${tc_name}/tcpdump1/tcpdump1.pcap -Y "${filter}" >
    ...     ${out}/HORJIOTCNGHO/${tc_name}/tcpdump1/tcpdump1.txt
    SSHLibrary.write    ${command}
    sleep    60s
    ${filepath}    set variable    ${out}/HORJIOTCNGHO/${tc_name}/tcpdump1/tcpdump1.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    [Return]    ${file}

Convert_pcap_file_XNAP_HO
    [Documentation]  this keyword will stop wireshark log collection and convert pcap file to .txt format.
    [Arguments]    ${filter}    ${tc_name}
    #stopping tcpdump
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump
    core.teardown_collectors    names=tcpdump
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${out}/HORJIOTCXNHO/${tc_name}/tcpdump/tcpdump.pcap -Y "${filter}" >
    ...     ${out}/HORJIOTCXNHO/${tc_name}/tcpdump/tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    60s
    ${filepath}    set variable    ${out}/HORJIOTCXNHO/${tc_name}/tcpdump/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    [Return]    ${file}

Convert1_pcap_file_XNAP_HO
    [Documentation]  this keyword will stop wireshark log collection and convert pcap file to .txt format.
    [Arguments]    ${filter}    ${tc_name}
    #stopping tcpdump
    core.stop_collectors    names=tcpdump1
    core.collect_collectors    names=tcpdump1
    core.teardown_collectors    names=tcpdump1
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${out}/HORJIOTCXNHO/${tc_name}/tcpdump1/tcpdump1.pcap -Y "${filter}" >
    ... 	${out}/HORJIOTCXNHO/${tc_name}/tcpdump1/tcpdump1.txt
    SSHLibrary.write    ${command}
    sleep    60s
    ${filepath}    set variable    ${out}/HORJIOTCXNHO/${tc_name}/tcpdump1/tcpdump1.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    [Return]    ${file}

Convert_pcap_file_IRAT_HO
    [Documentation]  this keyword will stop wireshark log collection and convert pcap file to .txt format.
    [Arguments]    ${filter}    ${tc_name}
    #stopping tcpdump
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump
    core.teardown_collectors    names=tcpdump
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${out}/HORJIOTCIRAT/${tc_name}/tcpdump/tcpdump.pcap -Y "${filter}" >
    ... 	${out}/HORJIOTCIRAT/${tc_name}/tcpdump/tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    60s
    ${filepath}    set variable    ${out}/HORJIOTCIRAT/${tc_name}/tcpdump/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    [Return]    ${file}

Convert1_pcap_file_IRAT_HO
    [Documentation]  this keyword will stop wireshark log collection and convert pcap file to .txt format.
    [Arguments]    ${filter}    ${tc_name}
    #stopping tcpdump
    core.stop_collectors    names=tcpdump1
    core.collect_collectors    names=tcpdump1
    core.teardown_collectors    names=tcpdump1
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${out}/HORJIOTCIRAT/${tc_name}/tcpdump1/tcpdump1.pcap -Y "${filter}" >
    ... 	${out}/HORJIOTCIRAT/${tc_name}/tcpdump1/tcpdump1.txt
    SSHLibrary.write    ${command}
    sleep    60s
    ${filepath}    set variable    ${out}/HORJIOTCIRAT/${tc_name}/tcpdump1/tcpdump1.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    [Return]    ${file}

Multi UE
    Prepare UE        UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias}
#    Attach UE and run throughput   ${UE_alias_1}   ${call_type}   ${direction_dl}
    Run throughput   UE_alias=${UE_alias_1}   call_type=${call_type}   direction=${direction_dl}   timeout=${timeout}
    ...    throughput=${throughput_dl}    deviation=${deviation_dl}

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}    ${timeout}
	log    ${timeout}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log	  ${a}
    Log To Console    UE preparation completed

Detach and Attach UE
    [Arguments]     ${UE_alias}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    40
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep    20
    Log To Console    UE Attach Successful
    #Prepare UE
    #Log To Console    Fetching Cell Details
    #ta_ultracaller.Cell Info    ue_alias=${UE_alias}

Validate_Cell_ID
    #${info}    ${expected_value}
    Prepare UE     UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
    ${UE_INFO}=    ta_ultracaller.Validate UE Info    ue_alias=@{UE_alias}    info=${info}    expected_value=${expected_value}
    Log to console    ${UE_INFO}

Run throughput
    [Arguments]    ${UE_alias}   ${call_type}    ${direction}    ${timeout}   ${throughput}
    log    ${UE_alias}
    log    ${throughput}
    log    ${timeout}
    log    ${throughput}
    log    ${direction}
    ta_ultracaller.start_datatransfer   ${UE_alias}   ${call_type}   ${direction_dl}
    Sleep  10
    #ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
#    ta_ultracaller.Detach UE     ue_alias=${UE_alias_1}
    #Sleep    20
#    Run Keyword And Continue On Failure  ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
#    ...    direction=${direction}   thrughtput=${throughput}    deviation=${deviation}

Starting Voice Call
    [Arguments]     ${UE_alias}    ${dt_name_v}
    ta_ultracaller.start voice call    ue_alias=${UE_alias}    testcasename=${dt_name_v}
    Log To Console    UE voice call Successfully started
    pva2.PVA_Attenuator_Trigger
    Log To Console    Attenuation for source & target cell successfull
    Sleep    5

Stopping Voice Call
    [Arguments]     ${UE_alias}   ${dt_name_v}
	  ta_ultracaller.stop voice call    ue_alias=${UE_alias}   testcasename=${dt_name_v}
    Log To Console    UE voice call Successfully stopped

Start UE Attach & Volte Call
    [Tags]    FULL_RUN
    Prepare UE	   UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias}
    #Starting Voice Call    ${UE_alias}    ${dt_name_v}

validate wireshark logs
    [Documentation]    this keyword is used to validate wireshark logs
    [Arguments]    ${log2}    ${message}
    @{log1}    Split to lines    ${log2}
    FOR    ${a}    IN    @{log1}
        ${status}    run keyword and return status    should contain    ${a}    ${message}
        run keyword if    '''${status}'''=='''True'''    exit for loop
    END
    Run Keyword if    '''${status}'''=='''True'''    Log to console    ${message} message is found in wireshark log
    ...    ELSE    Log to console     ${message} message is not found in wireshark log
    Run Keyword if    '''${status}'''!='''True'''    fail

Counter validation1
    [Arguments]    ${counter}
    ${result} =    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['CELLS']['LNCEL-0']['LTE_Cell_Resource']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times

Get_value_of_Counter
    [Arguments]    ${Counter_value}
    FOR    ${a}    IN    @{Counter_value}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

Counter Collection and Validation
    [Arguments]    ${bts_ip}    ${counter}    ${cell_id}    ${dict_variablle}    ${node_name}    ${string}
	log    ${cell_id}
	log    ${bts_ip}
    ${result}    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    ${counter_values}    Get Dictionary Values    ${result['BTS']['CELLS']['LNCEL-${cell_id}']
	...    ['MCC-001_MNC-01']['${dict_variablle}']['${counter}']}
    ${final_total_count}    Get_Sum_of_Counter    ${counter_values}
    log to console    Final count after S1HO for counter id ${counter} is ${final_total_count}
    Run Keyword if    '${final_total_count}'>'${Init_total_count}'
    ...    log to console    Counter value for ${string} successfully incrimented at ${node_name}
    ...    ELSE    fail    msg=Counter not incremented for ${string} test failed

Counter Collection and Validation for DRX
    [Arguments]    ${bts_ip}    ${counter}    ${cell_id}    ${dict_variablle}    ${string}
	log    ${cell_id}
	log    ${bts_ip}
    ${result}    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    ${counter_values}    Get Dictionary Values    ${result['BTS']['CELLS']['LNCEL-${cell_id}']
	...    ['MCC-001_MNC-01']['${dict_variablle}']['${counter}']}
    ${total_count}    Get_Sum_of_Counter    ${counter_values}
    log to console    Final Subframe count of ${string}_${counter} is ${total_count}
    Run Keyword if    '${total_count}'>'0'
    ...    log to console    Counter value for ${string} successfully incrimented
    ...    ELSE    fail    msg=Counter not incremented for ${string} test failed

Init Counter Collection
    [Arguments]    ${bts_ip}    ${counter}    ${cell_id}    ${dict_variablle}    ${string}
	log    ${cell_id}
    BTS admin connection     ${bts_ip}
    ${result}    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=cOAM_admin
    ${counter_values}    Get Dictionary Values    ${result['BTS']['CELLS']['LNCEL-${cell_id}']
	...    ['MCC-001_MNC-01']['${dict_variablle}']['${counter}']}
    ${Init_total_count}    Get_Sum_of_Counter    ${counter_values}
    Set Suite Variable    ${Init_total_count}
    log to console    Initial count for counter id ${counter} is ${Init_total_count} at ${string}
    [Teardown]    Disconnect from admin

Get_Sum_of_Counter
    [Arguments]    ${PM_counter_values}
    FOR    ${a}    IN    @{PM_counter_values}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}

Counter validation2
    [Arguments]    ${counter}
    ${result} =    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['CELLS']['LNCEL-0']['LTE_Inter_eNB_HO']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times

Stop pcap log capturing XNAP NGAP
    [Arguments]     ${Pcap_file_name}    ${pcap_file_path}=${file_path}
    Stop IP Traffic Capturing    ${connection}
    ${timestamp}    Get Current Date    result_format=%d.%m_%H-%M
    ${target_file_name}    set variable    wireshark_${Pcap_file_name}_pcap_${timestamp}_file.pcap
    Download File With Captured Traffic
    ...                                     target_file_name=${target_file_name}.gz
    ...                                     connection=${connection}
    Log  File ${target_file_name}.gz downloaded.  console=True
    [Teardown]  Run keywords    Disable Started IP Traffic Capturing    ${connection}    AND
    ...                         CoamAdmin.teardown    connection=${connection}
    Run           mv ${EXECDIR}/${target_file_name}.gz ${pcap_file_path}
    Run           cd ${pcap_file_path}; gzip -d ${target_file_name}.gz
    Set Suite Variable    ${target_file_name}
    set suite variable    ${pcap_file_path}
    Log    ${target_file_name}

Stop pcap log capturing 4G to 5G
    [Arguments]     ${pcap_file_path}=${file_path}
    Stop IP Traffic Capturing    ${connection}
    ${timestamp}    Get Current Date    result_format=%d.%m_%H-%M
    ${target_file_name}    set variable    wireshark_4G_TO_5G_pcap_${timestamp}_file.pcap
    Download File With Captured Traffic
    ...                                     target_file_name=${target_file_name}.gz
    ...                                     connection=${connection}
    Log  File ${target_file_name}.gz downloaded.  console=True
    [Teardown]  Run keywords    Disable Started IP Traffic Capturing    ${connection}    AND
    ...                         CoamAdmin.teardown    connection=${connection}
    Run           mv ${EXECDIR}/${target_file_name}.gz ${pcap_file_path}
    Run           cd ${pcap_file_path}; gzip -d ${target_file_name}.gz
    Set Suite Variable    ${target_file_name}
    set suite variable    ${pcap_file_path}
    Log    ${target_file_name}

Stop pcap log capturing 5G to 4G
    [Arguments]     ${pcap_file_path}=${file_path}
    Stop IP Traffic Capturing    ${connection}
    ${timestamp}    Get Current Date    result_format=%d.%m_%H-%M
    ${target_file_name}    set variable    wireshark_5G_TO_4G_pcap_${timestamp}_file.pcap
    Download File With Captured Traffic
    ...                                     target_file_name=${target_file_name}.gz
    ...                                     connection=${connection}
    Log  File ${target_file_name}.gz downloaded.  console=True
    [Teardown]  Run keywords    Disable Started IP Traffic Capturing    ${connection}    AND
    ...                         CoamAdmin.teardown    connection=${connection}
    Run           mv ${EXECDIR}/${target_file_name}.gz ${pcap_file_path}
    Run           cd ${pcap_file_path}; gzip -d ${target_file_name}.gz
    Set Suite Variable    ${target_file_name}
    set suite variable    ${pcap_file_path}
    Log    ${target_file_name}

Wireshark log validation XNAP NGAP
    [Arguments]    ${pcap_file_name}    ${target_num_contextrel}=${count}    ${input_filter}=${filter}
    ...    ${file_path}=/home/ute/pcap_log
    Setup Tshark    interface=any    alias=${pcap_file_name}    ssh_password=BT5l@bus3rl0g1n
    ${HOsuccess}    BuiltIn.Run Keyword And Continue On Failure    ute_tshark.Read Pcap
    ...               packet_filter=${input_filter}
    ...               pcap_file_path=${file_path}/${target_file_name}
    ...               alias=${pcap_file_name}
    Log    ${file_path}/${target_file_name}
    ${packets_count}    ute_tshark.Get Packets Count
    ...                 packet_filter=${input_filter}
    ...                 pcap_file_path=${file_path}/${target_file_name}
    ...                 alias=${pcap_file_name}
    log to console    number of successfull contextrelease command from core ${packets_count}
    should be equal    ${packets_count}    ${target_num_contextrel}
    log to console    IRAT wireshark log validated succesfully.
    Run           cd ${pcap_file_path}; gzip -9 ${target_file_name}
    Run           mv ${pcap_file_path}/${target_file_name}.gz ${tcpdump}
    log to console    Wireshark logfile moved successfully..

Wireshark log validation 4G to 5G
    [Arguments]    ${target_num_contextrel}=${count}    ${input_filter}=${filter}    ${file_path}=/home/ute/pcap_log
    Setup Tshark    interface=any    alias=pcap_4G_5G    ssh_password=BT5l@bus3rl0g1n
    ${HOsuccess}    BuiltIn.Run Keyword And Continue On Failure    ute_tshark.Read Pcap
    ...               packet_filter=${input_filter}
    ...               pcap_file_path=${file_path}/${target_file_name}
    ...               alias=pcap_4G_5G
    ${packets_count}    ute_tshark.Get Packets Count
    ...                 packet_filter=${input_filter}
    ...                 pcap_file_path=${file_path}/${target_file_name}
    ...                 alias=pcap_4G_5G
    log to console    number of successfull contextrelease command from core ${packets_count}
    should be equal    ${packets_count}    ${target_num_contextrel}
    log to console    IRAT wireshark log validated succesfully.
    Run           cd ${pcap_file_path}; gzip -9 ${target_file_name}
    Run           mv ${pcap_file_path}/${target_file_name}.gz ${tcpdump}
    log to console    Wireshark logfile moved successfully..

Wireshark log validation 5G to 4G
    [Arguments]    ${target_num_contextrel}=${count}    ${input_filter}=${filter}    ${file_path}=/home/ute/pcap_log
    Setup Tshark    interface=any    alias=pcap_5G_4G    ssh_password=BT5l@bus3rl0g1n
    ${HOsuccess}    BuiltIn.Run Keyword And Continue On Failure    ute_tshark.Read Pcap
    ...               packet_filter=${input_filter}
    ...               pcap_file_path=${file_path}/${target_file_name}
    ...               alias=pcap_5G_4G
    ${packets_count}    ute_tshark.Get Packets Count
    ...                 packet_filter=${input_filter}
    ...                 pcap_file_path=${file_path}/${target_file_name}
    ...                 alias=pcap_5G_4G
    log to console    number of successfull contextrelease command from core ${packets_count}
    should be equal    ${packets_count}    ${target_num_contextrel}
    log to console    IRAT wireshark log validated succesfully.
    Run           cd ${pcap_file_path}; gzip -9 ${target_file_name}
    Run           mv ${pcap_file_path}/${target_file_name}.gz ${tcpdump}
    log to console    Wireshark logfile moved successfully..

IRAT Test teardown
    Run keyword and ignore error    Disable Started IP Traffic Capturing    ${connection}
    Run keyword and ignore error    CoamAdmin.teardown    connection=${connection}
    Stop Tput and Detach UE

Disconnect from admin
    [Arguments]  ${name}=cOAM_admin
    CoamAdmin.teardown    connection=${name}

BTS admin connection
    [Arguments]  ${ip_address}=${BTS_IP}    ${name}=cOAM_admin
    ${date}=    DateTime.Get Current Date
    ${connection}    CoamAdmin.connect_to
    ...                 bts_host=${ip_address}
    ...                 username=Nemuadmin
    ...                 password=nemuuser
    ...                 name=${name}
    [Return]  ${connection}

Download File With Captured Traffic
    [Documentation]
    ...  Keyword for generate and download captured pcap traffic
    Log to console  Download file with captured traffic...
    [Arguments]    ${connection}  ${target_file_name}=${downloaded_file_pcap_gz}
    CoamAdmin.generate ip capture file    connection=${connection}
    CoamAdmin.download ip capture file    target_file_name=${target_file_name}
    ...                               connection=${connection}
    ...                               timeout=200
    [Return]  ${target_file_name}

Disable Started IP Traffic Capturing
    [Arguments]    ${connection}
    run keyword and ignore error  Stop IP Traffic Capturing    ${connection}

Start PCAP Traffic Capturing
    [Arguments]    ${measurement_point}    ${uplane_capturing}    ${password}    ${connection}    ${capture_time}
    Log to console  Start BTS pcap capturing...
    CoamAdmin.start ip capture file     measurement_point=${measurement_point}
    ...                             uplane_capturing=${uplane_capturing}
    ...                             password=${password}
    ...                             connection=${connection}
    ...                             timeout=${capture_time}

Stop IP Traffic Capturing
    [Arguments]  ${connection}
    Log to console  Stop BTS pcap capturing...
    CoamAdmin.stop ip capture file        connection=${connection}

Start PCAP log capturing
    [Arguments]    ${BTS_IP}=${BTS_Login_IP}    ${capture_time}=5
    Run    rm -rf ${file_path}
    Create directory    ${file_path}
    ${connection}    BTS admin connection    ${BTS_IP}
    Start PCAP Traffic Capturing    NE_Terminated    False    ${EMPTY}    ${connection}    ${capture_time}
    Log  PCAP Capturing started timeout: ${capture_time} sec.  console=True
    set suite variable    ${connection}

Start Prepare UE & Attach UE
    [Tags]    FULL_RUN
    Prepare UE     UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias}
    #Starting Voice Call    ${UE_alias}    ${dt_name_v}
