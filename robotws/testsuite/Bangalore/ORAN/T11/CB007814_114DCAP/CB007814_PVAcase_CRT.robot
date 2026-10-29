*** Settings ***
Documentation
...               Feature ID: CB007814

Library			taf.sw.dcap.rd     WITH NAME   dcap
Library			ute_fsmaccess
Resource		./resources/CB007623_keywords.robot
Library         ./resources/dcap_extract_file.py

Force Tags        CRT    SBTS24R3    FL00    QCD_MN_RAN    QCP_RAN_VRF
Test setup        Prepare environment
Test Teardown     Restore environment

*** Variables ***
&{CB007814_5GC002139_Verify_DL_&_UL_traffic_with_varying_network_conditions_Closed_loop_4X4 MIMO_20Mhz_SA}
...     QC_ID_FL00=QC_31505    QC_ID_SBTS24R2=QC_774139
@{capabilities}    Legacy_1
@{throughput_dl}=   300
@{throughput_ul}=   60
@{UE_alias}=  UE1
@{direction_dl}=  dl
@{direction_ul}=  ul
@{timeout}      100
@{deviation_dl}=  50
@{deviation_ul}=  50
@{data_transfer_protocol}       UDP
${ASP_BOARD_TYPE}     ABIO0
${Retry_count}    		    2
${path1}     /tmp/testgetter/output_file/macro__dlStat.csv
${path3}     /tmp/testgetter/output_file/macro__ulStat.csv
@{at_channel}               5   6   7   8                                                           # Attenuation port used
@{LTE_cell}     0
@{NR_cell}      3

*** Test Cases ***
CB007814_5GC002139_Verify_DL_&_UL_traffic_with_varying_network_conditions_Closed_loop_4X4 MIMO_20Mhz_SA
#	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${SCF_file}			skip_parameter_relation_errors=True
#	...								should_activate=True	timeout=500	    connection=${connection}
#	Wait Until Keyword Succeeds	   15 times	   20	 CB007623_keywords.Check BTS is OnAir
    Set testcase values
    Lock cells  ${LTE_cell}
    Lock NR cells  ${NR_cell}
	${set attenuation}  Create List     13,90     14,90     15,90     16,90
    Change attenuation  ${set attenuation}
    ${set attenuation}  Create List     5,0     6,0     7,0     8,0
	Change attenuation  ${set attenuation}
	Start DCAP log collection
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	Log to console    \nData transfer started
	ta_ultracaller.start_datatransfer   ${UE_alias}     ${data_transfer_protocol}     direction=@{direction_dl}
	sleep    10s
	Start Attenuation
