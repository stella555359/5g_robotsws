*** Settings ***

Documentation
...   author: MN RAN RD VRF BLR1 8
...   contact: I_MN_RAN_RD_VRF_BLR1_T08@internal.nsn.com
...   Description:This resource contains all common keywords used for Robustness CNI-145039.robot

Library     String
Library     DateTime
Library     Collections
Library     BuiltIn
Library     Process
Library     SSHLibrary
Library     OperatingSystem   WITH NAME    os
Library     taf.config.scf   WITH NAME    scf
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.collectors.core    WITH NAME    core
Library     taf.ul.alarms_watchdog   WITH NAME    alarm
Library     taf.sbts.oam.coam.admin    WITH NAME    COAM
Library     taf.collectors.btslog    WITH NAME    btslog
Library     taf.collectors.simple    WITH NAME    simple
Library     ta5g_pm_counters
Library     taf.analyzer.netconf
Library     taf.file.pack
Library     ../../resources/python/ta_ultracaller/    WITH NAME    ta_ultracaller
Library     ../../resources/python/netconf_validation.py
Library     ../../../resources/python/snapshot_parser/snapshot_parser/snapshot_parser_launcher.py
Library     ../../../resources/python/snapshot_parser/snapshot_parser/download_html.py

*** Variables ***
${bts_ip}                   192.168.255.129
${connection}			    Active_Session
@{UE_alias}=                UE1
@{capabilities}=            Legacy_1
${TEST NAME}=               Predicted_Robustness
${OUT_LOG_PATH}             /home/ute/results
${LOG_DIR}=                 /home/ute/test_results
${BTS_path}=                /home/ute/logs/CNI-145039
${user_toor4nsn}             toor4nsn
${Password_toor4nsn}=        oZPS0POrRieRtu
${VM_USER}=                  ute
@{throughput_dl}             250
@{direction_dl}=             dl
@{deviation_dl}=             90
@{throughput_ul}             90
@{udpcalltype}=              UDP
@{tcpcalltype}=              TCP
@{direction_ul}=             ul
@{deviation_ul}=             80
@{Acceptable_Peak_tp_DL} =   80
@{Acceptable_Peak_tp_UL} =   20
${waiting_interval}      200
${FaultID}      4383
${AlarmID}      7101
${pMax_V1}      200
${pMax_V2}      400
${ADMIN_PORT}                443
${USE_SSL}                   True
${CONFIG_PATH}				 /home/ute/testline_configuration1/${UE_file}
${UE_file}					 ta_ue_config.yaml
${miRxWindowStats_Counters}=      M55604C00001,M55604C00006,M55604C00007
${miORANtrx_Counters}=            M40027C1,M40027C2,M40027C3,M40027C4,M40027C5,M40027C6,M40027C7,M40027C8,M40027C9,M40027C10
...                               M40027C11,M40027C12,M40027C13,M40027C14,M40027C15,M40027C16,M40027C17,M40027C18,M40027C19,M40027C20
${snapshotfilename_unzip}          Snapshot_unzipped
${c_dump}=     /home/ute/results/coredump/
${d_dump}=     /home/ute/results/netconf/
${match_pattern}       RMOD_*_NetconfRpcMessageTrace_*.log
${Netconf_directory}=    /tmp/node_FHNET00/tmp      #Netconf log files path; varies depending on active node identifier (e.g., FHNET00, FHNET80)
@{PHRASES}    static-config-supported>PRACH    iq-bitwidth>9    compression-type>STATIC     #Mplane parameter retrieved from Netconf logs
${Jenkins_username}=      username   #login J1 Main [Jenkins] with NSN-INTRA account
${Jenkins_Keys}=          APITOKEN    #API token generated via Jenkins user profile settings
${NRCELL_NO}=             NRCELL-9      #configured NR Cell id
${LTECELL_NO}=            LNCEL-21       #configured LTE Cell id

*** Keywords ***

Validation of Repetitive RMOD Reset
    Disable mirxwindow_mitrRxwindow_miORANtrx parameter
	Enable miRxWindowStats counter paramter
	Enable miORANtrxstats counter paramter
	FOR    ${i}    IN RANGE    1    ${TC_01_No.of.RMOD_Reset_Iteration}
        ${status}     Run keyword and return status    Repetitive RMOD Reset
	    Run keyword if		"${status}" != "True"    Collect snapshot from BTS     RMODReset_Snapshot${i}.zip
		Run keyword and continue on failure      Should be True      ${status}
	    Exit For Loop If  "${status}" != "True"
	END
	Log to console  \n--Counter Wait Period 5mins--\n
	sleep	330s
	${status1}     Run keyword and return status    Counter Verification for MiRxwindowstats
	Run keyword if		"${status1}" != "True"    Collect snapshot from BTS     MiRxWindow_Snapshot.zip
	${status2}     Run keyword and return status    Counter Verification for MiORANTrx
	Run keyword if		"${status2}" != "True"    Collect snapshot from BTS     MiORANTrx_Snapshot.zip

