*** Settings ***
Documentation
...   author: Sreekumar Narimuri Kumaran
...   contact: sreekumar.narimuri_kumaran@nokia.com
...   Description: Resource file for CB006841

Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    DateTime
Library    RequestsLibrary
Library    Process
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Resource    testsuite/Bangalore/ORAN/resources/robot/expected_alarm.robot

*** Variables ***
@{UE_alias}=     UE2
@{capabilities_1}    Legacy_2
${mplane_ip}=    10.58.239.191
${DCAP_host}                10.41.209.110
${DCAP_username}	    utfuser
${DCAP_password}	    utfadmin!
${port}                     443
${secure}                   True
${rd_version}               dcapv3
${Default_DCAP_duration}    -1
${dcap_log_timeout}         1200
@{gnb_custom_filter}       cp_5g            condor5gSyslog
@{bts_custom_filter}        scf        		ipCapture
@{collection_timing}        Immediate       TraceEnd
@{lock_distname_oran}    NRCELL-0    NRCELL-1
@{lock_distname_cpri}    NRCELL-2    NRCELL-3    NRCELL-4    NRCELL-5

*** Keywords ***
Suite Setup
    Log to console    \n--Suite Setup--\n
    Open_Admin_Connection
    ${SUITE_PATH}    set variable    ${OUTPUT_DIR}/
    Set Suite Variable    ${SUITE_PATH}
    log to console    .....--Precondition--.....
    ${scf_path}    Download SCF    ${SUITE_PATH}
    set global variable    ${scf_path}
    Wait Until Keyword Succeeds    4min    1s    Lock_Cell_source_BTS
    PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Close_Admin_Connection


Suite Postcondition
    Open_Admin_Connection
    ${scf_path}    Download SCF    ${SUITE_PATH}
	Wait Until Keyword Succeeds    4min    1s    Unlock_Cell_source_BTS
    Close_Admin_Connection
	Link SCOUT SCF to Configuration ID for Reporting

Open_Admin_Connection
    Log To Console    connecting to BTS
    CoamAdmin.teardown_all_aliases_for_admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam

Close_Admin_Connection
    CoamAdmin.teardown    oam
    Log To Console    BTS IS Disconnected

parameter update
    [Documentation]     This keyword for performing Parameter value change.
    [Arguments]  ${dist_name}    ${abbrevation}    ${value}
    CoamAdmin.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=${abbrevation}    value=${value}    operation=update
    ...    skip_parameter_relation_errors=False    connection=oam

Attach UE and start throughput
    [Arguments]     ${UE_alias}   ${direction}   ${timeout}
    Prepare UE    ${UE_alias}     ${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Sleep    30
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep    30
    Log To Console    \nUE Attach Successful and starting data transfer\n
    ta_ultracaller.start_datatransfer  ${UE_alias}  ${CALL_type}  direction=${direction}
    log to console    \nStop data transfer\n
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
    Log To Console    \nUE Data Transfer Successful\n
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    20

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log	  ${a}
    Log To Console    \nUE preparation completed

Check BTS is Not OnAir
    [Documentation]  ... checking BTS status
	[Arguments]  	${connection}
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=${connection}
    Should Not Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'!='OnAir'
    ...    Log To Console    \nBTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail

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

Lock_Cell_source_BTS
    [Documentation]  ... Locking cells
	Log     Locking all cells
	FOR   ${cell}   IN    @{lock_distname_oran}
		CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/${cell}    timeout=60    connection=oam
		sleep    30s
	END
	FOR   ${cell}   IN    @{lock_distname_cpri}
		CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/${cell}    timeout=60    connection=oam
		sleep    30s
	END
	CoamAdmin.unlock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-0    timeout=60    connection=oam
	sleep    30s

Unlock_Cell_source_BTS
    [Documentation]  ... unlocking_cells
	Log 		Unlocking all cells
	FOR   ${cell}   IN    @{lock_distname_oran}
		CoamAdmin.unlock    dist_name=MRBTS-1024/NRBTS-1024/${cell}    timeout=60    connection=oam
		sleep    30s
	END
	FOR   ${cell}   IN    @{lock_distname_cpri}
		CoamAdmin.unlock    dist_name=MRBTS-1024/NRBTS-1024/${cell}    timeout=60    connection=oam
		sleep    30s
	END

Admin_setup
    Log To Console    connecting to BTS
    CoamAdmin.teardown_all_aliases_for_admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console    BTS is Connected
    Check BTS is OnAir   oam
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
    ${allowed_alarms}=    Expected_alarm

Admin_teardown
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog    target_dir=${out}
    core.teardown_collectors      names=btslog
    Link SCOUT SCF to Configuration ID for Reporting
    CoamAdmin.teardown    oam
    Log To Console    BTS IS Disconnected


Collect Snapshot
    ${snapshot_file_path}    set variable    ${out}Snapshot.zip
    Set Suite Variable    ${snapshot_file_path}
    CoamAdmin.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    timeout=300
    ...    connection=oam
    Log To Console    \nSnapshot collected and saved on path ${snapshot_file_path}

Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${port}    rd_version=${rd_version}        secure=${secure}    username=${DCAP_username}
	...		password=${DCAP_password}

Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    &{BTS_INFO}=    create dictionary   host=${mplane_ip}     port=${port}    username=Nemuadmin    password=nemuuser
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}    gnb_custom_profile=@{gnb_custom_filter}
    ...     bts_custom_profile=@{bts_custom_filter}	  wait_for_activation=True      collection_timing=@{collection_timing}
    Sleep       30      reason=Wait for DCAP start
    ${START_TRACE_ID}=      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG to console     DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Arguments]    ${testcase_name}
    [Documentation]     Stops DCAP and collect logs
    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=100
    LOG to console    DCAP logging stopped
	Wait Until Keyword Succeeds    10min    10s    Check_dcap_capture_is_ready
	log to console    trace is in ready state
    create directory         ${out}${testcase_name}
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${out}${testcase_name}/DCAP_logs    timeout=${dcap_log_timeout}

Check_dcap_capture_is_ready
	${result}=   rd.get_trace_info_by_id     trace_id=${START_TRACE_ID}   timeout=30
	Run Keyword If  '${result}[status]'=='ready'
    ...    Log To Console    \ntrace_id=${START_TRACE_ID} is in ready state
    ...    ELSE    fail

Get_SBTS_build_type_from_BTS
    [Documentation]     Fetched current SBTS build and return SBTS00 or branch
    &{a}=	CoamAdmin.get_software_info   oam
    log    ${a}
    ${value}=    Get From Dictionary	${a}	Active SW version
    log to console    ${value}
    ${SBTS}=	Fetch From Left    ${value}     _
    log to console    ${SBTS}
    [Return]  ${SBTS}

Rename Snapshot
    [Arguments]    ${testcase_name}
    [Documentation]     Rename snashot collected
    move file    ${snapshot_file_path}    ${out}${testcase_name}_Snapshot.zip