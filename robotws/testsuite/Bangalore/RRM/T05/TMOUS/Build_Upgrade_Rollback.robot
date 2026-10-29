*** Settings ***
Documentation
...								Upgrade build to specified software
...								Author		: Rakshith B
...								Email Id	: Rakshith.b@nokia.com

Library							String
Library							DateTime
Library							OperatingSystem
Library							taf.transport.ssh		WITH NAME	ssh
Library							taf.collectors.core		WITH NAME	core
Library							taf.ul.alarms_watchdog	WITH NAME	alarm
Library							taf.sbts.oam.coam.admin	WITH NAME	COAM
Library							taf.collectors.btslog	WITH NAME	btslog
Library							taf.config.scf			WITH NAME	scf

Test setup						Admin Setup
Test Teardown					Admin Teardown

*** Variables ***
${BTS_IP}						192.168.255.129											# IP for BTS
${Update_timeout}				60m														# Timeout for software update
${Download_path}				/home/ute/Downloads										# Software download path in test pc
${connection}					Active_Session											# Alias used for connection
${File_extension}				_release_BTSSM_downloadable_A54.zip						# Build extension used in download and upgrade build
${wget_link}					https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${Build_download_timeout}		30m														# Timeout to download build
${BTSlog_status}				Not started												# BTS default status
${Verify_Initial_BTS_status}	True													# Verify BTS status in admin setup
${Collect_snapshot}				True													# Collect BTS snapshot at end of testcase
${Delete_build}					True													# Delete build after upgrade
${Check_cell_status}			True													# Verify all cell status
${cell_status}
${SCF_file}

*** Test Cases ***
Upgrade_BTS_software
	[Documentation]		Upgrade BTS with provided build
	Check build file and Upgrade build

Verify_active_passive_and_Upgrade_BTS_software
	[Documentation]		Upgrade BTS with provided build
	${current_sw}		Check current software
	${Passive_build}	Verify Passive build
	Run keyword if		"${current_sw}" == "${Build}"		Print statement in console			Software is already active in BTS ${BTS_IP}
	...		ELSE		Run keyword if						"${Passive_build}" == "${Build}"	Rollback BTS software to passive
	...		ELSE		Check build file and Upgrade build

Rollback_BTS_software
	[Documentation]		Rollback build
	Rollback build

Verify_BTS_software
	[Documentation]		Verify Build
	Set global variable	${Collect_snapshot}				False
	${current_sw}		Check current software
	Run keyword if		"${current_sw}" != "${Build}"	Run keywords
	...					Print statement in console		Required software is not active in BTS !!!!
	...		AND			FAIL

Commission_BTS
	[Documentation]		Commissioning BTS with provided files
	Run Keyword If		"${BTS_IP}"=="192.168.255.129"	Start BTS logs
	Run Keyword If		"${SCF_file}" != ""	Check and commission file
	...		ELSE		Run keywords		Print statement in console		SCF file not provided !!!
	...		AND			FAIL
	COAM.reset_admin	timeout=60	connection=${connection}
	Print statement in console		Waiting for BTS status to be OnAir
	Wait Until Keyword Succeeds		1200		30	Check for BTS status
	Run keyword if		"${Check_cell_status}"=="True"		Check cell status
	Run keyword And Continue On Failure		Stop BTS logs and check

*** keywords ***
Admin Setup
	[Documentation]					This keyword checks the BTS status
	Print statement in console		Arguments BTS IP: ${BTS_IP}
	Print statement in console		Arguments Build: ${Build}
	Print statement in console		Arguments SCF: ${SCF_file}
	Create testcase folder
	COAM.setup_admin	bts_host=${BTS_IP}		timeout=60	alias=${connection}	admin_api_log_dir=/tmp
	Run keyword if		"${Verify_Initial_BTS_status}"=="True"	Wait Until Keyword Succeeds		120	30	Check BTS is OnAir
	Run keyword if		"${Verify_Initial_BTS_status}"=="True"	Check cell status	duration=100
	...		ELSE		Print statement in console		Skipping BTS state verification
	${BTS_details}		COAM.get_bts_info		timeout=60		connection=${connection}
	Set global variable	${BTS_ID}				${BTS_details['mrbtsID']}
	${Active_alarm}		COAM.get_active_alarms	timeout=60	connection=${connection}
	LOG					${Active_alarm}
	Run Keyword If		"${BTS_IP}"=="192.168.255.129"	Start watching alarm
	Backup SCF			Pre_execution_scf