#	Stop DCAP log collection
	sleep    150s
	Log to console    \nData transfer completed
	Run Keyword And Ignore error    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
	...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	${set attenuation}  Create List     5,0     6,0     7,0     8,0     13,0    14,0    15,0    16,0
	Change attenuation  ${set attenuation}
	unzip_and_extract_file_name    ${dcap_dirname}    ${outputdir}/dcap_64qam     /**/*.pcap
	Run Process    command=mergecap -a ${outputdir}/dcap_64qam/*.pcap -w ${outputdir}/dcap_64qam/output_file.pcap     shell=True
	Convert pcap to sherpa csv
	Convert sherpa csv and validate RI
	Initialize Counters and verify
    Run keyword and continue on failure     Unlock cells    ${LTE_cell}
    Run keyword and continue on failure     Unlock NRcells  ${NR_cell}

*** Keywords ***

Convert sherpa csv and validate RI
    sherpa_analyzer.setup reader    ${path1}
    ${result1}     sherpa_analyzer.get values for column    MEAN RI   regex_filter=1.0
    ${result2}     sherpa_analyzer.get values for column    MEAN RI    regex_filter=2.0
    ${result3}     sherpa_analyzer.get values for column    MEAN RI    regex_filter=3.0
    ${result4}     sherpa_analyzer.get values for column    MEAN RI    regex_filter=4.0
    Run Keyword And Continue On Failure     Should not be empty     ${result3}
    ${result1}     sherpa_analyzer.get values for column    256QAM    regex_filter=None
    ${result2}     sherpa_analyzer.get values for column    MAX MCS    regex_filter=27
    ${result3}     sherpa_analyzer.get values for column    MAX PRB    regex_filter=106
    ${result5}    QAM_validation    ${result1}
    Run Keyword And Continue On Failure     Should Not Be Empty     ${result5}
    Run Keyword And Continue On Failure     Should Not Be Empty     ${result2}
    Run Keyword And Continue On Failure     Should Not Be Empty     ${result3}

Start DCAP log collection
    dcap.connect_to  host=${DCAP_host}   port=443    username=utfuser   password=utfadmin!
    ...              rd_version=dcapv3  secure=True
    &{bts1_info}   create dictionary  host=${BTS_M_plane_ip}    port=443    username=Nemuadmin    password=nemuuser
    @{gnb_custom_profile}=    Create List    L2Ps_Sherpa
    ${output}    dcap.start_trace     duration=30    bts=${bts1_info}
    ...    gnb_custom_profile=@{gnb_custom_profile}
    ...    wait_for_activation=True
    ${val}        Get Dictionary Values      ${output}
	Set Suite Variable          ${trace_id}      ${val}[0]
	Log to console		Dcap started, ID: ${trace_id}

Stop DCAP log collection
    Run Keyword And Continue On Failure    dcap.stop_trace    trace_id=${trace_id}
    Sleep   600s
	Log to console		Dcap stopped, ID: ${trace_id}
    ${dcap_dirname}    dcap.get_results    result_id=${trace_id}    target_dir=${OUTPUT_DIR}    timeout=2000
    ${dcap_dirname}=    Set Suite Variable    ${dcap_dirname}

Convert pcap to sherpa csv
	Create Directory		/tmp/testgetter
    SHERPA.create sherpa converter
	...    name=sherpa
	...    file_path_pattern=${outputdir}/dcap_64qam/output_file.pcap
	...    output_path=/tmp/testgetter
    SHERPA.setup    sherpa
    SHERPA.convert    sherpa
    SHERPA.teardown    sherpa

Start Attenuation
	${set attenuation}	Create List		1,40     2,40     3,40     4,40
	Change attenuation by step increment		${set attenuation}		${10}

Prepare environment
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	${Pre_execution_scf_file}	COAM.Get Current Scf File		local_dir_path=${OUTPUT_DIR}/SCF	file_name=Pre_execution_scf.xml
	...							connection=${connection}
	Set Suite variable			${Pre_execution_scf_file}
	${Branch}		Get Branch
	Set Suite variable		${Branch}
	Set global variable		${SCF_file}         ${CURDIR}/resources/config/${Branch}/${TEST NAME}.xml
	Testcase setup

Testcase setup
	${BTS_details}		COAM.get_bts_info	 connection=${connection}
	Log					${BTS_details}
	Set global variable	${BTS_ID}			${BTS_details['mrbtsID']}
	${sw_version}		COAM.get_sw_version	   connection=${connection}
	Set Suite Metadata	Software version	${sw_version}
	${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarms
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${connection}       log_dir=/tmp
	CB007623_keywords.Start BTS logs

Expected alarms
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
	${allowed_alarm_11}    Create alarm    alarm_id=7116     fault_id=4692
	...		fault_name=No external synchronization source
	${allowed_alarm_12}    Create alarm    alarm_id=7116     fault_id=16
	...		fault_name=Unit synchronization failed
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}
	...	${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}
	...		${allowed_alarm_9}  ${allowed_alarm_10}		${allowed_alarm_11}		${allowed_alarm_12}
    [Return]    ${allowed_alarms}

Restore environment
	Run keyword and continue on failure     Unlock cells    ${LTE_cell}
    Run keyword and continue on failure     Unlock NRcells  ${NR_cell}
    alarm.check_detected_alarms
    alarm.stop_watching_alarms
	Collect snapshot from BTS
	${Default_file}		Set Variable	${OUTPUT_DIR}/SCF/Pre_execution_scf.xml
	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${Default_file}			skip_parameter_relation_errors=True
    ...								should_activate=True	timeout=500	    connection=${connection}
	Wait Until Keyword Succeeds	   20 times	   20	 CB007623_keywords.Check BTS is OnAir
	${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
	CB007623_keywords.Stop BTS logs and check
	COAM.teardown_admin    connection=${connection}
	Configure Reporting portal
	Remove Directory	${outputdir}/dcap_64qam		recursive=True

#top BTS logs and verify
#   [Documentation]     Stops BTS log and check for crash
#   CORE.stop_collectors    names=btslog
#   CORE.collect_collectors    names=btslog     target_dir=${OUTPUT_DIR}
#   CORE.teardown_collectors    names=btslog
#   ${check}    CB007623.Check_bts_logs       ${OUTPUT_DIR}/btslog
#   Run keyword And Continue On Failure    Should Be True       ${check}

Collect snapshot from BTS
	[Documentation]		Download BTS snapshot
	${status}			Run keyword and return status		COAM.Collect Snapshot	target_file_name=${OUTPUT_DIR}/Snapshot.zip
	...																				coverage=Full
	...																				force=True
	...																				timeout=1000
	...																				connection=${connection}
	Run Keyword If		'${status}'=='False'				Log   					Snapshot collection failed !!!			ERROR

Get Branch
    COAM.setup_admin    bts_host=${gNB_IP}    alias=Branch    admin_api_log_dir=/tmp
    ${sw_version}    COAM.get_sw_version    connection=Branch
    ${out}    Split String From Right    ${sw_version}    _    -1
    ${Branch}    Strip String    ${out}[0]    both    SBTS
    COAM.teardown_admin    connection=Branch
	[Return]	${Branch}

Initialize Counters and verify
	Log to console 		Sleeping for 5 min for counter to update
	sleep	300s
	${counter_1}	create list		M55301C15002    M55301C15005    M55301C15008    M55301C15011    M55301C15014    M55301C15017    M55301C15018
	...		M55301C15019    M55301C15021    M55301C15026    M55301C15027
	Check Counter MCS 		${counter_1}
	${counter_2}	create list		M55301C16002    M55301C16005    M55301C16008    M55301C16011    M55301C16014    M55301C16017    M55301C16018
	...		M55301C16019    M55301C16021    M55301C16026    M55301C16027
	Check Counter MCS 		${counter_2}
	${counter_3}	create list		M55301C17002    M55301C17005    M55301C17008    M55301C17011    M55301C17014    M55301C17017    M55301C17018
	...		M55301C17019    M55301C17021    M55301C17026    M55301C17027
	Check Counter MCS 		${counter_3}
	${counter_4}	create list		M55301C18002    M55301C18005    M55301C18008    M55301C18011    M55301C18014    M55301C18017    M55301C18018
	...		M55301C18019    M55301C18021    M55301C18026    M55301C18027
	Check Counter MCS 		${counter_4}
	${counter_5}	create list		M55303C00002    M55303C00005    M55303C00008    M55303C00011    M55303C00014    M55303C00017    M55303C00018
	...		M55303C00019    M55303C00021    M55303C00026    M55303C00027
	Check Counter MCS 		${counter_5}
	${counter_6}	create list		M55303C01002    M55303C01005    M55303C01008    M55303C01011    M55303C01014    M55303C01017    M55303C01018
	...		M55303C01019    M55303C01021    M55303C01026    M55303C01027
	Check Counter MCS 		${counter_6}

Check Counter MCS
    [Arguments]    ${counters}
    [Documentation]     Check counter value of gnb
	FOR		${counter_name}	IN	 @{counters}
		Log to console      \nChecking gnb counter ${counter_name}
		${result}		COAM.get_pm_counters
		...		counter_ids=${counter_name}    timeout=300    connection=${connection}
		log    ${result}
		${Dict_val}		validation.get_counter_list	${result}		${counter_name}
		${values}    Get Dictionary Values    ${result${Dict_val}}
		${Total_Count}    Get value of Counter    ${values}
		${status}		Evaluate		${Total_Count}>=0
		Run keyword and continue on failure		Should be True		${status}
	END

Configure Reporting portal
	[Documentation]		Configure reporting portal settings
	RP Settings
	Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
	Set QC_Tag

Link SCOUT SCF to Configuration ID for Reporting
	[Documentation]			Link Scout
    [Arguments]				${node_type}=gnb    ${tl_name_only}=${Scout_tl_name}
    ${node_type_Name}		Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF			"${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE			Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console			${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}	Set Variable    ${tl_name_only}
    ${external_scf_id}		Request Scout SCF   ${scout_testline_name}
    ${TC_ID}				Set Variable    ute:id:${external_scf_id}
    Set Tags				${TC_ID}

Request Scout SCF
	[Documentation]			Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW
    [Arguments]				${scout_testline_name}
    scout.setup_scout		scout_testline_name=${scout_testline_name}
    ${external_scf_id}		scout.request_scf   use_scout_internal_id=True
    [Teardown]				scout.teardown_scout_api
    [Return]				${external_scf_id}

Lock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=${Cell_dist}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${Cell_dist}-${cell}            locking_status=locked
        ...                                                                         operational_status=disabled
        ...                                                                         blocking_status=Unblocked
    END

Lock NR cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${nrcell_list}
    FOR    ${cell}    IN    @{nrcell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=${NRCell_dist}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${NRCell_dist}-${cell}            locking_status=locked
        ...                                                                         operational_status=disabled
        ...                                                                         blocking_status=Unblocked
    END

Check cell details
    [Documentation]             Check cell details
    [Arguments]                 ${cell}
    ...                         ${locking_status}=unlocked  ${operational_status}=enabled   ${blocking_status}=Unblocked
    ${cell_status}              COAM.get_cell_specific_info    cell_id=${cell}    connection=${connection}
    ${administrativeState}      Set Variable    ${cell_status['status']['administrativeState']}
    Run keyword And Continue On Failure    Should Be Equal    ${administrativeState.upper()}    ${locking_status.upper()}
    ${operationalState}         Set Variable    ${cell_status['status']['operationalState']}
    Run keyword And Continue On Failure    Should Be Equal    ${operationalState.upper()}    ${operational_status.upper()}
    ${usageState}               Set Variable    ${cell_status['status']['usageState']}
    #Run keyword And Continue On Failure    Should Be Equal    ${usageState.upper()}    ${usage_status.upper()}
    ${blockingState}            Set Variable    ${cell_status['status']['blockingState']}
    Run keyword And Continue On Failure    Should Be Equal    ${blockingState.upper()}    ${blocking_status.upper()}

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
    ${current_trunk_sw}          Run Keyword If      '${status}'=='True'     Replace String      ${current_sw}       ${sw_list[0]}     SBTS00
    ...                 ELSE                Set variable    ${current_sw}
    Log to console      \nCurrent software in BTS ${BTS_IP} is ${current_sw}
    [Return]            ${current_trunk_sw}

