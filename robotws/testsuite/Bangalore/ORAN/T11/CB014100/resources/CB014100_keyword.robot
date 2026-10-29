*** Settings ***
Documentation    Keyword collection for CB014100
...   author: pradeep.kumar_kl@nokia.com

Library                 Collections
Library                 ta_uexgate
Library                 taf.ul.ue.sim.env_setup
Library                 taf.sbts.oam.coam.admin
Library                 taf.ul.alarms_watchdog   WITH NAME    alarm
Library                 Process
Library                 BuiltIn
Library                 ta_emss
Library                 String
Library                 DateTime
Library                 SSHLibrary
Library    				taf.ccs.aashell    WITH NAME    cli
Library 				taf.ue.cus
Library   				taf.sw.scout    WITH NAME     scout
Library     			taf.collectors.core   WITH NAME   core
Library     			taf.collectors.btslog  WITH NAME   btslog
Library                 taf.sw.reporting_portal    WITH NAME   rp
Library                 OperatingSystem
Library                 SeleniumLibrary
Library                 testsuite/Bangalore/ORAN/resources/python/downloadwftpackage.py
#Resource                testsuite/Bangalore/ORAN/T08/resources/robot/CommonKeywordResourceFile.robot

*** Variables ***
${ssh_username}=           toor4nsn
${ssh_password}=           oZPS0POrRieRtu
${password_BTS}=           BT5l@bus3rl0g1n
${BTS_path}=               /home/ute/logs
${BTS_ADDRESS}=            192.168.255.129

${emssim_host}=         10.0.1.1
${emssim_port}=         4001
${input1}=				3
${loopNumberOfTimes}=    3
${egate_port}=          20000
${edaemon_port}=        10000
${egate_host}=          10.0.1.1
${swconfig_path}=     testsuite/Bangalore/ORAN/T11/CB014100/resources/swconfig.txt
${alias}=               default
${WEBUI_URL}                       https://192.168.255.129
${WEBUI_NAME}                      Nemuadmin
${WEBUI_PWD}                       nemuuser
${CUS_file}    ${CURDIR}/Config/CUS_login_prachcheck.sh
@{swconfig_flags}=      ${REDUCE_S1_RECONNECTION_TIME}
${REDUCE_S1_RECONNECTION_TIME}=    0x0015001B=15
${command}              dynamic_prach_conf_disp 0
${phraseinput}=         static-config-supported>PRACH
${value_true}=     true
${technology}=     LTE
*** Keywords ***
Suite setup
	taf.sbts.oam.coam.admin.Setup Admin
	${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}
	${rc}    ${hostname}=    Run And Return Rc And Output    hostname
	${scout_tl_name}=    Replace String    ${hostname}    -    _
    Set global variable     	${scout_tl_name}
    Copy swconfig to BTS    ${swconfig_path}
    Start Btslogs from Local machine     ${BTS_path}/${SUITE NAME}/${Date}/logfolder

