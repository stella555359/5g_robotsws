*** Settings ***
Documentation     Keywords and variables for CB007623.robot file
Library           String
Library           DateTime
Library           Process
Library           ../../../T11/CB007814_114DCAP/resources/CNI_97916.py
Library           Collections
Library           OperatingSystem
Library           taf.sw.dcap.rd   WITH NAME   rd
Library           taf.config.scf   WITH NAME    scf
Library           taf.transport.ssh    WITH NAME    SSH
Library           taf.selenium.sbts    WITH NAME    seleLib
Library           taf.collectors.core    WITH NAME    CORE
Library           taf.ul.alarms_watchdog   WITH NAME    alarm
Library           taf.sbts.oam.coam.admin    WITH NAME    COAM
Library          taf.collectors.btslog    WITH NAME    BTSLOG
Library           taf.sw.scout    WITH NAME    scout
Library           taf.hw.rf_attenuator  WITH NAME  at
Library           ../../../resources/python/ta_ultracaller/
Resource          ../../../resources/robot/reportingportal_Keywords.robot
Library                     ute_reporting_portal
Library         taf.analyzer.sherpa    WITH NAME    sherpa_analyzer
Library         taf.converters.sherpa    WITH NAME    SHERPA

Library             validation.py
*** Variables ***
${ASP_BOARD_TYPE}     ABIO0
${BTS_IP}                   192.168.255.129
${uepc_default_ip}          10.53.252.86          # Windows UE PC IP
${BTS_M_plane_ip}           10.63.48.81
#${DCAP_host}                10.58.239.215         # DCAP server IP
${DCAP_host}                10.41.209.114       # DCAP server IP
${uepc_default_username}    inbabtslabuser          # Windows UE PC username
${uepc_default_password}    BT5l@bus3rl0g1n         # Windows UE PC password
${emil_path}                C://Emil                # Emil path in UE PC machine
@{at_channel}               5   6   7   8   13  14  15  16                # Attenuation port used
${attenuator_host}          10.53.252.118           # Attenuator IP
${attenuator_port}          ${3001}                 # Attenuator Port
${CA_cell_1}                5                       # CA FDD cell 1
${CA_cell_2}                6                       # CA FDD cell 2
${CA_cell_3}                7                       # CA FDD cell 3
${CA_cell_4}                8                       # CA FDD cell 4
${CA_cell_5}                13                      # CA FDD cell 5
${CA_cell_6}                14                      # CA FDD cell 6
${CA_cell_7}                15
${CA_cell_8}                16
${a1Threshould_RIC}			5						# a1 threshould set in json file
${NRRANFUNCTION_ID}         1                       # NR RAN Function ID of current gnb
${NRE2LINK_ID}              1                       # NR Link ID of current gnb
${NRE2NODE_ID}              1                       # NR Node ID of current gnb
${CONFIG_PATH}				/home/ute/testline_configuration/Bangalore/10-2-CLOUD1236/${UE_file}
${gNB_IP}                   192.168.255.129                                         # gnb LMP IP
${wait_for_transfer}    True
&{BTS_INFO}                host=${BTS_M_plane_ip}  port=${port}  username='Nemuadmin' password='nemuuser' credential_region_Id='DEFAULT_CREDENTIALS'
@{gnb_custom_filters}       condor5gSyslog     cp_5g     # gnb custom filters for DCAP
@{bts_custom_filter}        immediateSnapshot    scf    ipCapture                   # BTS custom filters for DCAP
${collection_timing}        Immediate,TraceEnd                                # Snapshot collet option for DCAP
${Default_DCAP_duration}    10                                                      # DCAP log duration
${dcap_log_timeout}         1800                                                    # Timeout for DCAP log collection
${connection}               Active_Session                                          # Alias name
${emil_profile}             ${emil_path}//profiles//5G                  # Emil profile path in UE PC machine
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${at_vendor}                TOPYOUNG                                                # Attenuator Vendor
${at_model}                 TAS_16T16_0_2G6_90_1S_DEJS                              # Attenuator Model
${UE_file}					ta_ue_config.yaml										# UE Configuration file name
${direction}			 	dl														# Direction for data
@{UE_alias}					UE_1													# UE ID in configuration file
@{capabilities}				Legacy_1												# UE capability
${i}                        ${0}                                                    # Initial counter value
${port}                     443                                                     # Port value for DCAP connection
${secure}                   True                                                    # Secure value for DCAP connection
${rd_version}               dcapv3                                                  # DCAP version
@{data_transfer_protocol}   UDP                                                     # Default data transfer type
@{LTE_cell}		0
${dcapuser}         utfuser
${dcap_password}    utfadmin!
${gNB2_IP}                   10.58.239.89                                         # gnb LMP IP
${connection1}               Active_Session                                          # Alias name
@{NR_cell}      3
${Scout_tl_name}            10_2_CLOUD1236