Validation of Repetitive Site block and unblock
	FOR    ${i}    IN RANGE    1    ${TC_02_No.of.Site_Block_Iteration}
        ${status}     Run keyword and return status    Repetitive Site Block and unblock
	    Run keyword if		"${status}" != "True"    Collect snapshot from BTS     SiteBlock_Snapshot${i}.zip
		Run keyword and continue on failure      Should be True      ${status}
	    Exit For Loop If  "${status}" != "True"
	END

Validation of Repetitive Cell block and unblock
    Disable mirxwindow_mitrRxwindow_miORANtrx parameter
	Enable miRxWindowStats counter paramter
	Enable miORANtrxstats counter paramter
	FOR    ${i}    IN RANGE    1    ${TC_03_No.of.Cell_Block_Iteration}
        ${status}     Run keyword and return status    Repetitive Cell block and unblock
	    Run keyword if		"${status}" != "True"    Collect snapshot from BTS     CellBlock_Snapshot_${i}.zip
		Run keyword and continue on failure      Should be True      ${status}
	    Exit For Loop If  "${status}" != "True"
	END
	Log to console  \n--Counter Wait Period 5mins--\n
	sleep	330s
	${status1}     Run keyword and return status    Counter Verification for MiRxwindowstats
	Run keyword if		"${status1}" != "True"    Collect snapshot from BTS     MiRxWindow_Snapshot.zip
	${status2}     Run keyword and return status    Counter Verification for MiORANTrx
	Run keyword if		"${status2}" != "True"    Collect snapshot from BTS     MiORANTrx_Snapshot.zip

Validation of Repetitive RAT Reset
	FOR    ${i}    IN RANGE    1    ${TC_04_No.of.RAT_Reset_Iteration}
        ${status}     Run keyword and return status    Repetitive RAT Reset
	    Run keyword if		"${status}" != "True"    Collect snapshot from BTS     RATReset_Snapshot_${i}.zip
		Run keyword and continue on failure      Should be True      ${status}
	    Exit For Loop If  "${status}" != "True"
	END

Validation of Repetitive Site Reset
    Disable mirxwindow_mitrRxwindow_miORANtrx parameter
	Enable miRxWindowStats counter paramter
	Enable miORANtrxstats counter paramter
	FOR    ${i}    IN RANGE    1    ${TC_05_No.of.Site_Reset_Iteration}
        ${status}     Run keyword and return status    Repetitive Site Reset
	    Run keyword if		"${status}" != "True"    Collect snapshot from BTS     SiteReset_Snapshot_${i}.zip
		Run keyword and continue on failure      Should be True      ${status}
	    Exit For Loop If  "${status}" != "True"
	END
	Log to console  \n--Counter Wait Period 5mins--\n
	sleep	330s
	${status1}     Run keyword and return status    Counter Verification for MiRxwindowstats
	Run keyword if		"${status1}" != "True"    Collect snapshot from BTS     MiRxWindow_Snapshot.zip
	${status2}     Run keyword and return status    Counter Verification for MiORANTrx
	Run keyword if		"${status2}" != "True"    Collect snapshot from BTS     MiORANTrx_Snapshot.zip

Validation of Repetitive BTS Power Reset
	FOR    ${i}    IN RANGE    1    ${TC_06_No.of.Power_Reset_Iteration}
        ${status}     Run keyword and return status    Repetitive BTS Power Reset
	    Run keyword if		"${status}" != "True"    Collect snapshot from BTS     PowerReset_Snapshot_${i}.zip
		Run keyword and continue on failure      Should be True      ${status}
	    Exit For Loop If  "${status}" != "True"
	END

Validation of Repetitive BBMOD Reset
	FOR    ${i}    IN RANGE    1    ${TC_07_No.of.BBMOD_Reset_Iteration}
        ${status}     Run keyword and return status    Repetitive BBMOD Reset
	    Run keyword if		"${status}" != "True"    Collect snapshot from BTS     BBMODReset_Snapshot_${i}.zip
		Run keyword and continue on failure      Should be True      ${status}
	    Exit For Loop If  "${status}" != "True"
	END

Validation of Netconf Mandatory Parameter
    ${status}     Run keyword and return status    Netconf Mandatory Parameter
    Run keyword if		"${status}" != "True"    Collect snapshot from BTS     Netconf_Missing_Mandatory_parameter_Snapshot.zip
	Run keyword and continue on failure      Should be True      ${status}

Validation of Negative_scenarios
    ${status}     Run keyword and return status    Negative_scenarios by change in Pmax
    Run keyword if		"${status}" != "True"    Collect snapshot from BTS     Negative_scenarios_Snapshot_${i}.zip
	Run keyword and continue on failure      Should be True      ${status}

