*** Settings ***
Documentation
...   author: Lekhashree S N
...   contact: lekhashree.s_n@nokia.com
Test Setup      Common_Test_Setup
Test Teardown   Common_Test_Teardown
Suite Setup     Suite_setup
Suite Teardown  Suite_teardown
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.sbts.oam.coam.admin  WITH NAME   CoamAdmin
Library    taf.transport.ssh  WITH NAME  SSH
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    ute_tshark
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.hw.rf_attenuator    WITH NAME    atten
Library    taf.ue    WITH NAME    taf_ue
Library    DateTime
Library    Process
Library    String
Library    Telnet
Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    SSHLibrary


*** Variables ***
${DCAP_host}                10.58.239.215
${port}                     443
${secure}                   True
${rd_version}               dcapv3
${Default_DCAP_duration}    10
${dcap_log_timeout}         1200
@{bts_custom_filter}        ipCapture
@{collection_timing}        Immediate       TraceEnd
&{BTS_INFO_source}          host=${source_BTS_IP_Mplane}   port=443
${dcapusr}                  utfuser
${dcappwd}                  utfadmin!
${timeout}                  100
${DURATION}					800
${BTS_Login_IP}   			192.168.255.129
${VM_IP}    				10.58.238.158
${VM_usn}   				ute
${VM_pwd}   				BT5l@bus3rl0g1n
${source_BTS_IP_Mplane}     10.58.239.157
${MCG_IP}    				10.45.150.198
${MCG_usn}    				inbabtslabuser
${MCG_pwd}    				BT5l@bus3rl0g1n
${MCG_domain}      			NOKLAB
${status}    				None
${ABSTRACT_LIB_CONFIG}
${pva_ip}          			10.45.153.210
${vendor}          			TOPYOUNG
${model}           			TAS16T16-51-120-1N-DEJS
@{port_numbers}    			1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16
${rf_port_8}    			8
${rf_port_16}    			16
@{attenuation_values_cell2}    0dB    90dB    10dB    60dB    30dB    20dB    40dB    0dB    50dB    0dB    70dB    0dB
...     90dB    0dB
${value1}    				0dB
${value2}    				120dB
${ue_alias}                 _android1
${NGAP} 					ngap
${XNAP}						xnap
${scf}                      /home/ute/Desktop/scf/Configuration_scf_MRBTS-1057_HO.xml
${True}    					True
${dist}    					MRBTS-1057/NRBTS-1057/NRCELL-2/NRREL-256
${abbr}    					handoverAllowedSA
${k}    0

*** Test Cases ***
XNAP
    PVA_STARTUP_SOURCE_TO_TARGET
    Log To Console    Attenuator set to default
    Get TcpdumpLogs from Dcap
    Attach_voice_call    MRBTS-1057/NRBTS-1057/NRCELL-2
    PVA_TRIGGER_SOURCE_TO_TARGET
    Log to console    Source to target attenuation successful
    sleep    10
	Voice_call_stop
    Dcap Stop Trace and Get results SA    SDCAPlog
    Convert PCAP and validate    ${XNAP}
    Log to console    -- XNAP HO successful--

NGAP
	parameter update    ${dist}    ${abbr}    XnHoNotAllowed
    PVA_STARTUP_SOURCE_TO_TARGET
    Log To Console    Attenuator set to default
    Get TcpdumpLogs from Dcap
    Attach_voice_call    MRBTS-1057/NRBTS-1057/NRCELL-2
    PVA_TRIGGER_SOURCE_TO_TARGET
    Log to console    Source to target attenuation successful
    sleep    10
	Voice_call_stop
    Dcap Stop Trace and Get results SA    SDCAPlog
    Convert PCAP and validate    ${NGAP}
    Log to console    -- NGAP HO successful--

