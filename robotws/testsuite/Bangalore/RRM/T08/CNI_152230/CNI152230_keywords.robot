*** Settings ***
Documentation    This suite verifies CNI152230
...  author: Amit kumar sahu
...  contact: Amit.kumar_sahu@nokia.com
...  Description: keywords for CNI152230
Library  BuiltIn
Library  Collections
Library  String
Library  OperatingSystem
Library  SSHLibrary
Library  SeleniumLibrary
Library  DateTime
Library  taf.selenium.sbts  WITH NAME  seleLib
Library  taf.collectors.btslog  WITH NAME  btslog
Library  taf.collectors.core  WITH NAME  core
Library  taf.collectors.tcpdump  WITH NAME  tcpdump
Library     taf.config.scf   WITH NAME    scf
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library  taf.sw.dcap.rd  WITH NAME    dcap
Library  taf.transport.ssh  WITH NAME  ssh
Library  Process
Library    taf.converters.eventdecoder    WITH NAME    eventDecConv
Library    dcap_extract_file.py
Library    validation.py
Library    TTI_Log_Validation.py
Library    TTI_Log_Validation_post.py
Resource    testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot



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
#${Default_DCAP_duration}  12  # DCAP log duration
#${dcap_log_timeout}  1200  # Timeout for DCAP log collection
&{BTS_INFO}  host=${mplane_ip}  port=443  # BTS details
#@{gnb_custom_filters}  cp_5g  condor5gSyslog  # gnb custom filters for DCAP
#@{bts_custom_filter}  condor5gSyslog  #immediateSnapshot  scf  ipCapture  # BTS custom filters for DCAP
#@{collection_timing}  Immediate  TraceEnd  # Snapshot collet option for DCAP
@{counter_values}
${TTI_File_extension}    _tti-dec.deb

${Download_path}    /home/ute/Downloads          # Software download path in test pc
${Build_download_timeout}    5m                           # Timeout to download build
${wget_link}    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${confirmation}    yes



@{gnb_custom_filters}    condor5gSyslog     cp_5g    L2Ps_Component     # gnb custom filters for DCAP
@{bts_custom_filter}    immediateSnapshot    scf    ipCapture       # BTS custom filters for DCAP
@{collection_timing}        Immediate       TraceEnd      # Snapshot collet option for DCAP
${Default_DCAP_duration}    10                             # DCAP log duration
${dcap_log_timeout}         1200                          # Timeout for DCAP log collection
#${connection}               Active_Session                 # Alias name



${k}         0
${timestamp}
${now}
${SW}
${Activesw}
${value}
${dcapusr}  utfuser
${dcappwd}  utfadmin!
${int}
${fail_message}    please check manually TTI log for that rnti check the previous enrty of tbsize value of that rnti it must zero

*** Keywords ***


Test Setup
    Log To Console  connecting to BTS
    CoamAdmin.Teardown All Aliases For Admin
    CoamAdmin.Setup_Admin  bts_host=10.58.239.29  alias=oam
    Log To Console  BTS is Connected
    ${opt}  set variable  ${OUTPUT_DIR}/Pre/
    set test variable  ${opt}
    create directory  ${opt}
#    ${scf_path}  Download SCF  ${opt}
#    set global variable  ${scf_path}
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
#    ${allowed_alarms}=  Expected_alarm
#    Watch alarms  allowed_alarms=${allowed_alarms}  connection_kwargs=oam
    Set Environment Variable  ABSTRACT_LIB_CONFIG  /home/ute/testline_configuration/Bangalore/7_2_RJIO1066/ta_ue_config.yaml
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
#    stop watching alarms
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



Get TcpdumpLogs from Remote machine
    [Documentation]  this keyword is used to capture wireshark log in wireshark PC
    log to console  \nStarting Wireshark Logs
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.239.29
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
    SSHLibrary.write  ping 10.58.239.29
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


Start Prepare UE & Attach UE
    [Tags]    FULL_RUN
    Prepare UE     UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias}
#    Starting Voice Call    ${UE_alias}    ${dt_name_v}

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}    ${timeout}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    log   ${timeout}
    Log To Console    UE preparation completed

Detach and Attach UE
    [Arguments]     ${UE_alias}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    20
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep    20
    Log To Console    UE Attach Successful

Start Data Transfer
    Log To Console    \nstarting data transfer
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${call_type}    direction=${direction_dl}
    sleep    10

Stop Data Transfer
    log to console    \nStop data transfer
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    ${timeout}
    Log To Console    \nUE Data Transfer Successful
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}


Parameter change task
	Parameter value change    ${vonr_dist}    ${vonr_abbr}    true
	sleep	10s

Parameter value change
	[Documentation]		Change parameter value in SCF and commision it
	[Arguments]			${dist_name}	 ${parameter}	 ${value}
	Log to console		\nChanging BTS parameter ${parameter} to ${value} [Dist: ${dist_name}]
	${current_value}	Get Current Parameter Value	   ${dist_name}	   ${parameter}
	BuiltIn.LOG					${current_value}
	Run Keyword If		'${current_value.upper()}'!='${value.upper()}'	CoamAdmin.Perform Parameter Recommissioning	  dist_name=${dist_name}
	...					parameter=${parameter}		operation=update	value=${value}	  skip_parameter_relation_errors=True
	...					connection=oam
	...		ELSE		Log to console		\nCurrent ${parameter} value is already set to ${value}, No need to peform commissioning
	${current_value}	Get Current Parameter Value	   ${dist_name}	   ${parameter}
	BuiltIn.LOG					${current_value}
	Should Be Equal As Strings	  ${current_value.upper()}	  ${value.upper()}

Get Current Parameter Value
	[Documentation]		Get current parameter value
	[Arguments]			${dist_name}	${param_name}
	${temp_scf_file}	CoamAdmin.Get Current Scf File	local_dir_path=/tmp	file_name=temp_scf.xml	  timeout=60	connection=oam
	scf.Load Scf		${temp_scf_file}
	${param_value}		scf.get_value_from_scf		dist_name=${dist_name}	p_name=${param_name}
	[Return]			${param_value}


Start DCAP log collection
    dcap.connect_to  host=${DCAP_host}   port=443   username=utfuser    password=utfadmin!
    ...              rd_version=dcapv3  secure=True
    &{bts1_info}   create dictionary  host=${M_plane_ip}    port=443    username=Nemuadmin    password=nemuuser
    @{gnb_custom_profile}=    Create List    L2Ps_Component
    ${output}    dcap.start_trace     duration=30    bts=${bts1_info}
    ...    gnb_custom_profile=@{gnb_custom_profile}
    ...    wait_for_activation=True
    ${val}        Get Dictionary Values      ${output}
	Set Suite Variable          ${trace_id}      ${val}[0]
	Log to console		Dcap started, ID: ${trace_id}

Stop DCAP log collection
    Run Keyword And Continue On Failure    dcap.stop_trace    trace_id=${trace_id}
	Log to console		Dcap stopped, ID: ${trace_id}
    ${dcap_dirname}    dcap.get_results    result_id=${trace_id}    target_dir=${OUTPUT_DIR}    timeout=2000
    ${dcap_dirname}=    Set Suite Variable    ${dcap_dirname}