Validation of Crash and Memory leakage via snapshot parser
    Collect snapshot from BTS     Parser_Snapshot.zip
    ${result}=    snapshot_parser_launcher    ${Jenkins_username}    ${Jenkins_Keys}    ${out}/Parser_Snapshot.zip
    Should Contain    ${result}    PASS

Netconf Mandatory Parameter
    Netconf log collection from FHNET
    Search Phrases In File    ${d_dump}    @{phrases}

Repetitive RMOD Reset
    Check Cells are ON-Air    timeout=10s
	ResetAllRadio
    Check Cells are ON-Air    timeout=900s
    Run keyword if		'${Verify_L3Call}' == 'YES'    Attach UE and DL data transfer
    alarm.check_detected_alarms

Repetitive Site Block and unblock
    Check Cells are ON-Air    timeout=10s
	Site block and unblock
    Check Cells are ON-Air    timeout=900s
    Run keyword if		'${Verify_L3Call}' == 'YES'    Attach UE and DL data transfer
    alarm.check_detected_alarms

Repetitive Cell block and unblock
    Check Cells are ON-Air    timeout=10s
	All Cells block and unblock
	Check Cells are ON-Air    timeout=100s
	Run keyword if		'${Verify_L3Call}' == 'YES'    Attach UE and DL data transfer
	alarm.check_detected_alarms

Repetitive RAT Reset
    Check Cells are ON-Air    timeout=10s
	Perform RAT Reset
	Check Cells are ON-Air    timeout=900s
	Run keyword if		'${Verify_L3Call}' == 'YES'    Attach UE and DL data transfer
	alarm.check_detected_alarms

Repetitive Site Reset
    Check Cells are ON-Air    timeout=10s
	Reset Site
	Check Cells are ON-Air    timeout=900s
	Run keyword if		'${Verify_L3Call}' == 'YES'    Attach UE and DL data transfer
	alarm.check_detected_alarms

Repetitive BTS Power Reset
    Check Cells are ON-Air    timeout=10s
	WebEM BTS Power Reset
	Check Cells are ON-Air    timeout=900s
	Run keyword if		'${Verify_L3Call}' == 'YES'    Attach UE and DL data transfer
	alarm.check_detected_alarms

Repetitive BBMOD Reset
    Check Cells are ON-Air    timeout=10s
	BBMOD Reset
	Check Cells are ON-Air    timeout=900s
	Run keyword if		'${Verify_L3Call}' == 'YES'    Attach UE and DL data transfer
	alarm.check_detected_alarms

Negative_scenarios by change in Pmax
    COAM.get_cell_list    timeout=30    connection=${connection}    detailed_output=false
    Get RAT Type
    Run Keyword If    'LTE' in ${rat_types} and 'NR' in ${rat_types}
    ...    Parameter value change    ${dist_name}/${NRCELL_NO}    pMax    ${pMax_V1}
    ...    ELSE IF    'LTE' in ${rat_types}
    ...    Parameter value change    ${dist_name2}/${LTECELL_NO}    pMax    ${pMax_V1}
    ...    ELSE IF    'NR' in ${rat_types}
    ...    Parameter value change    ${dist_name}/${NRCELL_NO}    pMax    ${pMax_V1}
	sleep	30s
    Fault Should Be Present   4008
    Alarm Should Be Present   7112
    Get RAT Type
    Run Keyword If    'LTE' in ${rat_types} and 'NR' in ${rat_types}
    ...    Parameter value change    ${dist_name}/${NRCELL_NO}    pMax    ${pMax_V2}
    ...    ELSE IF    'LTE' in ${rat_types}
    ...    Parameter value change    ${dist_name2}/${LTECELL_NO}    pMax    ${pMax_V2}
    ...    ELSE IF    'NR' in ${rat_types}
    ...    Parameter value change    ${dist_name}/${NRCELL_NO}    pMax    ${pMax_V2}
    sleep   60s
    Fault Should Not Be Present    4008
    Alarm Should Not Be Present    7112
	Check Cells are ON-Air    timeout=100s

