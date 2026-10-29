*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy, Sreekumar Narimuri Kumaran, Lekhashree S N
...   Description: keywords for CB011062
Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    DateTime
Library    RequestsLibrary
Library    Process
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.ue    WITH NAME    ue
Library    taf.hw.pdu    WITH NAME    pdu
Library    taf.ul.alarms_watchdog
Library    taf.analyzer.netconf
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.fdsw.rc     WITH NAME    rc
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library    taf.sw.scout    WITH NAME    scout
Library    taf.nms.netact  WITH NAME    netact
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/Topyoung_Attenuator_T08.robot
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/CommonKeywordResourceFile.robot
Resource	testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot


*** Variables ***
${pcap}        pcap
${DURATION}    600
${VM_usn}    ute
${VM_pwd}    BT5l@bus3rl0g1n
@{UE_alias}=    UE2
@{capabilities}=    Legacy_2
@{timeout}=    100
${dt_name_dl}=    iperf_dl_test_1
${dl_name}=    iperf_dl_test_1
${filter_pcmd}           ntrstr
${mplane_ip}		    10.58.239.191
${testcase_name}            DCAPlog1
&{BTS_INFO}                 host=${mplane_ip}	port=443
${MRBTS_ID}=    1024
${RAT_ID}=    MRBTS-1024/NRBTS-1024
${CELL_ID}=    MRBTS-1024/NRBTS-1024/NRCELL-0
${BBMOD_ID}=    MRBTS-1024/EQM-1/APEQM-1/CABINET-1/BBMOD-1
${RMOD_ID}=    MRBTS-1024/EQM-1/APEQM-1/RMOD-1
${GNSSE_ID}=    MRBTS-1024/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
&{powerReset}=    type=powerReset    distname=PLMN-PLMN/MRBTS-${MRBTS_ID}
&{ratReset}=    type=ratReset    distname=PLMN-PLMN/${RAT_ID}
&{bbmodReset}=    type=bbmodReset    distname=PLMN-PLMN/${BBMOD_ID}
&{rmodReset}=    type=rmodReset    distname=PLMN-PLMN/${RMOD_ID}
&{gnsseReset}=    type=gnsseReset    distname=PLMN-PLMN/${GNSSE_ID}
&{cellReset}=    type=cellReset    distname=PLMN-PLMN/${CELL_ID}
@{reset_list}       &{powerReset}    &{ratReset}    &{rmodReset}  &{gnsseReset}  &{cellReset}
${web_url}=    srnclab1042lbwas.srnblr.nsn-rdnet.net
${netAct_user_name}    omc
${netAct_user_password}    Medsql!_1893
${NETACT_HOST_NAME}=     10.43.48.16
${ip_pdu}		10.58.242.49
${ip_pdu_port}		8
@{allowed_custom_alarms}    4655  61649  61524  4654  61652  6150  8000  4681  7312  7304  7313
${VM_IP}    10.58.238.125
${VM_username}    ute
${VM_password}    BT5l@bus3rl0g1n
@{deviation_dl}=    100
@{throughput_dl}=    1000
@{direction_dl}=      dl
@{CALL_type}    UDP
${alias}=    admin_1
${LBWAS_NODE}=    srnclab1042lbwas.srnblr.nsn-rdnet.net
${ENB_MPLANE_IP}=    10.58.239.191
${DCAP_host}                10.41.209.110
${DCAP_LITE_host}           10.58.238.125
${DCAP_username}	    utfuser
${DCAP_password}	    utfadmin!
${DCAP_LITE_username}	    utfuser
${DCAP_LITE_password}	    utfadmin!
${port}                     443
${DCAP_LITE_port}           9443
${secure}                   True
${rd_version}               dcapv3
${Default_DCAP_duration}    -1
${dcap_log_timeout}         1200
@{gnb_custom_filter}        condor5gSyslog
@{bts_custom_filter}        scf        		ipCapture
@{collection_timing}        Immediate       TraceEnd
${PCMD_cont}    id-VER-GNB-CUUP-CuUpUlRadioBearerPdcpMeasTraceRecord    id-VER-GNB-CUUP-CuUpDlRadioBearerPdcpMeasTraceRecord
...			ulRbPdcpMeasRecord    dlRbPdcpMeasRecord
@{port_numbers}		1	2	3	4	5	6	7	8	9
${source_bts_rf_port}		5
${target_bts_rf_port}		9
${pva_ip}    10.45.153.212
${pva_vendor}    TOPYOUNG
${pva_model}	 TAS16T16-51-120-1N-DEJS
${filter_pcap}               ngap
${message}    InitialContextSetupRequest    InitialContextSetupResponse
${unsecure_ciphering}			False
${authentication_method}    	NoAuthentication
&{default_NetconfAccount}		defaultNetconfAccountName=fjncuser0		defaultNetconfAccountPwd=ncCl2fjRu+autH0
&{netconf_mandatory_params}    	id=1		defaultNetconfAccount=&{default_NetconfAccount}
@{netconf_accounts}				${netconf_mandatory_params}
@{lock_distname_oran}    NRCELL-0    NRCELL-1
@{lock_distname_cpri}    NRCELL-2    NRCELL-3    NRCELL-4    NRCELL-5
${MCG_IP}    10.45.150.208
${MCG_usn}    inbabtslabuser
${MCG_pwd}    BT5l@bus3rl0g1n
${MCG_domain}      NOKLAB
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${scf_oran_rp1}		    testsuite/Bangalore/ORAN/T08/CB011062/config/SCF_ASOG_OFEGSA_AHHB.xml
${swconfig_path}=     testsuite/Bangalore/ORAN/T08/resources/config/swconfig.txt
*** Keywords ***
Reset_via_netact
    [Arguments]    ${dist_names}    ${type}
	NetAct Setup
    ${time_before_reset}=  Get Current Date
    ${gcf}=  Set variable  gracefulCellShutdown
	Run Keyword If  '${type}'=='powerReset'
    ...  netact.Reset NE    dist_names=${dist_names}    parameters=btsResetType=powerReset  parameters=${gcf}=false  verbose=True
    ...  ELSE  netact.Reset NE    dist_names=${dist_names}    verbose=True
    ${time_after_reset}=  Get Current Date
    ${time_diff}=  Subtract Date From Date  ${time_after_reset}  ${time_before_reset}
	[Return]	${time_diff}

