*** Settings ***
Documentation
...               Feature ID: CB009322
...               Author: Divyanshi.gupta@nokia.com
Library           OperatingSystem
Library           Process
Library           String
Library	          ./resources/Validation.py
Resource          ../CB007814_114DCAP/resources/CB007623_keywords.robot
Resource          ../resources/Common_resource.robot
Library           ../../resources/python/ta_ultracaller/

Test setup        Run keywords	Prepare environment		AND 	Common_resource.Admin Setup
Test Teardown     Common_resource.Admin Teardown
Suite teardown		Restore environment
Force Tags        CRT    SBTS24R3   FL00    QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
${voice_call_TC}=    VONR_Server_Call
@{udpcalltype}=    UDP
@{capabilities}    Legacy_2
@{UE_alias}=  UE1
@{direction_dl}=  dl
@{direction_ul}=  ul
@{calltype}=    TCP
${cell1}	1
${cell2}	3
${msg_col}		${5}
${con_col}		${19}
${BTS_M_plane_ip}           10.63.48.81
${DCAP_host}                10.41.209.114
${Default_DCAP_duration}    20
@{at_channel}               ${5}	${6}   ${7}   ${8}	${13}	${14}	${15}	${16}
${attenuator_host}          10.53.252.118
${attenuator_port}          ${3001}
&{BTS_INFO}                 host=${BTS_M_plane_ip}	port=${port}
@{gnb_custom_filters}       condor5gSyslog     cp_5g
@{bts_custom_filter}        scf
${uepc_default_ip}          10.53.252.83
${emil_path}                C://Emil
${emil_profile}             ${emil_path}//profiles//5G
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${Scout_tl_name}	    10_2_CLOUD1236

&{CB009322_A_CB008033_successful_Intra_gNB_Intra_DU_handover_for_SA_user}
...		QC_ID_FL00=31513

*** Test Cases ***
CB009322_A_CB008033_successful_Intra_gNB_Intra_DU_handover_for_SA_user
	Log to console		\nPerforming commissioning
	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${SCF_file}			skip_parameter_relation_errors=True
	...								should_activate=True	timeout=600	    connection=${connection}
	Wait Until Keyword Succeeds	   15 times	   30	 Common_resource.Check BTS is OnAir
    Sleep		20s
    Create dcap session
    Sleep		20s
	Dcap Start Trace SA
	Sleep		20s
	${set attenuation}	Create List		5,0		6,0		7,0		8,0		13,90	14,90	15,90	16,90
	Change attenuation	${set attenuation}
	ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	Log to console    \nStarting VONR call
	ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
	Sleep		20s
	Log to console    \nStarting DL and UL data transfer
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${calltype}    direction=${direction_dl}		tputcheck=No
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${calltype}    direction=${direction_ul}
	Log to console    \nWaiting for data transfer
	${set attenuation}	Create List		13,0	14,0	15,0	16,0
	Change attenuation	${set attenuation}
	${set attenuation}	Create List		5,60	6,60	7,60	8,60
	Increase attenuation by step		${set attenuation}		${10}
	ta_ultracaller.stop_voice_call    ${UE_alias}
	Log to console    \nVoice call stopped
	${set attenuation}	Create List		5,0		6,0		7,0		8,0		13,90	14,90	15,90	16,90
	Change attenuation	${set attenuation}
	Block cells		3
	Sleep   150s
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	Log to console    \nStarting VONR call
	ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
	Sleep		20s
	${set attenuation}	Create List		5,80	6,80	7,80	8,80
	Increase attenuation by step		${set attenuation}		${20}
	ta_ultracaller.stop_voice_call    ${UE_alias}
	Log to console    \nVoice call stopped
	Unblock cells	3
	${set attenuation}	Create List		5,0		6,0		7,0		8,0
	Change attenuation	${set attenuation}
	Parameter value change    ${dist_name}/NRCELL-1		 a3MeasEnabled		none
	Parameter value change    ${dist_name}/NRCELL-1		 a5MeasEnabled		none
	Parameter value change    ${dist_name}/NRCELL-3		 a3MeasEnabled		none
	Parameter value change    ${dist_name}/NRCELL-3		 a5MeasEnabled		none
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	${set attenuation}	Create List		13,0	14,0	15,0	16,0
	Change attenuation	${set attenuation}
	Log to console    \nStarting VONR call
	ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
	Sleep		20s
	${set attenuation}	Create List		5,80	6,80	7,80	8,80
	Increase attenuation by step		${set attenuation}		${20}
	ta_ultracaller.stop_voice_call    ${UE_alias}
	Log to console    \nVoice call stopped
	Dcap Stop Trace and Get results SA
    @{check_emil}	create list		UEContextModificationRequest::HandoverPreparationInformation,physCellId 123
	...		UEContextModificationResponse::physCellId 125
	...		UEContextReleaseRequest::radio-connection-with-ue-lost
	...		InitialULRRCMessageTransfer::rrcReestablishmentRequest
	...		NGAP: PDUSessionResourceModifyRequest::fiveQI 1
    Run keyword and Continue on Failure		Verify Emil    ${check_emil}
	Log to console    \nWaiting 5 minutes for counter update
    Sleep   5m
    ${Counter}	Create List		M55177C00006=${0}	M55177C00007=${0}	M55177C00008=${1}	M55177C00009=${1}	M55177C00010=${1}
	...		M55177C00011=${10}		M55177C00012=${10}	M55125C09005=${1}	M55125C09023=${1}	M55125C09024=${1}
	Check Counter values 		${Counter}

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
	${Dict_val}				Get_counter_list_9322		${result}				${counter_name}		${cell1}
	${counter_value_list}	Get Dictionary Values	${result${Dict_val}}
	${Total_Count1}			Get value of Counter	${counter_value_list}
	${Dict_val}				Get_counter_list_9322		${result}				${counter_name}		${cell2}
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
	Set Suite variable		${SCF_file}         ${CURDIR}/resources/Configuration/${Branch}/${TEST NAME}.xml
	COAM.teardown_admin    connection=${connection}
	#Get Hostname

Restore environment
	${set attenuation}	Create List		5,0		6,0		7,0		8,0		13,0	14,0	15,0	16,0
	Change attenuation	${set attenuation}
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	Collect snapshot from BTS
	Log to console		\nPerforming commissioning
#	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${Pre_execution_scf_file}			skip_parameter_relation_errors=True
#    ...								should_activate=True	timeout=500	    connection=${connection}
	Wait Until Keyword Succeeds	   15 times	   20	 Common_resource.Check BTS is OnAir
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
	Wait Until Keyword Succeeds	   5 times	   20	 Common_resource.Check BTS is OnAir

Verify Emil
	[Arguments]    ${values}
	[Documentation]     Convert emil file and verify
	Convert Emil File To Csv
	FOR		${check}	IN	 @{values}
		${result}		Parse_Emil_Csv_File 	 path=${OUTPUT_DIR}/DCAP_Logs/Extracted/		msg=${check}
		...										msg_col=${msg_col}						con_col=${con_col}
		Run keyword And Continue On Failure		Should Be True		${result}
	END