Suite Setup
    [Documentation]     Create Coam connection to BTS, check BTS status, start watching alarms.
    Run Process    rm    -rf    ${BTS_path}/    shell=True    stderr=IGNORE
    COAM.teardown_all_aliases_for_admin
	COAM.setup_admin    bts_host=${bts_IP}    alias=${connection}
	${BTS_details}      COAM.get_bts_info       connection=${connection}
    Log    ${BTS_details}
    ${current_sw}    COAM.get_sw_version    connection=${connection}
    BuiltIn.Log To Console    \n--Current Active build in gnb : ${current_sw} --\n
    Set Suite Metadata      Software version    ${current_sw}
	Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}     MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
	Set global variable    ${dist_name2}     MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
	Set global variable    ${mirxwindow_dist}     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
	Set global variable    ${miTrRxwindow_dist}     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
	Set global variable    ${miORANtrx_dist}     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ${cell_details}      COAM.get_cells_info       connection=${connection}
    ${cell_count}       Get Length      ${cell_details}
	@{FDD_cells}		Create List
	Set suite variable		@{FDD_cells}
	Set suite variable		${cell_count}
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${connection}
    ...    reconnect=true    log_dir=/tmp
    Wait Until Keyword Succeeds    900s    10s    Collect snapshot from BTS    PreTest_snapshot.zip
	Log    \n+ Suite Setup finished    console=yes

Attach UE and DL data transfer
    Log to console    \n--Checking Attach --\n
	ta_ultracaller.require_ue    ${UE_alias}    ${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	sleep     60s
    BuiltIn.Log to console    \n--starting DL_Data transfer --\n
	ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
	sleep    30s
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    direction=${direction_dl}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    BuiltIn.Log to console    \n--DL_Data transfer completed --\n


Expected alarm
    [Documentation]     Alarms which are ignored on runtime
    ${allowed_alarm_1}    Create alarm    alarm_id=7220     fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220     fault_id=4654     fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220     fault_id=61649    fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220     fault_id=4655     fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220     fault_id=61652    fault_name=R&D Service Port enabled
    ${allowed_alarm_6}    Create alarm    alarm_id=61641    fault_id=61641    fault_name=IP Traffic Capturing ongoing
    ${allowed_alarm_7}    Create alarm    alarm_id=7115     fault_id=4592     fault_name=BTS Reset Cause
    ${allowed_alarm_8}    Create alarm    alarm_id=7115     fault_id=8000     fault_name=Failure in connection between BTS and 3rd party tool
    ${allowed_alarm_9}    Create alarm    alarm_id=7102     fault_id=49       fault_name=Cell blocked
	${allowed_alarm_10}    Create alarm    alarm_id=7115     fault_id=4740     fault_name=EFaultId_ClearFaultNotifUnderMoAl
    ${allowed_alarm_11}    Create alarm    alarm_id=7115     fault_id=4681     fault_name=Sanity Check Error
    ${allowed_alarm_12}    Create alarm    alarm_id=7115     fault_id=4720
	...    fault_name=Mismatch of RU reported capabilities with static HW Validation information
	${allowed_alarm_13}    Create alarm    alarm_id=7115     fault_id=4602     fault_name=5G cell configuration mismatch
	${allowed_alarm_14}    Create alarm    alarm_id=7114     fault_id=7509
	...    fault_name=EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM
	${allowed_alarm_15}    Create alarm    alarm_id=7110     fault_id=4293     fault_name=IP Traffic Capacity Limit
	${allowed_alarm_16}    Create alarm    alarm_id=7107     fault_id=7300     fault_name=No X2 link available
	${allowed_alarm_17}    Create alarm    alarm_id=7102     fault_id=50       fault_name=BTS blocked
	${allowed_alarm_18}    Create alarm    alarm_id=7115     fault_id=6134     fault_name=EN DSS De-activated on partner side
	${allowed_alarm_19}    Create alarm    alarm_id=7114     fault_id=7513     fault_name=EN DSS De-activated on partner side
    ${allowed_alarm_20}    Create alarm    alarm_id=7112     fault_id=4008     fault_name=Power level not supported
    ${allowed_alarm_21}    Create alarm    alarm_id=7114     fault_id=7107
    ... 	fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}  ${allowed_alarm_9}  #${allowed_alarm_10}
    ...     ${allowed_alarm_11}  ${allowed_alarm_12}  ${allowed_alarm_13}  ${allowed_alarm_14}  ${allowed_alarm_15}  ${allowed_alarm_16}
	...     ${allowed_alarm_17}  ${allowed_alarm_18}  ${allowed_alarm_19}  ${allowed_alarm_20}  ${allowed_alarm_21}
    [Return]    ${allowed_alarms}

Check Cells are ON-Air
    [Arguments]    ${timeout}
    Get RAT Type
    Run Keyword If    'LTE' in ${rat_types} and 'NR' in ${rat_types}
    ...    Assert NR and LTE Cells Enabled    timeout=${timeout}
    ...    ELSE IF    'LTE' in ${rat_types}
    ...    ADMIN Assert All LNCells Are In Enabled State    timeout=${timeout}
    ...    ELSE IF    'NR' in ${rat_types}
    ...    ADMIN Assert All NRCells Are In Enabled State    timeout=${timeout}

Assert NR and LTE Cells Enabled
    [Arguments]    ${timeout}
    ADMIN Assert All NRCells Are In Enabled State    timeout=${timeout}
    ADMIN Assert All LNCells Are In Enabled State    timeout=${timeout}

