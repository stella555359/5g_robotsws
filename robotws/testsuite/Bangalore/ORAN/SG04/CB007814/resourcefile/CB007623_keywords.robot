*** Settings ***
Documentation     Keywords and variables for CB007623.robot file
...               Author: Rakshith.b@nokia.com
Library           String
Library           DateTime
Library           CB007623.py
Library           Collections
Library           OperatingSystem
Library           taf.sw.dcap.rd   WITH NAME   rd
Library           taf.config.scf   WITH NAME    scf
Library           taf.selenium.sbts    WITH NAME    seleLib
Library           taf.collectors.core    WITH NAME    CORE
Library           taf.ul.alarms_watchdog   WITH NAME    alarm
Library           taf.sbts.oam.coam.admin    WITH NAME    COAM
#Library          taf.collectors.btslog    WITH NAME    BTSLOG
Library           taf.hw.rf_attenuator.attenuator  WITH NAME  at
Library           ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Resource          ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Library           ./testsuite/Bangalore/ORAN/SG04/CB007814/resourcefile/CB007623.py
Library           taf.sw.scout    WITH NAME    scout
Library           taf.transport.ssh
*** Variables ***
${Scout_tl_name}            1_2_CLOUD970
${BTS_IP}                   192.168.255.129
${uepc_default_ip}          10.45.150.167          # Windows UE PC IP
${BTS_M_plane_ip}           10.58.239.174
${DCAP_host}                10.41.209.115           # DCAP server IP
${uepc_default_username}    inbabtslabuser          # Windows UE PC username
${uepc_default_password}    BT5l@bus3rl0g1n         # Windows UE PC password
${emil_path}                C://Emil                # Emil path in UE PC machine
@{at_channel}               1	2   3   4   5       # Attenuation port used
${attenuator_host}          10.53.188.13            # Attenuator IP
${attenuator_port}          ${3001}                 # Attenuator Port
${RIC_ip}    				10.53.188.106			# RIC IP
${RIC_username}    			root					# RIC IP username
${RIC_password} 			RIC@lab123				# RIC IP password
${RIC_file_name}			New_caSCell_Addition_AppliedtoPCell_FDD.json	# RIC configuration file
${Attached_cell}			2						# UE attached cell
${CA_cell_1}				1						# CA FDD cell 1
${CA_cell_2}				3						# CA FDD cell 2
${a1Threshould_RIC}			5						# a1 threshould set in json file
${NRRANFUNCTION_ID}         1                       # NR RAN Function ID of current gnb
${NRE2LINK_ID}              1                       # NR Link ID of current gnb
${NRE2NODE_ID}              1                       # NR Node ID of current gnb
${CONFIG_PATH}				/home/ute/testline_configuration_5G/Bangalore/debian10/${UE_file}# UE file configuration path
${gNB_IP}                   192.168.255.129                                         # gnb LMP IP
&{BTS_INFO}                 host=${BTS_M_plane_ip}	port=${port}                    # BTS details
@{gnb_custom_filters}       condor5gSyslog     cp_5g    bip_interface_mirroring     # gnb custom filters for DCAP
@{bts_custom_filter}        immediateSnapshot    scf    ipCapture                   # BTS custom filters for DCAP
@{collection_timing}        Immediate       TraceEnd                                # Snapshot collet option for DCAP
${Default_DCAP_duration}    10                                                      # DCAP log duration
${dcap_log_timeout}         1200                                                    # Timeout for DCAP log collection
${connection}               Active_Session                                          # Alias name
${emil_profile}             ${emil_path}//profiles//5G                              # Emil profile path in UE PC machine
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs   # Path for Emil logs are copied in UE PC
${at_vendor}                TOPYOUNG                                                # Attenuator Vendor
${at_model}                 TAS_16T16_0_2G6_90_1S_DEJS                              # Attenuator Model
${UE_file}					ta_ue_config.yaml										# UE Configuration file name
${direction}			 	dl														# Direction for data
@{UE_alias}					UE_1													# UE ID in configuration file
@{capabilities}				Legacy_1												# UE capability
${RIC_file_path}			${CURDIR}/${RIC_file_name}								# RIC configuration filepath in UE PC
${RIC_remote_path}			/root/ric/TO_CA_XAPP_DIRECT								# RIC configuration filepath in RIC machine
${RIC_remote_file}			${RIC_remote_path}/${RIC_file_name}						# RIC configuration filepath in RIC machine
${i}                        ${0}                                                    # Initial counter value
${port}                     443                                                     # Port value for DCAP connection
${secure}                   True                                                    # Secure value for DCAP connection
${rd_version}               dcapv3                                                  # DCAP version
@{data_transfer_protocol}   UDP                                                               # Default data transfer type