Perform Resets from Netact
    [Documentation]   This keyword will perform all resets defined in list
	FOR   ${reset}   IN   @{reset_list}
		Syslog_start
		${reset_type} =    Get From Dictionary    ${reset}    type
	    Log To Console    Reset type : ${reset_type}
		create directory     ${out}${reset_type}
		log to console     path created     ${out}${reset_type}
		log to console   \n---${reset_type} is started---
		${type}=    Set variable    ${reset}[type]
		${time_diff}=	Reset_via_netact     ${reset}[distname]    ${type}
		Log To Console    Reset time is ${time_diff}
		Run Keyword If   '${type}'=='ratReset'
		...  	Should Be True  ${time_diff}<200
		...     ELSE     Should Be True  ${time_diff}<360
		Wait Until Keyword Succeeds    10min    10s    Check BTS is OnAir	oam
		Attach UE and start throughput   ${UE_alias}    ${direction_dl}    ${timeout}
        PVA_Attenuator_no_att_for_rp1_radio    ${pva_ip}    ${pva_vendor}   ${pva_model}
		Attach UE and data transfer on CPRI radio NR cells
        PVA_Attenuator_full_att_for_rp1_radio    ${pva_ip}    ${pva_vendor}   ${pva_model}
		NetAct Teardown
		log to console   \n---${reset}[type] is completed---
		sleep    30s
		Collect Snapshot    ${out}${reset_type}/Snapshot.zip
		Log To Console      Snapshot is collected for Reset type : ${reset_type}
		${syslogpath}=    Set variable     ${out}${reset_type}/
		Syslog_stop     ${syslogpath}
		Log To Console      Syslog is collected for Reset type : ${reset_type}
	END

