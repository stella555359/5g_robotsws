*** Settings ***

Documentation
...   author: T02
...    Sample execution: robot -d /home/ute/logs/ -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG01/CB010916/general.robot

Library    taf.converters.emil    WITH NAME    emil
*** Keywords ***

Suite Setup
    Log To Console    SuiteStarted
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}
    coam.setup_admin    username=${bts_username}    password=${bts_password}
    ${sw_release}=    coam.get_sw_release_name    connection=${connection}
    ${build}=    coam.get_sw_version    connection=${connection}
    Set global variable    ${sw_build}    ${build}

Suite Teardown
    Log To Console    SuiteEnded
    coam.setup_admin    username=${bts_username}    password=${bts_password}
    ${sw_release}=    coam.get_sw_release_name    connection=${connection}
    ${build}=    coam.get_sw_version    connection=${connection}
    coam.teardown_all_aliases_for_admin

Test Setup
    coam.teardown_all_aliases_for_admin
    coam.setup_admin    username=${bts_username}    password=${bts_password}
    Wait Until Keyword Succeeds   6min    10s     Check_BTS_State
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Start BTS logs
    log     start

Start BTS logs
    [Documentation]     Starts BTS log in testpc
    Run     killall btslog
    btslog.create_btslog_collector    name=btslog
    core.setup_collectors    names=btslog
    core.set_suite_alias    btslog
    core.start_collectors    names=btslog

Stop BTS logs
    [Documentation]     Stops BTS log and check for crash
    core.stop_collectors    names=btslog
    core.collect_collectors    names=btslog     target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    core.teardown_collectors    names=btslog

Stop BTS logs_LTE830
    [Documentation]     Stops BTS log and check for crash
    core.stop_collectors    names=btslog
    core.collect_collectors    names=btslog     target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/syslogs_LTE830
    core.teardown_collectors    names=btslog

Stop BTS logs_DSS
    [Documentation]     Stops BTS log and check for crash
    core.stop_collectors    names=btslog
    core.collect_collectors    names=btslog     target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/syslogs_DSS
    core.teardown_collectors    names=btslog

Test Teardown
    Log to console   \n--End Test--\n
    Stop BTS logs
    Run Keyword And Continue On Failure    KeywordsCRT2.Validate ActiveAlarms    ${allowed_alarms}
    Run Keyword And Continue On Failure    KeywordsCRT2.Validate Historic_Alarms    ${allowed_alarms}
    COAM.collect_snapshot     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshot.zip
    COAM.collect_im_snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/imSnapshot.ims2
    COAM.collect_raw_alarm_history_file    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/alarmSnapshot.json
    COAM.collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/scf.xml
    Run Keyword And Ignore Error     DCAP_Stop_Trace_For_Teardown
    Run Keyword And Ignore Error    dcap.stop_trace    ${trace_id}
    Run keyword and ignore error    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    coam.teardown_all_aliases_for_admin

Prepare UE and Attach UE with default bearers
    ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    100
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}

TTI Counter Verification
	wait_for_next_full_pm_interval
	${PM_COUNTERS}=    get_latest_unpacked_full_pm_counters_file
	${CORR_NON_DUPL_UL_SCH_TB}    get_latest_pm_counter_value    M8001C13    PLMN-PLMN/MRBTS-911/LNBTS-912/LNCEL-9117    ${PM_COUNTERS}
	${CORR_UL_SCH_TB_RE_RECEPT}   get_latest_pm_counter_value    M8001C14    PLMN-PLMN/MRBTS-911/LNBTS-912/LNCEL-9117    ${PM_COUNTERS}
	${INCORR_UL_SCH_TB_RECEPT}    get_latest_pm_counter_value    M8001C15    PLMN-PLMN/MRBTS-911/LNBTS-912/LNCEL-9117    ${PM_COUNTERS}
    ${Ratio1}=  Evaluate    ${CORR_UL_SCH_TB_RE_RECEPT}/${CORR_NON_DUPL_UL_SCH_TB}
    Set Suite Variable    ${Ratio1}
    log    ${Ratio1}
    ${Ratio2}=  Evaluate    ${INCORR_UL_SCH_TB_RECEPT}/${CORR_NON_DUPL_UL_SCH_TB}
    Set Suite Variable    ${Ratio2}
    log    ${Ratio2}

DCAP_Stop_Trace_For_Teardown
    rd.abort_trace    trace_id=${START_TRACE_ID}    timeout=120
    LOG     DCAP logging stopped

Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${port}    rd_version=${rd_version}
    ...    username=utfuser    password=utfadmin!        secure=${secure}

DCAP_Start_Trace_enb_profile_customised
    [Documentation]     Start DCAP logs with custom filter
    ${bts_profiles}    rd.get_bts_profiles
    ${lte_profiles}    rd.get_lte_profiles
    &{bts_info}=  Create Dictionary    host=${BTS_M_plane_ip}    port=${port}
	...    username=Nemuadmin    password=${bts_password}
    ${output}       rd.start_trace  duration=-1     bts=${BTS_INFO}
	...     enb_custom_profile=@{enb_custom_filters}
    ...     bts_custom_profile=@{bts_custom_filter}
    ...     wait_for_activation=True
    # ${START_TRACE_ID}      Get from Dictionary    ${output}    id
    ${val}        Get Dictionary Values      ${output}

    Set Suite Variable          ${START_TRACE_ID}      ${val}[0]
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the eNB

Stop Voice call to release QCI1 bearer
    ta_ultracaller.stop_voice_call    ${UE_alias}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}

DCAP_Stop_Trace
    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=250
    LOG     DCAP logging stopped
    create directory         ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAPlogs/
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAPlogs/    timeout=1200


Netconf File Collection
    coam.collect_snapshot    target_file_name=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
    KeywordsCRT2.Extract netconf from snapshot

snapshotFileIdentifier
    @{getWithoutFilerValue}=    snapshotFileIdentifier.snapshotGetWithoutFilter
    ...    filename=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
    ...    path=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    ...    fileToBeChecked=NetconfRpcMessageTrace
    Log    @{getWithoutFilerValue}
    RETURN    @{getWithoutFilerValue}