ADMIN Assert All LNCells Are In Enabled State
    [Arguments]    ${timeout}=100
    ...            ${expected_state}=regex"Enabled|enabled"
    ...            ${class_name}=LNCEL
    ADMIN Assert All LNCells Are In Expected Operational State    expected_state=${expected_state}
    ...                                                         timeout=${timeout}
    ...                                                         class_name=${class_name}

ADMIN Assert All LNCells Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=100
    ...            ${state_type}=operationalState
    ...            ${class_name}=LNCEL
    ADMIN Assert All LNCells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All LNCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=100
    ...            ${class_name}=LNCEL
	...            ${alias}=${connection}
    COAM.Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}
    ...                       alias=${alias}

ADMIN Assert All NRCells Are In Enabled State
    [Arguments]    ${timeout}=100
    ...            ${expected_state}=regex"Enabled|enabled"
    ...            ${class_name}=NRCEL
    ADMIN Assert All NRCells Are In Expected Operational State    expected_state=${expected_state}
    ...                                                         timeout=${timeout}
    ...                                                         class_name=${class_name}

ADMIN Assert All NRCells Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=100
    ...            ${state_type}=operationalState
    ...            ${class_name}=NRCEL
    ADMIN Assert All NRCells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All NRCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=NRCEL
	...            ${alias}=${connection}
    COAM.Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}
    ...                       alias=${alias}

Suite Teardown
    BuiltIn.Log to console   \n--End Test--\n
    #${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    #LOG     ${Active_alarm}
    #alarm.check_detected_alarms
    #alarm.stop_watching_alarms
	Collect snapshot from BTS      suiteteardown_snapshot.zip
    COAM.teardown_admin    connection=${connection}

ResetAllRadio
    Log to console   \n--RMOD reset in progress--\n
    ${listRMOD}=    COAM.get_ids_for_all    RMOD     connection=${connection}
    log    ${listRMOD}
    ${len}=    Get length    ${listRMOD}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        COAM.reset_unit        dist_name=${listRMOD}[${i}]
        ...                     reset_type=Soft
        ...                     timeout=400
        ...                     connection=${connection}
        ...                     detailed_output=False
    END
	Log to console   \n--RMOD reset Completed--\n

Site block and unblock
    Log to console  \n--Site block/unblock Inprogress--\n
    COAM.block    timeout=30    connection=${connection}
    COAM.Assert Alarm Active    parameters=faultId=50
    ...                                            alarmId=7102
    ...                                            severity=Critical
    ...                                            faultName=BTS blocked
    ...                                            timeout=200
    ...                                            alias=${connection}
    COAM.unblock    timeout=300    connection=${connection}
    COAM.Assert Alarm Inactive    parameters=faultId=50
    ...                                            alarmId=7102
    ...                                            severity=Critical
    ...                                            faultName=BTS blocked
    ...                                            timeout=600
    ...                                            alias=${connection}
    sleep    300s
    Log to console  \n--Site block/unblock completed--\n

Enable miRxWindowStats counter paramter
	Parameter value change    ${mirxwindow_dist}    miRxWindowStats    5min
	sleep	10s

Enable miORANtrxstats counter paramter
	Parameter value change    ${miORANtrx_dist}    miOranTrxStats    5min
	sleep	10s

Disable mirxwindow_mitrRxwindow_miORANtrx parameter
	Parameter value change    ${mirxwindow_dist}    miRxWindowStats    disabled
	sleep	10s
	Parameter value change    ${miTrRxwindow_dist}    miTrRxWindowStats    disabled
	sleep	10s
	Parameter value change    ${miORANtrx_dist}    miOranTrxStats    disabled
	sleep	10s

Parameter value change
	[Documentation]		Change parameter value in SCF and commision it
	[Arguments]			${dist_name}	 ${parameter}	 ${value}
	Log to console		\nChanging BTS parameter ${parameter} to ${value} [Dist: ${dist_name}]
	${current_value}	Get Current Parameter Value	   ${dist_name}	   ${parameter}
	BuiltIn.LOG					${current_value}
	Run Keyword If		'${current_value.upper()}'!='${value.upper()}'	COAM.Perform Parameter Recommissioning	  dist_name=${dist_name}
	...					parameter=${parameter}		operation=update	value=${value}	  skip_parameter_relation_errors=True
	...					connection=${connection}
	...		ELSE		Log to console		\nCurrent ${parameter} value is already set to ${value}, No need to peform commissioning
	${current_value}	Get Current Parameter Value	   ${dist_name}	   ${parameter}
	BuiltIn.LOG					${current_value}
	Should Be Equal As Strings	  ${current_value.upper()}	  ${value.upper()}