*** Keywords ***
Admin Setup
    [Documentation]     Create Coam connection to BTS, check BTS status, start watching alarms, create testcase
#    ... folder and start BTS log
    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
    ${BTS_details}      COAM.get_bts_info       connection=${connection}
    Log    ${BTS_details}
    ${current_sw}    COAM.get_sw_version    connection=${connection}
    Log to console      \nCurrent Active build in gnb : ${current_sw}
    Set Suite Metadata      Software version    ${current_sw}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}     MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
#    Set global variable    ${Cell_dist}     /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${BTS_ID}/NRCELL_R
    Set global variable    ${dist_name_NRF}    ${dist_name}/NRE2NODE-${NRE2NODE_ID}/NRRANFUNCTION-${NRRANFUNCTION_ID}
    Set global variable    ${dist_name_NRE}    ${dist_name}/NRE2LINK-${NRE2LINK_ID}
	CB007623_keywords.Get Branch
    ${cell_details}      COAM.get_cells_info       connection=${connection}
    ${cell_count}       Get Length      ${cell_details}
    Set suite variable      ${cell_count}
#    CB007623_keywords.Check BTS is OnAir
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    ${allowed_alarms}    CB007623_keywords.Expected alarm
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${connection}       log_dir=/tmp
    Set testcase values
    Create dcap session
    Create testcase folder
    Start BTS logs



Get Branch
    COAM.setup_admin    bts_host=${gNB_IP}    alias=Branch    admin_api_log_dir=/tmp
    ${sw_version}    COAM.get_sw_version    connection=Branch
    ${out}    Split String From Right    ${sw_version}    _    -1
    ${str}    Strip String    ${out}[0]    both    SBTS
    Set Suite variable    ${Branch}    ${str}
    LOG    ${Branch}
    COAM.teardown_admin    connection=Branch


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

Check current software
    [Documentation]     Check current software in BTS
    ${current_sw}       COAM.get_sw_version     timeout=10   connection=${connection}
    @{sw_list}          String.Split String     ${current_sw}    _
    ${status}           Run Keyword And Return Status       Should Be True      ${sw_list[2]}==9999
    ${current_trunk_sw}          Run Keyword If      '${status}'=='True'     Replace String      ${current_sw}
	...		${sw_list[0]}     SBTS00
    ...                 ELSE                Set variable    ${current_sw}
    Log to console      \nCurrent software in BTS ${BTS_IP} is ${current_sw}
    [Return]            ${current_trunk_sw}

Lock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=${Cell_dist}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${Cell_dist}-${cell}
		...																			locking_status=locked
        ...                                                                         operational_status=disabled
        ...                                                                         blocking_status=Unblocked
    END