Copy swconfig to BTS
    [Documentation]		copy swconfig file to BTS
    [Arguments]         ${swconfig_path}
    ${swconfig_source}=		Set Variable     ${swconfig_path}
    set global variable		${swconfig_source}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login    ${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.Put File
	...     source=${swconfig_source}
	...     destination=/ffs/run    scp=scp
    SSHLibrary.Close All Connections

Get RUs detection time
     ${ru_time}=    get_ru_traces_time_parsed
     set suite metadata   Radio setup time    ${ru_time}

Verify Call
    Log to console    \n --Attach UE and perform data call-- \n
    Run UEx command      ue_attach id=1 cell=1
    Run UEx command      trf_data_start ue=1 dir=dl_and_ul protocol=udp Mbps_dl=100 Mbps_ul=100 stats=true
    Run UEx command     trf_data_stats ue=1 unit=Mbps
    Run UEx command      ue_detach    id=1

Testline reconfiguration for ORAN
    [Arguments]      ${scf_xml}      ${coco_yaml}     ${swconfig_flags}
    Log To Console                       \n--eNB configuration--\n
    Run raw command  help
    CB014100_keyword.Configure Netconf Credentials
    Add Enb Configuration                scfc=${scf_xml}              rad_params=${swconfig_flags}
    Add Simulator     sim_type=cus                    config=${coco_yaml}
    Configure environment    validate_enb=True    validate_sim=True    rmod_detection=True
    Get RUs detection time

Configure Netconf Credentials
    taf.sbts.oam.coam.admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=${alias}
    ...    accounts=@{sudo_list}

Log collection and validation
    Log folder creation
    taf.sbts.oam.coam.admin.Collect Snapshot    target_file_name=${out}/${snapshotfilename}    timeout=${snapshottimeout}    connection=${alias}
    taf.file.pack.Extract      path=${out}/${snapshotfilename}     output_dir=${out}/${snapshotfilename_unzip}
	${status}    ${result}=    Run Keyword And Ignore Error
	...    os.Run And Return Rc And Output
	...    find ${out}/${snapshotfilename_unzip} -name "*RPC.log"
	# result[0] = rc
	# result[1] = stdout
	${rc}=    Set Variable    ${result}[0]
	${output}=    Set Variable    ${result}[1]
	IF    '${output}' == ''
		${rc2}    ${output}=    os.Run And Return Rc And Output
		...    find ${out}/${snapshotfilename_unzip} -name "*NetconfRpcMessageTrace.log"
	END
	Run Keyword If    '${output}' == ''    Log To Console    No matching log files found!    WARN
	Log    Found log files:\n${output}
	Set Global Variable    ${output}
    validate_netconf_reply_message    file_path=${output}    rpctag=get    replytag=data    subtag=section-type    value=3
	os.Get file     ${output}
	${phrase}=    Set Variable    ${phraseinput}
	Set global variable    ${phrase}

Search Phrase In File
    [Arguments]    ${output}    ${phrase}
    ${contents}=    Grep File    ${output}    ${phrase}
    ${lines}=    Split To Lines    ${contents}
    ${found}=    Set Variable    ${False}
    FOR    ${line}    IN    @{lines}
        IF    '${line.strip()}' == '${phrase}'
            Log    Phrase found: ${phrase}
            ${found}=    Set Variable    ${True}
            Exit For Loop
        END
    END
	Run Keyword If    not ${found}    Log To Console    \nPhrase not found: ${phrase}\n
	Should Not Be True    ${found}    Phrase was not found in the file: ${phrase}

Log folder creation
	${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
	${CurrentDate}=    Convert to String     ${CurrentDate}
	${SUITE NAME}    Set Variable    ${SUITE NAME}
	${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
	os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}
	${out}    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/logfolder
	Set global variable    ${out}

Expected alarm
    [Documentation]     Alarms which are ignored on runtime
    ${allowed_alarm_1}    Create alarm    alarm_id=7220     fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220     fault_id=4654     fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220     fault_id=61649    fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220     fault_id=4655     fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220     fault_id=61652    fault_name=R&D Service Port enabled
    ${allowed_alarm_6}    Create alarm    alarm_id=61641    fault_id=61641    fault_name=IP Traffic Capturing ongoing
    ${allowed_alarm_7}    Create alarm    alarm_id=7115     fault_id=4592     fault_name=BTS Reset Cause
    ${allowed_alarm_8}    Create alarm    alarm_id=7115     fault_id=8000     fault_name=Failure in connection between BTS and 3rd party tool
    ${allowed_alarm_9}    Create alarm    alarm_id=7102     fault_id=49       fault_name=Cell blocked
    ${allowed_alarm_11}    Create alarm    alarm_id=7115     fault_id=4681     fault_name=Sanity Check Error
    ${allowed_alarm_12}    Create alarm    alarm_id=7115     fault_id=4720
    ...     fault_name=Mismatch of RU reported capabilities with static HW Validation information
	${allowed_alarm_13}    Create alarm    alarm_id=7115     fault_id=4602     fault_name=5G cell configuration mismatch
	${allowed_alarm_14}    Create alarm    alarm_id=7110     fault_id=4293     fault_name=IP Traffic Capacity Limit
	${allowed_alarm_15}    Create alarm    alarm_id=7107     fault_id=6331     fault_name=PLMN Unavailable
	${allowed_alarm_16}    Create alarm    alarm_id=7115     fault_id=4673     fault_name=Configuration mismatch with O-RU capabilities
	${allowed_alarm_17}    Create alarm    alarm_id=7115     fault_id=4282     fault_name=Configuration and hardware mismatch
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}  ${allowed_alarm_9}
    ...     ${allowed_alarm_11}  ${allowed_alarm_12}  ${allowed_alarm_13}  ${allowed_alarm_14}    ${allowed_alarm_15}    ${allowed_alarm_16}
	...     ${allowed_alarm_17}
    [Return]    ${allowed_alarms}

Login to CUS
    Log to console     \n ---Logging in to CUS---\n
    ${raw_output}=    Cusmmilogin
    Log    \nRaw Output:\n${raw_output}
	${fft_size}=    get_cus_output    ${raw_output}
	Log    FFT Size: ${fft_size}

Check BTS is OnAir
    Log to console    \n Check if BTS is on air
    [Documentation]     Check the BTS current status
    ${bts_status}      taf.sbts.oam.coam.admin.get_bts_statuses     connection=${alias}
    Wait Until Keyword Succeeds    6min     5     Should Be Equal As Strings      ${bts_status["proceduralStatus"]}    OnAir
    Run Keyword If      '${bts_status["proceduralState"]}'=='OnAir'     LOG     BTS procedural state is now: ${bts_status["proceduralState"]}
    ...     ELSE    fail
    Log to console      \nBTS procedural state : ${bts_status["proceduralState"]}

Suite Teardown
	Get Resource Usage
    Link SCOUT SCF to Configuration ID for Reporting
    Stops Btslogs from Local machine

Robustness scenario
        Reset Site
		Verify Call
		ResetAllBBmod
		Verify Call
		AllLTEcellBlockUnblock
		Verify Call
		LTE RAT Reset
		Verify Call

Reset Site
	FOR    ${i}    IN RANGE   ${loopNumberOfTimes}
		taf.sbts.oam.coam.admin.reset_site
		...    wait_for_reconnection=${value_true}
		...    connection=${alias}
		...    timeout=600
        Log to console    \n Site reset in progress
		Wait Until Keyword Succeeds     10m    10s    CB014100_keyword.Check_BTS_State
        taf.sbts.oam.coam.admin.Collect Snapshot    ${out}/Reset_logs/Iteration${i}
	    taf.sbts.oam.coam.admin.collect_im_snapshot        ${out}/Reset_logs/Iteration${i}
        taf.sbts.oam.coam.admin.collect_raw_alarm_history_file        ${out}/Reset_logs/alarmSnapshotIteration${i}.json
        Run Keyword and Continue On Failure    Get ActiveAlarms
	END

ResetAllBBmod
    ${listBBMOD}=    taf.sbts.oam.coam.admin.get_ids_for_all    BBMOD
    log    ${listBBMOD}
    ${len}=    Get length    ${listBBMOD}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        taf.sbts.oam.coam.admin.reset_unit        dist_name=${listBBMOD}[${i}]
        ...                     reset_type=warm
        ...                     timeout=400
        ...                     connection=${alias}
        ...                     detailed_output=False
        Log to console    \n Baseband unit reset in progress
		Wait Until Keyword Succeeds     10m    10s    CB014100_keyword.Check_BTS_State
		taf.sbts.oam.coam.admin.Collect Snapshot    ${out}/BBMODReset_logs/Iteration${i}
	    taf.sbts.oam.coam.admin.collect_im_snapshot        ${out}/BBMODReset_logs/Iteration${i}
        taf.sbts.oam.coam.admin.collect_raw_alarm_history_file        ${out}/BBMODReset_logs/alarmSnapshotIteration${i}.json
        Run Keyword and Continue On Failure    Get ActiveAlarms
    END

LTE RAT Reset
	FOR    ${i}    IN RANGE    1    ${loopNumberOfTimes}
		CB014100_keyword.Check_BTS_State
		Perform RAT Reset
		Wait Until Keyword Succeeds     10m    10s    CB014100_keyword.Check_BTS_State
		taf.sbts.oam.coam.admin.Collect Snapshot    ${out}/RATReset_logs/Iteration${i}
	    taf.sbts.oam.coam.admin.collect_im_snapshot        ${out}/RATReset_logs/Iteration${i}
        taf.sbts.oam.coam.admin.collect_raw_alarm_history_file        ${out}/RATReset_logs/alarmSnapshotIteration${i}.json
        Run Keyword and Continue On Failure    Get ActiveAlarms
	END

Perform RAT Reset
    Log to console   \n--RAT reset in progress--\n
    Get RAT Type
    FOR    ${RAT}    IN    @{rat_types}
        Run Keyword    taf.sbts.oam.coam.admin.rat_reset    rat_type=${RAT}    connection=${alias}    timeout=180    reset_type=Soft
    END
    Log to console   \n--RAT reset Completed--\n

Get RAT Type
    ${rat_types}    Create List
    ${nr_cells}    taf.sbts.oam.coam.admin.get_cells_info    cell_type=nr    connection=${alias}
    ${ne_cell_count}    Get Length    ${nr_cells}
    ${lte_cells}    taf.sbts.oam.coam.admin.get_cells_info    cell_type=lte    connection=${alias}
    ${lte_cell_count}    Get Length    ${lte_cells}
    Run Keyword If    ${ne_cell_count}!=${0}    Append To List    ${rat_types}    NR
    Run Keyword If    ${lte_cell_count}!=${0}    Append To List    ${rat_types}    LTE
    [Return]    ${rat_types}
	Set global variable      ${rat_types}

Start Btslogs from Local machine
    	[Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
        [Arguments]    ${log_directory}
    	os.Run     killall btslog
    	Run Keyword And Continue On Failure    btslog.create_btslog_collector    name=btslog
    	Run Keyword And Continue On Failure    CORE.setup_collectors    names=btslog
    	Run Keyword And Continue On Failure    CORE.set_suite_alias    btslog
    	Run Keyword And Continue On Failure    CORE.start_collectors    names=btslog
        Log    StartLogs on ${log_directory}

Stops Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: "/tmp/btslog2"
    #[Arguments]    ${log_alias}
    Run Keyword And Continue On Failure     core.stop_collectors      btslog
    Run Keyword And Continue On Failure     core.collect_collectors      names=btslog      target_dir=${out}/syslogs
    Run Keyword And Continue On Failure    core.teardown_collectors      btslog

Check_BTS_State
    ${bts_state}=    taf.sbts.oam.coam.admin.get_mrbts_state
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

AllLTEcellBlockUnblock
    ${listlncel}=    taf.sbts.oam.coam.admin.get_ids_for_all    LNCEL
    log    ${listlncel}
    ${len}=    Get length    ${listlncel}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        taf.sbts.oam.coam.admin.block_cell    dist_name=${listlncel}[${i}]
        ...                 timeout=30
        ...                 detailed_output=False
        ...                 connection=${alias}
        Sleep    10s
        Log to console    \n Cell blocked
        taf.sbts.oam.coam.admin.unblock_cell    dist_name=${listlncel}[${i}]
        ...                   timeout=30
        ...                   detailed_output=False
        ...                   connection=${alias}
        Log to console    \n Cell Unblocked
		Wait Until Keyword Succeeds     10m    10s    CB014100_keyword.Check_BTS_State
		taf.sbts.oam.coam.admin.Collect Snapshot    ${out}/BlockUnblock_logs/Iteration${i}
	    taf.sbts.oam.coam.admin.collect_im_snapshot        ${out}/BlockUnblock_logs/Iteration${i}
        taf.sbts.oam.coam.admin.collect_raw_alarm_history_file        ${out}/BlockUnblock_logs/alarmSnapshotIteration${i}.json
        Run Keyword and Continue On Failure    Get ActiveAlarms
    END

Get ActiveAlarms
	${allowed_alarms}    Expected alarm
	alarm.watch alarms    allowed_alarms=${allowed_alarms}
    ${Active_alarm}    alarm.get_active_alarms
    LOG     ${Active_alarm}
    alarm.check_detected_alarms
    alarm.stop_watching_alarms

Get Resource Usage
   cli.create_aashell_cli    name=aashell
   cli.setup    aashell
   ${resources_usage}=    cli.get_resources_usage    aashell
   [Teardown]    cli.teardown   aashell
