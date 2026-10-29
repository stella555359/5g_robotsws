*** Settings ***
Documentation
...								GSM RSSI Validation

Library						RSSI.py
Library						json
Library						String
Library						DateTime
Library						Collections
Library						OperatingSystem
Library						ute_reporting_portal
Library						taf.sw.scout				WITH NAME   	scout
Library						taf.transport.ssh			WITH NAME		ssh
Library						taf.collectors.core			WITH NAME		core
Library						taf.hw.rf_attenuator		WITH NAME		at
Library						taf.collectors.btslog		WITH NAME		btslog
Library						taf.sbts.oam.coam.admin		WITH NAME		COAM

Suite setup					Wait Until Keyword Succeeds	3 times	   		5
...							Execute command in UE PC	adb devices		Expected=${UE_serial_ID}

Test setup					Admin setup
Test teardown				Admin Teardown

*** Variables ***
${BTS_IP}					192.168.255.129
${connection}				GSM_RSSI
${UE_PC_IP}					10.45.150.135
${Windows_user}				ute
${Windows_pass}				BT5l@bus3rl0g1n
${ANT_line}					GNCEL-2/TRX-3
@{ANT_DN}					/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-10/ANTL_R-1
...							/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-10/ANTL_R-2
...							/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-10/ANTL_R-3
...							/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-10/ANTL_R-4
@{at_channel}				${1}	${2}	${3}	${4}	${5}	${6}	${7}
...							${8}	${9}	${10}	${11}	${12}	${13}	${14}
...							${15}	${16}
${attenuator_host}			10.45.153.207
${attenuator_port}			${3001}
${at_vendor}				TOPYOUNG
${at_model}	 				TAS_16T16_0_2G6_90_1S_DEJS
${BTSlog_status}			IDLE
${Antenna_line_monitoring}	IDLE
${IP_Capture}				IDLE
${Check_cell_status}		True
${cell_status}
${Report_to_QC}				True
${qc_domain}				MN_RAN
&{qc_project_val}			QC_PROJECT_FL00=RAN_VRF	QC_PROJECT_SBTS26R1=RAN_VRF	QC_PROJECT_SBTS26R2=RAN_VRF
&{ca_val}					QC_CA_FL00=VRF_RRM		QC_CA_SBTS26R1=VRF_RRM		QC_CA_SBTS26R2=VRF_RRM
&{RSSI_Validation}			QC_ID_FL00=31517		QC_ID_SBTS26R1=246759		QC_ID_SBTS26R2=302485
${Update_to_QC}				TRUE
${UE_serial_ID}				RZCTA0WBVSN

*** Test Cases ***
RSSI_Validation
	[Tags]    GSM_RSSI		TMO
	Print statement in console	Enabling Aeroplane mode
	Execute command in UE PC	adb -s ${UE_serial_ID} shell cmd connectivity airplane-mode enable
	Start antenna line monitoring
	Set attenuation to 0
	Print statement in console	Sleeping for 60s
	Sleep	60s
	Print statement in console	Disabling Aeroplane mode
	Execute command in UE PC	adb -s ${UE_serial_ID} shell cmd connectivity airplane-mode disable
	Print statement in console	Sleeping for 180s
	Sleep	180s
	Print statement in console	Starting voice call
	Execute command in UE PC	adb -s ${UE_serial_ID} shell am start -a android.intent.action.CALL -d tel:123456
	Print statement in console	Sleeping for 180s
	Sleep	180s
	Print statement in console	Stopping voice call
	Execute command in UE PC	adb -s ${UE_serial_ID} shell input keyevent 6
	Print statement in console	Sleeping for 180s
	Sleep	180s
	Print statement in console	Enabling Aeroplane mode
	Execute command in UE PC	adb -s ${UE_serial_ID} shell cmd connectivity airplane-mode enable
	Sleep	10s
	Set attenuation to 90
	Print statement in console	Sleeping for 180s
	Sleep	180s
	Stop antenna line monitoring
	Extract and Validate RSSI values	${OUTPUT_DIR}/RSSI_Voice_call.json

*** Keywords ***
Admin setup
	COAM.setup_admin			bts_host=${BTS_IP}	  	 	admin_api_log_dir=/tmp		alias=${connection}
	Check BTS is OnAir
	at.setup_attenuator			ip_addr=${attenuator_host}  port=${attenuator_port}		attenuation_port_numbers=@{at_channel}
    ...  						vendor=${at_vendor}  		model=${at_model}
	Set Initial attenuation
	Get the software build
	Start BTS logs

