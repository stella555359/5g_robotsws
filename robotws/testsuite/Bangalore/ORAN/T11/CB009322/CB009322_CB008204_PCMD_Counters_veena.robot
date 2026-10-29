*** Settings ***
Documentation
...               Feature ID: CB009322
...               Author     : Veena Bhaskaran
Library           OperatingSystem
Library           Process
Library           String
Library	          ./resources/Validation.py
Resource          ../CB007814_114DCAP/resources/CB007623_keywords.robot
Resource          ../resources/Common_resource.robot
Library           ../../resources/python/ta_ultracaller/

Test setup        Run keywords	Prepare environment		AND 	CB007623_keywords.Admin Setup
Test Teardown     CB007623_keywords.Admin Teardown
Suite teardown	    Restore environment
Force Tags        CRT    SBTS24R2   FL00    QCD_MN_RAN    QCP_RAN_ST

*** Variables ***
${voice_call_TC}=    VONR_Server_Call
@{udpcalltype}=    UDP
@{capabilities}    Legacy_1
@{UE_alias}=  UE_2
@{direction_dl}=  dl
@{direction_ul}=  ul
@{calltype}=    TCP
${cell1}	1
${cell2}	3
${msg_col}		${5}
${con_col}		${19}
${BTS_M_plane_ip}           10.63.48.81
${Default_DCAP_duration}    20
@{at_channel}               ${5}	${6}   ${7}   ${8}	${13}	${14}	${15}	${16}
${attenuator_host}          10.53.252.118
${attenuator_port}          ${3001}
${BTS_ID}                   MRBTS-1236
@{gnb_custom_filters}       condor5gSyslog     cp_5g
@{bts_custom_filter}        scf
${uepc_default_ip}          10.53.252.86
${emil_path}                C://Emil
${emil_profile}             ${emil_path}//profiles//5G
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${Scout_tl_name}	    10_2_CLOUD1236
${parameter_1} =  actL1PM
${epevalue_1} =  true
${parameter_2} =  mtSINR
${epevalue_2} =  15min
${parameter_3} =  actServicePRButiL
${epevalue_3} =  true
${epevalue_4} =  false
${counter_ids} =  M8005C306,M8005C307,M8005C308,M8005C309,M8005C314
${LNCELL}		LNCEL-0
${MRBTSID}      MRBTS-1236
${LNBTSID}      LNBTS-1236

&{CB013240_Verification of LTE Cell state counters.}
...		QC_ID_FL00=QC_73123

*** Test Cases ***
CB013240_Verification of LTE Cell state counters.
    Set Suite variable   ${message_col}  ${5}
    Set Suite variable   ${content_col}  ${19}
	Log to console		\nPerforming parameter commissioning
    Param_change    ${LNBTS_dist}    ${parameter_1}    ${epevalue_1}
    Param_change    ${LNBTS_dist}/PMRNL-1    ${parameter_2}    ${epevalue_2}
    Param_change    ${LNBTS_dist}    ${parameter_3}    ${epevalue_3}
    COAM.lock    ${dist_name}/NRCELL-1    timeout=120    connection=${connection}
    COAM.lock    ${dist_name}/NRCELL-3    timeout=120    connection=${connection}
    Dcap Start Trace SA
	ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	Log to console    \nStarting DL and UL data transfer
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}		tputcheck=No
    Log to console    \nWaiting for data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
	Log to console    \nWaiting for data transfer
	Log to console    \nStarting VONR call
	ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
    sleep    400s
	${log_entry_before} =    Fetch Counter Values
    ${enabled}=   Validate Counter Values    ${log_entry_before}
    Feature Enable Counter Validation
    Counter Verification for Max_RTWP
	Param_change    ${LNBTS_dist}    ${parameter_1}    ${epevalue_4}
    ${log_entry_after} =    Fetch Counter Values
    ${disabled}=    Validate Counter Values    ${log_entry_after}
	Should Be Equal	 ${enabled}    ${disabled}
	Counter Verification for Max_RTWP
    COAM.unlock    ${dist_name}/NRCELL-1    timeout=120    connection=${connection}
    COAM.unlock    ${dist_name}/NRCELL-3    timeout=120    connection=${connection}