Get Current Parameter Value
	[Documentation]		Get current parameter value
	[Arguments]			${dist_name}	${param_name}
	${temp_scf_file}	COAM.Get Current Scf File	local_dir_path=/tmp	file_name=temp_scf.xml	  timeout=60	connection=${connection}
	scf.Load Scf		${temp_scf_file}
	${param_value}		scf.get_value_from_scf		dist_name=${dist_name}	p_name=${param_name}
	[Return]			${param_value}


Get RAT Type
    ${rat_types}    Create List
    ${nr_cells}    COAM.get_cells_info    cell_type=nr    connection=${connection}
    ${ne_cell_count}    Get Length    ${nr_cells}
    ${lte_cells}    COAM.get_cells_info    cell_type=lte    connection=${connection}
    ${lte_cell_count}    Get Length    ${lte_cells}
    Run Keyword If    ${ne_cell_count}!=${0}    Append To List    ${rat_types}    NR
    Run Keyword If    ${lte_cell_count}!=${0}    Append To List    ${rat_types}    LTE
    [Return]    ${rat_types}
	Set global variable      ${rat_types}

Perform RAT Reset
    Log to console   \n--RAT reset in progress--\n
    Get RAT Type
    FOR    ${RAT}    IN    @{rat_types}
        Run Keyword    COAM.rat_reset    rat_type=${RAT}    connection=${connection}    timeout=180    reset_type=Soft
    END
    Log to console   \n--RAT reset Completed--\n

All Cells block and unblock
    Log to console   \n--Cell block&unblock in progress--\n
    Get RAT Type
    FOR    ${RAT}    IN    @{rat_types}
        Run Keyword    COAM.block_all_cells    rat=${RAT}    timeout=300    detailed_output=False    connection=${connection}
    END
    sleep	 30
    FOR    ${RAT}    IN    @{rat_types}
        Run Keyword    COAM.unblock_all_cells    rat=${RAT}    timeout=300    detailed_output=False    connection=${connection}
    END
	sleep	 30
	Log to console   \n--Cell Block&unblock Completed--\n

Reset Site
    Log to console   \n--Site reset in progress--\n
    COAM.reset_site    wait_for_reconnection=True     connection=${connection}     timeout=600     detailed_output=False
    sleep	 300
    Log to console   \n--Site reset in Completed--\n

Counter Verification for MiRxwindowstats
    Log to console    \n--MiRxwindowstats counter validation step Inprogress--\n
    ${log_entry}=    COAM.get_pm_counters    counter_ids=${miRxWindowStats_Counters}    connection=${connection}    timeout=100
    Log    ${log_entry}
    ${invalid_counters}=    Create List
    ${rmod_numbers}=    Fetch RMODS
    FOR    ${rmod_number}    IN    @{rmod_numbers}
        Log    Validating counters for RMOD-${rmod_number}
        FOR    ${counter_id}    ${counter_values}    IN    &{log_entry['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']['RMOD-${rmod_number}']['RURWS']}
            Log    Counter ID: ${counter_id}
            ${timestamps}=    Get Dictionary Keys    ${counter_values}
            ${timestamps}=    Convert To List    ${timestamps}
            Sort List    ${timestamps}
            ${last_index}=    Get Length    ${timestamps}
            ${last_index}=    Evaluate    ${last_index} - 1
            ${last_timestamp}=    Get From List    ${timestamps}    ${last_index}
            ${last_value}=    Get From Dictionary    ${counter_values}    ${last_timestamp}
            Log    Last Counter Value for ${counter_id} at ${last_timestamp} is ${last_value}
            Run Keyword If    ${last_value} <= 0
            ...    Append To List    ${invalid_counters}    ${counter_id} | ${last_timestamp}
        END
    END
    Run Keyword If    ${invalid_counters}    Fail    Invalid counters found: ${invalid_counters}
    Log    All last counter values are valid.

Counter Verification for MiORANTrx
    Log to console    \n--MiORANTrx saving counter validation step Inprogress--\n
    ${log_entry}=    COAM.get_pm_counters    counter_ids=${miORANtrx_Counters}    connection=${connection}    timeout=100
    Log    ${log_entry}
    ${invalid_counters}=    Create List
    ${rmod_numbers}=    Fetch RMODS
    FOR    ${rmod_number}    IN    @{rmod_numbers}
        Log    Validating counters for RMOD-${rmod_number}
        FOR    ${counter_id}
		...     ${counter_values}    IN    &{log_entry['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']['RMOD-${rmod_number}']['SFP-1']['OTRST']}
            Log    Counter ID: ${counter_id}
            ${timestamps}=    Get Dictionary Keys    ${counter_values}
            ${timestamps}=    Convert To List    ${timestamps}
            Sort List    ${timestamps}
            ${last_index}=    Get Length    ${timestamps}
            ${last_index}=    Evaluate    ${last_index} - 1
            ${last_timestamp}=    Get From List    ${timestamps}    ${last_index}
            ${last_value}=    Get From Dictionary    ${counter_values}    ${last_timestamp}
            Log    Last Counter Value for ${counter_id} at ${last_timestamp} is ${last_value}
            Run Keyword If    ${last_value} <= 0
            ...    Append To List    ${invalid_counters}    ${counter_id} | ${last_timestamp}
        END
    END
    Run Keyword If    ${invalid_counters}    Fail    Invalid counters found: ${invalid_counters}
    Log    All values are valid.

