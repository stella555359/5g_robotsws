*** Settings ***

Documentation    User define Keywords


Library		String
Library		Process
Library     BuiltIn
Library		DateTime
Library     Collections
Library     OperatingSystem      WITH NAME    os
Library     taf.ue
Library     taf.sw.dcap.rd       WITH NAME    rd
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.file.pack
Library     taf.ul.alarms_watchdog   WITH NAME    alarm
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.sw.scout    WITH NAME    scout


*** Variables ***
${BTS_ADDRESS}     192.168.255.129
${log_alias}    btslog
${str}=  SBTS00
${LOGS_PATH}=    /home/ute/logs
${VM_HOST_IP}=  10.41.209.165
${VM_username}=  ute
${VM_Password}=  BT5l@bus3rl0g1n
${BTSLOG_Path_for_validation}               /tmp/btslog2
&{BTS_Details}                     bts_host=192.168.255.129
...                                bts_port=443
...                                username=Nemuadmin
...                                password=nemuuser
...                                use_ssl=True
...                                update_interval=5000
...                                admin_api_log_dir=${EXECDIR}
...                                name=default
...                                bundle_path=None
...                                release=SBTS24r2
${btsremoteip}=    10.63.48.81
${BTS_M_plane_ip}           10.63.48.81                                               # BTS M PLane IP
${DCAP_host}                10.41.209.114                                             #DCAP server IP
${Windows_user}             inbabtslabuser                                            # Windows UE PC username
${Windows_pass}             BT5l@bus3rl0g1n
${dcap_log_timeout}=	800s
${btsuserremote}=    Nemuadmin
${btspassremote}=    nemuuser
@{Required_bts_status} =   Test    OnAir
@{CellState_NR} =   energySaving    notEnergySaving
@{CellState_LTE} =   energySaving    notEnergySaving
@{ORUState} =   AWAKE    SLEEP
${ABSTRACT_LIB_CONFIG}=    /home/ute/testline_configuration1/ta_ue_config.yaml
${SCFpath}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG08/CB013240/SCF/CB013240_SCF.xml
${input_File}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG08/CB013240/SCF/SavedSCF/CB013240_SCF.xml
${output_File}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG08/CB013240/SCF/output/CB013240_updated_SCF.xml
${savedSCF_path}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG08/CB013240/SCF/output/try
${filename}=    modified_CB013240_SCF1.xml
${cellSoduration}=    15
@{UE_alias}=            UE1
@{capabilities}=        Legacy_1
${SCF_Pre}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB007814/7814_SG02/SCF_Files/PreSetup_Config.xml
${LTE_dist}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1236/LNCEL_R-0
${MRBTS-ID}=     MRBTS-1236
${LNBTS-ID}=     LNBTS-1236
${LNCEL-ID}=    LNCEL-0
${MCC-No}=    MCC-001
${MNC-No}=    MNC-01
${LNCELL_avail}=    LTE_Cell_Avail
${counter_ids2}=    M8020C1,M8020C4,M8020C7,M8020C8
@{counter_list1}    M8020C1    M8020C4    M8020C7
@{counter_list2} =  M55601C00501   M55601C00002    M55601C01001    M55601C00502     M55601C01002    M55601C00503
${counter_ids1}=     M55601C00501,M55601C00002,M55601C01001,M55601C00502,M55601C01002,M55601C00503
${NRCELL_distname}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1236/NRCELL_R-1
${NRBTS-ID}=   NRBTS-1236
${NRCELL-ID}=    NRCELL-1
${NCELL_avail}=     NCAV
${BTS_path}    /home/ute/results
${step}       = /home/ute/logs
${alias}      admin_1
${OUT_LOG_PATH}     = /home/ute/results/
${backup_filename}=    1236TL_backup_SCF.xml
${backupSCF_path}=     /home/ute/robotws/testsuite/Bangalore/ORAN/SG08/CB013240/SCF/backup



*** Keywords ***
Login To Admin
    	coam.setup_admin    bts_host=${BTS_ADDRESS}    alias=${alias}    admin_api_log_dir=/tmp

Get Time and update SCF for Power Saving Parameters

Validate_BTS_STATUS
	[Arguments]    ${Required_BTS_Status}
	Run Keyword And Ignore Error    admin.connect_to
    ${bts_status}=  admin.get_bts_statuses    timeout=100
	${var}  Set Variable    ${bts_status['proceduralState']}
	${str}  BuiltIn.Convert To String    ${var}
	Should Be Equal    ${str}    ${Required_BTS_Status}