Admin Teardown
	[Documentation]		This keyword check BTS status post execution and alarms in runtime
	Check BTS is OnAir
	Run keyword if		"${Check_cell_status}"=="True"			Check cell status	duration=100
	Backup SCF			Post_execution_scf
	Run Keyword If		"${BTS_IP}"=="192.168.255.129"			Check for unexpected alarms
	Run Keyword If		"${BTS_IP}"=="192.168.255.129"			alarm.stop_watching_alarms
	${Active_alarm}		COAM.get_active_alarms    timeout=60	connection=${connection}
	LOG					${Active_alarm}
	Run Keyword If		'${BTSlog_status}'=='Started'			Stop BTSLOG and collect
	Run keyword if		"${Collect_snapshot}" == "True"			Run keyword if		"${TEST STATUS}" != "PASS"
	...					Snapshot download from BTS
	COAM.teardown_admin	connection=${connection}

Check for unexpected alarms
	[Documentation]		This keyword check BTS status post execution and alarms in runtime
	${status}			Run Keyword And Return Status	alarm.check_detected_alarms
	Run Keyword If		'${status}'=='False'	Log		Unexpected alarms raised !!!	WARN

Start BTS logs
	[Documentation]		Starts BTS log in testpc
	Print statement in console	Starting BTSlog
	Run					killall btslog
	btslog.create_btslog_collector				name=btslog
	${status}	Run Keyword And Return Status	core.setup_collectors		names=btslog
	Run Keyword If	'${status}'=='False'		Print statement in console	ERROR IN BTSLOG COLLECTION !!!
	core.set_suite_alias	btslog
	${status}	Run Keyword And Return Status	core.start_collectors		names=btslog
	Run Keyword If		'${status}'=='False'	Print statement in console	ERROR IN BTSLOG COLLECTION !!!
	Run Keyword If		'${status}'!='False'	Set test variable			${BTSlog_status}	Started

Stop BTS logs and check
	[Documentation]	Stops BTS log and check for crash
	${status}		Run Keyword If		'${BTSlog_status}'=='Started'	Stop BTSLOG and collect
	Set test variable	${BTSlog_status}	Collected
	#${check}		Run Keyword If		'${status}'=='True'	Check_bts_logs				${log_path}/btslog
	#Run Keyword If	${check} == False	Log		Unexpected prints found in syslog !!!	WARN

Stop BTSLOG and collect
	Print statement in console	Collecting BTSlog
	core.stop_collectors		names=btslog
	${status}	Run Keyword And Return Status	core.collect_collectors		names=btslog	target_dir=${log_path}
	Run Keyword If				'${status}'=='False'	Log		ERROR IN BTSLOG COLLECTION !!!	WARN
	core.teardown_collectors	names=btslog
	[Return]					${status}

Start watching alarm
	[Documentation]		Start watching for alarms
	${Active_alarm}		COAM.get_active_alarms	timeout=60	connection=${connection}
	${allowed_alarms}	Expected alarm
	alarm.Watch alarms	allowed_alarms=${allowed_alarms}		connection_kwargs=${connection}	log_dir=/tmp

Expected alarm
	[Documentation]			Alarm exception list which are ignored in watch alarm
	${allowed_alarm_1}		Create alarm	alarm_id=7220		fault_id=61524		fault_name=SSH enabled
	${allowed_alarm_2}		Create alarm	alarm_id=7220		fault_id=4654		fault_name=Ethernet port security is disabled
	${allowed_alarm_3}		Create alarm	alarm_id=7220		fault_id=61649		fault_name=LMP access via port 443
	${allowed_alarm_4}		Create alarm	alarm_id=7220		fault_id=4655		fault_name=Service account root access is enabled
	${allowed_alarm_5}		Create alarm	alarm_id=7220		fault_id=61652		fault_name=R&D Service Port enabled
	${allowed_alarm_6}		Create alarm	alarm_id=7220		fault_id=61648		fault_name=LMP connectivity detected
	${allowed_alarm_7}		Create alarm						fault_id=4592		fault_name=BTS Reset Cause
	${allowed_alarm_8}		Create alarm	alarm_id=7652		fault_id=6261
	...															fault_name=Failure in internal BTS connection or connection to 3rd party tool
	${allowed_alarm_9}		Create alarm 						fault_name=No X2 link available for a specific LTEENB
	${allowed_alarm_10}		Create alarm 						fault_name=No X2 link available
	${allowed_alarm_11}		Create alarm 						fault_name=Setup of X2 connectivity to gNB failed
	${allowed_alarms}		Create list		${allowed_alarm_1}	${allowed_alarm_2}	${allowed_alarm_3}	${allowed_alarm_4}	${allowed_alarm_5}
	...										${allowed_alarm_6}	${allowed_alarm_7}	${allowed_alarm_8}	${allowed_alarm_9}	${allowed_alarm_10}
	...										${allowed_alarm_11}
	[Return]				${allowed_alarms}

Check BTS is OnAir
	[Documentation]		Check BTS status and fail if BTS status is not OnAir
	${bts_status}		COAM.get_bts_statuses	timeout=60		connection=${connection}
	LOG					${bts_status}
	Should Be Equal As Strings	${bts_status["proceduralState"]}		OnAir
	Run Keyword If		'${bts_status["proceduralState"]}'=='OnAir'		LOG		BTS procedural state is now: ${bts_status["proceduralState"]}
	...		ELSE		fail
	Print statement in console	BTS procedural state : ${bts_status["proceduralState"]}

Create testcase folder
	[Documentation]		Logs folder will be created
	${val}				Run Keyword And Return Status	LOG		${OUTPUT_DIR}/${Folder}/${TEST NAME}
	Run Keyword If		${val} == False		Get Date
	Create directory	${OUTPUT_DIR}/${TEST NAME}
	Set suite variable	${log_path}			${OUTPUT_DIR}/${TEST NAME}

Get Date
	[Documentation]		Current date is set as logs folder name
	${date}				Get Current Date	result_format=%d_%m_%Y_%H%M%S_%f
	${date}				Convert to String	${date}
	Set global variable	${Folder}			${date}

Check build file and Upgrade build
	[Documentation]	Check the build file and download to testpc
	${current_sw}	Check current software
	Run keyword if	"${current_sw}" != "${Build}"	Update BTS software
	...		ELSE	Print statement in console		Planned software is already active in BTS ${BTS_IP}

Check file in vm
	[Documentation]	Check the build file in testpc
	${files}		List Files In Directory		${Download_path}
	${val}			Set Variable				False
	FOR	${file}	IN	@{files}
		${val}				Run keyword and return status	Check file name and return status	${file}
		Exit For Loop If	${val} == True
	END
	Run keyword if			${val} == False    Download build

Check file name and return status
	[Documentation]	Check the build file in testpc
	[Arguments]		${File}
	${val}			Run keyword if	"${File}" == "${Build}${File_extension}"	Set variable	True
	...	ELSE		Set variable	False
	Run keyword if	${val} == True	Print statement in console		Build file ${File} is already present in vm
	Should be True	${val}

Download build
	[Documentation]				Download build to test pc
	${Branch}	Split string		${Build}	_
	Print statement in console		Planned build branch is ${Branch}[0]
	Print statement in console		Planned build is ${Build}
	${File}		Set variable		${Build}${File_extension}
	${cmd}		Set variable		wget -o ${log_path}/wget_download_log.txt ${wget_link}/${Branch}[0]/${Build}/${File}
	Print statement in console		Downloading build ${Build} to path ${Download_path}, it may take some while
	Print statement in console		Running command : ${cmd}
	${rc}		Run And Return Rc	cd ${Download_path} && timeout ${Build_download_timeout} ${cmd}
	${output}	Get File			${log_path}/wget_download_log.txt
	Log			${output}
	Run Keyword If	${rc} == ${0}	Print statement in console	Download successfull
	...		ELSE	Run keywords	RUN				rm ${Download_path}/${Build}${File_extension}
	...		AND		Print statement in console		${output}
	...		AND		Print statement in console		Download failed
	Should be equal	${rc}	${0}

Check current software
	[Documentation]		Check current software in BTS
	${current_sw}		COAM.get_sw_version		timeout=60		connection=${connection}
	@{sw_list}			String.Split String		${current_sw}	_
	${status}			Run Keyword And Return Status			Should contain	${current_sw}	ENB_999
	${current_build}	Run Keyword If	'${status}'=='True'		Replace String	${current_sw}	${sw_list[0]}	SBTS00
	...		ELSE		Set variable	${current_sw}
	Print statement in console			Current software in BTS ${BTS_IP} is ${current_sw}
	[Return]			${current_build}

Update BTS software
	[Documentation]				Upgrade software build in BTS
	Check file in vm
	Verify upgrade path
	Run Keyword If				"${BTS_IP}"=="192.168.255.129"		Start BTS logs
	Print statement in console	Updating software in BTS ${BTS_IP} to ${Build}
	COAM.update_software		sw_package=${Download_path}/${Build}${File_extension}	should_activate=True
	...							timeout=${Update_timeout}	connection=${connection}
	Print statement in console	Software update completed, rebooting BTS ${BTS_IP} and waiting for reconnection
	Verify BTS reset
	Wait for BTS to be reachable
	COAM.reset_admin				timeout=60					connection=${connection}
	Run Keyword If					"${SCF_file}" != ""			Wait Until Keyword Succeeds
	...		3 times		5m			Check and commission file	duration=60
	Print statement in console		Waiting for BTS status to be OnAir
	Wait Until Keyword Succeeds		1200		30	Check for BTS status
	Run keyword if		"${Check_cell_status}"=="True"	Check cell status
	${current_sw}		Check current software
	Run keyword if		"${current_sw}" == "${Build}"	Print statement in console	Software update successfull
	...		ELSE		Print statement in console		Software update failed
	Run keyword And Continue On Failure					Stop BTS logs and check
	Should Be Equal As Strings		${current_sw}		${Build}
	[Teardown]	Run Keyword If		"${KEYWORD STATUS}"=="PASS"		Run keywords
	...								Print statement in console		Deleting build file ${Build}${File_extension}
	...					AND			Run Keyword If	"${Delete_build}"=="True"	RUN	rm ${Download_path}/${Build}${File_extension}

Check and commission file
	[Arguments]		${duration}=100
	Print statement in console		Checking BTS status to perform commissioning until ${duration}s
	${status}	Run keyword and return status	Wait Until Keyword Succeeds		${duration}	30	Check for BTS status
	Run Keyword If	'${status}'=='False'		Print statement in console		BTS status verification failed
	Print statement in console		Performing site commissioning, SCF file : ${SCF_file}
	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${SCF_file}	skip_parameter_relation_errors=True
	...								should_activate=True	timeout=600				connection=${connection}
	Print statement in console		Site commissioning successful

Check for BTS status
	[Documentation]	Check for BTS on air after software upgrade
	${bts_status}	COAM.get_bts_statuses	timeout=60							connection=${connection}
	Should Be Equal As Strings				${bts_status["proceduralState"]}	OnAir

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

Check cell status NR
	[Documentation]	Check all cell status
	[Arguments]		${connection}=${connection}
	${cells}		COAM.get_cells_info		cell_type=nr		timeout=60		connection=${connection}	detailed_output=False
	${count}		Get length				${cells}
	${status}		Run keyword and return status				Should be True	${count}>0
	Run Keyword If	'${status}'=='True'	check all cell status	${cells}		${connection}

Check cell status LTE
	[Documentation]	Check all cell status
	[Arguments]		${connection}=${connection}
	${cells}		COAM.get_cells_info		cell_type=lte		timeout=60		connection=${connection}	detailed_output=False
	${count}		Get length				${cells}
	${status}		Run keyword and return status				Should be True	${count}>0
	Run Keyword If	'${status}'=='True'	check all cell status	${cells}		${connection}

Check cell status WCDMA
	[Documentation]	Check all cell status
	[Arguments]		${connection}=${connection}
	${cells}		COAM.get_cells_info		cell_type=wcdma		timeout=60		connection=${connection}	detailed_output=False
	${count}		Get length				${cells}
	${status}		Run keyword and return status				Should be True	${count}>0
	Run Keyword If	'${status}'=='True'	check all cell status	${cells}		${connection}

Check cell status GSM
	[Documentation]	Check all cell status
	[Arguments]		${connection}=${connection}
	${cells}		COAM.get_cells_info		cell_type=gsm		timeout=60		connection=${connection}	detailed_output=False
	${count}		Get length				${cells}
	${status}		Run keyword and return status				Should be True	${count}>0
	Run Keyword If	'${status}'=='True'	check all cell status	${cells}		${connection}

check all cell status
	[Arguments]		${cells}	${connection}=${connection}
	FOR	${cell_dist}	IN	@{cells}
		Check cell details	${cell_dist['id']['internal']}		connection=${connection}
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
	${status}					Run keyword and return status		LOG					${cell_status['technology']}
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

Snapshot download from BTS
	[Documentation]		Collect BTS snaphot for packets verification
	Print statement in console		Downloading Snapshot from BTS
	${check}			Run Keyword And Return Status	COAM.collect_snapshot	target_file_name=${log_path}/Snapshot.zip
	...					coverage=Full	force=True		timeout=2000s			connection=${connection}
	Run Keyword If		${check} == False	Log	Snapshot download failed !!!	WARN

Rollback build
	[Documentation]		Rollback build
	${current_sw}		Check current software
	Run keyword if		"${current_sw}" != "${Build}"	Rollback Passive build
	...		ELSE		Print statement in console		Software is already active in BTS ${BTS_IP}

Verify Passive build
	[Documentation]		Verify Passive build
	${Second_build}		Get Current Parameter Value			MRBTS-${BTS_ID}/MNL-1/MNL_R-1		passiveSWReleaseVersion
	Print statement in console		Passive software in BTS ${BTS_IP} is ${Second_build}
	@{sw_list}			String.Split String					${Second_build}	_
	${status}			Run Keyword And Return Status		Should contain	${Second_build}	ENB_999
	${Passive_build}	Run Keyword If	'${status}'=='True'	Replace String	${Second_build}	${sw_list[0]}	SBTS00
	...					ELSE			Set variable		${Second_build}
	[Return]			${Passive_build}

Rollback Passive build
	[Documentation]		Rollback Passive build
	${Passive_build}	Verify Passive build
	Run keyword if		"${Passive_build}" == "${Build}"	Rollback BTS software to passive
	...		ELSE		Print statement in console			Required build is not availble in active or passive partition of BTS ${BTS_IP}
	Run keyword if		"${Passive_build}" != "${Build}"	Fail