Preconditions
    Log    Connecting to NetAct supporting CB010239   console=${True}
    ${enb_release}=  CoamAdmin.get sw release name    connection=oam
    Set Test Variable  ${NETACT_CONNECTERD}  ${False}
    Set Test Variable  ${RMOD_OFF}  ${False}
    Set Test Variable  ${NETACT_CONNECTERD}  ${True}
    ${bts_id}  Get BTS ID
    ${dist_name}    Set Variable    PLMN-PLMN/MRBTS-${bts_id}
    Set Test Variable  ${DIST_NAME}    ${dist_name}
    NetAct Teardown
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=oam
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \nBTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    Turn on RMOD from pdu

Turn off RMOD to generate FID:10
    Log    Step 1: Turn off RMOD to generate FID:10  console=${True}
    pdu.setup_pdu    model=RRB    host=${ip_pdu}    alias=RRB_connection
    pdu.power_off    port=${ip_pdu_port}   pdu_device=RRB_connection
    Sleep   60

    ${fault_status}  Run keyword and return status  Wait until keyword succeeds  420  10
    ...  CoamAdmin.Assert Alarm Active  parameters=alarmId=7116, faultId=10, faultName="No connection to unit", severity=Critical
	...    timeout=120    connection=oam
    Run keyword if  ${fault_status}
    ...  Log  Fault 10 "No connection to unit" - severity=Critical - appeared  console=${True}
    ...  ELSE  Set Test Failed    Fault 10 "No connection to unit - did not not appear    ${True}

Run Diagnostic Check allow_service_impact=False
    Log    Step 2: Run Diagnostic Check allow_service_impact=False    console=${True}
    ${time1}=    Get Current Date    result_format=datetime
    Set Test Variable  ${start_time}  ${time1}
    NetAct Setup
    add_node   service_name=cmwas   hostname=${NETACT_HOST_NAME}
    ...        username=${netAct_user_name}  password=${netAct_user_password}    alias=netactlab
    ${DC_output}    netact.Run Diagnostic Check  ${DIST_NAME}  allow_service_impact=false  verbose=true  timeout=500
	Sleep     60
    Log    Check if Check point 31 Active critical alarms NOK    console=${True}
    Should Contain   ${DC_output}   Details: Check point failure: 31 Active critical
    ${alarm_history}    CoamAdmin.Get Alarms    connection=oam    detailed_output=True
    Set Test Variable  ${alarm_list}    ${alarm_history}[requestMessage]
    Set Test Variable  ${CONDITION_NOT_MET}  ${True}
    FOR  ${alarm}  IN  @{alarm_history}
      ${contains_faultid}    Run Keyword And Return Status
      ...    Should Contain    ${alarm}    faultId=4681
      ${contains}    Run Keyword And Return Status
      ...    Should Contain    ${alarm}    additionalFaultID=4681
      ${faultSeverity}    Fetch From Right  ${alarm}  faultSeverity
      ${faultDescription}    Fetch From Right  ${alarm}  faultDescription
      ${DC_points_with_NOK_results}    Fetch From Right  ${alarm}  supplAlarmInfo
      Run Keyword If    '${contains_faultid}' == 'True' and '${faultSeverity}' == 'Warning' and '${faultDescription}' == 'Diagnostic Check Error'
	  ...  Run Keywords     Log    Fault 4681 was found with severity=Warning  console=${True}
      ...  AND    Set Test Variable  ${CONDITION_NOT_MET}  ${False}
      ...  AND    Exit For Loop
    END
    Run keyword if  ${CONDITION_NOT_MET}
    ...  Log  WebEM: Fault 4681 "Diagnostic Check Error" is active on BTS. [OK]  console=${True}
    ...  ELSE  Set Test Failed  WebEM: Fault 4681 "Diagnostic Check Error" is not active on BTS. [NOK]    ${True}