IRAT
	CoamAdmin.unlock     dist_name=MRBTS-1056/LNBTS-1/LNCEL-1    timeout=60    connection=oam1
    CoamAdmin.lock      dist_name=MRBTS-1056/NRBTS-1056/NRCELL-4     timeout=60    connection=oam1
    PVA_STARTUP_SOURCE_TO_TARGET
    Log To Console    Attenuator set to default
    Get TcpdumpLogs from Dcap
    Attach_voice_call    MRBTS-1057/NRBTS-1057/NRCELL-2
    PVA_TRIGGER_SOURCE_TO_TARGET
    Log to console    Source to target attenuation successful
    sleep    10
	Voice_call_stop
    Dcap Stop Trace and Get results SA    SDCAPlog
    Convert PCAP and validate irat    ${NGAP}
    Log to console    -- IRAT HO successful--
	CoamAdmin.lock     dist_name=MRBTS-1056/LNBTS-1/LNCEL-1    timeout=60    connection=oam1
    CoamAdmin.unlock      dist_name=MRBTS-1056/NRBTS-1056/NRCELL-4     timeout=60    connection=oam1

Validating_counters_for_all_above_testcases
	log to console    \n.....--Validating Counters--.....
    sleep    5min
	#XN
	Counter validation_s    M55143C00004    NXNCC    1
	Counter validation_s    M55143C00001    NXNCC    1
	#IRAT
	Counter validation_s    M55125C02002    NNGCC    1
	Counter validation_s    M55125C02006    NNGCC    1
	#NG
	Counter validation_s    M55125C07501    NNGCC    1
	Counter validation_s    M55125C07512    NNGCC    1
	Counter validation_s    M55125C07513    NNGCC    1
	Counter validation_s    M55125C07522    NNGCC    1
    #XN
	Counter validation_t    M55143C00006    NXNCC    1
	Counter validation_t    M55125C01501    NNGCC    1
	#NG
	Counter validation_t    M55125C07520    NNGCC    1
	Counter validation_t    M55125C07504    NNGCC    1
	Counter validation_t    M55125C07503    NNGCC    1

*** Keywords ***
Create_Folder_Structure
    [Arguments]    ${out}
    ${syslog}    set variable    ${out}/Syslog/
    ${Snapshot}    set variable    ${out}/Snapshot/
    set test variable    ${syslog}
    create directory     ${syslog}
    set test variable    ${Snapshot}
    create directory     ${Snapshot}

Get TcpdumpLogs from Dcap
    [Documentation]    this keyword is used to capture wireshark log in Dcap
    Create dcap session
	log to console    Starting Ipcapture in DCAP
	Dcap Start Trace SA

Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${port}    rd_version=${rd_version}    secure=${secure}    username=${dcapusr}
	...    password=${dcappwd}

Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO_source}
    ...     bts_custom_profile=@{bts_custom_filter}		collection_timing=@{collection_timing}
    ${START_TRACE_ID}      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Arguments]    ${testcase_name}
    [Documentation]     Stops DCAP and collect logs
    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=100
    LOG to console    DCAP logging stopped
    create directory         ${out}/${testcase_name}
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${out}/${testcase_name}/DCAP_logs    timeout=${dcap_log_timeout}