Admin Teardown
	Run Keyword If 		'${BTSlog_status}'=='Started'				Stop BTSLOG and collect
	Restore attenuation
	Run keyword if		"${Report_to_QC}" == "True"					Report to QC
	Run Keyword If		"${Antenna_line_monitoring}" == "Started"	Stop antenna line monitoring
	Run Keyword If		"${IP_Capture}" == "Started"				Stop IP Capture
	Run keyword if		"${TEST STATUS}" != "PASS"					Collect snapshot from BTS
	COAM.teardown_admin	connection=${connection}
	Print statement in console	Disabling Aeroplane mode
	Execute command in UE PC	adb -s ${UE_serial_ID} shell cmd connectivity airplane-mode disable

Check BTS is OnAir
	[Documentation]		Check the BTS current status
	${bts_status}		COAM.get_bts_statuses	 connection=${connection}
	Should Be Equal As Strings		${bts_status["proceduralState"]}	  OnAir
	Run Keyword If					'${bts_status["proceduralState"]}'=='OnAir'	   LOG	  BTS procedural state is now: ${bts_status["proceduralState"]}
	...	   ELSE						fail
	Print statement in console		BTS procedural state : ${bts_status["proceduralState"]}
	Print statement in console		Waiting for all cells to be operational
	Run keyword if		"${Check_cell_status}"=="True"		Check cell status

Check cell status
	[Arguments]		${duration}=300				${connection}=${connection}
	Print statement in console					Waiting upto ${duration}s for all cells to be operational
	${status}	Run keyword and return status	Wait Until Keyword Succeeds		${duration}	10	Check cell status GSM	${connection}
	Run Keyword If	'${status}'=='False'		Run keywords					Set test variable			${cell_status}	Failed
	...		AND		Print statement in console	GSM cells verification failed
	${status}	Run keyword and return status	Wait Until Keyword Succeeds		${duration}	10	Check cell status WCDMA	${connection}
	Run Keyword If	'${status}'=='False'		Run keywords					Set test variable			${cell_status}	Failed
	...		AND		Print statement in console	WCDMA cells verification failed
	${status}	Run keyword and return status	Wait Until Keyword Succeeds		${duration}	10	Check cell status LTE	${connection}
	Run Keyword If	'${status}'=='False'		Run keywords					Set test variable			${cell_status}	Failed
	...		AND		Print statement in console	LTE cells verification failed
	${status}	Run keyword and return status	Wait Until Keyword Succeeds		${duration}	10	Check cell status NR	${connection}
	Run Keyword If	'${status}'=='False'		Run keywords					Set test variable			${cell_status}	Failed
	...		AND		Print statement in console	NR cells verification failed
	Run Keyword If	"${cell_status}"=="Failed"	Run keywords
	...											Print statement in console		Cells verification failed	AND		FAIL
	...		ELSE								Print statement in console		All cells are operational

Collect snapshot from BTS
	[Documentation]					Download BTS snapshot
	Print statement in console		Collecting snapshot from BTS
	${status}			Run keyword and return status		COAM.Collect Snapshot	target_file_name=${OUTPUT_DIR}/Snapshot.zip
	...																				coverage=Full
	...																				force=True
	...																				timeout=1000
	...																				connection=${connection}
	Run Keyword If		'${status}'=='False'				Log   					Snapshot collection failed !!!

Check cell status NR
	[Documentation]	Check all cell status
	[Arguments]		${connection}=${connection}
	${cells}		COAM.get_cells_info		cell_type=nr	timeout=10	 connection=${connection}	 detailed_output=False
	${count}    	Get length    ${cells}
	${status}		Run keyword and return status	Should be True	${count}>0
	Run Keyword If	'${status}'=='True'	check all cell status	${cells}	${connection}

Check cell status LTE
	[Documentation]	Check all cell status
	[Arguments]		${connection}=${connection}
	${cells}		COAM.get_cells_info		cell_type=lte	timeout=10	 connection=${connection}	 detailed_output=False
	${count}		Get length    ${cells}
	${status}		Run keyword and return status	Should be True	${count}>0
	Run Keyword If	'${status}'=='True'	check all cell status	${cells}	${connection}

Check cell status WCDMA
	[Documentation]	Check all cell status
	[Arguments]		${connection}=${connection}
	${cells}		COAM.get_cells_info		cell_type=wcdma		timeout=60		connection=${connection}	detailed_output=False
	${count}		Get length				${cells}
	${status}		Run keyword and return status				Should be True	${count}>0
	Run Keyword If	'${status}'=='True'	check all cell status	${cells}		${connection}

