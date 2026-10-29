*** Settings ***
Documentation
...               Author: vaishnavi.v@nokia.com
...               Feature ID: CB009322
Library           OperatingSystem
Library           Process
Library           String
Library	          ./resources/Validation.py
Resource          ../CB007814_114DCAP/resources/CB007623_keywords.robot
Resource          ../resources/Common_resource.robot
Library           ../../resources/python/ta_ultracaller/

Test setup        Run keywords	Prepare environment		AND 	Common_resource.Admin Setup
Test Teardown     Run keywords	Unblock cells	${cell1}	AND		Common_resource.Admin Teardown
Suite teardown		Restore environment
Force Tags        CRT    SBTS24R3   FL00    QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
${voice_call_TC}=    VONR_Server_Call_automation
@{udpcalltype}=    UDP
@{capabilities}    Legacy_2
@{UE_alias}=  UE_1
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
${uepc_default_ip}          10.53.252.86
${emil_path}                C://Emil
${emil_profile}             ${emil_path}//profiles//5G
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${Scout_tl_name}	    10_2_CLOUD1236
@{Lte_custom_filters}		cp_4g

&{CB009322_A_CB008731_TC14_Verification_of_successful_Handover_from_LTE_to_5G_with_active_voice_call}
...		QC_ID_FL00=QC_31515

*** Test Cases ***
CB009322_A_CB008731_TC14_Verification_of_successful_Handover_from_LTE_to_5G_with_active_voice_call
	Log to console		\nPerforming commissioning
	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${SCF_file}			skip_parameter_relation_errors=True
	...								should_activate=True	timeout=500	    connection=${connection}
	Wait Until Keyword Succeeds	   15 times	   20	 Common_resource.Check BTS is OnAir
	Block cells		${cell1}
	${set attenuation}	Create List		5,0        6,0        7,0        8,0        13,90        14,90        15,90        16,90
	Change attenuation	${set attenuation}
	Create dcap session
	Dcap Start Trace SA and LTE
	ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	Log to console    \nStarting VONR call
	ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
	Sleep		10s
	Log to console    \nStarting DL and UL data transfer
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${calltype}    direction=${direction_dl}		tputcheck=No
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${calltype}    direction=${direction_ul}
	Log to console    \nData transfer started
	${set attenuation}    Create List        13,0        14,0        15,0        16,0
    Change attenuation    ${set attenuation}
	${set attenuation}    Create List        5,60    6,60    7,60    8,60
    Increase attenuation by step		${set attenuation}		${10}
	ta_ultracaller.stop_voice_call    ${UE_alias}
	Log to console    \nVoice call stopped
	Dcap Stop Trace and Get results SA
    @{check_emil}	create list		HandoverRequest		HandoverRequestAcknowledge		HandoverNotify
    Run keyword and Continue on Failure		Verify Emil    ${check_emil}
	Log to console    \nWaiting 5 minutes for counter update
    Sleep   5m
    ${Counter}	Create List		M55142C00501=${1}	M55142C00502=${1}	M55142C00508=${1}	M55125C09524=${1}
    ...         M55125C09525=${1}	M55163C00513=${1}   M55163C00514=${1}
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
	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${Pre_execution_scf_file}			skip_parameter_relation_errors=True
    ...								should_activate=True	timeout=500	    connection=${connection}
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
	Convert Emil File To Csv SA and LTE
	FOR		${check}	IN	 @{values}
		${result}		Parse_Emil_Csv_File 	 path=${OUTPUT_DIR}/DCAP_Logs/Extracted/		msg=${check}
		...										msg_col=${msg_col}						con_col=${con_col}
		Run keyword And Continue On Failure		Should Be True		${result}
	END

Dcap Start Trace SA and LTE
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}    gnb_custom_profile=@{gnb_custom_filters}
    ...     bts_custom_profile=@{bts_custom_filter}		enb_custom_profile=@{lte_custom_filters}
	...		collection_timing=@{collection_timing}		wait_for_activation=True
	${val}					Get Dictionary Keys				${output}
	${START_TRACE_ID}		Get from Dictionary				${output}	${val}[0]
	Set Suite Variable		${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Convert Emil File To Csv SA and LTE
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
    ssh.Connect_to    ${UE_PC_IP}    ${Windows_user}    ${Windows_pass}    alias=mcg_vm		timeout=300
    FOR    ${out_index}    IN    @{it}
#       Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}
#       ...     source_file=${out_index}/4g/controlPlane
#	    Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}
#       ...     source_file=${out_index}/5g/controlPlane
        Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}
        ...     source_file=${out_index}
        Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}
        ...     source_file=${out_index}

    END
    ${output}		ssh.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm		timeout=60s
    LOG		${output}
	ssh.Disconnect		connection=mcg_vm