Check Energy saving State NR
	[Arguments]    ${CellState}
	Run Keyword And Ignore Error    admin.connect_to
	${CellEnergySavingState}=    admin.get_parameters
	...    dist_name=${NRCELL_distname}
 	...    parameter=energySavingState
    	...    timeout=300
	${state}  Set Variable    ${CellEnergySavingState['energySavingState']}
	${compare}  BuiltIn.Convert To String    ${state}
	Log To Console    \nCELL STATE IS : ${compare}
	Run Keyword And Continue On Failure    Should Be Equal    ${compare}    ${CellState}

Check Energy saving State
	[Arguments]    ${CellState}
	Run Keyword And Ignore Error    admin.connect_to    name=${alias}
	${CellEnergySavingState}=    admin.get_parameters
	...    dist_name=${LTE_dist}
 	...    parameter=energySavingState
	...    connection=${alias}
    	...    timeout=300
	${state}  Set Variable    ${CellEnergySavingState['energySavingState']}
	${compare}  BuiltIn.Convert To String    ${state}
	Log To Console    \nCELL STATE IS : ${compare}
	Run Keyword And Continue On Failure    Should Be Equal    ${compare}    ${CellState}

Download SCF
    [Documentation]    ... Downloading SCF
    admin.get_current_scf_file    file_name=${filename}    timeout=60    local_dir_path=${savedSCF_path}    connection=${alias}
    os.File Should Exist    ${savedSCF_path}/${filename}
    Log To Console    SCF Downloaded
    Log To Console    SCF file name is ${filename}
    [Return]    ${filename}