*** Keywords ***
Admin Setup
    [Documentation]     Create Coam connection to BTS, check BTS status, start watching alarms, create testcase
	...	folder and start BTS log
    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
    ${BTS_details}      COAM.get_bts_info       connection=${connection}
    Log    ${BTS_details}
    ${current_sw}    COAM.get_sw_version    connection=${connection}
    Log to console      \nCurrent Active build in gnb : ${current_sw}
    Set Suite Metadata      Software version    ${current_sw}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}     MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    Set global variable    ${Cell_dist}     /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${BTS_ID}/NRCELL_R
    CB007623_keywords.Get Branch
    ${cell_details}      COAM.get_cells_info       connection=${connection}
    ${cell_count}       Get Length      ${cell_details}
    Check BTS is OnAir
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${connection}       log_dir=/tmp
    Create dcap session
    Get Date
	Create testcase folder

Get Branch
    COAM.setup_admin    bts_host=${gNB_IP}    alias=Branch    admin_api_log_dir=/tmp
    ${sw_version}    COAM.get_sw_version    connection=Branch
    ${out}    Split String From Right    ${sw_version}    _    -1
    ${str}    Strip String    ${out}[0]    both    SBTS
    Set Suite variable    ${Branch}    ${str}
    LOG    ${Branch}
    COAM.teardown_admin    connection=Branch


Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${port}    rd_version=${rd_version}        secure=${secure}    username=utfuser   password=utfadmin!

Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}
	...		gnb_custom_profile=@{gnb_custom_filters}
    ...     bts_custom_profile=@{bts_custom_filter}		collection_timing=@{collection_timing}
    Sleep       60      reason=Wait for DCAP start
    ${START_TRACE_ID}      Get from Dictionary    ${output}    id
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Documentation]     Stops DCAP and collect logs
    Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
    rd.stop_trace    trace_id=${START_TRACE_ID}
    LOG     DCAP logging stopped
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${OUTPUT_DIR}/DCAP_Logs
	...		timeout=${dcap_log_timeout}

Check current software
    [Documentation]     Check current software in BTS
    ${current_sw}       COAM.get_sw_version     timeout=10   connection=${connection}
    @{sw_list}          String.Split String     ${current_sw}    _
    ${status}           Run Keyword And Return Status       Should Be True      ${sw_list[2]}==9999
    ${current_trunk_sw}          Run Keyword If      '${status}'=='True'     Replace String      ${current_sw}       ${sw_list[0]}     SBTS00
    ...                 ELSE                Set variable    ${current_sw}
    Log to console      \nCurrent software in BTS ${BTS_IP} is ${current_sw}
    [Return]            ${current_trunk_sw}