Fetch RMODS
	${bts_info}      COAM.get_bts_info       connection=${connection}
	Log     ${bts_info['radioModules']['rmod'][0]['id']['configuration']}
    ${rmod_configs}=    Create List
    ${rmod_numbers}=    Create List
    FOR    ${rmod}    IN    @{bts_info['radioModules']['rmod']}
        ${configuration}=    Get From Dictionary    ${rmod['id']}    configuration
        ${split_result}=    Split String    ${configuration}    /
        ${rmod_id}=    Set Variable    ${split_result[-1]}
        ${number}=    Split String    ${rmod_id}    -
#       Append To List    ${rmod_configs}    ${configuration}
        Append To List    ${rmod_numbers}    ${number[1]}
    END
    Log    All RMOD Configurations: ${rmod_configs}
    Log    RMOD Numbers: ${rmod_numbers}
    [Return]    ${rmod_numbers}

WebEM BTS Power Reset
    Log to console   \n--BTS Power reset in progress--\n
    ${status}    run keyword and return status   COAM.Power_Reset   reset_with_snapshot=${False}   wait_for_reconnection=${False}
    ...    connection=${connection}
    Should Be Equal    ${status}    ${true}
    BuiltIn.sleep  10s
    Log to console   Site power reseting...
    Log to console    Waiting for BTS up from power reset
    sleep	 300
	Log to console   \n--BTS Power reset Completed--\n

BBMOD Reset
    Log to console   \n--BBMOD reset in progress--\n
    ${BBMODS}  COAM.get_ids_for_all    BBMOD    connection=${connection}
    Log to console  \n--Performing BBMOD reset--\n
    FOR    ${BBMOD}    IN  @{BBMODS}
      COAM.reset_unit    dist_name=${BBMOD}    reset_type=Warm    timeout=300s    connection=${connection}
    END
    Log to console  \n--BBMOD reset Completed and waiting for BBMOD to come up--\n
    Sleep	150s
	Log to console   \n--BBMOD reset Completed--\n

Start Syslogs
    Log To Console    \n [INFO] bts collector creation is in progress
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
	Log To Console    \n [INFO] bts collector creation success
    core.setup_collectors      names=btslog
    core.set_suite_alias    btslog
    core.start_collectors      names=btslog