Download TTI build
    [Documentation]     Download build to test pc
	${Build}    Check current software
    ${Branch}    Split string    ${Build}    _
    ${File}     Setvariable     ${Build}${TTI_File_extension}
    ${cmd}    set variable    wget -o ${OUTPUT_DIR}/wget_download_log.txt ${wget_link}/${Branch}[0]/${Build}/${File}
    Log to console    \nDownloading build ${Build} to path ${OUTPUT_DIR}, it may take some while
    Log to console    \nRunning command : ${cmd}
    ${rc}    Run And Return Rc    cd ${OUTPUT_DIR} && timeout ${Build_download_timeout} ${cmd}
    ${output}   OperatingSystem.Get File    ${OUTPUT_DIR}/wget_download_log.txt
    Log     ${output}
    Run Keyword If    ${rc} == ${0}     Log to console      \nDownload successfull
	...     ELSE        Run keywords    RUN    rm ${OUTPUT_DIR}/${Build}${TTI_File_extension}
	...     AND     Log to console      \n${output}
    ...     AND     Log to console      \n\nDownload failed
    Should be equal     ${rc}   ${0}
    ${uninstall_cmd}    set variable    sudo apt-get purge tti-dec
    Run    bash -c "echo ${confirmation} | ${uninstall_cmd}"
    ${install_cmd}    set variable    sudo gdebi ${OUTPUT_DIR}/${File}
    Run    bash -c "echo ${confirmation} | ${install_cmd}"

Check current software
    [Documentation]     Check current software in BTS
    ${current_sw}    CoamAdmin.get_sw_version    timeout=10    connection=oam
	@{sw_list} 		String.Split String 	${current_sw}	 _
	${status} 	Run Keyword And Return Status 		Should Be True		${sw_list[2]}==9999
	${current_trunk_sw}		Run Keyword If 		'${status}'=='True'		Replace String      ${current_sw}       ${sw_list[0]}     SBTS00
	...		ELSE	Set variable    ${current_sw}
    Log to console    \nCurrent software in BTS is ${current_sw}
    [Return]    ${current_trunk_sw}

Unzip and extract files
    [Arguments]    ${dcap_dirname}
    [Documentation]        Convert TTI logs collected from DCAP
    ${source_path}    Set Variable        ${OUTPUT_DIR}/Extracted/pre/
    Set Global Variable    ${source_path}
    create directory         ${source_path}
    Log to console    \n--Extracting the files--
    Start Process		unzip    -q    ${dcap_dirname}    -d    ${source_path}
    sleep    30s

Validation of TTI traces
    [Arguments]    ${source_path}
    ${date}=    Get Current Date    result_format=%Y%m%d
    Log To Console    Directory path being checked: ${source_path}/${date}/
    ${it}=    OperatingSystem.List Directory    ${source_path}/${date}/
    Set Suite Variable    ${it}
    ${output}=    Create List
    FOR    ${out_index}    IN    @{it}
        ${files_list}=    OperatingSystem.List Directory    ${source_path}/${date}/${out_index}
        ${output}=    _validation_tti    ${files_list}    ${source_path}    ${date}    ${out_index}
    END
    Should Not Be Empty    ${output}
    Log    ${output}    console=yes


Unzip and extract files post
    [Arguments]    ${dcap_dirname}
    [Documentation]        Convert TTI logs collected from DCAP
    ${source_path}    Set Variable        ${OUTPUT_DIR}/Extracted/post/
    Set Global Variable    ${source_path}
    create directory         ${source_path}
    Log to console    \n--Extracting the files--
    Start Process		unzip    -q    ${dcap_dirname}    -d    ${source_path}
    sleep    30s


Validation of TTI traces post
    [Arguments]    ${source_path}
    ${date}=    Get Current Date    result_format=%Y%m%d
    Log To Console    Directory path being checked: ${source_path}/${date}/
    ${it}=    OperatingSystem.List Directory    ${source_path}/${date}/
    Set Suite Variable    ${it}
    ${output}=    Create List
    FOR    ${out_index}    IN    @{it}
        ${files_list}=    OperatingSystem.List Directory    ${source_path}/${date}/${out_index}
        ${output}=    _validation_tti_post    ${files_list}    ${source_path}    ${date}    ${out_index}
    END
    Run Keyword If    ${output} == []    Log    CHECK POINT-2 CNI 152230 Validation PASS    console=yes
    Run Keyword Unless    ${output} == []    Log    ${fail_message}    console=yes
    Run Keyword Unless    ${output} == []    Log    ${output}    console=yes
    Should Be Empty    ${output}
    Log    ${output}    console=yes