*** Keywords ***
Check Counter values
    [Arguments]    ${counters}
    [Documentation]     Check counter value of gnb
	FOR		${counter_val}	IN	 @{counters}
		${counter_name}		${value}	Split String	${counter_val}	=	1
		Run keyword and continue on failure		Counter check	${counter_name}		${value}
	END

Counter check
	[Arguments]    ${counter_name}		${value}
	Log to console      \nChecking gnb counter ${counter_name}
	${result}		COAM.get_pm_counters
	...		counter_ids=${counter_name}    timeout=300    connection=${connection}
	log    ${result}
	${Dict_val}				Validation.Get_counter_list_9322		${result}				${counter_name}		${cell1}
	${counter_value_list}	Get Dictionary Values	${result${Dict_val}}
	${Total_Count1}			Get value of Counter	${counter_value_list}
	${Dict_val}				 Validation.Get_counter_list_9322		${result}				${counter_name}		${cell2}
	${counter_value_list}	Run keyword and ignore error	Get Dictionary Values	${result${Dict_val}}
	${Total_Count2}			Run keyword if 		"${counter_value_list}[0]"=="PASS"		Get value of Counter	${counter_value_list}[1]
	...		ELSE			Set variable		${0}
	${status}		Evaluate		${Total_Count1}+${Total_Count2} >= ${value}
	Run keyword and continue on failure		Should be True		${status}

Prepare environment
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	${Pre_execution_scf_file}	COAM.Get Current Scf File		local_dir_path=${OUTPUT_DIR}/SCF	file_name=Pre_execution_scf.xml
	...							connection=${connection}
	Set Suite variable			${Pre_execution_scf_file}
	${Branch}		Get Branch
#	Set Suite variable		${SCF_file}         ${CURDIR}/resources/Configuration/${Branch}/${TEST NAME}.xml
	Set Suite variable      ${SCF_file}         ${CURDIR}/resources/Configuration/${Branch}/${TEST NAME}.xml
    Log to console      \nPerforming commissioning
    COAM.Perform Commissioning      bts_id=${BTS_ID}        scf_file=${SCF_file}          skip_parameter_relation_errors=True
    ...                             should_activate=True    timeout=500     connection=${connection}
    Wait Until Keyword Succeeds    15 times    20    CB007623_keywords.Check BTS is OnAir
#    ${set attenuation}  Create List     5,0     6,0     7,0     8,0     13,0    14,0    15,0    16,0
#    Change attenuation  ${set attenuation}
    COAM.teardown_admin    connection=${connection}
	#Get Hostname

Restore environment
	${set attenuation}	Create List		5,0		6,0		7,0		8,0		13,0	14,0	15,0	16,0
	Change attenuation	${set attenuation}
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	Collect snapshot from BTS
	Log to console		\nPerforming commissioning revert SCF
	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${Pre_execution_scf_file}			skip_parameter_relation_errors=True
    ...								should_activate=True	timeout=500	    connection=${connection}
	Wait Until Keyword Succeeds	   15 times	   20	 CB007623_keywords.Check BTS is OnAir
	COAM.teardown_admin    connection=${connection}

Get Branch
    ${sw_version}    COAM.get_sw_version    connection=${connection}
    ${out}    Split String From Right    ${sw_version}    _    -1
    ${Branch}    Strip String    ${out}[0]    both    SBTS
	[Return]	${Branch}

Collect snapshot from BTS
	[Documentation]		Download BTS snapshot
	Log to console		\nCollecting snapshot
	${status}			Run keyword and return status		COAM.Collect Snapshot	target_file_name=${OUTPUT_DIR}/Snapshot.zip
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
	${set_value}  at.read_attenuation  port=${${channel_num}}
	${new_val}		Run Keyword If		"${set_value}"!="${value}"		Evaluate    ${set_value} + ${Attenuator_step_val}
	...		ELSE	Set Variable		${set_value}
	Run Keyword If		"${set_value}"!="${value}"	Set Attenuator value	${channel_num}		${new_val}
	[return]		${new_val}