Log folder creation
	${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
	${CurrentDate}=    Convert to String     ${CurrentDate}
	${SUITE NAME}    Set Variable    ${SUITE NAME}
	${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
	os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}
	${out}    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/logfolder
	Set global variable    ${out}

Collect snapshot from BTS
	[Documentation]					Download BTS snapshot
	[Arguments]     ${snapshotfilename}
	Log folder creation
	Log To Console    \n Collecting snapshot from BTS
	${status}			Run keyword and return status		COAM.Collect Snapshot	target_file_name=${out}/${snapshotfilename}
	...																				coverage=Full
	...																				force=True
	...																				timeout=1000
	...																				connection=${connection}
	Run Keyword If		'${status}'=='False'				Log   					Snapshot collection failed !!!

Netconf log collection from FHNET
    ${executor}    Create Dictionary    host=${bts_ip}    user=${user_toor4nsn}    password=${Password_toor4nsn}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=${Netconf_directory}
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    30s
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    ${all_files}=    os.List Files In Directory    ${c_dump}
    FOR    ${file}    IN    @{all_files}
		${result}=    Run Keyword And Ignore Error    Should Match    ${file}    ${match_pattern}
        Run Keyword If    '${result[0]}' == 'PASS'    Move File    ${c_dump}${file}     ${d_dump}
	END

Search Phrases In File
    [Arguments]    ${directory}    @{phrases}
    ${files}=    os.List Files In Directory    ${directory}
    FOR    ${phrase}    IN    @{phrases}
        ${found_files}=    Create List
        ${not_found_files}=    Create List
        FOR    ${file}    IN    @{files}
            ${file_path}=    Set Variable    ${directory}/${file}
            Log    Searching for phrase '${phrase}' in file '${file_path}'
            ${contents}=    Run Keyword    os.Get File    ${file_path}
            ${is_found}=    Run Keyword And Return Status    Should Contain    ${contents}    ${phrase}
            IF    ${is_found}
                Log    Phrase '${phrase}' FOUND in file '${file_path}'
                Append To List    ${found_files}    ${file}
            ELSE
                Append To List    ${not_found_files}    ${file}
           END
        END
        IF    ${found_files}
            Log    Phrase '${phrase}' was found in files:
            FOR    ${file}    IN    @{found_files}
                Log    Found in file: ${file}
            END
        ELSE
            Log    Phrase '${phrase}' NOT found in any file under '${directory}'. Listing files checked:
            FOR    ${file}    IN    @{not_found_files}
                Log    Checked file (not found): ${file}
            END
            Fail    Phrase '${phrase}' NOT found in any file under '${directory}'.
        END
    END

Autonomous Reset Recovery After C-Plane Crash
    Check Cells are ON-Air    timeout=10s
    Get RAT Type
    Run Keyword If    'LTE' in ${rat_types}    Trigger C-Plane Crash For LTE
    Run Keyword If    'NR' in ${rat_types}     Trigger C-Plane Crash For NR
    #Counter Verification for MiRxwindowstats
    #Counter Verification for MiORANTrx

Trigger C-Plane Crash For LTE
    ${process_cmd}=    Set Variable    pgrep -f /ram/node_C-CPNODE*
    Trigger Internal Crash    ${process_cmd}

Trigger C-Plane Crash For NR
    ${process_cmd}=    Set Variable    pgrep -f /ram/node_CPRT*
    Trigger Internal Crash    ${process_cmd}

Trigger internal crash
    [Arguments]  ${GET_PROCESS}
    SSHLibrary.Open connection         ${bts_ip}
    SSHLibrary.Login                   ${user_toor4nsn}         ${Password_toor4nsn}
    ${id1}=    SSHLibrary.Execute Command  ${GET_PROCESS}
    @{id}=    Split String    ${id1}    \n
    ${first_id}=    Get From List    ${id}    0
    SSHLibrary.Execute Command    kill -11 ${first_id}
    SSHLibrary.Close Connection
    #Counter Verification for MiRxwindowstats
    #Counter Verification for MiORANTrx
    Post Crash Verification    ${FAULT_ID}    ${ALARM_ID}
    #[Teardown]  SSHLibrary.Close Connection

Post Crash Verification
    [Arguments]    ${FaultID}    ${AlarmID}
    Wait Until Keyword Succeeds    ${WAITING_INTERVAL}    2s    Fault and Alarm Should Appear    ${FaultID}    ${AlarmID}
    Wait Until Keyword Succeeds    ${WAITING_INTERVAL}    2s    Fault and Alarm Should Disappear    ${FaultID}    ${AlarmID}
    Check Cells are ON-Air    timeout=900s
    #Counter Verification for MiRxwindowstats
    #Counter Verification for MiORANTrx

Fault and Alarm Should Appear
    [Arguments]    ${FaultID}    ${AlarmID}
    Fault Should Be Present    ${FaultID}
    Alarm Should Be Present    ${AlarmID}

Fault and Alarm Should Disappear
    [Arguments]    ${FaultID}    ${AlarmID}
    Fault Should Not Be Present    ${FaultID}
    Alarm Should Not Be Present    ${AlarmID}

Fault Should Be Present
    [Arguments]    ${fault_id}
    ${active_alarms}=    COAM.get_active_alarms    connection=${connection}
    ${fault_ids}=    Evaluate    [a['faultId'] for a in ${active_alarms}]
    ${fault_id_int}=    Convert To Integer    ${fault_id}
    Should Contain    ${fault_ids}    ${fault_id_int}

Fault Should Not Be Present
    [Arguments]    ${fault_id}
    ${active_alarms}=    COAM.get_active_alarms    connection=${connection}
    ${fault_ids}=    Evaluate    [a['faultId'] for a in ${active_alarms}]
    ${fault_id_int}=    Convert To Integer    ${fault_id}
    Should Not Contain    ${fault_ids}    ${fault_id_int}

Alarm Should Be Present
    [Arguments]    ${alarm_id}
    ${active_alarms}=    COAM.get_active_alarms    connection=${connection}
    ${alarm_ids}=    Evaluate    [a['alarmId'] for a in ${active_alarms}]
    ${alarm_id_int}=    Convert To Integer    ${alarm_id}
    Should Contain    ${alarm_ids}    ${alarm_id_int}

Alarm Should Not Be Present
    [Arguments]    ${alarm_id}
    ${active_alarms}=    COAM.get_active_alarms    connection=${connection}
    ${alarm_ids}=    Evaluate    [a['alarmId'] for a in ${active_alarms}]
    ${alarm_id_int}=    Convert To Integer    ${alarm_id}
    Should Not Contain    ${alarm_ids}    ${alarm_id_int}