_validation_tti
    [Arguments]    ${files_list}    ${source_path}    ${date}    ${out_index}
        ${output}=    Create List
        FOR    ${file}    IN    @{files_list}
            ${status}=    Run Keyword And Return status    Should End With    ${file}    .pcap
            Run Keyword unless    ${status}    continue FOR Loop
            Convert pcap file to json and validate
            ...    source_path=${source_path}${date}/${out_index}    source_file=${file}
            Log To Console    \n--Validating the json file--
            ${result}=    Get TTIEvents_pre    file_name=${source_path}${date}/${out_index}/ttipre.json
            Log To Console    ${result}
            Run Keyword If    ${result} != {}    Append To List    ${output}    ${result}
        END
        Return From Keyword    ${output}

_validation_tti_post
    [Arguments]    ${files_list}    ${source_path}    ${date}    ${out_index}
        ${output}=    Create List
        FOR    ${file}    IN    @{files_list}
            ${status}=    Run Keyword And Return status    Should End With    ${file}    .pcap
            Run Keyword unless    ${status}    continue FOR Loop
            Convert pcap file to json and validate post
            ...    source_path=${source_path}${date}/${out_index}    source_file=${file}
            Log To Console    \n--Validating the json file--
            ${result}=    Get TTIEvents_post    file_name=${source_path}${date}/${out_index}/ttipost.json
            Log To Console    ${result}
            Run Keyword If    ${result} != {}    Append To List    ${output}    ${result}
        END
        Return From Keyword    ${output}


Convert pcap file to json and validate
    [Arguments]    ${source_path}    ${source_file}
	Log to console    \n--Converting pcap file to json--
    eventDecConv.create_eventdecoder_converter
    ...          name=converter_1
    ...          input_file_path=${source_path}/${source_file}
    ...          output_file_path=${source_path}/ttipre
    ...          output_file_format=json
    ...          tti_dec_path=/opt/tti-dec
    eventDecConv.convert  converter_1

Convert pcap file to json and validate post
    [Arguments]    ${source_path}    ${source_file}
	Log to console    \n--Converting pcap file to json--
    eventDecConv.create_eventdecoder_converter
    ...          name=converter_1
    ...          input_file_path=${source_path}/${source_file}
    ...          output_file_path=${source_path}/ttipost
    ...          output_file_format=json
    ...          tti_dec_path=/opt/tti-dec
    eventDecConv.convert  converter_1


Lock cells
	[Arguments]     @{cell_list}
	[Documentation]		Lock the specified cell
	FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
		CoamAdmin.lock    dist_name=${Cell_dist}-${cell}		connection=CoamAdmin
	END

Unlock cells
	[Arguments]     @{cell_list}
	[Documentation]		Unlock specified cell
	FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
		CoamAdmin.unlock    dist_name=${Cell_dist}-${cell}		connection=CoamAdmin
	END
    Wait Until Keyword Succeeds    10 times    30    Common_resource.Check cell status


SWinfo
    ${SW}=    CoamAdmin.get_software_info    timeout=10    alias=oam
    ${value}=    Get From Dictionary    ${SW}    Active SW version
    [Return]    ${value}

With Timestamp
    ${timestamp}=    Get Time    result_format=%Y-%m-%d %H:%M:%S
    [Return]   ${timestamp}

Counter validation
    [Arguments]    ${counter}        #${occurence}   # ${name}
	coamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    ${now}=    with Timestamp
    ${Activesw}=    SWinfo
#    Log To Console    [${now}]BTS is Connected
    Log To Console   [${now}]Current active SW on BTS : ${Activesw}

    ${result} =    coamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1066']['NRBTS-1066']['NRCELL-0']['NCAV']['${counter}']}
    Log To Console    ${values}
    ${Total_Count}=    Get_value_of_Counter    ${values}
	coamAdmin.teardown    oam
#    Log To Console    [${now}]BTS IS Disconnected
	[Return]    ${Total_Count}


Get_value_of_Counter
    [Arguments]    ${Counter_value}
    FOR    ${a}    IN    @{Counter_value}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}