Check if FaultID 4681 appeared on NetAct
    Log    Step 3: Check if FaultID 4681 appeared on NetAct    console=${True}
    Sleep     60
    ${end_time}=    Get Current Date    result_format=datetime
    ${alarms}=    netact.Get Cleared Alarms    dist_name=PLMN-PLMN/MRBTS-1024   time_from=${start_time}
    ...                                 time_to=${end_time}    alias=None
    Log   ${alarms}    console=${TRUE}

    Set Test Variable  ${CONDITION_NOT_MET}  ${True}
    FOR  ${alarm}  IN  @{alarms}
      ${perceivedSeverity}=     Get From Dictionary    ${alarm}   perceivedSeverity
      ${additionalFaultID}=     Get From Dictionary    ${alarm}   additionalText3
      ${contains}    Run Keyword And Return Status
      ...    Should Contain    ${additionalFaultID}    additionalFaultID=4681
      ${DC_points_with_NOK_results}    Fetch From Right  ${additionalFaultID}  supplAlarmInfo=
      ${DC_points_with_NOK_results2}   Fetch From Left  ${DC_points_with_NOK_results}    .
      ${contains2}    Run Keyword And Return Status
      ...    Should Contain    ${DC_points_with_NOK_results2}    31
      Run Keyword If    '${contains}' == 'True' and '${contains2}' == 'True'    Run Keywords
      ...  Log    Fault 4681 was found on netact    console=${True}
      ...  AND    Set Test Variable  ${CONDITION_NOT_MET}  ${False}
      ...  AND    Exit For Loop
    END
    Run Keyword if    ${CONDITION_NOT_MET}   Set Test Failed    Fault 4681 was not found on netact.    ${True}

Run Diagnostic Check allow_service_impact=True
    Log    Step 5: Run Diagnostic Check allow_service_impact=True    console=${True}
    ${DC_output_2}    netact.Run Diagnostic Check  ${DIST_NAME}  allow_service_impact=false  verbose=true  timeout=500
    Log    Check if Check point 31 Active critical alarms OK    console=${True}
    Should Contain   ${DC_output_2}   Check point successful: 31 Active critical alarms
    NetAct Teardown

Get BTS ID
    ${bts_info}    CoamAdmin.Get Bts Info	connection=oam
    ${bts_id}    Set Variable  ${bts_info['mrbtsID']}
    ${bts_id}    Convert To String    ${bts_id}
    [Return]  ${bts_id}

Check if NetAct is deintegrated
    [Documentation]   Checks if NetAct is deintegrated
    ${NetAct_obj_IM}   Run Keyword And Return Status
    ...   Query Infomodel  none /MRBTS-*/RAT-*/NE3SADAPT-*   timeout=60   allow_negative_result=False
    Run Keyword If   ${NetAct_obj_IM}   Return From Keyword

    ${proceduralState_NetAct}   Run Keyword And Return Status
    ...   Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [stateInfo.proceduralState=Disconnected]
    ...   timeout=60   allow_negative_result=False
    Run Keyword Unless   ${proceduralState_NetAct}
    ...   Set Test Failed
    ...   It was expected, that NetAct will be deintegrated to BTS at this point, check manually why deintegration failed.   ${TRUE}

    ${connection_to_NetAct}   Run Keyword And Return Status
    ...   Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [managerInfo=empty]
    ...   timeout=60   allow_negative_result=False
    Run Keyword Unless   ${connection_to_NetAct}
    ...   Set Test Failed
    ...   It was expected, that NetAct will be deintegrated to BTS at this point, check manually why deintegration failed.   ${TRUE}

Set Test Failed
    [Documentation]
    ...  Mark the test as failed, but do not go to teardown if fail_fast is not True.
    ...  example of simple use:
    ...  Run Keyword If  'a'==`a`
    ...  Set Test Failed    failed reason    ${True}
    ...  default ${fail_fast}=False

    [Arguments]    ${failed_message}    ${fail_fast}=False

    Run Keyword if  ${fail_fast}  Fail  ${failed_message}
    ...  ELSE    Run Keyword And Continue On Failure  Fail  ${failed_message}