Expected alarm
    [Documentation]     Alarms which are ignored on runtime
    ${allowed_alarm_1}    Create alarm    alarm_id=7220     fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220     fault_id=4654
	...		fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220     fault_id=61649
	...		fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220     fault_id=4655
	...		fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220     fault_id=61652
	...		fault_name=R&D Service Port enabled
    ${allowed_alarm_6}    Create alarm    alarm_id=61641    fault_id=61641
	...		fault_name=IP Traffic Capturing ongoing
    ${allowed_alarm_7}    Create alarm    alarm_id=7115     fault_id=4592
	...		fault_name=BTS Reset Cause
    ${allowed_alarm_8}    Create alarm    alarm_id=7115     fault_id=8000
	...		fault_name=Failure in connection between BTS and 3rd party tool
    ${allowed_alarm_9}   Create alarm    alarm_id=7102     fault_id=49
	...		fault_name=Cell blocked
    ${allowed_alarm_10}    Create alarm    alarm_id=7115     fault_id=4720
	...		fault_name=Mismatch of RU reported capabilities with static HW Validation information
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}
	...	${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}    ${allowed_alarm_6}    ${allowed_alarm_7}    ${allowed_alarm_8}
	...    ${allowed_alarm_9}    ${allowed_alarm_10}
    [Return]    ${allowed_alarms}

Admin Teardown
    [Documentation]     Check for alarm and delete COAM connection
    Check BTS is OnAir
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    alarm.check_detected_alarms
    alarm.stop_watching_alarms
    Run keyword And Ignore Error     CORE.stop_collectors    names=btslog
    Run keyword And Ignore Error     CORE.teardown_collectors    names=btslog
    COAM.teardown_admin    connection=${connection}
    ${result_sys}		CB007623.Validate_syslog 	 ${OUTPUT_DIR}/DCAP_Logs/Extracted/
	Should Be True		${result_sys}
	Remove Directory	${OUTPUT_DIR}/DCAP_Logs/Extracted		recursive=True
    Set QC_Tag

Start BTS logs
    [Documentation]     Starts BTS log in testpc
    OperatingSystem.Run     killall btslog
    BTSLOG.create_btslog_collector    name=btslog
    CORE.setup_collectors    names=btslog
    CORE.set_suite_alias    btslog
    CORE.start_collectors    names=btslog

Stop BTS logs and check
    [Documentation]     Stops BTS log and check for crash
    CORE.stop_collectors    names=btslog
    CORE.collect_collectors    names=btslog     target_dir=${OUTPUT_DIR}
    CORE.teardown_collectors    names=btslog
    ${check}    Check_bts_logs       ${OUTPUT_DIR}/btslog
    Run keyword And Continue On Failure    Should Be True       ${check}

Get Date
    [Documentation]     Get date to create testcase folder
    ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}

Create testcase folder
    [Documentation]     Create testcase folder in testpc
    ${val}    Run Keyword And Return Status    LOG    ${OUTPUT_DIR}/${Folder}/${TEST NAME}
    Run Keyword If    ${val} == False    Get Date
    create directory    ${OUTPUT_DIR}/${Folder}/${TEST NAME}/DCAP_Logs
    Set Suite variable  ${testdir}      ${OUTPUT_DIR}/${Folder}/${TEST NAME}

Parameter value change
    [Arguments]    ${dist_name}     ${parameter}    ${value}
    [Documentation]     Change parameter valur=e in SCF and commision it
    Log to console      \nChanging gnb parameter ${parameter} to ${value}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run Keyword If    '${current_value.upper()}'!='${value.upper()}'    COAM.Perform Parameter Recommissioning
	...		dist_name=${dist_name}
    ...     parameter=${parameter}      operation=update    value=${value}    skip_parameter_relation_errors=True
	...		connection=${connection}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run keyword And Continue On Failure    Should Be Equal As Strings    ${current_value.upper()}    ${value.upper()}

Get Current Parameter Value
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get current parameter value
    ${temp_scf_file}    COAM.Get Current Scf File    local_dir_path=/tmp    file_name=temp_scf.xml
	...		connection=${connection}
    scf.Load Scf    ${temp_scf_file}
    ${param_value}    scf.get_value_from_scf    dist_name=${dist_name}    p_name=${param_name}
    [Return]    ${param_value}