Check cell status GSM
	[Documentation]	Check all cell status
	[Arguments] 	${connection}=${connection}
	${cells}		COAM.get_cells_info		cell_type=gsm	timeout=10	 connection=${connection}	 detailed_output=False
	${count}    	Get length    ${cells}
	${status}		Run keyword and return status	Should be True	${count}>0
	Run Keyword If	'${status}'=='True'	check all cell status	${cells}	${connection}

check all cell status
	[Arguments]		${cells}	${connection}=${connection}
	FOR	   ${cell_dist}	   IN	 @{cells}
		Check cell details		 ${cell_dist['id']['internal']}		connection=${connection}
	END

Check cell details
	[Documentation]				Check cell details
	[Arguments]					${cell}		${connection}=${connection}
	...							${locking_status}=unlocked
	${cell_status}				COAM.get_cell_specific_info	cell_id=${cell}		timeout=60		connection=${connection}
	${administrativeState}		Set Variable	${cell_status['status']['administrativeState']}
	Run keyword if 				'${administrativeState.upper()}'=='${locking_status.upper()}'	Check cell technology	${cell_status}

Check cell technology
	[Arguments]					${cell_status}
	${status}					Run keyword and return status		LOG				${cell_status['technology']}
	Run Keyword If				'${status}'=='False'				Check power saving	${cell_status}
	Run Keyword If				'${status}'=='True'					Run keyword if	'${cell_status['technology'].upper()}'=='FDD'
	...							Check power saving					${cell_status}
	Run Keyword If				'${status}'=='True'					Run keyword if	'${cell_status['technology'].upper()}'=='TDD'
	...							Check power saving					${cell_status}

Check power saving
	[Arguments]					${cell_status}
	${status}					Run keyword and return status		LOG						${cell_status['energySavingState']}
	Run Keyword If				'${status}'=='False'				Check cell available	${cell_status}
	Run Keyword If				'${status}'=='True'					Run keyword if	'${cell_status['energySavingState'].upper()}'=='ENERGYSAVING'
	...							Check cell power saving				${cell_status}
	Run Keyword If				'${status}'=='True'					Run keyword if	'${cell_status['energySavingState'].upper()}'!='ENERGYSAVING'
	...		  					Check cell available				${cell_status}

Check cell available
	[Arguments]					${cell_status}		${operational_status}=enabled	${usage_status}=Active
	...							${blocking_status}=Unblocked
	${operationalState}			Set Variable	${cell_status['status']['operationalState']}
	Run keyword And Continue On Failure		Should Be Equal	${operationalState.upper()}			${operational_status.upper()}
	${usageState}				Set Variable	${cell_status['status']['usageState']}
	Run keyword And Ignore error			Should Be Equal			${usageState.upper()}		${usage_status.upper()}
	${blockingState}			Set Variable	${cell_status['status']['blockingState']}
	Run keyword And Continue On Failure		Should Be Equal			${blockingState.upper()}	${blocking_status.upper()}

Check cell power saving
	[Arguments]					${cell_status}		${operational_status}=disabled	${usage_status}=Idle
	...							${blocking_status}=Unblocked
	${operationalState}			Set Variable	${cell_status['status']['operationalState']}
	Run keyword And Continue On Failure		Should Be Equal	${operationalState.upper()}			${operational_status.upper()}
	${usageState}				Set Variable	${cell_status['status']['usageState']}
	Run keyword And Ignore error			Should Be Equal			${usageState.upper()}		${usage_status.upper()}
	${blockingState}			Set Variable	${cell_status['status']['blockingState']}
	Run keyword And Continue On Failure		Should Be Equal			${blockingState.upper()}	${blocking_status.upper()}


Set Initial attenuation
	${set attenuation}		Create List		1,90	2,90	3,90	4,90	5,90	6,90	7,90	8,90	9,90	10,90
	...										11,90	12,90	13,90	14,90	15,90	16,90
	Change attenuation		${set attenuation}

Set attenuation to 0
	${set attenuation}		Create List		5,0
	Change attenuation		${set attenuation}

Set attenuation to 90
	${set attenuation}		Create List		5,90
	Change attenuation		${set attenuation}

Restore attenuation
	${set attenuation}		Create List		3,0		5,90
	Change attenuation		${set attenuation}

Change attenuation
    [Arguments]     	${port_val_list}
    [Documentation]     Set the attenuation of specified port
	Print statement in console      Changing attenuator values : ${port_val_list}
    FOR    ${val}    IN    @{port_val_list}
        ${channel_num}      ${value}    Split String    ${val}  ,   1
        Set Attenuator value    ${channel_num}      ${value}
    END