Turn on RMOD from pdu
    Log    Turning on RMOD    console=${True}
    pdu.setup_pdu    model=RRB    host=${ip_pdu}    alias=RRB_connection
    pdu.power_on    port=${ip_pdu_port}   pdu_device=RRB_connection
    sleep    10
	Wait Until Keyword Succeeds    10min    10s    Check BTS is OnAir	oam

Common Test Setup
    Log To Console    \nconnecting to BTS
    CoamAdmin.Teardown All Aliases For Admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console   \n BTS is Connected
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=oam
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \nBTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    Turn on RMOD from pdu
    Wait Until Keyword Succeeds  30s  10s  Get Configuration Details
    ${opt}    set variable    ${SUITE_PATH}/CB011062/
    set test variable    ${opt}
    create directory     ${opt}
    Download SCF
    ${allowed_alarms}=    Expected_alarm
    Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=oam
    Create dcap session
	Lock_Cell_source_BTS

Common Test Teardown
    stop watching alarms
    Download SCF
    Collect Snapshot    ${opt}Snapshot.zip
	Unlock_Cell_source_BTS
	NetAct Teardown
	Turn on RMOD from pdu
    CoamAdmin.teardown    oam
    Log To Console    \nBTS IS Disconnected

Common Suite Setup
    Log to console    \n--Suite Setup--\n
    Open_Admin_Connection
    ${SUITE_PATH}    set variable    ${OUTPUT_DIR}/
    Set Suite Variable    ${SUITE_PATH}
    log to console    .....--Precondition--.....
	PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}   ${pva_model}
    Close_Admin_Connection

Open_Admin_Connection
    Log To Console    connecting to BTS
    CoamAdmin.teardown_all_aliases_for_admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam

Close_Admin_Connection
    CoamAdmin.teardown    oam
    Log To Console    BTS IS Disconnected

Common Suite Teardown
    Open_Admin_Connection
    Close_Admin_Connection
    Link SCOUT SCF to Configuration ID for Reporting

SCF commissioning and check ONAIR
    [Documentation]  ... Commissiioning BTS and checking BTS status
    [Arguments]    ${scf}    ${DUR}
    Log to console    BTS commissioning is Ongoing
    ${status}=    CoamAdmin.perform_commissioning    scf_file=${scf}    timeout=${DUR}    connection=oam
    Sleep    5min
    Wait Until Keyword Succeeds    10min    10s    Check BTS is OnAir	oam

Download SCF
    [Documentation]    ... Downloading SCF
    ${timestamp}    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S
    ${filename}    SET VARIABLE    ${opt}${timestamp}_scf.xml
    CoamAdmin.get_current_scf_file    connection=oam    file_name=${filename}    timeout=60    local_dir_path=${opt}
    OperatingSystem.File Should Exist    ${filename}
    Log To Console    \nSCF Downloaded
    Log To Console    \nSCF file name is ${filename}
    [Return]    ${filename}

Collect Snapshot
    [Arguments]     ${path}
    ${snapshot_file_path}    set variable    ${path}
    CoamAdmin.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    timeout=300
    ...    connection=oam
    Log To Console    \nSnapshot collected and saved on path ${snapshot_file_path}

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log	  ${a}
    Log To Console    \nUE preparation completed

Attach UE and data transfer on CPRI radio NR cells
	FOR   ${cell}   IN    @{lock_distname_oran}
		CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/${cell}    timeout=60    connection=oam
		sleep    30s
	END
	FOR   ${cell}   IN    @{lock_distname_cpri}
		CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/${cell}    timeout=60    connection=oam
		sleep    30s
	END
	CoamAdmin.unlock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-2    timeout=60    connection=oam
	sleep    30s
	Attach UE and start throughput   ${UE_alias}    ${direction_dl}    ${timeout}
	CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-2    timeout=60    connection=oam
	sleep    30s
    CoamAdmin.unlock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-0    timeout=60    connection=oam
	sleep    30s