Get Hostname
	[Documentation]		Get hosename of test machine
	${output}			Run			hostname
	${Scout_tl_name}	String.Replace String	 string=${output}	   search_for=-	   replace_with=_
	Set Suite variable	${Scout_tl_name}

Block cells
	[Arguments]			${cell}
	Log to console		\nBlocking cell : ${cell}
	COAM.block_cell		dist_name=${Cell_dist}-${cell}		connection=${connection}

Unblock cells
	[Arguments]			${cell}
	Log to console		\nUnblocking cell : ${cell}
	COAM.unblock_cell	 dist_name=${Cell_dist}-${cell}		connection=${connection}
	Log to console		\nWaiting for cell to be onAir
	Wait Until Keyword Succeeds	   5 times	   20	 Check BTS is OnAir

Verify Emil
	[Arguments]    ${values}
	[Documentation]     Convert emil file and verify
	Convert Emil File To Csv
	FOR		${check}	IN	 @{values}
		${result}		Parse_Emil_Csv_File 	 path=${OUTPUT_DIR}/DCAP_Logs/Extracted/		msg=${check}
		...										msg_col=${msg_col}						con_col=${con_col}
		Run keyword And Continue On Failure		Should Be True		${result}
	END


Param_change
    	[Arguments]    ${distname}    ${parameter}    ${value}
		Log to console     \n Modifiying the parameters to activate or deactivate the feature
        COAM.perform_parameter_recommissioning
    	...    dist_name=${distname}
    	...    parameter=${parameter}
    	...    operation=update
    	...    value=${value}
    	...    should_activate=true
    	...    timeout=420
        ...    connection=${connection}

Fetch Counter Values
    Log to console     \n Fetching PM counters
    ${log_entry} =    COAM.get_pm_counters    counter_ids=${counter_ids}    timeout=300    connection=${connection}
    Log    ${log_entry}
    [Return]    ${log_entry}

Feature Enable Counter Validation
    ${value}=    Evaluate    (${pi_value}<-700) and (${pi_value}>-1000)
	Log to Console    \n @{counter_values_enabled_list}
    Should Be True    ${value}

Validate Counter Values
    [Arguments]    ${log_entry}
    @{counter_list}=    create List    'M8005C306'    'M8005C307'    'M8005C308'    'M8005C309'
	@{counter_values_enabled_list}=    Create List
	Set Suite Variable    @{counter_values_enabled_list}
    FOR    ${pi_id}    IN    @{counter_list}
        Log    ${pi_id}
        ${count}=    set variable
        ...     ${log_entry['BTS']['${MRBTSID}']['${LNBTSID}']['${LNCELL}']['MCC-404']['MNC-99']['LTE_Pwr_and_Qual_UL'][${pi_id}]}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log   ${pi_value}
        Set Suite Variable    ${pi_value}
        ${counter_values}=    Create Dictionary    ${pi_id}=${pi_value}
        Append To List    ${counter_values_enabled_list}    ${counter_values}
        Set Suite Variable    ${counter_values_enabled_list}
    END
	[Return]    ${counter_values_enabled_list}

Counter Verification for Max_RTWP
    Log to console    \n--Max RTWP counter validation--\n
    @{counter_list}=    create List    'M8005C314'
    ${log_entry} =    COAM.get_pm_counters    counter_ids=M8005C314
    ...    timeout=300
    ...    connection=${connection}
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable
        ...      ${log_entry['BTS']['${MRBTS_dist}']['LNBTS-${BTS_ID}']['${LNCELL}']['MCC-404']['MNC-99']['LTE_Pwr_and_Qual_UL'][${pi_id}]}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        log   ${pi_value}
	    ${value}=     evaluate   (${pi_value}<-50) and (${pi_value}>-100)
	    log    ${value}
        should be True    ${value}
        Log to console    \n--${pi_value}--\n
        ${value}=    evaluate    ${pi_value}!=0
        should be true    ${value}
    END