Counter value
    [Arguments]    ${counter_name}    ${path5}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...		couter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['CELLS']['NRCELL-1']['${path5}']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Check Counter
     [Arguments]    ${port_val_list}     ${counter_initial}    ${value2}   ${path5}    ${s}
     [Documentation]     Get Counter name
	 log       ${port_val_list}
     FOR    ${index}    IN RANGE    ${s}
##          ${i}    Evaluate    ${counter_initial}
          ${test1}=    Catenate    SEPARATOR=${EMPTY}    ${counter_initial}    ${value2}
          Counter value    ${test1}    ${path5}
          sleep  20
          ${value2}     Evaluate    ${value2}+1
          ${value2}     Convert To String    ${value2}
     END

Get value of Counter
    [Arguments]    ${Counter_value}
    [Documentation]     Get total value from list
    FOR    ${a}    IN    @{Counter_value}
        ${i}    Evaluate    ${i} + ${a}
    END
    [Return]    ${i}



Restart the GNB
    [Documentation]     Restart gnb
    Log to console      \nRebooting gNB and waiting for reconnection
    COAM.reset		reset_coverage=Site		wait_for_reconnection=True      timeout=300
	...	connection=${connection}
    COAM.reset_admin     connection=${connection}

Check BTS is OnAir
    [Documentation]     Check the BTS current status
    ${bts_status}      COAM.get_bts_statuses       connection=${connection}
    Should Be Equal As Strings      ${bts_status["proceduralState"]}    OnAir
    Run Keyword If      '${bts_status["proceduralState"]}'=='OnAir'     LOG
	...		BTS procedural state is now: ${bts_status["proceduralState"]}
    ...     ELSE    fail
    Log to console      \nBTS procedural state : ${bts_status["proceduralState"]}
#    CB007623_keywords.Check cell status

Get Current Parameter Value from selenium
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get parameter value
    Log to console      \nChecking gnb parameter ${param_name} value
    seleLib.login    url=https://192.168.255.129    username=Nemuadmin    password=nemuuser
    ...		browser=Chrome    alias=connection
    ${view}     seleLib.start_up_view_window_exists         sbts=connection
    Run Keyword If       '${view}'== 'True'     seleLib.close_start_up_view_window      sbts=connection
    ${curr_value}    seleLib.get_parameter_value    dist_name=${dist_name}    filter_param=${param_name}    s
	...		bts=connection
    seleLib.close_browser       sbts=connection
    [Return]    ${curr_value}

Set testcase values
    [Documentation]     Set variable for testcase
    ${BTS_details}      COAM.get_bts_info    connection=${connection}
    Log                 ${BTS_details}
    Set global variable      ${BTS_ID}       ${BTS_details['mrbtsID']}
    Set global variable      ${Cell_dist}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${BTS_ID}/LNCEL_R
    Set global variable      ${NRCell_dist}      /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${BTS_ID}/NRCELL_R
    Set global variable      ${MRBTS_dist}   MRBTS-${BTS_ID}
    Set global variable      ${LNBTS_dist}   ${MRBTS_dist}/LNBTS-${BTS_ID}
    ${sw_version}       COAM.get_sw_version    connection=${connection}
    Set Suite Metadata       Software version    ${sw_version}
    Set Suite variable    ${sw_version}
    ${Active_build}     Check current software
    Set Suite variable    ${Active_build}

Check BTS status on runtime and collect dcap logs
    [Arguments]    ${dist_name}
	[Documentation]     Check for parameter change and start DCAP
    Log to console      \nWaiting for state change
    FOR    ${a}    IN RANGE    1   5
         ${Value}        Get Current Parameter Value from selenium       ${dist_name} 	state
         ${bts_status}      COAM.get_bts_statuses       connection=${connection}
         Run Keyword If       '${Value}'== 'NotAdded'       Dcap Start Trace SA
         Exit For Loop IF       '${Value}'== 'NotAdded'
    END
    Log to console      \nSleeping for 2m
    sleep       2m      reason=Wait for change in state
    FOR    ${a}    IN RANGE    1    5
         ${Value}        Get Current Parameter Value from selenium       ${dist_name} 	state
         ${bts_status}      COAM.get_bts_statuses       connection=${connection}
         Exit For Loop IF       '${Value}'== 'Added'
    END
    Dcap Stop Trace and Get results SA
    Should Be Equal As Strings      ${Value}    Added
    ${bts_status}      COAM.get_bts_statuses       connection=${connection}
    Should Be Equal As Strings      ${bts_status["proceduralState"]}    OnAir