Lock NR cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${nrcell_list}
    FOR    ${cell}    IN    @{nrcell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=${NRCell_dist}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${NRCell_dist}-${cell}
		...																			locking_status=locked
        ...                                                                         operational_status=disabled
        ...                                                                         blocking_status=Unblocked
    END


Check cell details
    [Documentation]             Check cell details
    [Arguments]                 ${cell}
    ...                         ${locking_status}=unlocked  ${operational_status}=enabled
	...		                    ${blocking_status}=Unblocked
    ${cell_status}              COAM.get_cell_specific_info    cell_id=${cell}    connection=${connection}
    ${administrativeState}      Set Variable    ${cell_status['status']['administrativeState']}
    Run keyword And Continue On Failure    Should Be Equal
	...		${administrativeState.upper()}    ${locking_status.upper()}
    ${operationalState}         Set Variable    ${cell_status['status']['operationalState']}
    Run keyword And Continue On Failure    Should Be Equal
	...		${operationalState.upper()}    ${operational_status.upper()}
    ${usageState}               Set Variable    ${cell_status['status']['usageState']}
    #Run keyword And Continue On Failure    Should Be Equal
	#...		${usageState.upper()}    ${usage_status.upper()}
    ${blockingState}            Set Variable    ${cell_status['status']['blockingState']}
    Run keyword And Continue On Failure    Should Be Equal
	...		${blockingState.upper()}    ${blocking_status.upper()}

Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${port}    rd_version=${rd_version}
	...		secure=${secure}    username=${dcapuser}   password=${dcap_password}

Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}
	...		gnb_custom_profile=@{gnb_custom_filters}
    ...     bts_custom_profile=@{bts_custom_filter}		collection_timing=${collection_timing}
    Sleep       60      reason=Wait for DCAP start
    ${START_TRACE_ID}      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Documentation]     Stops DCAP and collect logs
    Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
    rd.stop_trace    ${START_TRACE_ID}
    LOG     DCAP logging stopped
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${OUTPUT_DIR}/DCAP_Logs
	...		timeout=${dcap_log_timeout}

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
	${allowed_alarm_10}    Create alarm    alarm_id=7115     fault_id=4740
	...		fault_name=EFaultId_ClearFaultNotifUnderMoAl
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}
	...	${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}
	...		${allowed_alarm_9}  #${allowed_alarm_10}
    [Return]    ${allowed_alarms}

Admin Teardown
    [Documentation]     Check for alarm and delete COAM connection
    Run keyword and continue on failure     Unlock cells    ${LTE_cell}
    Run keyword and continue on failure     Unlock NRcells  ${NR_cell}
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    #alarm.check_detected_alarms
    alarm.stop_watching_alarms
    Run keyword And Ignore Error     CORE.stop_collectors    names=btslog
    Run keyword And Ignore Error     CORE.teardown_collectors    names=btslog
    CB007623_keywords.Check BTS is OnAir
    COAM.teardown_admin    connection=${connection}
    ${result_sys}		Common_script.Validate_syslog 	 ${OUTPUT_DIR}/DCAP_Logs/Extracted/
	Should Be True		${result_sys}
#	Remove Directory	${OUTPUT_DIR}/DCAP_Logs/Extracted		recursive=True
    RP Settings
    Wait Until Keyword Succeeds   2min     10s      Link SCOUT SCF to Configuration ID for Reporting
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
    ${check}    CNI_97916.Check_bts_logs       ${OUTPUT_DIR}/btslog
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
    create directory    ${OUTPUT_DIR}/DCAP_Logs

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
     [Arguments]      ${counter_initial}    ${value2}   ${path5}    ${s}
     [Documentation]     Get Counter name
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
    CB007623_keywords.Check cell status