Stops Btslogs from Local machine
    	[Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d

    	Run Keyword And Continue On Failure     core.stop_collectors      btslog
    	Run Keyword And Continue On Failure     core.collect_collectors      btslog
    	Run Keyword And Continue On Failure    core.teardown_collectors      btslog

Start Btslogs from Local machine
    	[Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
    	...

    	btslog.create_btslog_collector    btslog
    	...    log_dir=/tmp/btslog2
    	core.setup_collectors     btslog
    	core.start_collectors     btslog
    	core.Set Suite Alias    btslog

Link SCOUT SCF to Configuration ID for Reporting
    	[Documentation]
    	...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    	...
    	...    Example:
    	...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    	...
    	...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    	...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    	[Arguments]    ${node_type}=enb    ${tl_name_only}=10_2_SG4MRBTS970
    	${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    	...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    	...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    	Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    	${scout_testline_name}=    Set Variable    ${tl_name_only}
    	${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    	${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    	Set Tags  ${TC_ID}

Request Scout SCF
    	[Arguments]   ${scout_testline_name}
    	[Documentation]    :Author: Michele
    	...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    	scout.setup_scout  scout_testline_name=${scout_testline_name}
    	${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    	scout.teardown_scout_api
    	[Return]   ${external_scf_id}

Get_Pre_Active_alarms
    	[Documentation]    Active Alarms
    	admin.connect_to
    	${Pre_Active_Alarm}    admin.get_active_alarms

Get_Post_Active_alarms
    	[Documentation]    Active Alarms
    	${Post_Active_Alarm}   admin.get_active_alarms

Create_DCAP_Logs_Path
    	[Documentation]     Create testcase folder in testpc
		${SUITE NAME}    Set Variable    ${SUITE NAME}
        ${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
    	${val1}    Run Keyword And Return Status    LOG    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAP_Logs
    	os.create directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAP_Logs

Dcap Start Trace
    	[Documentation]     Start DCAP logs with custom filter
    	Create_DCAP_Logs_Path
    	dcap.connect_to  host=${dcaphost}   port=443    username=dcapuser   password=dcapadmin!
    	...              rd_version=dcapv3  secure=True
    	&{bts1_info}   create dictionary  host=${btsremoteip}    port=443    username=${btsuserremote}    password=${btspassremote}
    	${output}    dcap.start_trace     duration=-1    bts=&{bts1_info}    gnb_trace_profile=dcap-lite-default
		...          bts_trace_profile=dcap-lite-default
		...          enb_trace_profile=dcap-lite-default
		...	     Wait_for_activation=${True}
    	Sleep       300s      reason=Wait for DCAP start    #400
    	${START_TRACE_ID}      Get from Dictionary    ${output}    tracer_id
    	Set Suite Variable  ${START_TRACE_ID}
    	LOG      DCAP log collection has been started in the gNB

Dcap Stop Trace
		[Documentation]     Stops DCAP and collect logs
		Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
		dcap.stop_trace    trace_id=${START_TRACE_ID}
		Sleep    60
		LOG     DCAP logging stopped
		dcap.get_results    result_id=${START_TRACE_ID}    target_dir=${SUITE NAME}${Folder}/${LOGS_PATH}/${TEST_NAME}/DCAP_Logs
		...                                                timeout=1200s

Get Date
    	[Documentation]     Get date to create testcase folder
    	${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    	${date}    Convert to String    ${date}
    	Set global variable    ${Folder}    ${date}

Collect_Alarms
		Wait Until Keyword Succeeds    2min    30s    admin.collect_raw_alarm_history_file        target_file_name=${out}/AllAlarms.json

Collect_ImSnapshot
		Wait Until Keyword Succeeds    2min    30s    admin.collect_im_snapshot        target_file_name=${out}/ImSnapshot.ims2

Collect_SCF
	admin.get_current_scf_file    file_name=${backup_filename}    timeout=60    local_dir_path=${backupSCF_path}    connection=${alias}
    os.File Should Exist    ${backupSCF_path}/${backup_filename}
    Log To Console    SCF Downloaded
    Log To Console    SCF file name is ${backup_filename}
    [Return]    ${backup_filename}

Test Setup
		Run Keywords     Login To Admin
		Create testcase folder
		${SUITE NAME}    Set Variable    ${SUITE NAME}
    	${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
		os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    	Run Keyword And Ignore Error    Start Btslogs from Local machine
		#SCF commissioning    ${SCF_TDS}
    	Get_Pre_Active_alarms
		#BuiltIn.Run Keyword And Continue On Failure    Dcap Start Trace
		#Set QC_Tag depending on SW version

Test Teardown
        ${Active_alarm}    admin.get_active_alarms       connection=${alias}
        LOG     ${Active_alarm}
		Log to console    \n Collect snapshot\n
		Wait Until Keyword Succeeds    5min    120s    admin.collect_snapshot    target_file_name=${out}/${step}/Snapshot_${step}.zip
        ...             connection=${alias}

Create testcase folder
    	[Documentation]     Create testcase folder in testpc
		${SUITE NAME}    Set Variable    ${SUITE NAME}
        ${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
    	${val}    Run Keyword And Return Status    LOG    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    	os.create directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    	${out}    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    	set test variable    ${out}

Suite_Setup
		Log to console  --Test Started--\n
    	${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
		${CurrentDate}=    Convert to String     ${CurrentDate}
		${SUITE NAME}    Set Variable    ${SUITE NAME}
		${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
		os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    	Set global variable    ${Date}    ${CurrentDate}
		${out}    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/logfolder
		Set global variable    ${out}

Counter Verification
    Log to console    \n--Energy saving counter validation step--\n
    ${log_entry} =    admin.get_pm_counters    counter_ids=${counter_ids2}    connection=${alias}              #counters for LTE
    ...    timeout=300
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list1}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry['BTS']['${MRBTS-ID}']['${LNBTS-ID}']['${LNCEL-ID}']['${MCC-No}']['${MNC-No}']['${LNCELL_avail}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        ${value}=    evaluate    ${pi_value}!=0
        should be true    ${value}
        Run Keyword If    ${pi_value}!=0
        ...    Log    Value is within range
        ...    ELSE    Fail    Value is not within the specified range
        Log    ${pi_value}
        Log to console    \n--${pi_value}--\n
    END

Connect_to_BTS_check_the_state
       	${bts_state}=     admin.get_mrbts_state
		BuiltIn.Log       [INFO] BTS STATE : ${bts_state}

SCF commissioning
		[Documentation]  ... Commissiioning BTS and checking BTS status
		[Arguments]    ${scf}
		Log to console    BTS commissioning is Ongoing
		${status}=    admin.perform_commissioning    scf_file=${scf}    timeout=2000    connection=${alias}

Counter Verification NR
    Log to console    \n--Energy saving counter validation step--\n
    ${log_entry} =    admin.get_pm_counters    counter_ids=${counter_ids1}    connection=${alias}               #counters for NR
    ...    timeout=300
	...   connection=${alias}
    log    ${log_entry}
	FOR    ${pi_id}    IN    ${counter_list2}
    Log    ${pi_id}
    ${count}=    set variable    ${log_entry['BTS']['${MRBTS-ID}']['${NRBTS-ID}']['${NRCELL-ID}']['${NCELL_avail}']}
    ${a}=    get dictionary values    ${count}
    ${pi_value}=    Set Variable    ${a[-1]}
    ${value}=    evaluate    ${pi_value}!=0
    should be true    ${value}
    Run Keyword If    ${pi_value}!=0
    ...    Log    Value is within range
    ...    ELSE
    ...    Fail    Value is not within the specified range
    Log    ${pi_value}
    Log to console    \n--${pi_value}--\n
    END

Suite_Teardown
        admin.perform_commissioning    scf_file=${backupSCF_path}/${backup_filename}    timeout=2000    connection=${alias}
    	admin.teardown_all_aliases_for_admin
        interface.Common step trigger
		Check resource hanging
        Log to console  /n -- End of Test --/n

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
	...    /home/ute/robotws/testsuite/Bangalore/ORAN/T07/CB009447_CRT/TC1/hanging.py ${out}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI