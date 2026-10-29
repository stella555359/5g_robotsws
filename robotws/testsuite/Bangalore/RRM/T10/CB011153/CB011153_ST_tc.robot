*** Settings ***
Documentation
...               Feature ID: CB011153
Library           OperatingSystem
Library           Process
Library           String
Library           Collections
Library			  ta5g_pm_counters
Library           SSHLibrary
Library           DateTime
Library           taf.sw.dcap.rd   WITH NAME   rd
Library           taf.transport.ssh    WITH NAME    ssh
Library           taf.sbts.oam.coam.admin   WITH NAME    coam
Library           taf.collectors.btslog    WITH NAME    btslog
Library           taf.hw.rf_attenuator  WITH NAME  at
Library           taf.collectors.tshark    WITH NAME    tshark1
Library           taf.collectors.tcpdump    WITH NAME    tcpdump
Library           taf.collectors.core    WITH NAME    core1
Library           testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library           taf.converters.pcaptopdml    WITH NAME    pcaptopdml
Library           taf.analyzer.pdml   WITH NAME   taf_pdml_analyser
Library           taf.ul.alarms_watchdog		WITH NAME	alarm
Library           ute_reporting_portal
Library           taf.sw.scout	WITH NAME   scout

Test setup        Run keywords
...         OperatingSystem.Run     rm -rf /home/ute/robotws/btslog/* ; rm -rf /home/ute/robotws/tcpdump/*
... 		AND	 	COAM.setup_admin    bts_host=${gNB_IP}		alias=${connection}		admin_api_log_dir=/tmp
... 		AND 	Prepare environment
...			AND		Enable feature parameter GNB1
...			AND		Set counter values
...         AND     Login attenuator and set attenuation
...         AND     Get the software build

Test Teardown     Run keywords	Revert feature parameter
...			AND		alarm.stop_watching_alarms
...         AND     Run keyword if	"${Report_to_QC}" == "True"	Report to QC
...			AND		Restore environment
...			AND		COAM.teardown_admin    connection=${connection}

*** Variables ***
${Update_to_QC}				TRUE
@{capabilities}    			Legacy_1
@{UE_alias}  				UE1
@{direction_dl}  			dl
@{direction_ul}  			ul
@{calltype}	    			UDP
${gNB_IP} 		  			192.168.255.129
@{at_channel}				${1}	${2}	${3}	${4}	${5}	${6}	${7}
...							${8}	${9}	${10}	${11}	${12}	${13}	${14}
...							${15}	${16}
${attenuator_host}          10.53.164.198
${attenuator_port}          ${3001}
${at_vendor}	 			TOPYOUNG
${at_model}	 				TAS_16T16_0_2G6_90_1S_DEJS
${connection}				GNB1
&{Cells_configured}			11=205	12=491
${lcel11_M8013C10}		['BTS']['MRBTS-464']['LNBTS-464']['LNCEL-11']['MCC-001']['MNC-01']['LTE_UE_State']['M8013C10']
${lcel11_M8013C138}		['BTS']['MRBTS-464']['LNBTS-464']['LNCEL-11']['MCC-001']['MNC-01']['LTE_UE_State']['M8013C138']
${lcel11_M8013C139}		['BTS']['MRBTS-464']['LNBTS-464']['LNCEL-11']['MCC-001']['MNC-01']['LTE_UE_State']['M8013C139']
${lcel12_M8013C10}      ['BTS']['MRBTS-464']['LNBTS-464']['LNCEL-12']['MCC-001']['MNC-01']['LTE_UE_State']['M8013C10']
${lcel12_M8013C138}     ['BTS']['MRBTS-464']['LNBTS-464']['LNCEL-12']['MCC-001']['MNC-01']['LTE_UE_State']['M8013C138']
${lcel12_M8013C139}     ['BTS']['MRBTS-464']['LNBTS-464']['LNCEL-12']['MCC-001']['MNC-01']['LTE_UE_State']['M8013C139']
${lcel11_port}        		${11}
${lcel12_port}        		${7}
${lcel463_port}			${8}
${Check_cell_status}		True
${cell_status}
${BTSlog_status}			Not started
${Report_to_QC}				True
${qc_domain}				MN_RAN
#&{qc_project_val}			QC_PROJECT_FL00=RAN_VRF	QC_PROJECT_SBTS25R2=RAN_VRF	QC_PROJECT_SBTS25R3=RAN_VRF
#&{ca_val}					QC_CA_FL00=VRF_RRM		QC_CA_SBTS25R2=VRF_RRM		QC_CA_SBTS25R3=VRF_RRM
#&{CB011153_SR_B_Fast_UE_Context_release_inter_eNB_handling_of_RLF_triggered_handover}
#...							QC_ID_FL00=59419		QC_ID_SBTS25R2=140807		QC_ID_SBTS25R3=198078

*** Test Cases ***
CB011153_SR_B_Fast_UE_Context_release_intra_eNB_handling_of_RLF_triggered_handover
	[Tags]    CB011153
	Start alarm monitoring
	Initialise counters
	Start Syslog
	${set attenuation}	Create List		${lcel11_port},40	${lcel12_port},0
	Change attenuation	${set attenuation}
	sleep	20
	ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${calltype}    direction=${direction_dl}		tputcheck=No
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${calltype}    direction=${direction_ul}
    Get TcpdumpLogs from Remote machine
    Trigger HO from source to target cell1
    Run Keyword and continue on failure     Stop Syslog and verify
    Run Keyword and continue on failure     Convert pcap file       11153_fastue       s1ap		GNB1
	${M8013C10_count}     ${M8013C138_count}     ${M8013C139_count}     Check counter values


CB011153_SR_B_Fast_UE_Context_release_inter_eNB_handling_of_RLF_triggered_handover
	[Tags]    CB011153
	Start alarm monitoring
	Initialise counters
	FOR    ${index}    IN RANGE    4
	    ${set attenuation}	Create List		${lcel463_port},50	${lcel12_port},0
	    Change attenuation	${set attenuation}
	    sleep	20
	    ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
	    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	    ta_ultracaller.start_data_transfer  ${UE_alias}   ${calltype}    direction=${direction_dl}		tputcheck=No
	    ta_ultracaller.start_data_transfer  ${UE_alias}   ${calltype}    direction=${direction_ul}
        Trigger HO from source to target enb
    END
	${M8013C10_count}     ${M8013C138_count}     ${M8013C139_count}     Check counter values


*** Keywords ***
Enable feature parameter GNB1
	Print statement in console		Enable feature parameter on GNB1
	COAM.perform_parameter_recommissioning    dist_name=MRBTS-464/LNBTS-464
    ...    parameter=actFastUECRelease    value=true    operation=update
    ...    skip_parameter_relation_errors=False    connection=${connection}
	COAM.perform_parameter_recommissioning    dist_name=MRBTS-464/LNBTS-464
    ...    parameter=actRLFbasedRCR    value=true    operation=update
    ...    skip_parameter_relation_errors=False    connection=${connection}
	Print statement in console		Enable feature parameter success on GNB1

Revert feature parameter
    Print statement in console      Enable feature parameter on GNB1
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-464/LNBTS-464
    ...    parameter=actFastUECRelease    value=true    operation=update
    ...    skip_parameter_relation_errors=False    connection=${connection}
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-464/LNBTS-464
    ...    parameter=actRLFbasedRCR    value=true    operation=update
    ...    skip_parameter_relation_errors=False    connection=${connection}
    Print statement in console      Enable feature parameter success on GNB1

Verify message custom
    [Arguments]    ${pdmlFile}
    ${pdml_entries_sst}    OperatingSystem.RUN    cat ${pdmlFile} | grep -i xnap.sst
    ${pdml_entries_sd}     OperatingSystem.RUN    cat ${pdmlFile} | grep -i xnap.sd
    ${pdml_entries_xn}     OperatingSystem.RUN    cat ${pdmlFile} | grep -i xnap.HandoverRequestAcknowledge_element
    Run keyword and Continue on Failure		Should contain			${pdml_entries_sst}     sst: 01
    Run keyword and Continue on Failure		Should contain			${pdml_entries_sd}      sd: d143a5
    Run keyword and Continue on Failure		Should Not be Empty		${pdml_entries_xn}


Verify pcap messages
    Run keyword and Continue on Failure         Verify message custom    ${OUTPUT_DIR}/tcpdump/xnho_stt_1.pdml
    Run keyword and Continue on Failure         Verify message custom    ${OUTPUT_DIR}/tcpdump/xnho_tts_1.pdml
    Run keyword and Continue on Failure         Verify message custom    ${OUTPUT_DIR}/tcpdump/xnho_stt_2.pdml

Prepare environment
	${Pre_execution_scf_file}	COAM.Get Current Scf File		local_dir_path=${OUTPUT_DIR}/SCF	file_name=GNB1_Pre_execution_scf.xml
	...							connection=${connection}	timeout=30
	Set Suite variable			${Pre_execution_scf_file}
	${Branch}		Get Branch
	Set Suite variable		${SCF_file}         ${CURDIR}/resources/Configuration/${Branch}/${TEST NAME}.xml
#    Restart the GNB     ${connection}
	Get Hostname
#	Wait Until Keyword Succeeds	   900	   20	 Check BTS is OnAir		${connection}
#	Run keyword if		"${Check_cell_status}"=="True"		Check cell status		connection=${connection}

Restore environment
	${set attenuation}	Create List		${1105_port},90	${1110_port},0
	Change attenuation	${set attenuation}
	Run keyword if		"${TEST STATUS}" != "PASS"	Collect snapshot	${connection}
	Wait Until Keyword Succeeds	   60	   20	 Check BTS is OnAir		${connection}
	Run keyword if		"${Check_cell_status}"=="True"		Check cell status		connection=${connection}

Collect snapshot
	[Arguments]		${connection}
	Collect snapshot from BTS	Snapshot_name=GNB1_Snapshot		connection=${connection}

Get Branch
    ${sw_version}    COAM.get_sw_version    connection=${connection}
    ${out}    Split String From Right    ${sw_version}    _    -1
    ${Branch}    Strip String    ${out}[0]    both    SBTS
	[Return]	${Branch}

Collect snapshot from BTS
	[Documentation]		Download BTS snapshot
	[Arguments]    		${Snapshot_name}=Snapshot.zip		${connection}=${connection}
	Print statement in console		Collecting snapshot for ${connection}
	${status}			Run keyword and return status		COAM.Collect Snapshot	target_file_name=${OUTPUT_DIR}/${Snapshot_name}.zip
	...																				coverage=Full
	...																				force=True
	...																				timeout=1000
	...																				connection=${connection}
	Run Keyword If		'${status}'=='False'				Log   					Snapshot collection failed !!!			ERROR

Increase attenuation by step
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	${length} 		Get Length		${port_val_list}
	FOR    ${i}    IN RANGE    10
		${status}		Attenuation loop		${port_val_list}	${Attenuator_step_val}
		Exit For Loop If 	"${status}"=="${length}"
	END

Attenuation loop
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	${loop_status}		Set Variable		${0}
	FOR    ${val}    IN    @{port_val_list}
		${channel_num}		${value}	Split String	${val}	,	1
		${status}			Change value of Attenuator		${channel_num}		${value}	${Attenuator_step_val}
		${loop_status}		Run Keyword If		"${status}"=="${value}"		Evaluate		${loop_status}+${1}
		...		ELSE		Set Variable		${loop_status}
	END
	[return]	${loop_status}

Change value of Attenuator
	[Arguments]		${channel_num}		${value}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	Print statement in console      Changing attenuator port ${channel_num} to ${value}db
	${set_value}  at.read_attenuation  port=${${channel_num}}
	${new_val}		Run Keyword If		"${set_value}"!="${value}"		Evaluate    ${set_value} + ${Attenuator_step_val}
	...		ELSE	Set Variable		${set_value}
	Run Keyword If		"${set_value}"!="${value}"	Set Attenuator value	${channel_num}		${new_val}
	[return]		${new_val}

Block cells
	[Arguments]			${cell}
	Print statement in console		Blocking cell : ${cell}
	COAM.block_cell		dist_name=${Cell_dist}-${cell}		connection=${connection}

Unblock cells
	[Arguments]			${cell}
	Print statement in console		Unblocking cell : ${cell}
	COAM.unblock_cell	 dist_name=${Cell_dist}-${cell}		connection=${connection}
	Print statement in console		Waiting for cell to be onAir
	Wait Until Keyword Succeeds	   120	   20	 Check BTS is OnAir

Verify Emil
	[Arguments]    ${values}
	[Documentation]     Convert emil file and verify
	Convert Emil File To Csv
	FOR		${check}	IN	 @{values}
		${result}		Parse_Emil_Csv_File 	 path=${OUTPUT_DIR}/DCAP_Logs/Extracted/		msg=${check}
		...										msg_col=${msg_col}						con_col=${con_col}
		Run keyword And Continue On Failure		Should Be True		${result}
	END

Configure attenuator
    Setup Attenuator
    Read Ports attenuation

Setup Attenuator
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}

Read Ports attenuation
    ${port_values}    at.read_ports_attenuation  ${ports}

XnHO from source to target cell
    Print statement in console    -- Degrade source cell signal --
    @{values}    Set Variable    30dB    30dB    30dB    30dB
    Attenuate source cell     ${values}
    Print statement in console    -- Enhance target cell signal --
    @{values}    Set Variable    0dB     0dB
    Attenuate target cell     ${values}
    Sleep    20s

Attenuate source cell
    [Arguments]    ${values}
    at.set_ports_attenuation  ${source_ports}  ${values}  confirm=True  confirmation_delay=5

Attenuate target cell
    [Arguments]    ${values}
    at.set_ports_attenuation  ${target_ports}  ${values}  confirm=True  confirmation_delay=5

XnHO from target to source cell
    Print statement in console    -- Degrade target cell signal --
    @{values}    Set Variable    55dB     55dB
    Attenuate target cell     ${values}
    Print statement in console    -- Enhance source cell signal --
    @{values}    Set Variable    0dB    0dB    00dB    00dB
    Attenuate source cell     ${values}
    Sleep    20s

Trigger HO from source to target cell1
    ${set attenuation}  Create List     11,30       7,10
	Change attenuation	${set attenuation}
    Sleep       2s
    ${set attenuation}  Create List     11,20       7,20
    Change attenuation  ${set attenuation}
    Sleep       20s
    ${set attenuation}  Create List     11,10       7,30
    Change attenuation  ${set attenuation}
    Sleep       20s
    ${set attenuation}  Create List     11,0       7,40
    Change attenuation  ${set attenuation}
    Sleep       20s

Trigger HO from source to target enb
    ${set attenuation}  Create List     8,30       7,10
    Change attenuation	${set attenuation}
    Sleep       2s
    ${set attenuation}  Create List     8,20       7,20
    Change attenuation  ${set attenuation}
    Sleep       10s
    ${set attenuation}  Create List     8,10       7,30
    Change attenuation  ${set attenuation}
    Sleep       20s
    ${set attenuation}  Create List     8,0        7,40
    Change attenuation  ${set attenuation}
    Sleep       20s
    ${set attenuation}  Create List     8,0        7,43
    Change attenuation  ${set attenuation}
    Sleep       10s
    ${set attenuation}  Create List     8,0        7,46
    Change attenuation  ${set attenuation}
    Sleep       10s
    ${set attenuation}  Create List     8,0        7,49
    Change attenuation  ${set attenuation}
    Sleep       10s
    ${set attenuation}  Create List     8,0        7,50
    Change attenuation  ${set attenuation}
    Sleep       10s
XnHO from target to source cell1
	${set attenuation target}	Create List		${1105_port},0
	Change attenuation	${set attenuation target}
	@{db change}	Create List	  10	20	 30	 40     50	60	70	80
	FOR	${i}	IN	@{db change}
	${set attenuation}	Create List		${1110_port},${${i}}
	Change attenuation	${set attenuation}
	END

Setup Attenuator Teardown
    @{values}    Set Variable    0dB    0dB    0dB    0dB
    Attenuate source cell     ${values}
    @{values}    Set Variable    70dB     70dB
    Attenuate target cell     ${values}

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    [Arguments]  ${connection}=${connection}
    ${bts_status}=  coam.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Print statement in console    BTS procedural state is now: ${bts_status["proceduralState"]} on ${connection}
    ...    ELSE    fail

Check cell status
	[Arguments]		${duration}=300				${connection}=${connection}
	Print statement in console					Waiting upto ${duration}s for all cells to be operational
	${status}	Run keyword and return status	Wait Until Keyword Succeeds		${duration}	10	Check cell status LTE	${connection}
	Run Keyword If	'${status}'=='False'		Run keywords					Set test variable			${cell_status}	Failed
	...		AND		Print statement in console	LTE cells verification failed

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

Change attenuation
    [Arguments]     ${port_val_list}
    [Documentation]     Set the attenuation of specified port
	Print statement in console      Changing attenuator values : ${port_val_list}
    FOR    ${val}    IN    @{port_val_list}
        ${channel_num}      ${value}    Split String    ${val}  ,   1
        Set Attenuator value    ${channel_num}      ${value}
    END

Login attenuator and set attenuation
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}    attenuation_port_numbers=@{at_channel}
     ...  vendor=${at_vendor}  model=${at_model}
    ${set attenuation}      Create List     1,90    2,90    3,0     4,90    5,90    6,90    7,90    8,90    9,90    10,90
    ...                                     11,90   12,90
	Change attenuation	${set attenuation}

Set Attenuator value
    [Arguments]     ${channel_num}      ${value}
    [Documentation]     Set the attenuation of specified port
    ${channel_num}      Convert To Integer      ${channel_num}
    ${value}        Convert To Integer      ${value}
    ${set_value}  at.read_attenuation  port=${${channel_num}}
    at.set_attenuation  port=${channel_num}     value=${value}      confirm=${True}
    sleep   2s      reason=Wait for change in state
    ${set_value}  at.read_attenuation  port=${${channel_num}}
    Should Be Equal As Strings  ${set_value}  ${value}

Start Tshark capture
	tshark1.create_tshark_collector
     ...    name=tshark1
     ...    options=-i eth0
     ...    sudo_password=ute
     core1.setup_collectors    names=tshark1
     core1.start_collectors    names=tshark1

Stop tshark capture
     core1.stop_collectors    names=tshark1
     core1.collect_collectors    names=tshark1
     core1.teardown_collectors    names=tshark1

Set counter values
	[Documentation]			Set counter expected values
	&{Counters_val}			Create Dictionary	M8013C10=${3}   M8013C138=${2}		M8013C139=${2}
	@{Counters_list}			Create list	    M8013C10    M8013C138   M8013C139
	Set Suite variable		&{Counters_val}
	Set Suite variable		@{Counters_list}


Initialise counters
	${value}			Get Dictionary Keys		${Cells_configured}
	FOR		${cell}	IN	 @{value}
		Set counter as zero		${cell}		@{Counters_list}
	END

Set counter as zero
	[Documentation]	Set counetrs to zero
	[Arguments]		${cell}		@{Counters}
	FOR		${value}	IN	 @{Counters}
		Set test Variable	 ${${value}_${cell}_${0}}	 ${0}
	END

Check counters
	[Documentation]		Check counters
	[Arguments]	   		${counter}=${Counters_list}		${cell}=1
	ta5g_pm_counters.wait_for_next_full_pm_interval
	FOR		${check}	IN	 @{counter}
		${value}	Run keyword and continue on failure		Counter value	${check}	${cell}
		Run keyword and continue on failure		Set test Variable	${${check}_count}	 ${value}
        ${expected_count}    Get From Dictionary     ${Counters_val}     ${check}
        Run keyword and continue on failure     Should be true      ${${check}_count} != 0
	END

Get counters from gnb1
#	ta5g_pm_counters.wait_for_next_full_pm_interval
	Print statement in console	Sleeping 5 minutes for counter update
    Sleep   5m
	Print statement in console	Checking counter on GNB1
	${counter1}     Run keyword and continue on failure		Counter value	M8013C10 	1		${lcel11_M8013C10}
	${counter2}     Run keyword and continue on failure		Counter value	M8013C138	1		${lcel11_M8013C138}
	${counter3}     Run keyword and continue on failure		Counter value	M8013C139	1		${lcel11_M8013C139}
    [Return]        ${counter1}     ${counter2}     ${counter3}

Check counter values
    [Arguments]     ${expected_M8013C10}=0    ${expected_M8013C138}=0    ${expected_M8013C139}=0
	Print statement in console	Checking counter on GNB1
    ${curr13c10}     ${curr13c138}     ${curr13c139}     Get counters from gnb1
    Run keyword and continue on failure     Should be True  ${curr13c10} > ${expected_M8013C10}
    Run keyword and continue on failure     Should be True  ${curr13c138} > ${expected_M8013C138}
    Run keyword and continue on failure     Should be True  ${curr13c139} > ${expected_M8013C139}
    [Return]        ${curr13c10}     ${curr13c138}     ${curr13c139}


Check counter for xnho target to source
    [Arguments]     ${expected_3540}=0    ${expected_3008}=0    ${expected_3007}=0
	Print statement in console	Checking counter on GNB1
    ${curr3540}     ${curr3008}     ${curr3007}     ${currC00001}   ${currC00004}   ${currC00005}   ${currC00006}   Get counters from gnb1
    Run keyword and continue on failure     Should be True  ${curr3540} >= ${expected_3540}
    Run keyword and continue on failure     Should be True  ${curr3008} >= ${expected_3008}
    Run keyword and continue on failure     Should be True  ${curr3007} >= ${expected_3007}
    Run keyword and continue on failure     Should be True  ${currC00001} >= 1
    Run keyword and continue on failure     Should be True  ${currC00004} >= 1
    Run keyword and continue on failure     Should be True  ${currC00005} >= 1
    Run keyword and continue on failure     Should be True  ${currC00006} >= 1
    [Return]        ${curr3540}     ${curr3008}     ${curr3007}


Check counter for gnb1 source to target
    [Arguments]     ${expected_3540}=0    ${expected_3008}=0    ${expected_3007}=0
	Print statement in console	Checking counter on GNB1
    ${curr3540}     ${curr3008}     ${curr3007}     ${currC00001}   ${currC00004}   ${currC00005}   ${currC00006}   Get counters from gnb1
    Run keyword and continue on failure     Should be True  ${curr3540} > ${expected_3540}
    Run keyword and continue on failure     Should be True  ${curr3008} > ${expected_3008}
    Run keyword and continue on failure     Should be True  ${curr3007} >= ${expected_3007}
    Run keyword and continue on failure     Should be True  ${currC00001} >= 1
    Run keyword and continue on failure     Should be True  ${currC00004} >= 1
    Run keyword and continue on failure     Should be True  ${currC00005} >= 2
    Run keyword and continue on failure     Should be True  ${currC00006} >= 2
    [Return]        ${curr3540}     ${curr3008}     ${curr3007}

Check counters from gnb2
    [Arguments]     ${expected_3540}=0
	Print statement in console	Checking counter on GNB2
	${counter1}     Run keyword and continue on failure		Counter value	M55138C03540	1		${dict2_M55138C03540}		${connection_2}
	${counter2}     Run keyword and continue on failure		Counter value	M55163C03007	1		${dict2_M55163C03007}		${connection_2}
	${counter3}     Run keyword and continue on failure		Counter value	M55163C03008	1		${dict2_M55163C03008}		${connection_2}
    ${counter4}     Run keyword and continue on failure     Counter value   M55143C00001    1       ${dict2_M55143C00001}		${connection_2}
    ${counter5}     Run keyword and continue on failure     Counter value   M55143C00004    1       ${dict2_M55143C00004}		${connection_2}
    ${counter6}     Run keyword and continue on failure     Counter value   M55143C00005    1       ${dict2_M55143C00005}		${connection_2}
    ${counter7}     Run keyword and continue on failure     Counter value   M55143C00006    1       ${dict2_M55143C00006}		${connection_2}
	Run keyword and continue on failure		Should be True  ${counter1} >= ${expected_3540}
    Run keyword and continue on failure		Should be True  ${counter2} > 0
    Run keyword and continue on failure		Should be True  ${counter3} >= 0
    Run keyword and continue on failure		Should be True  ${counter4} > 1
    Run keyword and continue on failure		Should be True  ${counter5} > 1
    Run keyword and continue on failure		Should be True  ${counter6} >= 1
    Run keyword and continue on failure		Should be True  ${counter7} >= 1
    [Return]        ${counter1}

Counter value
	[Documentation]			Check counter value of BTS
	[Arguments]				${counter_name}			${cell}			${Dict_val}			${connect}=${connection}
	Print statement in console			Checking BTS counter ${counter_name}
	${result}				COAM.get_pm_counters	counter_ids=${counter_name}	timeout=1000	connection=${connect}
	Log						${result}
	Log						${cell}
	${counter_value_list}	Get Dictionary Values	${result${Dict_val}}
#	${Total_Count}		Evaluate    ${counter_value_list}[-1]+${counter_value_list}[-2]+${counter_value_list}[-3]
	${Total_Count}			Get value of Counter	${counter_value_list}
	[Return]				${Total_Count}

Get value of Counter
	[Documentation]		Get total value from list
	[Arguments]			${Counter_value}
	Set test Variable	${i}	${0}
	FOR	   ${value}	   IN	 @{Counter_value}
		${i}	Evaluate	${i} + ${value}
	END
	[Return]	${i}

Get TcpdumpLogs from Remote machine
    [Documentation]    this keyword is used to capture wireshark log in wireshark PC
	[Arguments]
    Print statement in console    --Starting Wireshark Logs--
	Run keyword and Ignore error	COAM.stop_ip_capture_file	timeout=120		connection=${connection}	detailed_output=False
	COAM.start_ip_capture_file		measurement_point=NE_Terminated		uplane_capturing=TRUE	password=		timeout=120
	...		connection=${connection}	detailed_output=False

Convert pcap file
    [Documentation]  this keyword will stop wireshark log collection and convert pcap file to .txt format.
    [Arguments]     ${filename}     ${filter}		${GNB}
    Print statement in console    --Stoping Wireshark Logs--
	Run Keyword and Ignore error    COAM.stop_ip_capture_file	timeout=120		connection=${connection}	detailed_output=False
	Run Keyword and Ignore error    COAM.generate_ip_capture_file	password=	timeout=120	 connection=${connection}	detailed_output=False
	COAM.download_ip_capture_file	target_file_name=${OUTPUT_DIR}/tcpdump/${filename}_GNB1.pcap	 timeout=120	connection=${connection}
	...		detailed_output=False
    ${command}    set variable
	...		tshark -r ${OUTPUT_DIR}/tcpdump/${filename}_${GNB}.pcap -Y "${filter}" -T pdml > ${OUTPUT_DIR}/tcpdump/${filename}.pdml
	Operatingsystem.RUN		${command}
    ${filepath}    set variable    ${OUTPUT_DIR}/tcpdump/${filename}.pdml
    ${file}=    OperatingSystem.Get file    ${filepath}
    [Return]    ${file}

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

Fetch filtered PDML file from pcap
    [Arguments]                     ${pcapFile}
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    pcaptopdml.create_pcap_to_pdml_converter
    ...      name=converter
    ...      file_path_pattern=${pcapFile}
    ${pdmlFile}    pcaptopdml.convert    converter
    [Return]    ${pdmlFile}

Start alarm monitoring
	[Documentation]		Start monitoring alarm in BTS
	${Active_alarm}		COAM.get_active_alarms	  			connection=${connection}
	LOG					${Active_alarm}
	${allowed_alarms}	Expected alarm
	alarm.Watch alarms	allowed_alarms=${allowed_alarms}	connection_kwargs=${connection}	   log_dir=${OUTPUT_DIR}

Expected alarm
	[Documentation]			Alarms which are ignored on runtime
	${allowed_alarm_1}		Create alarm	alarm_id=7220		fault_id=61524		fault_name=SSH enabled
	${allowed_alarm_2}		Create alarm	alarm_id=7220	  	fault_id=4654		fault_name=Ethernet port security is disabled
	${allowed_alarm_3}		Create alarm	alarm_id=7220	  	fault_id=61649		fault_name=LMP access via port 443
	${allowed_alarm_4}		Create alarm	alarm_id=7220	  	fault_id=4655		fault_name=Service account root access is enabled
	${allowed_alarm_5}		Create alarm	alarm_id=7220	  	fault_id=61652		fault_name=R&D Service Port enabled
	${allowed_alarm_6}		Create alarm						fault_id=4592		fault_name=BTS Reset Cause
	${allowed_alarm_7}		Create alarm					  	fault_id=49			fault_name=Cell blocked
	${allowed_alarm_8}		Create alarm	alarm_id=7652	  	fault_id=4458		fault_name=SSH Login Configuration failed
	${allowed_alarm_9}		Create alarm					  	fault_id=6261
	...						fault_name=Failure in internal BTS connection or connection to 3rd party tool
	${allowed_alarm_10}		Create alarm					  	fault_id=6278		fault_name=MFBI cell configuration conflict
	${allowed_alarm_11}		Create alarm					  	fault_id=6327		fault_name=Setup of X2 connectivity to gNB failed
	${allowed_alarm_12}		Create alarm						fault_id=6203		#fault_name=Transport layer connection failure in X2 interface
    ${allowed_alarm_13}     Create alarm                        fault_id=4297
    ${allowed_alarm_14}     Create alarm                        fault_id=7319
    ${allowed_alarm_15}     Create alarm                        fault_id=7300
    ${allowed_alarm_16}     Create alarm                        fault_id=61641
	${allowed_alarms}		Create list		${allowed_alarm_1}	${allowed_alarm_2}	${allowed_alarm_3}	${allowed_alarm_4}
	...										${allowed_alarm_5}	${allowed_alarm_6}	${allowed_alarm_7}	${allowed_alarm_8}
	...										${allowed_alarm_9}	${allowed_alarm_10}	${allowed_alarm_11}	${allowed_alarm_12}
	...										${allowed_alarm_13}	${allowed_alarm_14}	${allowed_alarm_15}	${allowed_alarm_16}
	[Return]				${allowed_alarms}

Check alarm
	[Documentation]		Check BTS alarm
	${Active_alarm}		COAM.get_active_alarms	  connection=${connection}
	LOG					${Active_alarm}
	${status}			Run keyword and return status		alarm.check_detected_alarms
	Run Keyword If		'${status}'!='True'					Log		Unexpected alarm is detected !!!		ERROR

Start BTS logs
	[Documentation]					Starts BTS log in testpc
	Print statement in console		Starting BTS log
	Run								killall btslog
	btslog.create_btslog_collector	name=btslog
	core1.setup_collectors			names=btslog
	core1.set_suite_alias			btslog
	core1.start_collectors			names=btslog

Stop BTS logs and check
	[Documentation]		Stops BTS log and check for crash
	${status}			Run keyword and return status		Stop BTS log
	Run Keyword If		'${status}'=='True'					Verify BTS log
	...		ELSE		Log   Syslog collection failed!!!	ERROR

Stop BTS log
	[Documentation]				Stops BTS log
	Print statement in console	Collecting BTS log
	core1.stop_collectors		names=btslog
	core1.collect_collectors		names=btslog	target_dir=${OUTPUT_DIR}
	core1.teardown_collectors	names=btslog

Verify BTS log
	[Documentation]		Verify BTS log
#	${check}			Check_bts_logs			${OUTPUT_DIR}/btslog/
    Run Keyword If		'${check}'!='True'		Run keywords	Log   Unexpected prints found in syslog !!!    ERROR
	...													AND		FAIL

Start Syslog
    [Documentation]    ... Starting Syslogs
    Run                             killall btslog
	Print statement in console    ---- Starting Syslog ----
    btslog.create_btslog_collector
    ...   name=btslog
    ${status} 	Run Keyword And Return Status 		core1.setup_collectors    names=btslog
	Run Keyword If 		'${status}'=='False'		Print statement in console	ERROR IN BTSLOG COLLECTION !!!
    ${status} 	Run Keyword And Return Status 		core1.start_collectors    names=btslog
	Run Keyword If 		'${status}'=='False'		Print statement in console	ERROR IN BTSLOG COLLECTION !!!
    core1.set_suite_alias    btslog
	Run Keyword If 		'${status}'!='False'		Set test variable			${BTSlog_status}	Started

Stop Syslog
    sleep    20s
    core1.stop_collectors      names=btslog
    core1.collect_collectors      names=btslog          target_dir=${OUTPUT_DIR}
    BuiltIn.Log     ${OUTPUT_DIR}
    core1.teardown_collectors      names=btslog
    Print statement in console    ---- Stopped Syslog ----

Stop Syslog and verify
    Run Keyword If		'${BTSlog_status}'=='Started'		Stop Syslog
    ${log_file}     OperatingSystem.Run         tar -xvf ${OUTPUT_DIR}/btslog/syslog_files.tgz -C ${OUTPUT_DIR}/btslog/
    Sleep   10s
    ${string_check}		OperatingSystem.Run		cat ${OUTPUT_DIR}/btslog/SYSLOG_* | grep -i isUeContextFoundAndAutheticationDoneAndActFastUECRelease
    ${string_check1}        OperatingSystem.Run     cat ${OUTPUT_DIR}/btslog/SYSLOG_* | grep -i FastReleaseUe
    ${file_content}     OperatingSystem.Run         cat ${OUTPUT_DIR}/btslog/SYSLOG_*
    Run keyword and Ignore Error    Should contain        ${string_check1}        isFastReleaseUe returns:true
    Run keyword and Ignore Error     Should contain        ${string_check}        isUeContextFoundAndAutheticationDoneAndActFastUECRelease to true
    Run keyword and Ignore Error    Should contain        ${file_content}     ERlsCause_OutSync
    Run keyword and Ignore Error    Should contain        ${file_content}    RRC_CONNECTION_RECONFIGURATION_COMPLETE
    Run keyword and Ignore Error    Should contain        ${file_content}    S1AP_UE_CONTEXT_RELEASE_COMPLETE


Restart the GNB
    [Arguments]     ${connect}
    [Documentation]     Restart gnb
    Print statement in console      Rebooting gNB and waiting for reconnection on ${connect}
    COAM.reset      reset_coverage=Site     wait_for_reconnection=True      timeout=300     connection=${connect}
    COAM.reset_admin     connection=${connect}

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
	Print statement in console		Updating result to QC as ${TEST STATUS}
	${Res}		Run keyword if	"${TEST STATUS}" == "PASS"		Set variable	passed
	...			ELSE			Set variable	 failed
	${Link}		Report To Rp	name=${TEST NAME}		result=${Res}	ca=${ca}
	...																	testline=${Hostname}	build=${Active_build}	qc_domain=${qc_domain}
	...																	qc_project=${qc_project}		qc_id=${QC_ID}			label=
	...																	tool=WebEM				kpi_results=			links=
	...																			tc_execution_id=${external_scf_id}
	Print statement in console		Reportal portal link : \n${Link}

Get Hostname
	[Documentation]		Get hosename of test machine
	${output}			Run			hostname
	${Hostname}			String.Replace String	 string=${output}	   search_for=-	   replace_with=_
	Set Suite variable	${Hostname}

Set QC Id
	[Documentation]		Get QC ID of testcase
	@{sw_list}			String.Split String		${Active_build}	 _
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
    ${current_trunk_sw}     Run Keyword If      '${status}'=='True'     Replace String      ${Build}        ${sw_list[0]}     SBTS00
    ...                 ELSE                Set variable    ${Build}
    [Return]            ${current_trunk_sw}

Print statement in console
	[Arguments]		${Statement}
	${date}			Get Current Date	result_format=%H:%M:%S
	${date}			Convert to String	${date}
	Log         	\n[${date}] ${Statement}    console=True