Attach UE and start throughput
    [Arguments]     ${UE_alias}   ${direction}   ${timeout}
    Prepare UE    ${UE_alias}     ${capabilities}
    Get TcpdumpLogs from Remote machine
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Sleep    30
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep    30
    ${output}    Convert pcap file    ngap
    validate wireshark logs    ${output}    InitialContextSetupRequest    0
    validate wireshark logs    ${output}    InitialContextSetupResponse    0
    Move File    ${out}tcpdump/tcpdump.pcap    ${out}tcpdump/tcpdump1.pcap
    Log To Console    \nUE Attach Successful and starting data transfer\n
    ta_ultracaller.start_datatransfer  ${UE_alias}  ${CALL_type}  direction=${direction}
    log to console    \nStop data transfer\n
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
    Log To Console    \nUE Data Transfer Successful\n
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    20

Get TcpdumpLogs from Remote machine
    [Documentation]    this keyword is used to capture wireshark log in wireshark PC
    log to console    \nStarting Wireshark Logs
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.239.191
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-i any
    ...    executor=${executor_oam_vm}
    core.setup_collectors    names=tcpdump
    core.set_suite_alias	tcpdump
    core.start_collectors    names=tcpdump


SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    SSHLibrary.close connection

Convert pcap file
    [Arguments]    ${filter_pcap}
    log to console    \nStopping Wireshark Logs
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump    target_dir=${out}
    core.teardown_collectors    names=tcpdump
    ${command}=    set variable    tshark -r ${out}tcpdump/tcpdump.pcap -Y "${filter_pcap}" > ${out}tcpdump/tcpdump.txt
	Run    ${command}
    sleep    60s
    ${filepath}    set variable    ${out}tcpdump/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    [Return]    ${file}

Convert wireshark pcap File To Text
	[Arguments]    ${testcase_name}    ${filter_pcap}
	[Documentation]        Convert Wireshark logs collected from DCAP
	${path1}     Set Variable        ${out}${testcase_name}/
    ${source_paths}    Set Variable        ${path1}Extracted/
    create directory         ${source_paths}
	${date}    Get Current Date    result_format=%Y%m%d
    ${files}    OperatingSystem.List Files In Directory    ${path1}
    FOR    ${zip}    IN    @{files}
		Start Process		unzip    -q    ${path1}${zip}    -d    ${source_paths}
		sleep     5
	END
	${it}=    OperatingSystem.List Directory    ${source_paths}${date}
    FOR    ${out_index}    IN    @{it}
		${exists}    ${pcap_file_name}=    Iterate and Check pcap extension file exists      ${source_paths}${date}/${out_index}
        run keyword if    "${exists}" == "True"    Run keyword And Ignore Error    Start wireshark pcap File Conversion To Text with MCG PC
        ...    source_path=${source_paths}${date}/${out_index}
		...    source_file=${pcap_file_name}    filter=${filter_pcap}
    END
    ${output}    ssh.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm        timeout=30s
    LOG     ${output}


Start wireshark pcap File Conversion To Text
    [Arguments]    ${source_path}     ${source_file}    ${filter}
    ${source_pcap_file}=    OperatingSystem.List Directory    ${source_path}/${source_file}
    ${first}=   set variable    tshark -r ${source_path}/${source_file}/${source_pcap_file}[0] -Y "${filter}" >
    ${second}=    set variable    ${source_path}/${source_file}/tcpdump.txt
    ${command}=    set variable    ${first}  ${second}
    Run    ${command}
	sleep    60s
    ${filepath}    set variable    ${source_path}/${source_file}/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
	[Return]	${file}

Start wireshark pcap File Conversion To Text with MCG PC
    [Documentation]  this keyword will convert pcap file to .txt format in MCG PC.
    [Arguments]    ${source_path}     ${source_file}    ${filter}
    ssh.Connect_to    ${MCG_IP}    ${MCG_usn}    ${MCG_pwd}    alias=mcg_vm
	ssh.upload_file    local_path=${source_path}/${source_file}    remote_path=${uepc_Log_path}//tcpdump.pcap
    ...    connection=mcg_vm
    ${first}=   set variable    cd "/cygdrive//c//Program Files//Wireshark" && .//tshark.exe
    ${second}=    set variable    -r ${uepc_Log_path}//tcpdump.pcap -Y "${filter}" > ${uepc_Log_path}//tcpdump.txt
    ${run_command}=    set variable    ${first}  ${second}
	LOG	${run_command}
	${output}		ssh.Execute    command=${run_command}      connection=mcg_vm		timeout=30s
	LOG		${output}
	sleep    1min
	ssh.download_file    remote_path=${uepc_Log_path}//tcpdump.txt		local_path=${out}/tcpdump//tcpdump.txt     connection=mcg_vm
    ${filepath}    set variable    ${out}tcpdump/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    [Return]    ${file}