Get Current Parameter Value from selenium
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get parameter value
    Log to console      \nChecking gnb parameter ${param_name} value
    seleLib.login    url=https://192.168.255.129    username=Nemuadmin    password=nemuuser
	...		browser=Chrome    alias=connection
    ${view}     seleLib.start_up_view_window_exists         sbts=connection
    Run Keyword If       '${view}'== 'True'     seleLib.close_start_up_view_window      sbts=connection
    ${curr_value}    seleLib.get_parameter_value    dist_name=${dist_name}    filter_param=${param_name}
	...		sbts=connection     timeout=300
    seleLib.close_browser       sbts=connection
    [Return]    ${curr_value}


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
        Log     ${message_col}
        Log   ${content_col}
        ${result}
		...		CNI_97916.Parse_Emil_Csv_File_For_Message     path=${OUTPUT_DIR}/DCAP_Logs/Extracted/      msg=${check}
#        ...                                                 msg_col=${4}                      con_col=${19}
        ...                                     msg_col=${message_col}                      con_col=${content_col}
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
         CNI_97916.Extract_zip        ${path1}/${zip}        ${source_paths}
    END
    ${check}    List Directory    ${source_paths}
    FOR    ${value}    IN    @{check}
        ${date}		Set Variable		${value}
    	Exit For Loop
    END
    ${it}=    List Directory    ${source_paths}/${date}
    SSH.Connect_to    ${uepc_default_ip}    ${uepc_default_username}    ${uepc_default_password}
	...		alias=mcg_vm    timeout=300
    FOR    ${out_index}    IN    @{it}
        #         Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}
        #        ...     source_file=${out_index}/5g/controlPlane
         Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}
        ...     source_file=${out_index}
    END
    ${output}		SSH.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm		timeout=30s
    LOG		${output}
	SSH.Disconnect		connection=mcg_vm

Start Emil To Convert Emil File To Csv
    [Arguments]    ${source_path}     ${source_file}
    [Documentation]         Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}    List Directory    ${source_path}/${source_file}  *.5gm
    Log     ${uepc_Log_path}
    SSH.Execute    command=mkdir ${uepc_Log_path}     connection=mcg_vm
    SSH.upload_file    local_path=${source_path}/${source_file}/${source_emil_file}[0]
	...		remote_path=${uepc_Log_path}//${source_emil_file}[0]
    ...     connection=mcg_vm
    Run keyword and ignore error	SSH.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f
	...		connection=mcg_vm		timeout=600s
    ${src_file}     Set Variable        ${uepc_Log_path}//${source_emil_file}[0]
	${cmd}	Set Variable
	...	cd ${emil_path} && ./Emil.exe ${src_file} -tocsvrnd -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile}
	LOG	${cmd}
	${output}		SSH.Execute    command=${cmd}      connection=mcg_vm		timeout=5m
	LOG		${output}
	${csvfile}    String.Replace String    string=${source_emil_file}[0]    search_for=.5gm    replace_with=.csv
	SSH.download_file    remote_path=${uepc_Log_path}//${csvfile}
	...		local_path=${source_path}/${source_file}/${csvfile}      connection=mcg_vm

#Lock cells
#	[Arguments]     @{cell_list}
#	[Documentation]		Lock the specified cell
#	FOR    ${cell}    IN    @{cell_list}
#        Log to console      \nLocking cell : ${cell}
#		COAM.lock    dist_name=${Cell_dist}-${cell}		connection=${connection}
#	END

