*** Settings ***
Documentation     Keywords and variables for CB007623.robot file
...               Author: ambati.sunil_kumar@nokia.com
Library    String
Library    DateTime
Library    CB007623.py
Library    Collections
Library    OperatingSystem
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.config.scf   WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    SSH
Library    taf.selenium.sbts    WITH NAME    seleLib
Library    taf.collectors.core    WITH NAME    CORE
Library    taf.ul.alarms_watchdog   WITH NAME    alarms
Library    taf.sbts.oam.coam.admin    WITH NAME    COAM
Library    taf.hw.rf_attenuator  WITH NAME  at
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Resource    Common_resource.robot
Resource    alarm.robot

*** Variables ***
${uepc_default_ip}          10.45.150.232          # Windows UE PC IP
${BTS_M_plane_ip}           10.58.239.174
${DCAP_host}                10.41.209.114          # DCAP server IP
${uepc_default_username}    inbabtslabuser          # Windows UE PC username
${uepc_default_password}    BT5l@bus3rl0g1n         # Windows UE PC password
${emil_path}                C://Emil                # Emil path in UE PC machine
@{set_atten_List}  Create List   ${1}   ${2}   ${3}    ${4}   # Attenuation port used
${attenuator_host}          10.53.252.119            # Attenuator IP
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
${at_model}                 TAS16T16-51-120-1N-DEJS                              # Attenuator Model
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
@{data_transfer_protocol}    UDP             # Default data transfer type

*** Keywords ***

Create dcap session
    [Documentation]    Establish DCAP session
	rd.connect_to    host=${DCAP_host}    port=${port}    rd_version=${rd_version}    secure=${secure}

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
	...    timeout=${dcap_log_timeout}

Start BTS logs
    [Documentation]     Starts BTS log in testpc
    Run     killall btslog
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
    create directory    ${OUTPUT_DIR}/DCAP_Logs

Counter value
    [Arguments]    ${counter_name}    ${path5}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...		counter_ids=${counter_name}    timeout=120    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['CELLS']['NRCELL-1']['${path5}']['${counter_name}']}
    ${Total_Count}    Common_resource.Get value of Counter    ${values}
    [Return]    ${Total_Count}

Check Counter
    [Arguments]    ${port_val_list}     ${counter_initial}    ${value2}   ${path5}    ${s}
    [Documentation]     Get Counter name
	log    ${port_val_list}
    FOR    ${index}    IN RANGE    ${s}
	    ${test1}=    Catenate    SEPARATOR=${EMPTY}    ${counter_initial}    ${value2}
		Counter value    ${test1}    ${path5}
		sleep  20
		${value2}     Evaluate    ${value2}+1
		${value2}     Convert To String    ${value2}
	END

Restart the GNB
    [Documentation]     Restart gnb
	Log to console      \nRebooting gNB and waiting for reconnection
	COAM.reset    reset_coverage=Site    wait_for_reconnection=True    timeout=300
	...    connection=${connection}
    COAM.reset_admin     connection=${connection}


Get Current Parameter Value from selenium
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get parameter value
    Log to console      \nChecking gnb parameter ${param_name} value
    seleLib.login    url=https://192.168.255.129    username=Nemuadmin    password=nemuuser
    ...		browser=Chrome    alias=connection
	${view}    seleLib.start_up_view_window_exists    sbts=connection
	Run Keyword If       '${view}'== 'True'     seleLib.close_start_up_view_window      sbts=connection
	${curr_value}    seleLib.get_parameter_value    dist_name=${dist_name}    filter_param=${param_name}    s
	...    bts=connection
    seleLib.close_browser       sbts=connection
    [Return]    ${curr_value}

Check BTS status on runtime and collect dcap logs
    [Arguments]    ${dist_name}
	[Documentation]     Check for parameter change and start DCAP
    Log to console      \nWaiting for state change
    FOR    ${a}    IN RANGE    1   5
	    ${Value}    Get Current Parameter Value from selenium       ${dist_name} 	state
		${bts_status}    COAM.get_bts_statuses    connection=${connection}
		Run Keyword If    '${Value}'== 'NotAdded'    Dcap Start Trace SA
		Exit For Loop IF    '${Value}'== 'NotAdded'
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
		${result}		Parse_Emil_Csv_File_For_Message 	 ${OUTPUT_DIR}/DCAP_Logs/Extracted/		${check}
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
        Extract_zip        ${path1}/${zip}        ${source_paths}
    END
    ${check}    List Directory    ${source_paths}
    FOR    ${value}    IN    @{check}
        ${date}		Set Variable		${value}
    	Exit For Loop
    END
    ${it}=    List Directory    ${source_paths}/${date}
    SSH.Connect_to    ${uepc_default_ip}    ${uepc_default_username}    ${uepc_default_password}    alias=mcg_vm
    FOR    ${out_index}    IN    @{it}
	    Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}
		...     source_file=${out_index}/5g/controlPlane
	END
    ${output}		SSH.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm		timeout=30s
    LOG		${output}
	SSH.Disconnect		connection=mcg_vm