Set Attenuator value
    [Arguments]     ${channel_num}      ${value}
    [Documentation]     Set the attenuation of specified port
    ${channel_num}      Convert To Integer      ${channel_num}
    ${value}			Convert To Integer      ${value}
    ${set_value}  		at.read_attenuation  	port=${${channel_num}}
    at.set_attenuation  port=${channel_num}     value=${value}      	confirm=${True}
    #sleep   2s      	reason=Wait for change in state
    ${set_value}  		at.read_attenuation  port=${${channel_num}}
    Should Be Equal As Strings  ${set_value}  ${value}

Execute command in UE PC
	[Documentation]		Execute command in UE PC
	[Arguments]			${command}		${Expected}=
	Print statement in console		Executing command "${command}" in machine "${UE_PC_IP}"
	Wait Until Keyword Succeeds		3 times	   		5
	...		ssh.Connect_to			${UE_PC_IP}		${Windows_user}		${Windows_pass}    alias=UE_PC_CMD		timeout=60
    ${output}			ssh.Execute		${command}	connection=UE_PC_CMD
    Log					${output}
	Should contain		${output}		${Expected}
	[Teardown]			ssh.Disconnect	connection=UE_PC_CMD
	[Return]			${output}

Print statement in console
	[Arguments]		${Statement}
	${date}			Get Current Date	result_format=%H:%M:%S
	${date}			Convert to String	${date}
	Log         	\n[${date}] ${Statement}    console=True

Start antenna line monitoring
	Print statement in console			Starting Wireshark Logs
	COAM.start_ip_capture_file			measurement_point=NE_Terminated		uplane_capturing=TRUE	password=	timeout=120
	...									connection=${connection}			detailed_output=False
	Set test variable					${IP_Capture}						Started
	Print statement in console			Starting antenna line monitoring
	COAM.start_antl_online_monitoring	${ANT_DN}	timeout=30				connection=${connection}
	Set test variable					${Antenna_line_monitoring}			Started

Stop antenna line monitoring
	Print statement in console	Stopping antenna line monitoring
	Run Keyword If		"${Antenna_line_monitoring}" == "Started"	COAM.stop_antl_online_monitoring
	...																${OUTPUT_DIR}/RSSI_Voice_call.json	timeout=30	connection=${connection}
	Set test variable	${Antenna_line_monitoring}		Stopped
	Run Keyword If		"${IP_Capture}" == "Started"	Stop IP Capture

Stop IP Capture
	Print statement in console		Stopping Wireshark Logs
	COAM.stop_ip_capture_file		timeout=120		connection=${connection}	detailed_output=False
	COAM.generate_ip_capture_file	timeout=120		connection=${connection}	detailed_output=False	password=
	COAM.download_ip_capture_file	target_file_name=${OUTPUT_DIR}/RSSI.pcap
	...								timeout=120		connection=${connection}	detailed_output=False
	Set test variable				${IP_Capture}	Stopped

Extract and Validate RSSI values
	[Arguments]	${RSSI_file}
	Print statement in console	Verifying the RSSI values in file ${RSSI_file}
	${File}		Get File    ${RSSI_file}
	${Data}		Evaluate	json.loads('''${File}''')   json
	LOG			${Data}
	Validate RSSI values_from_python	${RSSI_file}	${ANT_line}

Validate RSSI values
	[Arguments]		${Data}		${i}			${dist}
	${Value}		${result}	Verify_RSSI		${Data}		${i}	${dist}
	Print statement in console	ANT ${i}: ${Value}
	Run keyword And Continue On Failure	Should be True	${result}

Validate RSSI values_from_python
	[Arguments]	${RSSI_file}	${ANT_line}
	${Value}	${Result}		Convert_validate_RSSI	${RSSI_file}	${ANT_line}
	FOR    ${index}    IN RANGE    4
		Print statement in console	ANT ${index}: ${Value}[${index}]
	END
	Run keyword And Continue On Failure	Should be True	${Result}

Link SCOUT SCF to Configuration ID for Reporting
	[Documentation]			Link Scout
    [Arguments]				${node_id}=${0}			${node_type}=gnb    ${tl_name_only}=${Hostname}
    ${node_type_Name}		Run Keyword If			"${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF			"${node_type}"=="enb"	Set Variable  	eNB
    ...     ELSE			Fail    				Wrong node_type '${node_type}'! allowed: enb|gnb
	Log						${node_id}
    Print statement in console			SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}	Set Variable			${tl_name_only}
    ${external_scf_id}		Request Scout SCF		${scout_testline_name}
    ${TC_ID}				Set Variable			ute:id:${external_scf_id}
    Set Tags				${TC_ID}
	Set Suite variable		${external_scf_id}