Iterate and Check pcap extension file exists
	[Arguments]    ${folder_path}
	${files}=    OperatingSystem.List Files In Directory    ${folder_path}
	${status}=    Set Variable     False
	FOR    ${file}    IN    @{files}
		${rest}    ${last}=    Split String From Right    ${file}    .    1
		log    ${rest}
		log    ${last}
		${status}=    Run Keyword And Return Status    Should Contain    ${last}     pcap
		log		${status}
		IF    "${last}" == "${pcap}"
		    ${status}=    Set Variable     ${True}
		END
		Exit For Loop IF    "${last}" == "${pcap}"
	END
	[Return]    ${status}     ${file}



validate wireshark logs
    [Documentation]    this keyword is used to validate wireshark logs
    [Arguments]    ${logfile}    ${message}    ${content}
    @{log}    Split to lines    ${logfile}
    FOR    ${a}    IN    @{log}
         ${status}    run keyword and return status    should contain    ${a}    ${message}
         run keyword if    '${status}'=='True' and '${content}'=='0'    exit for loop
         ${status}    run keyword if    '${status}'=='True'    For loop for wireshark validation    ${a}    ${content}
         ${status}    run keyword if    '${status}'=='True'    exit for loop
    END
    Run Keyword if    '${status}'=='True'    Log to console    ${message} message is found in wireshark log
    ...    ELSE    Log to console     ${message} message is not found in wireshark log
    Run Keyword if    '${status}'!='True'    fail

For loop for wireshark validation
    [Arguments]    ${log}    ${message}
    ${list_length}    Get Length    ${message}
    FOR    ${a}    IN    ${message}
        ${status}    run keyword and return status    should contain    ${log}    ${a}
        ${count}    run keyword if    '${status}'=='True'     Evaluate    ${count} + 1
        run keyword if    '${count}'=='${list_length}'    exit for loop
    END
    [Return]    ${status}

NetAct Setup
	netact.Add Web URL  ${LBWAS_NODE}  ${netAct_user_name}  ${netAct_user_password}
    netact.Add Node  cmwas  ${NETACT_HOST_NAME}  ${netAct_user_name}  ${netAct_user_password}
    netact.Add Node  fmwas  ${NETACT_HOST_NAME}  ${netAct_user_name}  ${netAct_user_password}
    ${NA_ID}  Get Substring  ${LBWAS_NODE}  0  -26
    Log  Integrated to NetAct ID ${NA_ID}  WARN
    Log  NetAct: <a href="https://${LBWAS_NODE}">${NA_ID}</a>  WARN  html=True

NetAct Teardown
	netact.Add Web URL  ${LBWAS_NODE}  ${netAct_user_name}  ${netAct_user_password}
    netact.Delete Node  cmwas
    netact.Delete Node  fmwas
    Log  NetAct services are deleted - cmwas and fmwas

Automatic Netact Integration
    [Arguments]    ${mr}=MRC-Common/MR-Common
    ${sw_release}    Get SW Release Name
    Run keyword and ignore error    netact.Deintegrate MRBTS from NetAct    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${status}    Run keyword and return status    netact.Integrate MRBTS with NetAct    release=${sw_release}
    ...    mr=${mr}  mrbts_address=${ENB_MPLANE_IP}
    ...    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}  security_mode=no TLS
    ${mr_upper}    Run Keyword If   not ${status}    Evaluate   "${mr}".upper()
    Run Keyword If    ${status}    Log   Integration completed
    ...    ELSE   netact.Integrate MRBTS with NetAct    release=${sw_release}
    ...    mr=${mr_upper}  mrbts_address=${ENB_MPLANE_IP}
    ...    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}  security_mode=no TLS