Rollback BTS software to passive
	[Documentation]				Rollback build
	Run Keyword If				"${BTS_IP}"=="192.168.255.129"		Start BTS logs
	Print statement in console	SW Rollback started
	COAM.Rollback_software		timeout=600	connection=${connection}
	Verify BTS reset
	Wait for BTS to be reachable
	COAM.reset_admin			timeout=60	connection=${connection}
	Print statement in console				Waiting for BTS status to be OnAir
	Wait Until Keyword Succeeds	1200		30	Check for BTS status
	Run keyword if		"${Check_cell_status}"=="True"		Check cell status
	Run keyword And Continue On Failure		Stop BTS logs and check
	Verify build after rollback

Verify build after rollback
	[Documentation]	Verify build
	${current_sw}	Check current software
	Run keyword if	"${current_sw}" != "${Build}"	Print statement in console	Rollback failed
	...		ELSE	Print statement in console		Rollback successfull
	Run keyword if	"${current_sw}" != "${Build}"	Fail

Get the software build
	${sw_version}		COAM.get_sw_version		connection=${connection}
	Set Suite Metadata	Software version		${sw_version}
	Set Suite variable	${sw_version}
	${Active_build}		Check current software
	Set Suite variable	${Active_build}

Verify upgrade path
	[Documentation]	Verify upgrade path
	[Arguments]		${dist_name}=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
	Run keyword and ignore error	Parameter value change		${dist_name}	actValidationOnUpgrade	false

Parameter value change
	[Documentation]		Change parameter value in SCF and commision it
	[Arguments]			${dist_name}	${parameter}	${value}
	Print statement in console		Changing BTS parameter ${parameter} to ${value} [Dist: ${dist_name}]
	${current_value}	Get Current Parameter Value		${dist_name}	${parameter}
	LOG					${current_value}
	Run Keyword If		'${current_value.upper()}'!='${value.upper()}'	COAM.Perform Parameter Recommissioning	dist_name=${dist_name}
	...					parameter=${parameter}		operation=update	value=${value}		skip_parameter_relation_errors=True
	...					connection=${connection}	timeout=180
	...		ELSE		Print statement in console	Current ${parameter} value is already set to ${value}, No need to peform commissioning
	${current_value}	Get Current Parameter Value	${dist_name}		${parameter}
	LOG					${current_value}
	Should Be Equal As Strings	${current_value.upper()}	${value.upper()}
	Print statement in console	Changing BTS parameter successful

Get Current Parameter Value
	[Arguments]			${dist_name}	${param_name}
	[Documentation]		Get current parameter value
	${temp_scf_file}	COAM.Get Current Scf File	local_dir_path=/tmp			file_name=temp_scf.xml	export_type=configurationAndRuntimeObjects
	...												connection=${connection}	timeout=60s
	scf.Load Scf		${temp_scf_file}
	${param_value}		scf.get_value_from_scf		dist_name=${dist_name}		p_name=${param_name}
	[Return]			${param_value}

Verify BTS reset
	Wait Until Keyword Succeeds		600	10	Check Ping stop for BTS
	Print statement in console		BTS is not reachable

Wait for BTS to be reachable
	Wait Until Keyword Succeeds		600	10	Check Ping start for BTS
	Print statement in console		BTS is reachable
	sleep	60

Check Ping stop for BTS
	${output}			Run			ping -c 1 ${BTS_IP}
	Should not contain	${output}	1 received

Check Ping start for BTS
	${output}		Run			ping -c 1 ${BTS_IP}
	Should contain	${output}	1 received

Print statement in console
	[Arguments]	${Statement}
	${date}		Get Current Date			result_format=%H:%M:%S
	${date}		Convert to String			${date}
	Log			\n[${date}] ${Statement}	console=True

Backup SCF
	[Documentation]				Back the SCF before execution
	[Arguments]					${File_name}
	Print statement in console	Backing up current SCF to file ${log_path}/SCF/${File_name}.xml
	${Pre_execution_scf_file}	COAM.Get Current Scf File		local_dir_path=${log_path}/SCF	file_name=${File_name}.xml
	...							timeout=60						connection=${connection}
	Set Suite variable			${Pre_execution_scf_file}