Request Scout SCF
	[Documentation]			Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW
    [Arguments]				${scout_testline_name}
    scout.setup_scout		scout_testline_name=${scout_testline_name}
    ${external_scf_id}		scout.request_scf   use_scout_internal_id=True
    [Teardown]				scout.teardown_scout_api
    [Return]				${external_scf_id}

Report to QC
    Get Hostname
	Wait Until Keyword Succeeds		2min    10s      Link SCOUT SCF to Configuration ID for Reporting
	Set QC Id
	Run keyword if					"${Update_to_QC}" == "TRUE"		Update to Reporting portal

Update to Reporting portal
	[Documentation]		Report the status to QC
	Print statement in console	Updating result to QC as ${TEST STATUS}
	${Res}		Run keyword if	"${TEST STATUS}" == "PASS"		Set variable	passed
	...			ELSE			Set variable	 failed
	${Link}		Report To Rp	name=${TEST NAME}		result=${Res}	ca=${ca}
	...																	testline=${Hostname}		build=${Active_build}	qc_domain=${qc_domain}
	...																	qc_project=${qc_project}	qc_id=${QC_ID}			label=
	...																	tool=WebEM					kpi_results=			links=
	...																	tc_execution_id=${external_scf_id}
	Print statement in console	Reportal portal link : \n${Link}

Get Hostname
	[Documentation]		Get hosename of test machine
	${output}			Run			hostname
	${Hostname}			String.Replace String	 string=${output}	   search_for=-	   replace_with=_
	Set Suite variable	${Hostname}

Set QC Id
	[Documentation]		Get QC ID of testcase
	@{sw_list}			String.Split String	${Active_build}	 _
	${status}			Run Keyword And Return Status 		Should contain		${Active_build}	ENB_999
	${Tag}				Run Keyword If		'${status}'=='True'					Set Variable    FL00
    ...     			ELSE    			Set Variable   						${sw_list[0]}
	${QC_ID}    		Get from Dictionary	${${TEST_NAME}}						QC_ID_${Tag}
	${qc_project}		Get from Dictionary	${qc_project_val}					QC_PROJECT_${Tag}
	${ca}				Get from Dictionary	${ca_val}							QC_CA_${Tag}
	Set Suite variable	${QC_ID}
	Set Suite variable	${ca}
	Set Suite variable	${qc_project}
	Set Tags    		${QC_ID}

Get the software build
    ${sw_version}       COAM.get_sw_version     connection=${connection}
    Set Suite Metadata  Software version        ${sw_version}
    Set Suite variable  ${sw_version}
    ${Active_build}     Check current software
    Set Suite variable  ${Active_build}

Check current software
    [Documentation]     Check current software in BTS
    ${Build}            COAM.get_sw_version     connection=${connection}
    @{sw_list}          String.Split String     ${Build}     _
	${status}			Run Keyword And Return Status 		Should contain		${Build}	ENB_999
    ${current_trunk_sw}	Run Keyword If      	'${status}'=='True'     Replace String      ${Build}        ${sw_list[0]}     SBTS00
    ...                 ELSE                	Set variable    ${Build}
    [Return]            ${current_trunk_sw}

Start BTS logs
    [Documentation]    Starts BTS log in testpc
    Print statement in console    Starting BTSlog
    Run    killall btslog
    btslog.create_btslog_collector    name=btslog
    ${status}				Run Keyword And Return Status	core.setup_collectors    		names=btslog
    Run Keyword If 			'${status}'=='False'			Print statement in console		ERROR IN BTSLOG COLLECTION !!!
    core.set_suite_alias	btslog
    ${status} 	Run Keyword And Return Status 			core.start_collectors    		names=btslog
	Run Keyword If 		'${status}'=='False'			Print statement in console		ERROR IN BTSLOG COLLECTION !!!
	Run Keyword If 		'${status}'!='False'			Set test variable				${BTSlog_status}	Started

Stop BTSLOG and collect
    Print statement in console		Collecting BTSlog
	core.stop_collectors    		names=btslog
    ${status} 	Run Keyword And Return Status 			core.collect_collectors    names=btslog    target_dir=${OUTPUT_DIR}
	Run Keyword If 		'${status}'=='False'			Log		ERROR IN BTSLOG COLLECTION !!!		WARN
    core.teardown_collectors    names=btslog
	[Return]		${status}