Verify Emil logs
	[Arguments]    @{values}
	[Documentation]     Convert emil file and verify
	Convert Emil File To Csv
	FOR		${check}	IN	 @{values}
#		${result}		Parse_Emil_Csv_File_For_Message 	 ${OUTPUT_DIR}/DCAP_Logs/Extracted/		${check}
        ${result}       CB007623.Parse_Emil_Csv_File_For_Message     path=${OUTPUT_DIR}/DCAP_Logs/Extracted/      msg=${check}
        ...                                                 msg_col=${2}                      con_col=${9}
		Run keyword And Continue On Failure		Should Be True		${result}
	END

Convert Emil File To Csv
    [Documentation]        Convert Emil logs collected from DCAP
    Log to console      \nConverting Emil logs and verifying
    ${path1}     Set Variable        ${OUTPUT_DIR}/DCAP_Logs
    ${source_paths}    Set Variable        ${path1}/Extracted/
    create directory         ${source_paths}
    ${files}    List Files In Directory    ${path1}
    FOR    ${zip}    IN    @{files}
        CB007623.Extract_zip        ${path1}/${zip}        ${source_paths}
    END
    ${check}    List Directory    ${source_paths}
    FOR    ${value}    IN    @{check}
        ${date}		Set Variable		${value}
    	Exit For Loop
    END
    ${it}=    List Directory    ${source_paths}/${date}
    taf.transport.ssh.connect_to    ${uepc_default_ip}    ${uepc_default_username}    ${uepc_default_password}    alias=mcg_vm    timeout=60
    FOR    ${out_index}    IN    @{it}
        Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}
        ...     source_file=${out_index}
    END
#    ${output}		SSH.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm		timeout=30s
#    LOG		${output}
	taf.transport.ssh.Disconnect		connection=mcg_vm

Start Emil To Convert Emil File To Csv
    [Arguments]    ${source_path}     ${source_file}
    [Documentation]         Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}    List Directory    ${source_path}/${source_file}
    taf.transport.ssh.Execute    command=mkdir ${uepc_Log_path}     connection=mcg_vm
    taf.transport.ssh.upload_file    local_path=${source_path}/${source_file}/${source_emil_file}[0]
	...		remote_path=${uepc_Log_path}//${source_emil_file}[0]
    ...     connection=mcg_vm
    Run keyword and ignore error	taf.transport.ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f
	...		connection=mcg_vm		timeout=30s
    ${src_file}     Set Variable        ${uepc_Log_path}//${source_emil_file}[0]
	${cmd}	Set Variable	cd ${emil_path} && ./Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile}
	LOG	${cmd}
	${output}		taf.transport.ssh.Execute    command=${cmd}      connection=mcg_vm		timeout=5m
	LOG		${output}
	${csvfile}    String.Replace String    string=${source_emil_file}[0]    search_for=.5gm    replace_with=.csv
	taf.transport.ssh.download_file    remote_path=${uepc_Log_path}//${csvfile}		local_path=${source_path}/${source_file}/${csvfile}
	...    connection=mcg_vm

Lock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=${Cell_dist}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${Cell_dist}-${cell}            locking_status=locked
        ...                                                                         operational_status=disabled     usage_status=Idle
        ...                                                                         blocking_status=Unblocked
    END