Check cell status
	[Documentation]		Check all cell status
    ${cells}    COAM.get_ids_for_all    NRCEL    timeout=30s    connection=${connection}
    FOR    ${cell}    IN    @{cells}
		${cell_status}	COAM.get_cell_specific_info		cell_id=${cell}	connection=${connection}
		${administrativeState}		Set Variable		${cell_status['status']['administrativeState']}
		Run keyword And Continue On Failure		Should Be Equal		${administrativeState}		Unlocked
		${operationalState}	Set Variable	${cell_status['status']['operationalState']}
		Run keyword And Continue On Failure		Should Be Equal		${operationalState}		enabled
		${usageState}		Set Variable	${cell_status['status']['usageState']}
		Run keyword And Continue On Failure		Should Be Equal		${usageState}		Active
		${blockingState}		Set Variable	${cell_status['status']['blockingState']}
		Run keyword And Continue On Failure		Should Be Equal		${blockingState}		Unblocked
		${proceduralStatus}		Set Variable	${cell_status['status']['proceduralStatus']}
		Run keyword And Continue On Failure		Should Be Equal		${proceduralStatus}		configured
		${barringStatus}		Set Variable	${cell_status['status']['barringStatus']}
		Run keyword And Continue On Failure		Should Be Equal		${barringStatus}		unbarred
		${status}		Run Keyword And Return Status
		...		Set Variable	${cell_status['status']['availabilityStatus']}
		Run keyword And Continue On Failure		Should Not Be True		${status}
		${technology}		Set Variable	${cell_status['technology']}
		Run Keyword If		"${technology}"=="TDD"		Append To List		${TDD_cells}	${cell}
	END

Unlock cells
	[Arguments]     ${cell_list}
	[Documentation]		Unlock specified cell
	FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
		COAM.unlock    dist_name=${Cell_dist}-${cell}		timeout=180     connection=${connection}
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
	${new_val}		Run Keyword If		"${set_value}"!="${value}"
	...		Evaluate    ${set_value} - ${Attenuator_step_val}
	...		ELSE	Set Variable		${set_value}
	Run Keyword If		"${set_value}"!="${value}"	Set Attenuator value	${channel_num}		${new_val}
	[return]		${new_val}

RIC Setup
	[Documentation]		RIC xapp configuration
    Log to console      \nConfiguring RIC
	SSH.Connect_to    ${RIC_ip}    ${RIC_username}    ${RIC_password}    alias=RIC_vm
	${ip}	SSH.Execute     command=kubectl get svc -A|grep service-ricxapp-ca-sa-tsserver | awk '{print $4}'
	...		connection=RIC_vm	timeout=30s
	${ip}	Strip String    ${ip}    characters=\r\n
	FOR    ${i}    IN RANGE    1	7
		LOG		command=curl -L -X DELETE http://${ip}:9091/ric/v1/ca/tsPolicy/${i}
		${output}	SSH.Execute     command=curl -L -X DELETE http://${ip}:9091/ric/v1/ca/tsPolicy/${i}
		...		connection=RIC_vm	timeout=30s
	END
	SSH.upload_file    local_path=${RIC_file_path}   remote_path=${RIC_remote_file}		connection=RIC_vm
	${cmd}	Set Variable
	...	curl -L -X POST http://${ip}:9091/ric/v1/ca/tsPolicy -H "Content-Type: application/json" -d @${RIC_remote_file}
	${output}		SSH.Execute     command=${cmd}      connection=RIC_vm		timeout=30s
	${rc}    Run Keyword And Return Status		Should Be Empty       ${output}
	sleep	5s
	${output}	Run Keyword If    "${rc}"=="False"	SSH.Execute	command=${cmd}	connection=RIC_vm	timeout=30s
	Run Keyword If    "${rc}"=="False"	Should Be Empty		${output}
	SSH.Disconnect		connection=RIC_vm

Attach ue and run throughput
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}    ${throughput}    ${deviation}    ${timeout}
	...    ${calltype}    ${start_bip}=False
	...		${Collect_eGEN}=False    ${check_tpt}=False
	...		${wait_for_transfer}=True
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
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords
	...		ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}
	...		${timeout}
    ...    AND    Sleep    250
    ...    AND    Log to console    \nData transfer completed
    Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure
	...		ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
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



Admin Setup2
	COAM.setup_admin    bts_host=${gNB2_IP}    alias=${connection1}    admin_api_log_dir=/tmp
#	Wait until keyword succeeds   1min   2s    COAM.block_rat    rat=NR    connection=${connection1}
	Wait until keyword succeeds   1min   2s    COAM.block_rat    rat=LTE    connection=${connection1}