Counter validation_s
    [Arguments]    ${counter}    ${a}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
	${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1057']['NRBTS-1057']['NRCELL-2']['${a}']['${counter}']}
	${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'!='${occurence}'
    ...    log to console    ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if    '${Total_Count}'!='${occurence}'    fail

Counter validation_t
    [Arguments]    ${counter}    ${a}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam1
	${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1056']['NRBTS-1056']['NRCELL-4']['${a}']['${counter}']}
	${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'!='${occurence}'
    ...    log to console    ${counter} counter is getting pegged ${Total_Count} times where it suppose to peg ${occurence}
    Run Keyword if    '${Total_Count}'!='${occurence}'    fail

Get_value_of_Counter
    [Arguments]    ${Counter_value}
    FOR    ${a}    IN    @{Counter_value}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}

Start_Syslog
    Log to console   --Starting Syslogs Logs--
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
    core.collect_collectors      names=btslog    target_dir=${syslog}
    core.teardown_collectors      names=btslog

Common_Test_Setup
    Start_Syslog
    Check BTS is OnAir
	${out}    set variable
    ...    ${OUTPUT_DIR}/${TEST_NAME}
    set test variable    ${out}
    create directory     ${out}
    Create_Folder_Structure    ${out}
    Set Environment Variable    ABSTRACT_LIB_CONFIG    /home/ute/testline_configuration/Bangalore/7_2_RJIO1057/__init__.py
    Set_export_yml      ${ABSTRACT_LIB_CONFIG}
	taf_ue.Require UE    _android1    REAL_UE

Common_Test_Teardown
    Stop_syslog

Suite_setup
	Log To Console    connecting to BTS
    CoamAdmin.teardown_all_aliases_for_admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console    BTS is Connected
	CoamAdmin.Setup_Admin    bts_host=10.58.239.155    alias=oam1
    Log To Console    BTS is Connected
	SCF commissioning and check ONAIR    ${scf}
	CoamAdmin.reset_site    connection=oam1
    Wait Until Keyword Succeeds    5min    20s    Check BTS is OnAir    oam1

Suite_teardown
	Download SCF
	Collect Snapshot
	CoamAdmin.teardown    oam
	CoamAdmin.teardown    oam1
    Log To Console    BTS IS Disconnected

Download SCF
    [Documentation]    ... Downloading SCF
    ${timestamp}    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S
    ${filename}    SET VARIABLE    ${OUTPUT_DIR}/${timestamp}_scf.xml
    CoamAdmin.get_current_scf_file    connection=oam    file_name=${filename}    timeout=60    local_dir_path=${OUTPUT_DIR}
    OperatingSystem.File Should Exist    ${filename}
    Log To Console    SCF Downloaded
    Log To Console    SCF file name is ${filename}
    [Return]    ${filename}

Collect Snapshot
    ${snapshot_file_path}    set variable    ${OUTPUT_DIR}/Snapshot.zip
    CoamAdmin.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    timeout=300
    ...    connection=oam
    Log To Console    Snapshot collected and saved on path ${snapshot_file_path}

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    [Arguments]  ${connection}=oam
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    BTS procedural state is now: ${bts_status["proceduralState"]}${\n}
    ...    ELSE    fail

SCF commissioning and check ONAIR
    [Documentation]  ... Commissiioning BTS and checking BTS status
	[Arguments]    ${scf}    ${DUR}=${DURATION}
	Log to console    BTS commissioning is Ongoing
	CoamAdmin.perform_commissioning    scf_file=${scf}    timeout=${DUR}    connection=oam
    Wait Until Keyword Succeeds    5min    20s    Check BTS is OnAir

Set_export_yml
   [Arguments]    ${yml_filepath}
   SSHLibrary.Open Connection    host=${VM_IP}
   SSHLibrary.Login    ute    password=BT5l@bus3rl0g1n    delay=10
   SSHLibrary.write    ${yml_filepath}
   SSHLibrary.Close All Connections

Convert PCAP and validate
    [Arguments]    ${filter}
    Convert wireshark pcap File To Text    SDCAPlog    ${filter}

Convert PCAP and validate irat
    [Arguments]    ${filter}
	Convert wireshark pcap File To Text irat    SDCAPlog    ${filter}

Convert wireshark pcap File To Text
	[Arguments]    ${testcase_name}    ${filter}
	[Documentation]        Convert Wireshark logs collected from DCAP
	${path1}     Set Variable        ${out}/${testcase_name}/
	${date}    Get Current Date    result_format=%Y%m%d
    ${files}    OperatingSystem.List Files In Directory    ${path1}
    FOR    ${zip}    IN    @{files}
        SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
		${command}=    set variable    cd ${path1}
		SSHLibrary.write    ${command}
		${command1}=    set variable    unzip ${path1}${zip}
		SSHLibrary.write    ${command1}
		sleep    60s
		SSH_teardown
	END
	${it}=    OperatingSystem.List Directory    ${path1}/${date}
    FOR    ${out_index}    IN    @{it}
        Run Keyword If    '${filter}'=='${NGAP}'   Run keyword And Ignore Error
		...    Start wireshark pcap File Conversion To Text ngap    source_path=${path1}/${date}    source_file=${out_index}
		...    filter=${filter}
		Run Keyword If    '${filter}'=='${XNAP}'   Run keyword And Ignore Error
		...    Start wireshark pcap File Conversion To Text xnap    source_path=${path1}/${date}    source_file=${out_index}
		...    filter=${filter}
    END

#---Paramter chnage---
parameter update
    [Arguments]  ${dist_name}    ${abbrevation}    ${value}
    Log to console    Changing the parameter configuration-
    CoamAdmin.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=${abbrevation}    value=${value}    operation=update
    ...    skip_parameter_relation_errors=False    connection=oam

#---- ngap ----
Start wireshark pcap File Conversion To Text ngap
    [Arguments]    ${source_path}     ${source_file}    ${filter}
	SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${source_path}/${source_file}/*.pcap -Y "${filter}" > ${source_path}/${source_file}/tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    30s
    ${filepath}    set variable    ${source_path}/${source_file}/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    validate wireshark logs    ${file}   HandoverRequired
    validate wireshark logs    ${file}   HandoverCommand
    validate wireshark logs    ${file}   UEContextReleaseCommand
    #log to console    validation sucessful at source Gnb

#----xnap-----
Start wireshark pcap File Conversion To Text xnap
    [Arguments]    ${source_path}     ${source_file}    ${filter}
	SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${source_path}/${source_file}/*.pcap -Y "${filter}" > ${source_path}/${source_file}/tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    30s
    ${filepath}    set variable    ${source_path}/${source_file}/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    validate wireshark logs    ${file}   HandoverRequest
    validate wireshark logs    ${file}   HandoverRequestAcknowledge
    validate wireshark logs    ${file}   UEContextRelease
    #log to console    validation sucessful at source Gnb

#----IRAT----
Convert wireshark pcap File To Text irat
	[Arguments]    ${testcase_name}    ${filter}
	[Documentation]        Convert Wireshark logs collected from DCAP
	${path1}     Set Variable        ${out}/${testcase_name}/
	${date}    Get Current Date    result_format=%Y%m%d
    ${files}    OperatingSystem.List Files In Directory    ${path1}
    FOR    ${zip}    IN    @{files}
        SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
		${command}=    set variable    cd ${path1}
		SSHLibrary.write    ${command}
		${command1}=    set variable    unzip ${path1}${zip}
		SSHLibrary.write    ${command1}
		sleep    60s
		SSH_teardown
	END
	${it}=    OperatingSystem.List Directory    ${path1}/${date}
    FOR    ${out_index}    IN    @{it}
        Run Keyword If    '${filter}'=='${NGAP}'    Run keyword And Ignore Error
		...    Start wireshark pcap File Conversion To Text ngap irat    source_path=${path1}/${date}    source_file=${out_index}
		...    filter=${filter}
    END

Start wireshark pcap File Conversion To Text ngap irat
    [Arguments]    ${source_path}     ${source_file}    ${filter}
	SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${source_path}/${source_file}/*.pcap -Y "${filter}" > ${source_path}/${source_file}/tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    30s
    ${filepath}    set variable    ${source_path}/${source_file}/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    validate wireshark logs    ${file}   HandoverRequired
    validate wireshark logs    ${file}   HandoverCommand
	#validate wireshark logs    ${file}   mobilityFromNRCommand
    validate wireshark logs    ${file}   UEContextReleaseCommand
    log to console    validation sucessful at source Gnb

validate wireshark logs
    [Documentation]    this keyword is used to validate wireshark logs
    [Arguments]    ${log}    ${message}
    @{log}    Split to lines    ${log}
    FOR    ${a}    IN    @{log}
        ${status}    run keyword and return status    should contain    ${a}    ${message}
        run keyword if    '''${status}'''=='''True'''    exit for loop
    END
    Run Keyword if    '''${status}'''=='''True'''    Log to console    ${message} message is found in wireshark log
    ...    ELSE    Log to console     ${message} message is not found in wireshark log
    Run Keyword if    '''${status}'''!='''True'''    fail

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

#---  PVA ---
Setup Attenuator
    [Arguments]    ${pva_ip}    ${vendor}    ${model}
    atten.setup_attenuator    vendor=${vendor}    ip_addr=${pva_ip}    model=${model}    port=3001
	...    attenuation_port_numbers=${port_numbers}

Set Attenuation Values
    [Arguments]    ${port}    @{values}
    ${length}=    Get length    ${values}
    FOR    ${i}    IN RANGE    0    ${length}
        ${value}=    Set Variable    ${values[${i}]}
        log to console    ${value}
        atten.set_attenuation    port=${port}    value=${value}    confirm=True    confirmation_delay=5
    END

Set Attenuation Pairs
    [Arguments]    ${port1}    ${port2}    @{values}
    ${length}=    Get length    ${values}
    FOR    ${i}    IN RANGE    0    ${length}    2
        ${value1}=    Set Variable    ${values[${i}]}
        log to console    ${value1}
        ${i}=    Evaluate    ${i}+1
        ${value2}=    Set Variable    ${values[${i}]}
        log to console    ${value2}
        atten.set_attenuation    port=${port1}    value=${value1}    confirm=True    confirmation_delay=5
        atten.set_attenuation    port=${port2}    value=${value2}    confirm=True    confirmation_delay=5
    END

PVA_STARTUP_SOURCE_TO_TARGET
	#[Arguments]    ${pva_ip}    ${vendor}    ${model}
    Setup Attenuator    ${pva_ip}    ${vendor}    ${model}
	atten.set_attenuation    port=${rf_port_8}    value=${value1}   confirm=True    confirmation_delay=2
	atten.set_attenuation    port=${rf_port_16}    value=${value2}   confirm=True    confirmation_delay=2

PVA_TRIGGER_SOURCE_TO_TARGET
    #[Arguments]    ${pva_ip}    ${vendor}    ${model}
    Setup Attenuator    ${pva_ip}    ${vendor}    ${model}
	Set Attenuation Pairs    ${rf_port_8}    ${rf_port_16}    @{attenuation_values_cell2}

#--- L3 call----
L3call
    taf_ue.Require UE    _android1    REAL_UE
    Attach_voice_data_transfer_L3Call    MRBTS-1057/NRBTS-1057/NRCELL-2

Attach_voice_call
    [Documentation]    L3 Call Methodology
    [Arguments]    ${Cell_moc}
    BuiltIn.Log To Console    ${Cell_moc}
    Attach Ue via taf ue    ue_alias=${ue_alias}
    Log To Console   \n[ INFO ]: UE Alias ${ue_alias}:UE is Attached to Network
    Start voice call1    ue_alias=${ue_alias}
    Log To Console  \n[ INFO ]: Voice call is started

Voice_call_stop
	Stop voice call1
    Log To Console  \n[ INFO ]: voice call stopped
    Detach Ue via taf ue    ue_alias=${ue_alias}
    Log To Console  \n[ INFO ]: UE Detached from Network

Attach Ue via taf ue
    [Documentation]  taf.ue.at helps to perform ue attach
    ...    more details:https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue%3A+__init__.py+configuration+file
    [Arguments]   ${ue_alias}
    taf_ue.Attach Ue  ue_alias=${ue_alias}
    Log To Console   \n[ INFO ]: UE Alias ${ue_alias}:UE is Attached to Network

Detach Ue via taf ue
    [Documentation]  taf.ue.at helps to perform ue Detach
    ...    more details:https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue%3A+__init__.py+configuration+file
    [Arguments]   ${ue_alias}
    taf_ue.Detach Ue  ue_alias=${ue_alias}
    BuiltIn.Log To Console    message=[ INFO ]: UE Detached from Network completed.

Start voice call1
    [Arguments]   ${ue_alias}
    taf_ue.start_voice_call  vc_alias=internal_call  ue_alias=${ue_alias}    to=+123456

Stop voice call1
    taf_ue.stop_voice_call   vc_alias=internal_call