Get Configuration Details
    ${bts_info}=  CoamAdmin.get bts info  connection=oam
    Set Suite Variable  ${active_sw_version}  ${bts_info['swInfo']['swVersion']}
    ${regex}=  Set Variable  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)_(ENB|FSM3)_(?P<version>\\d{4})
    ${result}=  Get Regexp Matches  ${active_sw_version}  ${regex}  product  postfix
    ${result_version}=  Get Regexp Matches  ${active_sw_version}  ${regex}  version
    ${product}  ${postfix}=  Set Variable  ${result[0]}
    ${product}=  Convert To Uppercase  ${product}
    ${postfix}=  Convert To Uppercase  ${postfix}
    Set Suite Variable  ${SW_TYPE}  ${product}${postfix}
    Run Keyword If  '${result_version[0]}'=='0000'  Set Suite Variable  ${RELEASE}  ${SW_TYPE}
    ...  ELSE IF  '${result_version[0]}'=='9999'  Set Suite Variable  ${RELEASE}  SBTS00
    Set Suite Variable  ${MRBTS_ID}  ${bts_info['mrbtsID']}
    Run Keyword And Ignore Error  Set Suite Variable  ${NRBTS_ID}  ${bts_info['nrBtsId']}

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
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${out}${testcase_name}    timeout=${dcap_log_timeout}

Check_dcap_capture_is_ready
	${result}=   rd.get_trace_info_by_id     trace_id=${START_TRACE_ID}   timeout=30
	Run Keyword If  '${result}[status]'=='ready'
    ...    Log To Console    \ntrace_id=${START_TRACE_ID} is in ready state
    ...    ELSE    fail


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

Expected_alarm
    ${allowed_alarm_1}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61524
    ...                    fault_name=SSH enabled

    ${allowed_alarm_2}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4654
    ...                    fault_name=Ethernet port security is disabled

    ${allowed_alarm_3}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61649
    ...                    fault_name=LMP access via port 443

    ${allowed_alarm_4}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4655
    ...                    fault_name=Service account root access is enabled

    ${allowed_alarm_5}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61652
    ...                    fault_name=R&D Service Port enabled


    ${allowed_alarms}=     Create list
    ...                    ${allowed_alarm_1}
    ...                    ${allowed_alarm_2}
    ...                    ${allowed_alarm_3}
    ...                    ${allowed_alarm_4}
    ...                    ${allowed_alarm_5}

    [Return]    ${allowed_alarms}

Convert pcap file with MCGPC
    [Documentation]  this keyword will stop wireshark log collection and convert pcap file to .txt format.
    log to console    Stoping Wireshark Logs
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump    target_dir=${out}
    core.teardown_collectors    names=tcpdump
    ssh.Connect_to    ${MCG_IP}    ${MCG_usn}    ${MCG_pwd}    alias=mcg_vm
	ssh.upload_file    local_path=${out}/tcpdump//tcpdump.pcap    remote_path=${uepc_Log_path}//tcpdump.pcap
    ...     connection=mcg_vm
	${run_command}    Set Variable
    ...     cd /cygdrive//c//Wireshark && .//tshark.exe -r ${uepc_Log_path}//tcpdump.pcap -Y "e2ap" > ${uepc_Log_path}//tcpdump.txt
	LOG	${run_command}
	${output}		ssh.Execute    command=${run_command}      connection=mcg_vm		timeout=30s
	LOG		${output}
	sleep    1min
	ssh.download_file    remote_path=${uepc_Log_path}//tcpdump.txt		local_path=${out}/tcpdump//tcpdump.txt     connection=mcg_vm
    ${filepath}    set variable    ${out}tcpdump/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    [Return]    ${file}

Syslog_start
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

Syslog_stop
    [Arguments]    ${syslogpath}
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog    target_dir=${syslogpath}
    core.teardown_collectors      names=btslog
    Log To Console    BTS IS Disconnected