Lock NR cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${nrcell_list}
    FOR    ${cell}    IN    @{nrcell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=${NRCell_dist}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${NRCell_dist}-${cell}            locking_status=locked
        ...                                                                         operational_status=disabled     usage_status=Idle
        ...                                                                         blocking_status=Unblocked
    END


Check cell details
    [Documentation]             Check cell details
    [Arguments]                 ${cell}
    ...                         ${locking_status}=unlocked  ${operational_status}=enabled   ${usage_status}=Active  ${blocking_status}=Unblocked
	log    ${usage_status}
    ${cell_status}              COAM.get_cell_specific_info    cell_id=${cell}    connection=${connection}
    ${administrativeState}      Set Variable    ${cell_status['status']['administrativeState']}
    Run keyword And Continue On Failure    Should Be Equal    ${administrativeState.upper()}    ${locking_status.upper()}
    ${operationalState}         Set Variable    ${cell_status['status']['operationalState']}
    Run keyword And Continue On Failure    Should Be Equal    ${operationalState.upper()}    ${operational_status.upper()}
    ${usageState}               Set Variable    ${cell_status['status']['usageState']}
    #Run keyword And Continue On Failure    Should Be Equal    ${usageState.upper()}    ${usage_status.upper()}
    ${blockingState}            Set Variable    ${cell_status['status']['blockingState']}
    Run keyword And Continue On Failure    Should Be Equal    ${blockingState.upper()}    ${blocking_status.upper()}


Change attenuation
	[Arguments]		${port_val_list}
	[Documentation]		Set the attenuation of specified port
	FOR    ${val}    IN    @{port_val_list}
		${channel_num}		${value}	Split String	${val}	,	1
		Set Attenuator value	${channel_num}		${value}
	END

Set Attenuator value
	[Arguments]		${channel_num}		${value}
	[Documentation]		Set the attenuation of specified port
	${channel_num}		Convert To Integer		${channel_num}
	${value}		Convert To Integer		${value}
    Log to console      \nChanging attenuator port ${channel_num} to ${value}db
	at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}    attenuation_port_numbers=@{at_channel}
	...  vendor=${at_vendor}  model=${at_model}
	${set_value}  at.read_attenuation  port=${${channel_num}}
	at.set_attenuation  port=${channel_num} 	value=${value}		confirm=${True}
	sleep	2s		reason=Wait for change in state
	${set_value}  at.read_attenuation  port=${${channel_num}}
	Should Be Equal As Strings  ${set_value}  ${value}

Change attenuation by step
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	${length} 		Get Length		${port_val_list}
	FOR    ${i}    IN RANGE    10
		${status}		Loop for attenuation		${port_val_list}	${Attenuator_step_val}
		Exit For Loop If 	"${status}"=="${length}"
	END

Loop for attenuation
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	${loop_status}		Set Variable		${0}
	FOR    ${val}    IN    @{port_val_list}
		${channel_num}		${value}	Split String	${val}	,	1
		${status}		Change Attenuator value		${channel_num}		${value}	${Attenuator_step_val}
		${loop_status}		Run Keyword If		"${status}"=="${value}"		Evaluate		${loop_status}+${1}
		...		ELSE		Set Variable		${loop_status}
	END
	sleep	30s		reason=Wait for change in state
	[return]	${loop_status}

Change Attenuator value
	[Arguments]		${channel_num}		${value}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	${set_value}  at.read_attenuation  port=${${channel_num}}
	${new_val}		Run Keyword If		"${set_value}"!="${value}"		Evaluate    ${set_value} - ${Attenuator_step_val}
	...		ELSE	Set Variable		${set_value}
	Run Keyword If		"${set_value}"!="${value}"	Set Attenuator value	${channel_num}		${new_val}
	[return]		${new_val}