Extract netconf from snapshot
        @{getWithoutFilerValue}=     snapshotGetWithoutFilter    Snapshotfile.zip	${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
        ...    NetconfRpcMessageTrace
        log     ${getWithoutFilerValue}[0]
        log     ${getWithoutFilerValue}[1]
        log     ${getWithoutFilerValue}[2]
        ${netconf_file_path}=    String.Replace string    ${getWithoutFilerValue}[2]    ${TEST_NAME}//    ${TEST_NAME}/
        BuiltIn.Log    ${netconf_file_path}
        Extract
   	...    path=${netconf_file_path}
   	...    output_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
   	...    .=*.log
        ${netconf_filename}=    os.List Files In Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/    *_NetconfRpcMessageTrace.log
        os.Move file    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/*_NetconfRpcMessageTrace.log
    ...		${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log

Start Voice call to establish QCI1 dedicated bearer
    ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}

Setup_Attenuator_AHHB
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${ports_AHHB}
      ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_AHHB}     values=${valuesmax}    confirm=True    confirmation_delay=5s

Setup_Attenuator
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation    ports=${ports}    values=${values0}    confirm=True    confirmation_delay=5s

PerformRecommissioning
    [Arguments]    ${scf_filepath}
    COAM.perform_commissioning
    ...    scf_file=${scf_filepath}
    ...    should_activate=True
    ...    timeout=400
    ...    connection=default

Check_BTS_State
    ${bts_state}=    COAM.get_mrbts_state
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

Validate_BTS_STATUS
    	[Arguments]    ${Required_BTS_Status}
    	${bts_status}=  coam.get_bts_statuses
	${var}  Set Variable    ${bts_status['proceduralState']}
	${str}  BuiltIn.Convert To String    ${var}
	Should Be Equal    ${str}    ${Required_BTS_Status}

move_to_test_dedicated_state_Disable
    	coam.reset_site
	sleep     5m     To check the state of BTS after disable.
    	Wait Until Keyword Succeeds    20min    30s    Validate_BTS_STATUS    ${Required_bts_status}[1]

move_to_test_dedicated_state_Enable
    	coam.reset_to_test_dedicated     detailed_output=True
	sleep     5m     To check the state of BTS after disable.
	Wait Until Keyword Succeeds    10min    30s    Validate_BTS_STATUS    ${Required_bts_status}[0]

start_downlinkNr_test
	Run Keyword And Ignore Error    coam.connect_to    username=${bts_username}    password=${bts_password}
    Run Keyword And Continue On Failure     coam.start_5g_downlink_test    dist_name=${NrcellId}
	...    test_model=${TestModel}    codebook_2_antports=${codebook2antports}
	...    beam_pattern_id=@{BeamPatternId}    i11_codebook_4_antports=${i11Codebook4antports}
	...    polarization=${polarization}    power_backoff=${powerBackoff}    nrarfcn_ul=${nrarfcnUl}
	...    ru_mode=${ruMode}    phys_cell_id=${PhyCellId}     p_max=${pmax}
	...    i2_codebook_4_antports=${i2codebook4antports}     nrarfcn_dl=${nrarfcnDl}
	...    i13_codebook_4_antports=${i13codebook4antports}     mimo_rank=${MIMOrank}
	sleep   1m

stop_downlinkNr_test
    	Run Keyword And Continue On Failure     coam.stop_5g_downlink_test    dist_name=${NrcellId}

PerformRFDiagTest
    ${GetStats}=    RFDiagnosticsStatisticsTest
    Log     ${GetStats}
    ${GetStats1}=    RFDiagnosticsTest
    Log     ${GetStats1}

ResetAllCells
    [Arguments]    ${technology}
    COAM.reset_all_cells    technology=${technology}
    ...                       timeout=400
    ...                       connection=${connection}
    ...                       detailed_output=False

RadioLock
    [Arguments]    ${Rmod}
    COAM.lock     dist_name=${Rmod}
    ...            timeout=240s
    Sleep    60s

RadioUnlock
    [Arguments]    ${Rmod}
    COAM.unlock     dist_name=${Rmod}
    ...              timeout=240s

Counter_Value_Check
    [Arguments]    ${path}    @{ListofCountervalues}
    ${counter_List}=    COAM.get_pm_counters_by_dist_name    timeout=100
    log    ${counter_List['${path}']}
    FOR   ${count1}	IN	@{ListofCountervalues}
    	Run Keyword and Continue On Failure    Should Not Be Empty    ${counter_List['${path}']}[${count1}]}    0
        log    ${counter_List['${path}']}[${count1}]}
        ${counter_values}=    set variable    ${counter_List['${path}']}[${count1}]}
        #${counter_values}=    Get Dictionary values     ${${counter_List['${path}']}[${count1}]}}
        #log    ${counter_values}
        log    ${counter_values}[1]
        #Get From Dictionary If Exists    ${counter_values}    1
    END
    Sleep   60s

Antenalinemonitor
    [Arguments]    ${sleepToMonitorAntl}
    ${getFullDictWithRmod}=    COAM.get_antennas
    log    ${getFullDictWithRmod}
    ${getrmodList}=    Get Dictionary Keys     ${getFullDictWithRmod}
    FOR   ${rmod}   IN   @{getrmodList}
         log    ${getFullDictWithRmod}[${rmod}]
         getAntlValueFromDict    ${getFullDictWithRmod}[${rmod}]
    END
    log    ${antlList}
    ${ant3}=    COAM.start_antl_online_monitoring    target_dns=@{antlList}
    ...     timeout=10    connection=default
    sleep    ${sleepToMonitorAntl}
    log    ${ant3}
    ${ant4}    COAM.stop_antl_online_monitoring    output_file_name=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/alm_rmod.json
    ...    timeout=20    connection=default
    log    ${ant4}
    ${x}=    os.Get File    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/alm_rmod.json
    ${dict}    Evaluate    json.loads('''${x}''')    json
    ${y}=    Get Dictionary keys     ${dict}
    log    ${y}
    FOR    ${i}    IN    @{y}
        ${dictValueToIterate}=     set variable    ${dict}[${i}]
        multipleRadioCollection   ${dictValueToIterate}
    END

RFDiagnosticsStatisticsTest
    ${trigger}=      COAM.start_rf_statistic_diagnostic_test
    		     ...     radios_array=@{radios}
        	     ...     high_threshold=80
       		     ...     low_threshold=-55
       		     ...     force_act_remove_rf_diag=true
		     ...     timeout=60
	             ...     detailed_output=true
		     ...     connection=default
    ${result}=       COAM.save_rf_statistic_diagnostic_test
    		     ...     timeout=60
    		     ...     detailed_output=true
    		     ...     connection=default
    RETURN     ${result}

RFDiagnosticsTest
    ${trigger}=      COAM.start_rf_diagnostic_test
    		     ...     force_act_remote_rf_diag=true
        	     ...     cells=@{cellsnum}
       		     ...     cell_type=NR
       		     ...     rf_power_error_high_threshold=8
		     ...     rf_power_error_low_threshold=-8
	             ...     tx_antenna_vswr_high_threshold=3
		     ...     rx_antenna_rtwp_low_threshold=-110
		     ...     rx_antenna_rtwp_high_threshold=-30
		     ...     band_class=None
		     ...     rx_antenna_rssi_low_threshold=-110
		     ...     rx_antenna_rssi_high_threshold=-30
		     ...     timeout=120
		     ...     connection=default
		     ...     optional_band_thresholds=None
    ${result}=       COAM.save_rf_diagnostic_test_results
    		     ...     timeout=120
    		     ...     connection=default
    RETURN     ${result}

getAntlValueFromDict
     [Arguments]    ${ListContainingAntl}
     FOR    ${antlDescription}    IN     @{ListContainingAntl}
          log    ${antlDescription}[id][internal]
          Insert Into List    ${antlList}    ${-1}    ${antlDescription}[id][internal]
     END

multipleRadioCollection
     [Arguments]    ${dictValueToIterate}
     FOR    ${i}   IN   @{dictValueToIterate}
           multipleAntennasCollection    ${i}[antennaLines]
     END

PerformNRResetRAT
    COAM.rat_reset    rat_type=NR    timeout=240    connection=default

loopingCellsunderAntannaLine
    [Arguments]    ${keyList}     ${dictionaryContainingValue}
     log     ${keyList}
     FOR    ${k}   IN   @{keyList}
          ${temp}=         Get Dictionary values  ${dictionaryContainingValue}[${k}]
          log     "*********************************** TO BE VERIFIED ************************"
          log     ${temp}
     END

SingleBBmodReset
    [Arguments]    ${name}
    COAM.reset_unit        dist_name=${name}
    ...                    reset_type=warm
    ...                    timeout=450
   Wait Until Keyword Succeeds     6m    10s    Ensure cells are enabled

ResetSingleRadio
        [Arguments]     ${RMOD}
        COAM.reset_unit         dist_name=${RMOD}
        ...                     reset_type=Soft
        ...                     timeout=400
        ...                     connection=${connection}
        ...                     detailed_output=False
        Wait Until Keyword Succeeds   6min    10s     Check_BTS_State

ResetAllRadio
    ${listRMOD}=    coam.get_ids_for_all    RMOD
    log    ${listRMOD}
    ${len}=    Get length    ${listRMOD}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        coam.reset_unit        dist_name=${listRMOD}[${i}]
        ...                     reset_type=Soft
        ...                     timeout=400
        ...                     connection=${connection}
        ...                     detailed_output=False
    END

SiteReset
        coam.Reset    timeout=900
        Wait Until Keyword Succeeds   10min    10s     Check_BTS_State

PerformPowerResetfromIpPdu
    [Arguments]    ${pdu_host_ip}    ${portnum}
    pdu.setup_pdu     model=RRB    host=${pdu_host_ip}    alias=RRB_ippdu
    pdu.reset_ports    ports=${portnum}    time_interval=20    pdu_device=RRB_ippdu
    pdu.teardown_pdu    pdu_device=RRB_ippdu

RenameFile
    [Documentation]   This Keywords is Used for to rename ALM logs
    [Arguments]    ${path}    ${Dest_path}
    SSHLibrary.Open Connection    host=10.53.188.132
    SSHLibrary.Login    ute    password=${Windows_pass}    delay=1
    SSHLibrary.Write    mv ${path}/alm_rmod.json ${path}/alm_rmod_${Dest_path}.json
    SSHLibrary.read     delay=3s
    SSHLibrary.Close All Connections

Perform Parameter Recommissioning
    [Arguments]    ${parameter_dist_name}    ${parameter_name}     ${value}
    COAM.perform_parameter_recommissioning
    ...    dist_name=${parameter_dist_name}
    ...    parameter=${parameter_name}
    ...    operation=${operation_value}
    ...    value=${value}
    ...    skip_parameter_relation_errors=${value_true}
    ...    should_activate=${value_true}
    ...    timeout=300
    Sleep    60s

multipleAntennasCollection
    [Arguments]    ${multipleAntennas}
     FOR    ${j}   IN   @{multipleAntennas}
           ${key}=     Get Dictionary keys     ${j}[measureDatas]
           loopingCellsunderAntannaLine     ${key}    ${j}[measureDatas]
     END

Get_Pre_Active_alarms
    	[Documentation]    Active Alarms
    	coam.connect_to    username=${bts_username}    password=${bts_password}
    	${Pre_Active_Alarm}    coam.get_active_alarms

Get_Post_Active_alarms
    	[Documentation]    Active Alarms
    	${Post_Active_Alarm}   coam.get_active_alarms

Get Actual Configuration MO Data
    [Arguments]    ${mo_id}
    ${actual_conf}=    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${managed_object}=    netact.Get Managed Object    ${actual_conf}    ${mo_id}    alias=${NETACT_NAME}
    [Return]    ${managed_object.meta_class}     ${managed_object.meta_version}

Create_Activate_Plan_Netact
    [Arguments]     ${actual_plan_name}    ${BackupPlan}     ${celladministrativeState}
    ${plan_conf}=    netact.Create Plan Configuration    ${actual_plan_name}    ${PLAN_DESCRIPTION}    alias=${NETACT_NAME}
    ${meta_class}     ${meta_version}=    Get Actual Configuration MO Data   ${mo_id}
    ${managed_object}=    netact.Create Managed Object    ${plan_conf}    ${meta_class}    ${meta_version}    ${mo_id}    CREATE
    ...                                            alias=${NETACT_NAME}    administrativeState=${celladministrativeState}
    Provision Plan    ${actual_plan_name}    ${BackupPlan}

Add_cmwas_node
    netact.Add Node    cmwas    ${fm_cm_itsmwas_hostIp}
    ...                         ${node_Username_fmwas}
    ...                         ${node_password_fmwas}
    ...                         alias=${NETACT_NAME}

Provision Plan
    [Arguments]    ${plan_name}    ${backup_planname}
    netact.provision_plan    ${plan_name}    ${managed_object}    backup_plan_name=${backup_planname}
    ...               create_backup_plan=${TRUE}    provisioning_operation=activate    alias=${NETACT_NAME}

Delete Plan
   [Arguments]    ${plan_name}
   netact.delete_plan    plan_name=${plan_name}    alias=${NETACT_NAME}

Add URL
    netact.add_web_url    web_url=${web_url}
    ...                   username=${netactUSERNAME}
    ...                   password=${netactPASSWORD}
    ...                   alias=${NETACT_NAME}

NetActTeardown
    Delete Plan    plan_shutcell_t02
    Delete Plan    plan_unlockcell_t02
    netact.Delete Node    cmwas    alias=${NETACT_NAME}
    netact.Delete Node    nwi3    alias=${NETACT_NAME}
    netact.Clean All    alias=${NETACT_NAME}

NetActSetup
    Add URL
    Add_cmwas_node
    Run Keyword And Ignore Error     Delete Plan    plan_shutcell_t02
    Run Keyword And Ignore Error     Delete Plan    plan_unlockcell_t02

Perform commissioning with ANT port re-map
    [Arguments]    ${ANT_port_remap}
    coam.Perform Delta Recommissioning
    ...    delta_file=${ANT_port_remap}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=180
    ...    alias=${connection}
    Log To Console    ANT port remapping done successfully

Ensure cells are enabled
    ${cells_info}=    coam.Get cells info
    FOR    ${cell}    IN    @{cells_info}
        ${current_date}=         Get Current Date
        ${operational_state}=    Set variable     ${cell['status']['operationalState']}
        ${globalCellId}=    Set variable     ${cell['globalCellId']}
        Log to console     ${current_date} : CELL-${globalCellId} STATE : ${operational_state}     WARN
        Should be equal as strings    ${operational_state}    enabled
    END

Expected_alarm
    ${allowed_alarm_1}    Create alarm    alarm_id=${alarm_id1}    fault_id=${fault_id1}   fault_name=${fault_name1}
    ${allowed_alarm_2}    Create alarm    alarm_id=${alarm_id2}   fault_id=${fault_id2}    fault_name=${fault_name2}
	${allowed_alarm_3}    Create alarm    alarm_id=${alarm_id3}   fault_id=${fault_id3}    fault_name=${fault_name3}
	${allowed_alarm_4}    Create alarm    alarm_id=${alarm_id4}    fault_id=${fault_id4}    fault_name=${fault_name4}
    ${allowed_alarm_5}    Create alarm    alarm_id=${alarm_id5}    fault_id=${fault_id5}    fault_name=${fault_name5}
	${allowed_alarm_6}    Create alarm    alarm_id=${alarm_id6}   fault_id=${fault_id6}    fault_name=${fault_name6}
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}
	...   ${allowed_alarm_4}    ${allowed_alarm_5}		${allowed_alarm_6}
    [Return]    ${allowed_alarms}

checkCellState
         [Arguments]    ${Argument1}     ${Argument2}      ${Argument3}       ${Argument4}
         ${cell_status}	    COAM.get_cell_specific_info      cell_id=MRBTS-911/NRBTS-911/NRCELL-1      connection=${connection}
         ${administrativeState}		Set Variable		${cell_status['status']['administrativeState']}
         Run keyword And Continue On Failure		Should Be Equal		${administrativeState}    ${Argument1}
         ${operationalState}	Set Variable	${cell_status['status']['operationalState']}
         Run keyword And Continue On Failure		Should Be Equal		${operationalState}       ${Argument2}
         ${usageState}		Set Variable	${cell_status['status']['usageState']}
         Run keyword And Continue On Failure		Should Be Equal		${usageState}       ${Argument3}
         ${blockingState}		Set Variable	${cell_status['status']['blockingState']}
         Run keyword And Continue On Failure		Should Be Equal		${blockingState}       Unblocked
         ${proceduralStatus}		Set Variable	${cell_status['status']['proceduralStatus']}
         Run keyword And Continue On Failure		Should Be Equal		${proceduralStatus}	${Argument4}
         ${barringStatus}		Set Variable	${cell_status['status']['barringStatus']}
         Run keyword And Continue On Failure		Should Be Equal		${barringStatus}       unbarred
         ${status}		Run Keyword And Return Status 		Set Variable
         ...   ${cell_status['stazltus']['availabilityStatus']}
         Run keyword And Continue On Failure		Should Not Be True		${status}

Nested Looping
    [Arguments]    ${I}    ${value}
	@{parameter-check}=    create list
	FOR    ${line}    IN    @{I}
        Run Keyword If     '${line.text}'=='${value}'    Append To List    ${parameter-check}    ${line.text}
	END
	[RETURN]    ${parameter-check}

Parameter Check
	[Arguments]    ${parameter-check}    ${val}
	${final_band}=    create list
    FOR    ${I}    IN    @{parameter-check}
	    Log    ${I}
        ${aa}=    Nested Looping    ${I}	${val}
		${final_band}=    combine lists    ${aa}    ${final_band}
    END
	${len}=    get length    ${final_band}

Initiate the TCP Downlink and uplink data transfer
    [Arguments]    ${UE_alias}    ${capabilities}
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    sleep    100
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
    Run Keyword    ta_ultracaller.start_data_transfer      ${UE_alias}     ${tcpcalltype}    direction=${direction_dl}
    Run Keyword    ta_ultracaller.await_data_transfer_finish     ${UE_alias}    ${direction_dl}     ${timeout}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}     #Throughput check
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
    Run Keyword    ta_ultracaller.start_data_transfer     ${UE_alias}      ${tcpcalltype}     direction=${direction_ul}
    Run Keyword    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_ul}     ${timeout}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Run Keyword And Continue On Failure     ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}   direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}      #Throughput check
    Log to console    \nData transfer completed

ExtractLogsForValidation
     [Arguments]    ${logs_to_be_extracted}
     ${path1}     Set Variable        ${logs_to_be_extracted}

     ${path2}     Set Variable        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
     ${source_paths}    Set Variable        ${path2}/DCAP_logs_Extracted/
     create directory         ${source_paths}
     ${files}    os.List Files In Directory    ${logs_to_be_extracted}
     FOR    ${zip}    IN    @{files}
        Extract_zip        ${path1}/${zip}        ${source_paths}
     END
     ${it}=    os.List Directory    ${source_paths}

TTI parse UL
     [Arguments]    ${SW_build}
     @{inp}=    Create List    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20
     ...    21    22    23    24    25    26    27
     Log    ${inp}
     @{inp1}=    Create List    QPSK    16QAM    64QAM    256QAM
     ${path1}     Set Variable        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
     ${source_paths}    Set Variable        ${path1}/DCAP_logs_Extracted/
     Log    ${source_paths}
     ${out1}=    tti_trace_validation.parse     ${source_paths}     UL    ETtiTraceUlParUe_mcsIndexCw1    ${inp}
     ...    ETtiTraceUlParUe_Modulation    ${inp1}    build=${SW_build}

TTI parse DL
     [Arguments]    ${SW_build}
     @{inp}=    Create List    27    26    25    24     23    22    21    20    19    18    17    16    15    14    13    12    11    10
     ...    9    8    7    6    5    4    3     2     1
     Log    ${inp}
     @{inp1}=    Create List     1
     ${path1}     Set Variable        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
     ${source_paths}    Set Variable        /${path1}/DCAP_logs_Extracted/
     ${out1}=    tti_trace_validation.parse     ${source_paths}     DL    ETtiTraceDlParUe_mcsIndexCw1
	 ...    ${inp}    ETtiTraceDlParUe_rrmUeUsingDl256QamMappingTable    ${inp1}    build=${SW_build}
     Set suite Variable    ${out1}
     Log    ${out1}

Validate SysLogs
    ${check}=    os.Run    grep -o "RromGracefulCellShutdown" ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/syslog_anamoly.txt
      #BuiltIn.Should Match   ${check}    RromGracefulCellShutdown
      IF     "${check}"=="RromGracefulCellShutdown"
          Log    Validation successful
      END
    ${contains}=    Evaluate   "RromGracefulCellShutdown" in """${check}"""

    Run Keyword If    "${contains}"=="False"    Fail     msg=Validation failure!!!
    Run Keyword If    "${contains}"=="True"    Log To Console    \n--Validation successful
      Run Keyword If    ${True}    Log    Validation Successful
      IF    "${contains}"=="True"
          Log To Console    \n--Validation successful
      END

Filter Gnb_syslog
    [Arguments]    ${syslog_files}    ${SEARCH_STRING}    ${output_file_path}
    ${rc}    ${output}=    os.Run And Return Rc And Output    tar -xzvf ${syslog_files}
    ${files_list}=    String.Split To Lines    ${output}
	LOG    ${output_file_path}
    ${search_string_values}=    Create List
    FOR    ${file}    IN    @{files_list}
         #${rc}    ${output}=    os.Run And Return Rc And Output    tar -xzvf ${file}
         #Log    ${output}
         ${check}=    os.Run   grep -o ${SEARCH_STRING} ${file}
         Append To List    ${search_string_values}    ${check}
    END
    ${contains}=    Evaluate   "${SEARCH_STRING}" in """${search_string_values}"""
    Run Keyword If    "${contains}"=="False"    Fail     msg=Validation failure!!!
    Run Keyword If    "${contains}"=="True"    Log To Console    \n--Validation successful
    Run Keyword If    ${True}    Log    Validation Successful

Verify gracelfullshutdown in Syslogs
    [Arguments]    ${search_string}
    os.Run And Return Rc And Output    rm -f ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/syslog_anamoly.txt
    ${rc}    ${output}=   os.Run And Return Rc And Output
    ...    find ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/syslogs_LTE830/btslog -maxdepth 1 -name syslog_files.tgz
    Run Keyword If    "${output}"==""    Fail     msg=There is no syslog_files.tgz caught!!!
    Run Keyword If    "${output}"!=""    Filter Gnb_syslog    ${output}    ${search_string}
    ...    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/syslog_anamoly.txt

Stop Syslog from Remote machine
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=${OUTPUT_DIR}
    core.teardown_collectors      names=btslog

Verify Emil logs
	[Arguments]    ${dcap_log}    @{values}
	#[Arguments]    @{emil_values}
	Convert Emil File To Csv    ${dcap_log}
	FOR    ${check}    IN 	  @{values}
	    ${result}		Parse_Emil_Csv_File_For_Message 	 ${dcap_log}		${check}
	    Run keyword And Continue On Failure		Should Be True		${result}
	END

Start Emil To Convert Emil File To Csv
    [Arguments]    ${source_path}     ${source_file}
    [Documentation]         Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}    os.List Directory    ${source_path}/${source_file}
    ssh.Execute    command=mkdir ${uepc_Log_path}     connection=mcg_vm
    ${emil_File_List}=    findEmilFileFromList      ${source_emil_file}
    FOR    ${emil_File}    IN 	  @{emil_File_List}
    	ssh.upload_file    local_path=${source_path}/${source_file}/${emil_File}   remote_path=${uepc_Log_path}//${emil_File}
    	...     connection=mcg_vm
    	Run keyword and ignore error	ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f      connection=mcg_vm		timeout=30s
        ${src_file}     Set Variable        ${uepc_Log_path}//${emil_File}
        ${cmd}	Set Variable
		...    cd ${emil_path} && ./Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile}
        LOG	${cmd}
        ${output}		ssh.Execute    command=${cmd}      connection=mcg_vm		timeout=5m
        LOG		${output}
        LOG             ${emil_File}
        #@{emil_file_name_splits}= 	Split String	${emil_File}    ${.}
        #LOG    ${emil_file_name_splits}
        #Run keyword and ignore error    ${src_file}    String.Replace String    string=${emil_File}    search_for=.emil    replace_with=.csv
        ${src_file}=    Run keyword and ignore error    String.Replace String    string=${emil_File}    search_for=.5gm    replace_with=.csv
        ${files}    os.List Directory    ${uepc_Log_path}
        #${emil_File_List}=    findCSVFileFromList      ${files}
        #ssh.download_file    remote_path=${uepc_Log_path}//${emil_File_List}		local_path=${source_path}/${source_file}/${emil_File_List}
		#...    connection=mcg_vm
    END

Convert Emil File To Csv
    [Arguments]    ${dcap_log}
    [Documentation]        Convert Emil logs collected from DCAP
    Log to console      \nConverting Emil logs and verifying
    #${path1}=     Set Variable        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    ${path1}=     Set Variable        /home/ute/results/CRT2SuiteLteNr/21_01_2025_1408/Dput_SCell_2CC
    Set Global variable     ${path1}
    ${source_paths}    Set Variable        ${path1}/Extracted/
    create directory         ${source_paths}
    #${files}    os.List Files In Directory    ${path1}
    #FOR    ${zip}    IN    ${files}
    Extract_zip        ${dcap_log}        ${source_paths}
    #END
    ${check}    os.List Directory    ${source_paths}
    FOR    ${value}    IN    @{check}
        ${date}=		Set Variable		${value}
    	Exit For Loop
    END
    #${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    #${date}    Convert to String    ${date}
    ${it}=    os.List Directory    ${source_paths}/${date}
    ssh.Connect_to    ${UE_PC_IP}    ${Windows_user}    ${Windows_pass}    alias=mcg_vm
    FOR    ${out_index}    IN    @{it}
        Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}/
        #...     source_file=${out_index}/4g/controlPlane
        ...     source_file=${out_index}
        #Emil decoding in csv to specific folder with callable filter
    END
    ${output}		ssh.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm		timeout=30s
    LOG		${output}
    ssh.Disconnect		connection=mcg_vm

Filter ERR WRN Message From Syslog By One File
    [Arguments]    ${log_file}    ${filter_message_file}    ${output_file}
    [Documentation]    This keyword is used to filter error and warnning message from one file.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_file} | Yes | log file which needs to be filterred. |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By One File | ${CURDIR}/syslog.txt    ${CURDIR}/filter_log.txt    ${CURDIR}/output_log.txt |
    os.File Should Exist    ${filter_message_file}
    ${content}=    os.Get File    ${filter_message_file}
    BuiltIn.Log to Console   ${content}
    ${content_list}=    String.Split To Lines    ${content}
    BuiltIn.Log to console  ${content_list}
    FOR    ${filter_item}    IN    @{content_list}
    os.Run And Return Rc And Output    grep ${filter_item} ${log_file}>>${output_file}
    END

Search Logs For String And Copy To Output
    #[Arguments]    ${log_file}    ${SEARCH_STRING}    ${output_file}
    [Documentation]    Search for a specific string in log files and copy matching lines to an output file.
    #${log_files}=    Replace String    ${log_file}    \n    ' '
    #${command}=    Set Variable    grep ${SEARCH_STRING} ${log_files} >> ${output_file}
    #LOG    ${log_file}
    #${check}=    OperatingSystem.Run   grep -o ${SEARCH_STRING} ${log_file} >> ${output_file}
    #Run Process    ${check}    shell=True

Verify static PRACH config from Netconf logs
    [Arguments]    ${netconf_file}
    ${static_PRACH}=    netconf_get_value     ${netconf_file}     rpc    edit-config    static-config-supported
    Should Be Equal    ${static_PRACH[0][1]}    PRACH

Start DCAP log
    dcap.connect_to    host=${DCAP_host}     port=${DCAP_port}    username=${username}    password=${password}     secure=${True}
    &{bts1_info}   create dictionary     host=${BTS_MPLANE}    port=443    username=Nemuadmin    password=${bts_password}
    @{enb_custom_profile}=    Create List    condor4gAa
    @{bts}      Create List     ${bts1_info}
    ${output}    dcap.Start_trace     duration=-1    bts=@{bts}    enb_custom_profile=@{enb_custom_profile}    wait_for_activation=True
    LogToConsole    ${output}
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    set global variable    ${trace_id}
    LogToConsole    Dcap started
    sleep    4m

cat-M UE call
    ue.Require ue    ue_alias=${CATM_UE_ALIAS1}   capabilities=CatM
    Attach UE and check if ue attched to particular EARFCN
    ...    UE_ALIAS=${CATM_UE_ALIAS1}    EARFCN=${500}
    sleep	2
    ue.Start Data Transfer   duration=${CALL_DURATION_S}   throughput=${CATM_CALL_DL_BW_KBPS}   dt_name=dl
    ...   ue_alias=${CATM_UE_ALIAS1}  protocol=udp   direction=dl     packet_size=1200
    sleep     20
    Run keyword And COntinue On Failure    ue.await data transfer finish    dt_name=dl
    ue.Verify Average Throughput With Deviation    dt_name=dl    tput=${CATM_CALL_DL_BW_KBPS}   deviation=${CATM_MAX_BW_DEVIATION_PERCENT}
    ue.Detach UE  ${CATM_UE_ALIAS1}

Attach UE and check if ue attched to particular EARFCN
    [Arguments]     ${UE_ALIAS}      ${EARFCN}
	Log To Console    \n Attaching the device ${UE_ALIAS} ...
	Log    ${EARFCN}
    ue.Attach UE   ue_alias=${UE_ALIAS}

ADMIN Add Allowed Alarms
    [Arguments]    ${faults_list}
    ...            ${alias}=${ADMIN_ALIAS}
    FOR  ${index}  IN  @{faults_list}
        COAM.Add Allowed Alarm   fault_id=&{index}[fault_id]
    ...                            alarm_id=&{index}[alarm_id]
    ...                            alarm_severity=&{index}[alarm_severity]
    ...                            notifier=&{index}[notifier]
    ...                            fault_name=&{index}[fault_name]
    ...                            alias=${alias}
    END

LTE wideband call with legacy UE
    log to console  reserving UEs...
    os.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ${ue_details1}=    ta_ultracaller.Require_ue    ${UE_alias1}    ${capabilities1}
    ute_ue.require ue  ${UE_CATM2}  capabilities=catm2
    os.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias1}
    ute_ue.detach ue  ${UE_CATM2}
    sleep    40s
    Set To Dictionary    ${ue_details1['LEGACY_1']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']}
    ...    iperf_udp='-p:5069 -b:82M -l:1024 -t:60 -i:1'
    log    ${ue_details1}
    log to console    Attach Legacy1 UE...
    os.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Attach UE      ue_alias=${UE_alias1}
    sleep    20s
    log to console  Calculating Max DL THroughput Achieved on Single Legacy Device....
    ta_ultracaller.start_datatransfer    ue_alias=${UE_alias1}    direction=${direction_dl}    protocoltype=${data_transfer_protocol}
    sleep  50
    ta_ultracaller.await_data_transfer_finish    ${UE_alias1}    ${direction_dl}    ${timeout}
    sleep  100
    ${Result}=    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias1}    direction=${direction_dl}
    ...    thrughtput=${throughputt_dl1}    deviation=${deviation}
    ${Value}=    get from dictionary    ${Result['${UE_alias1[0]}']}    tputvalue
    log to console  Max DL Throughput on Single Legacy Device is ${Result['LEGACY_1']['tputvalue']}
	${status}=    BuiltIn.Evaluate      ${Value}>=76
	Run keyword And Continue On Failure		Should Be True    ${status}

LTE wideband and catM call
    log to console  reserving UEs...
    os.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ${ue_details1}=    ta_ultracaller.Require_ue    ${UE_alias1}    ${capabilities1}
    ute_ue.require ue  ${UE_CATM}  capabilities=catm
    os.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias1}
	ute_ue.detach ue  ${UE_CATM}
    sleep    40s
	Set To Dictionary    ${ue_details1['LEGACY_1']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']}
    ...    iperf_udp='-p:5069 -b:82M -l:1024 -t:60 -i:1'
    log    ${ue_details1}
    log to console    Attach Legacy1 UE...
    os.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Attach UE      ue_alias=${UE_alias1}
    sleep    20s
    log to console  Calculating Max DL THroughput Achieved on Single Legacy Device....
    ta_ultracaller.start_datatransfer    ue_alias=${UE_alias1}    direction=${direction_dl}    protocoltype=${data_transfer_protocol}
    sleep  50
    ta_ultracaller.await_data_transfer_finish    ${UE_alias1}    ${direction_dl}    ${timeout}
    sleep  100
    ${Result}=    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias1}    direction=${direction_dl}
    ...    thrughtput=${throughputt_dl1}    deviation=${deviation}
    ${Value}=    get from dictionary    ${Result['${UE_alias1[0]}']}    tputvalue
    log to console  Max DL Throughput on Single Legacy Device is ${Result['LEGACY_1']['tputvalue']}
	${status}=    BuiltIn.Evaluate      ${Value}>=76
	Run keyword And Continue On Failure		Should Be True    ${status}
	sleep    60s
	ta_ultracaller.Detach UE      ue_alias=${UE_alias1}
	Set To Dictionary    ${ue_details1['LEGACY_1']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']}
    ...    iperf_udp='-p:5059 -b:62M -l:1024 -t:60 -i:1'
    log    ${ue_details1}
       os.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Attach UE      ue_alias=${UE_alias1}
    sleep    20s
    log to console    Attach CaTM UE...
    log to console  Start DL Traffic On Legacy1 UE...
    ta_ultracaller.start_datatransfer    ue_alias=${UE_alias1}    direction=${direction_dl}    protocoltype=${data_transfer_protocol}.
    Starting 'DL' throughput on '${UE_CATM}' with bw='${CALL_DL_BANDWIDTH_CATMM}' during '60s'
    sleep  50
    log to console  Wait Data Transfer Finish On Legacy1 UE...
    ta_ultracaller.await_data_transfer_finish    ${UE_alias1}    ${direction_dl}    ${timeout}
    log to console  Wait Data Transfer Finish On ${UE_CATM} UE..
    Wait 'DL' throughput finish on '${UE_CATM}'
    sleep    100s
    ${Result1}=    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias1}    direction=${direction_dl}
    ...    thrughtput=${throughputt_dl11}    deviation=${deviation}
    ${Value_1}=    get from dictionary    ${Result1['${UE_alias1[0]}']}    tputvalue
    log to console    Avg Throughput on Legacy1 camped on PLMN40499 Cell is ${Result1['LEGACY_1']['tputvalue']}
	${status_1}=    BuiltIn.Evaluate      ${Value_1}>=55
	Run keyword And Continue On Failure		Should Be True    ${status_1}
    Verify 'DL' throughput on '${UE_CATM}' bw is '${CALL_DL_BANDWIDTH_CATMM}' with deviation '10%'

Get Time and update SCF for Power Saving Parameters
	${bts_time}=    calculateDateTime
	LOG    ${bts_time}
	${time}  BuiltIn.Convert To String    ${bts_time}
	${day}    ${hour}    ${minute}=    Evaluate    ${time}
	LOG    ${day}
	LOG    ${hour}
	LOG    ${minute}
	coam.teardown_all_aliases_for_admin
	Login To Admin
	Download SCF
	update_lbps_start_time    ${output_File}    ${output_File}    ${day}    ${hour}    ${minute}    ${cellSoduration}
	remove_ns_prefix    ${output_File}    ${output_File}

Check Energy saving State
	[Arguments]    ${dist_name}    ${CellState}
	Run Keyword And Ignore Error    coam.connect_to    username=${bts_username}    password=${bts_password}
	${CellEnergySavingState}=    coam.get_parameters
	...    dist_name=${dist_name}
 	...    parameter=energySavingState
    ...    timeout=300
	...    parameter=energySavingState
	...    timeout=300
	${state}  Set Variable    ${CellEnergySavingState['energySavingState']}
	${compare}  BuiltIn.Convert To String    ${state}
	Log To Console    \nCELL STATE IS : ${compare}
	Run Keyword And Continue On Failure    Should Be Equal    ${compare}    ${CellState}

Check RU Powerstate
	[Arguments]    ${dist_name}    ${ORUState}
	Run Keyword And Ignore Error    coam.connect_to    username=${bts_username}    password=${bts_password}
	${OruPowerState}=    coam.get_parameters
	...    dist_name=${dist_name}
	...    parameter=PowerState
	...    timeout=300
	LOG    ${OruPowerState}
	LOG    ${OruPowerState['powerState']}
	${state}  Set Variable    ${OruPowerState['powerState']}
	${compare}  BuiltIn.Convert To String    ${state}
	Log To Console    \nORU STATE IS : ${compare}
	Run Keyword And Continue On Failure    Should Be Equal    ${compare}    ${ORUState}

Download SCF
    [Documentation]    ... Downloading SCF
    coam.get_current_scf_file    file_name=${filename}    timeout=60    local_dir_path=${savedSCF_path}
    os.File Should Exist    ${savedSCF_path}/${filename}
    Log To Console    SCF Downloaded
    Log To Console    SCF file name is ${filename}
    [Return]    ${filename}

Peform_block_Cell
       [Arguments]    ${dist_name}
       coam.block_cell
       ...                 dist_name=${dist_name}

Peform_unblock_Cell
       [Arguments]    ${dist_name}
       coam.unblock_cell
	   ...                 dist_name=${dist_name}

Block all cells Except OFEGSA
	Peform_block_Cell    ${AHHBCELL1}
	Peform_block_Cell    ${AHHBCELL2}
	Peform_block_Cell    ${AZRBCELL1}
	Peform_block_Cell    ${AZRBCELL2}
	Peform_block_Cell    ${AZRBCELL3}
	Peform_block_Cell    ${AZRBCELL4}
	Peform_block_Cell    ${AHPMDANRCELL}
	Peform_block_Cell    ${AZQPNRCELL}

Unblock all cells Except OFEGSA
	Peform_unblock_Cell    ${AHHBCELL1}
	Peform_unblock_Cell    ${AHHBCELL2}
	Peform_unblock_Cell    ${AZRBCELL1}
	Peform_unblock_Cell    ${AZRBCELL2}
	Peform_unblock_Cell    ${AZRBCELL3}
	Peform_unblock_Cell    ${AZRBCELL4}
	Peform_unblock_Cell    ${AHPMDANRCELL}
	Peform_unblock_Cell    ${AZQPNRCELL}

Block all cells Except OFEGSA DSS cells
	Peform_block_Cell    ${AHHBCELL1}
	Peform_block_Cell    ${AHHBCELL2}
	Peform_block_Cell    ${AZRBCELL1}
	Peform_block_Cell    ${AZRBCELL2}
	Peform_block_Cell    ${AZRBCELL3}
	Peform_block_Cell    ${AZRBCELL4}
	Peform_block_Cell    ${AHPMDANRCELL}
	Peform_block_Cell    ${AHPMDANRCELL2}
	Peform_block_Cell    ${AZQPNRCELL}
    Peform_block_Cell    ${AZQPNRCELL2}
    Peform_block_Cell    ${AWHQNNRCELL}
    Peform_block_Cell    ${OFEGSACELLNR2}
    Peform_block_Cell    ${OFEGSACELLNR5}
    Peform_block_Cell    ${OFEGSACELLLTE1}

Unblock all cells Except OFEGSA DSS cells
	Peform_unblock_Cell    ${AHHBCELL1}
	Peform_unblock_Cell    ${AHHBCELL2}
	Peform_unblock_Cell    ${AZRBCELL1}
	Peform_unblock_Cell    ${AZRBCELL2}
	Peform_unblock_Cell    ${AZRBCELL3}
	Peform_unblock_Cell    ${AZRBCELL4}
	Peform_unblock_Cell    ${AHPMDANRCELL}
	Peform_unblock_Cell    ${AHPMDANRCELL2}
	Peform_unblock_Cell    ${AZQPNRCELL}
        Peform_unblock_Cell    ${AZQPNRCELL2}
        Peform_unblock_Cell    ${AWHQNNRCELL}
        Peform_unblock_Cell    ${OFEGSACELLNR2}
        Peform_unblock_Cell    ${OFEGSACELLNR5}
        Peform_unblock_Cell    ${OFEGSACELLLTE1}

Login To Admin
    	coam.connect_to    bts_host=${BTS_ADDRESS}    username=${bts_username}    password=${bts_password}

Place Calls On Cells
	Prepare UE and Attach UE with default bearers
    sleep     15s
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_ul}
    sleep    30s
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    direction=${direction_ul}
    Sleep    100s
	coam.connect_to    bts_host=${BTS_ADDRESS}    username=${bts_username}    password=${bts_password}

SCF commissioning
	[Documentation]  ... Commissiioning BTS and checking BTS status
	[Arguments]    ${scf}
	Log to console    BTS commissioning is Ongoing
	${status}=    coam.perform_commissioning    scf_file=${scf}    timeout=2000
Emil decoding in csv to specific folder with callable filter
        [Arguments]    ${trace_id}
    ${dcap}=  Create Dictionary
    ...    host=10.41.209.118    port=443    username=utfuser    password=utfadmin!
    ${filter}=    Evaluate  lambda x: x.get('ZMQ/SCTP name') == "F1AP: InitialULRRCMessageTransfer"
    #emil.create_emil_converter_for_trace_id
    emil.Create Emil Converter For Source
    ...    name=emil_csv
    ...    client_filter=${filter}
    ...    file_path_pattern=samplefile/*.5gm
    ...    dcap=${dcap}
    ...    trace_id=${trace_id}
    ...    output_type=csv
    ...    output_directory=samplefile/trace_id_csv
    emil.setup    emil_csv
    emil.convert    emil_csv
    emil.teardown    emil_csv

DCAP_EMIL_DECODER
    [Documentation]     Emil Decode to CSV
    ...     1. extract data
    ...     2. filter 5gm file and add in Single folder
    ...     3. pass the isted file from dirct
    [Arguments]     ${Utf Folder Path}
    ...        ${UTF IP}=10.41.209.118
    #${Extracted Folder Path}    Extract UTF Downloaded File    utf file path=${Utf Folder Path}
    #${Extracted Folder Path}    /home/ute/Downloads/dcap
    ${List of emil file}    Filter Emil Log    Extracted Folder Path=/home/ute/Downloads/dcap
    ${dcap}  Create Dictionary
    ...    host=${UTF IP}    port=443    username=utfuser    password=utfadmin!
    ${Decoded_emil_folder}    os.Create Directory    path=${Utf Folder Path}/Decoded_emil_folder
    ${length}    Get Length    item=${List of emil file}
    FOR    ${5gmfile}    IN RANGE    ${length}
        BuiltIn.Set Test Variable   ${Decoded_emil_path}    ${Utf Folder Path}/Decoded_emil_folder
        ${5gm_file_Path}    BuiltIn.Convert To String    ${List of emil file}[${5gmfile}]
        Log    ${Utf Folder Path}/Decoded_emil_folder
        #emil.Create Emil Converter For Source    name=emil_json
        #...    file_path_pattern=${5gm_file_Path}
        #...    output_directory=${Decoded_emil_path}
        #...    dcap=${dcap}
        #emil.setup    emil_json
        #emil.convert    emil_json
        #emil.teardown    emil_json
        emil.Create Emil Converter For Source    name=emil_csv
        ...    file_path_pattern=${5gm_file_Path}
        ...    output_directory=${Decoded_emil_path}
        ...    dcap=${dcap}
        ...    output_type=csv
        emil.setup    emil_csv
        emil.convert    emil_csv
        emil.teardown    emil_csv
    END

    RETURN    ${Decoded_emil_path}

Extract UTF Downloaded File
    [Documentation]    Keyword Extract the ziped UTF downloaded file
    ...     : Using linux command can we able to achive unzip -r filename.zip
    ...     :Using Python standalone can be done same.
    ...     :Param ${utf file path}
    ...     :Return ${TARGET PATH}
    [Arguments]    ${utf file path}
	BuiltIn.Log To Console    message=[ INFO ]: Started UTF File Extraction
	BuiltIn.Set Test Variable    ${TARGET PATH}     ${utf file path}/Extracted
	os.Create Directory    path=${TARGET PATH}
    Sleep    10s
	${status}    FH.Unzip Folder    zip_file_path=${utf file path}    target_path=${TARGET PATH}
    Sleep    10s
    # Should Be Equal    ${status}    ${True}    [ ERROR ]: UTF File Not extracted Properly.
    BuiltIn.Log To Console    message=[ INFO ]: UTF File Extraction completed. Stored Path: ${TARGET PATH}
    RETURN    ${TARGET PATH}

Filter Emil Log
    [Documentation]    Filter Emil logs From UTF Extracted folder
    ...    :params ${Extracted Folder Path}
    [Arguments]    ${Extracted Folder Path}
    ${Listing Extracted item}    os.List Directory    ${Extracted Folder Path}
    ${Folder Name}    UTF Inner Folder Name
    @{Avaialble_control_plane_file}    BuiltIn.Create List
    FOR  ${item}  IN  @{Listing Extracted item}
        IF    ${item} == ${Folder Name}
            ${Inner Folders}    os.List Directories In Directory
            ...    path=${Extracted Folder Path}/${item}
            FOR    ${Inner Folder}   IN   @{Inner Folders}
                ${Files Inner Folder}    os.List Files In Directory
                ...    path=${Extracted Folder Path}/${item}/${Inner Folder}
                FOR   ${5gm File}    IN    @{Files Inner Folder}
                    BuiltIn.Convert To String    ${5gm File}
                    @{String_split}    Split String    string=${5gm File}    separator=.
                    IF   '${String_split}[-1]' == '5gm'
                        Collections.Append To List    ${Avaialble_control_plane_file}
                        ...    ${Extracted Folder Path}/${item}/${Inner Folder}/${5gm File}
                    END
                END
            END
            BREAK
        END
    END
    RETURN   @{Avaialble_control_plane_file}

UTF Inner Folder Name
    [Documentation]    To Find Inner Folder Name By Using DateTime Module
    ...    :Condition - In Case, UTF Folder Name Structure Changes Code Need to be Modify Accordingly.
    ...     As per Current status Inner Folder Structe Designed By Date Time.
    ...    : Return ${Folder name}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d
    # -%H:%M:%S
    Convert To String    ${time_stamp}
    ${list string}    String.Split String    ${time_stamp}    separator=-
    ${Folder Name}    BuiltIn.Catenate    ${list string}[0]${list string}[1]${list string}[2]
    RETURN    ${Folder Name}

Validate ActiveAlarms
    [Arguments]    @{fault_list}
    ${alr}=     coam.get_active_alarms
    log     ${alr}
    ${alr_num}=     coam.get_active_alarms_number
    Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        Log    ${alr}[${i}][faultName]
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        run keyword and continue on failure    should contain any    @{fault_list}    ${fltstring}
        #run keyword and continue on failure    should contain any    @{fault_list}    ${Alrstring}
    END

Validate Historic_Alarms
    [Arguments]    @{fault_list}
    ${alr}=     coam.get_active_alarms
    log     ${alr}
    ${alr_num}=     coam.Get Historic Alarms Number
    Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        Log    ${alr}[${i}][faultName]
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        run keyword and continue on failure    should contain any    @{fault_list}    ${fltstring}
        #run keyword and continue on failure    should contain any    @{fault_list}    ${Alrstring}
    END

DssPreconditions
    [Arguments]    ${DSS_SCF_FILE}
    Log  ==== Preconditions ====  console=True
    Set BTS And Cell ID CRM String     ${DSS_SCF_FILE}
    Log  = Preconditions passed =  console=True

Set BTS And Cell ID CRM String
    [Arguments]    ${DSS_SCF_FILE}
    #${lnbts_id} =    get_id_for_current     class_name=LNBTS
    #${nrbts_id} =    get_id_for_current     class_name=NRBTS
    #${enb_hex} =    Convert To Hex  ${lnbts_id}
    #${gnb_hex} =    Convert To Hex  ${nrbts_id}
    ${lte_lcr_id} =    Get Parameter Value From SCF  ${DSS_SCF_FILE}  LNCEL  LNCEL-${LTE_CELL_ID}  /p[@name='lcrId']
    ...  dist_name_substring=True
    ${nr_lcr_id} =    Get Parameter Value From SCF  ${DSS_SCF_FILE}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='lcrId']
   ...  dist_name_substring=True
    ${lte_lcr_id_hex} =    Convert To Hex  ${lte_lcr_id}
    ${nr_lcr_id_hex} =    Convert To Hex  ${nr_lcr_id}
    ${dss_string} =    Set Variable  ${enb_hex}c${lte_lcr_id_hex}g${gnb_hex}c${nr_lcr_id_hex}
    Set Test Variable    ${DSS_STRING}    ${dss_string}

Wait For CRM Message In Syslog
    #[Arguments]    ${regexpattern}    ${var_start_sys}
    #${tmp}=    Convert To Number    ${inputtime}
    #${regexpattern}=    dlAllocationSequenceNumber
    #${var_start_sys}=    dlAllocationSequenceNumber
    ${rc}    ${output}=   os.Run And Return Rc And Output
    ...    find ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/syslogs_DSS/btslog -maxdepth 1 -name syslog_files.tgz
    ${rc}    ${extracted_syslogs}=    os.Run And Return Rc And Output    tar -xzvf ${output}
    ${files_list}=    String.Split To Lines    ${output}
    #${crm}=       Run       grep \"${var_start_sys}\" ${extracted_syslogs}/*.LOG
    log    ${files_list}
    #${offlineindicationregex}=  Get Regexp Matches  ${crm}  ${regexpattern}