Start Emil To Convert Emil File To Csv
    [Arguments]    ${source_path}     ${source_file}
    [Documentation]         Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}    List Directory    ${source_path}/${source_file}
	SSH.Execute    command=mkdir ${uepc_Log_path}     connection=mcg_vm
	SSH.upload_file    local_path=${source_path}/${source_file}/${source_emil_file}[0]
	...    remote_path=${uepc_Log_path}//${source_emil_file}[0]
	...    connection=mcg_vm
	Run keyword and ignore error	SSH.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f
	...    connection=mcg_vm    timeout=30s
    ${src_file}     Set Variable        ${uepc_Log_path}//${source_emil_file}[0]
	${cmd}	Set Variable	cd ${emil_path} && ./Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile}
	LOG	${cmd}
	${output}		SSH.Execute    command=${cmd}      connection=mcg_vm		timeout=5m
	LOG		${output}
	${csvfile}    String.Replace String    string=${source_emil_file}[0]    search_for=.5gm    replace_with=.csv
	SSH.download_file    remote_path=${uepc_Log_path}//${csvfile}		local_path=${source_path}/${source_file}/${csvfile}      connection=mcg_vm

Lock cells
	[Arguments]     @{cell_list}
	[Documentation]		Lock the specified cell
	FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
		COAM.lock    dist_name=${Cell_dist}-${cell}		connection=${connection}
	END

Unlock cells
	[Arguments]     @{cell_list}
	[Documentation]		Unlock specified cell
	FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
		COAM.unlock    dist_name=${Cell_dist}-${cell}		connection=${connection}
	END
    Wait Until Keyword Succeeds    10 times    30    Common_resource.Check cell status


Setup_Topyoung_attenuator
    [Arguments]    @{set_atten_List}
	[Documentation]    Test the setup and configuration of the RF attenuator.
	${topyoung_device}=    at.setup_attenuator
    ...    ip_addr=${attenuator_host}
    ...    port=${attenuator_port}
    ...    attenuation_port_numbers=${set_atten_List}
    ...    vendor=${at_vendor}
    ...    model=${at_model}
    Log    ${topyoung_device}

Set_Attenuator_Value_Startup
    [Arguments]    @{set_atten_List}
	[Documentation]    Set attenuation for all ports to 0.
	Setup_Topyoung_attenuator    @{set_atten_List}
    FOR    ${port}    IN    @{set_atten_List}
        ${port}=    Convert To Integer    ${port}
        ${value}=   Convert To Integer    0
        ${set_result}=    at.set_attenuation    ${port}    ${value}
        Log    Port ${port} set to 0: ${set_result}
    END

Set_Attenuator_Value_Default
    [Arguments]    @{set_atten_List}
    [Documentation]    Set attenuation for all ports to 0.
    FOR    ${port}    IN    @{set_atten_List}
        ${port}=    Convert To Integer    ${port}
        ${value}=   Convert To Integer    0
        ${set_result}=    at.set_attenuation    ${port}    ${value}
        Log    Port ${port} set to 0: ${set_result}
    END


Start_Attenuation
    [Arguments]    @{set_atten_List}
	[Documentation]    Gradually increase attenuation value in steps of 10 until 40.
	FOR    ${port}    IN    @{set_atten_List}
        ${port}=    Convert To Integer    ${port}
        ${value}=   Convert To Integer    0
        WHILE    ${value} <= 40
            Log    Setting port ${port} to attenuation value ${value}
            ${set_result}=    at.set_attenuation    ${port}    ${value}
            Log    Port ${port} set to ${value}: ${set_result}
            ${value}=    Evaluate    int(${value}) + 10
        END
        Log    Port ${port} final value set to ${value - 10}: ${set_result}
	END

RIC Setup
	[Documentation]		RIC xapp configuration
    Log to console      \nConfiguring RIC
	SSH.Connect_to    ${RIC_ip}    ${RIC_username}    ${RIC_password}    alias=RIC_vm
	${ip}	SSH.Execute     command=kubectl get svc -A|grep service-ricxapp-ca-sa-tsserver | awk '{print $4}'
	...    connection=RIC_vm	timeout=30s
	${ip}	Strip String    ${ip}    characters=\r\n
	FOR    ${i}    IN RANGE    1	7
		LOG		command=curl -L -X DELETE http://${ip}:9091/ric/v1/ca/tsPolicy/${i}
		${output}	SSH.Execute     command=curl -L -X DELETE http://${ip}:9091/ric/v1/ca/tsPolicy/${i}
		...		connection=RIC_vm	timeout=30s
	END
	SSH.upload_file    local_path=${RIC_file_path}   remote_path=${RIC_remote_file}		connection=RIC_vm
	${cmd}	Set Variable
    ...    curl -L -X POST http://${ip}:9091/ric/v1/ca/tsPolicy -H "Content-Type: application/json" -d @${RIC_remote_file}
	${output}		SSH.Execute     command=${cmd}      connection=RIC_vm		timeout=30s
	${rc}    Run Keyword And Return Status		Should Be Empty       ${output}
	sleep	5s
	${output}	Run Keyword If    "${rc}"=="False"	SSH.Execute	command=${cmd}	connection=RIC_vm	timeout=30s
	Run Keyword If    "${rc}"=="False"	Should Be Empty		${output}
	SSH.Disconnect		connection=RIC_vm

Loop for attenuation increase
    [Arguments]		${port_val_list}	${Attenuator_step_val}
	${loop_status}    Set Variable    ${0}
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