RIC Setup
	[Documentation]		RIC xapp configuration
    Log to console      \nConfiguring RIC
	taf.transport.ssh.Connect_to    ${RIC_ip}    ${RIC_username}    ${RIC_password}    alias=RIC_vm
	${ip}	taf.transport.ssh.Execute     command=kubectl get svc -A|grep service-ricxapp-ca-sa-tsserver | awk '{print $4}'
	...		connection=RIC_vm	timeout=30s
	${ip}	Strip String    ${ip}    characters=\r\n
	FOR    ${i}    IN RANGE    1	7
		LOG		command=curl -L -X DELETE http://${ip}:9091/ric/v1/ca/tsPolicy/${i}
		${output}	taf.transport.ssh.Execute     command=curl -L -X DELETE http://${ip}:9091/ric/v1/ca/tsPolicy/${i}
		...		connection=RIC_vm	timeout=30s
	END
	taf.transport.ssh.upload_file    local_path=${RIC_file_path}   remote_path=${RIC_remote_file}		connection=RIC_vm
	${cmd}	Set Variable
	...		curl -L -X POST http://${ip}:9091/ric/v1/ca/tsPolicy -H "Content-Type: application/json" -d @${RIC_remote_file}
	${output}		taf.transport.ssh.Execute     command=${cmd}      connection=RIC_vm		timeout=30s
	${rc}    Run Keyword And Return Status		Should Be Empty       ${output}
	sleep	5s
	${output}	Run Keyword If    "${rc}"=="False"	taf.transport.ssh.Execute	command=${cmd}	connection=RIC_vm	timeout=30s
	Run Keyword If    "${rc}"=="False"	Should Be Empty		${output}
	taf.transport.ssh.Disconnect		connection=RIC_vm

Attach ue and run throughput
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}    ${throughput}    ${deviation}    ${timeout}    ${calltype}    ${start_bip}=False
	...		${Collect_eGEN}=False    ${check_tpt}=False    ${check_cell}=True    ${check_gnb_attach}=False    ${wait_for_transfer}=True
	log    ${check_cell}
	log    ${check_gnb_attach}
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console      \nExecuting testcase in UE : ${capabilities}
#   Run Keyword If    '${check_gnb_attach}'=='True'    Start tshark collection
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ${attach_log}    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    #Run Keyword If    '${check_cell}'=='True'    Should contain    ${attach_log}    ${LTE_cell_id}
    Log to console    \nStarting ${direction} data transfer
    ta_ultracaller.start_datatransfer    ${UE_alias}    ${calltype}   direction=${direction}
    Run Keyword If    '${start_bip}'=='True'    Collect BIP logs
    Run Keyword If    '${Collect_eGEN}'=='True'    Collect eGEN Logs
#    Run Keyword If    '${check_gnb_attach}'=='True'    Run Keywords    Sleep    20      AND     Stop tshark collection
#    ...    AND    Check for attach request in tshark logs
    Log to console    \nWaiting for data transfer
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}
	...		${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure    ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
	...		direction=${direction}    thrughtput=${throughput}    deviation=${deviation}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}

Loop for attenuation increase
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	${loop_status}		Set Variable		${0}
	FOR    ${val}    IN    @{port_val_list}
		${channel_num}		${value}	Split String	${val}	,	1
		${status}		Increase Attenuator value		${channel_num}		${value}	${Attenuator_step_val}
		${loop_status}		Run Keyword If		"${status}"=="${value}"		Evaluate		${loop_status}+${1}
		...		ELSE		Set Variable		${loop_status}
	END
	sleep	30s		reason=Wait for change in state
	[return]	${loop_status}

Increase Attenuator value
	[Arguments]		${channel_num}		${value}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	${set_value}  at.read_attenuation  port=${${channel_num}}
	${new_val}		Run Keyword If		"${set_value}"!="${value}"		Evaluate    ${set_value} + ${Attenuator_step_val}
	...		ELSE	Set Variable		${set_value}
	Run Keyword If		"${set_value}"!="${value}"	Set Attenuator value	${channel_num}		${new_val}
	[return]		${new_val}

Change attenuation by step increment
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	${length} 		Get Length		${port_val_list}
	FOR    ${i}    IN RANGE    10
		${status}		Loop for attenuation increase		${port_val_list}	${Attenuator_step_val}
		Exit For Loop If 	"${status}"=="${length}"
	END
Admin Setup CB007814
    [Documentation]     Create Coam connection to BTS, check BTS status and start watching alamrs
    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=${OUTPUT_DIR}/tmp
    ${BTS_details}      COAM.get_bts_info       connection=${connection}
#    CB007623_keywords.Check BTS is OnAir
#    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
#    LOG     ${Active_alarm}
#    ${allowed_alarms}    CB007623_keywords.Expected alarm
##    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${connection}       log_dir=${OUTPUT_DIR}/tmp
    Set testcase values
    Create dcap session
    Create testcase folder


Admin Teardown CB007814
    [Documentation]     Check for alarm and delete COAM connection
    CB007623_keywords.Check BTS is OnAir
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    alarm.check_detected_alarms
    alarm.stop_watching_alarms
    Dcap Stop Trace and Get results SA
#    Stop DCAP log collection
    Run keyword And Ignore Error     CORE.stop_collectors    names=btslog
    Run keyword And Ignore Error     CORE.teardown_collectors    names=btslog
    COAM.teardown_admin    connection=${connection}


Unlock cells
    [Arguments]     ${cell_list}
    [Documentation]     Unlock specified cell
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
        COAM.unlock    dist_name=${Cell_dist}-${cell}       timeout=180     connection=${connection}
    END
#    Wait Until Keyword Succeeds    10 times    30    CB007623_keywords.Check cell status

Unlock NRcells
    [Documentation]     Unlock specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
        COAM.unlock         dist_name=${NRCell_dist}-${cell}      timeout=180     connection=${connection}
    END
    Log to console                  \nWaiting for cell to be onAir
    Wait Until Keyword Succeeds     30 times    10      Check cell details      ${NRCell_dist}-${cell}

Check cell status
    [Documentation]     Check all cell status
    ${cells}    COAM.get_ids_for_all    NRCEL    timeout=30s    connection=${connection}
    FOR    ${cell}    IN    @{cells}
        ${cell_status}  COAM.get_cell_specific_info     cell_id=${cell} connection=${connection}
        ${administrativeState}      Set Variable        ${cell_status['status']['administrativeState']}
        Run keyword And Continue On Failure     Should Be Equal     ${administrativeState}      Unlocked
        ${operationalState} Set Variable    ${cell_status['status']['operationalState']}
        Run keyword And Continue On Failure     Should Be Equal     ${operationalState}     enabled
        ${usageState}       Set Variable    ${cell_status['status']['usageState']}
        Run keyword And Continue On Failure     Should Be Equal     ${usageState}       Active
        ${blockingState}        Set Variable    ${cell_status['status']['blockingState']}
        Run keyword And Continue On Failure     Should Be Equal     ${blockingState}        Unblocked
        ${proceduralStatus}     Set Variable    ${cell_status['status']['proceduralStatus']}
        Run keyword And Continue On Failure     Should Be Equal     ${proceduralStatus}     configured
        ${barringStatus}        Set Variable    ${cell_status['status']['barringStatus']}
        Run keyword And Continue On Failure     Should Be Equal     ${barringStatus}        unbarred
        ${status}       Run Keyword And Return Status       Set Variable    ${cell_status['status']['availabilityStatus']}
        Run keyword And Continue On Failure     Should Not Be True      ${status}
        ${technology}       Set Variable    ${cell_status['technology']}
        Run Keyword If      "${technology}"=="TDD"      Append To List      ${TDD_cells}    ${cell}
    END

Link SCOUT SCF to Configuration ID for Reporting
    [Arguments]    ${node_id}=${0}    ${node_type}=gnb    ${tl_name_only}=${Scout_tl_name}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
	log    ${node_id}
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Request Scout SCF
    [Arguments]    ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

