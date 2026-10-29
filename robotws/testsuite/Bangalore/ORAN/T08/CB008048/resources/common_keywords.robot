*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy
...   contact: kancham.reddy_madhuri_reddy@nokia.com
...   Description: Test Suite
...   "Test Case coverage in Documentation section for each case respectively"

Library     SSHLibrary
Library     BuiltIn
Library     Process
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Library     taf.nms.netact    WITH NAME    NMS
Library     taf.hw.pdu    WITH NAME    pdu
Library     taf.file.pack
Library     taf.analyzer.netconf		WITH NAME	Netconf
Library     taf.collectors.simple    WITH NAME    simple
Library     ./../../../../resources/python/AIC_LogCapture.py
Library		./../../../resources/python/ta_ultracaller/


*** Variables ***
${host_vDU}    10.43.196.131
${host_vCU}    10.43.196.130
${PORT}    443
${USER}    Nemuadmin
${PWD}    Nokia@123
${vDU_SCF_PATH}    /home/ute/MRBTS_30004/SCF/SCF_vDU_MRBTS_30004.xml
${vCU_SCF_PATH}    /home/ute/MRBTS_30004/SCF/SCF_vCU_MRBTS_30004.xml
${srvc_name}    cmwas
${NetAct_Node}    10.43.48.159
${NetAct_ssh_uname}    omc
${NetAct_ssh_pwd}    Medsql!_1893
${NETACT_NAME}    srnclab1046
${vDU_NODE_HOST}    10.58.230.134
${vDU_NODE_USER}    core
${vDU_NODE_PASSWORD}     system123
${vDU_NAMESPACE}    cran22
${vdu_connection}       vDU
${vcu_connection}       vCU
${rannic_dn}    MRBTS-30004/EQM_R-1/APEQM_R-1/RNICMOD_R-1
${netconf_path}    /home/ute/results/CB008048
${netconf_file}    RMOD_L-1_NetconfRpcMessageTrace.log
${throughput_dl}=   300
${throughput_ul}=   60
@{UE_alias}=  UE1
@{direction_dl}=  dl
@{direction_ul}=  ul
${timeout}      100
@{deviation_dl}=  50
@{deviation_ul}=  50
@{capabilities}=     Legacy_1
@{data_transfer_protocol}       UDP
${rmods_list}=    Create List    1    3

*** Keywords ***
Test Setup
    Log to console    \n--Cloud environment Setup--
    Setup_VDU
    Setup_VCU
    pdu.setup_pdu     model=RRB    host=${pdu_host_ip}    alias=RRB
    Get_active_alarms_vDU
    Prepare_MantaRay_Environment
    Check vDU Cell status

Test Teardown
    Log to console    \n--Cloud environment Teardown--
    Snapshot_vDU
    Snapshot_vCU
    Run Keyword and ignore Error    pdu.power_on    port=${portnum}    pdu_device=RRB
    pdu.teardown_pdu      pdu_device=RRB
    Run Keyword and ignore Error    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/MNL-1    autoInstallOfPredefinedRu    true
    Run Keyword and ignore Error    Perform_Parameter_Recommissioning_vDU
    ...    ${mrbtsid}/EQM-1/APEQM-1/${rmod_id}    serialNumberPlanned    ${correctSNO}
    Wait until keyword succeeds    12m    10s    Check vDU Cell status
    Get_active_alarms_vDU
    admindu.disconnect    vdu_connection=${vdu_connection}
    admincu.disconnect    connection=vCU
    Teardown_MantaRay_Environment

Setup_VDU
    Log to console    \n--Connecting vDU--
    admindu.connect_to    host=${host_vDU}    port=${PORT}    connection_name=${vdu_connection}
    ...    username=${USER}    password=${PWD}    secure=True    timeout=300
    Log to console    \n--vDU is connected--

Setup_VCU
    Log to console    \n--Connecting vCU--
    admincu.connect_to    host=${host_vCU}    port=${PORT}    username=${USER}
    ...    password=${PWD}    secure=True    alias=vCU    timeout=300
    Log to console    \n--vCU is connected--

Prepare_MantaRay_Environment
    [Documentation]    Create an instance of SshNode class, establishes temporary ssh connection as first verification step
	...     and then checks status of given service.
    NMS.add_node    service_name=${srvc_name}    hostname=${NetAct_Node}    username=${NetAct_ssh_uname}
	...    password=${NetAct_ssh_pwd}    alias=${NETACT_NAME}
    ${url}=    NMS.detect_web_url    alias=${NETACT_NAME}
    LOG    Detected web url is:${url}
    ${Added_url}=    NMS.add_web_url    web_url=${url}    username=${NetAct_ssh_uname}    password=${NetAct_ssh_pwd}    alias=${NETACT_NAME}
    LOG    Added web url is:${Added_url}

Teardown_MantaRay_Environment
    NMS.delete_node    service_name=${srvc_name}    alias=${NETACT_NAME}
    NMS.clean_all    alias=${NETACT_NAME}

Perform_vDU__SCF_Commission
    ${result}=    admindu.upload_plan    path_to_plan_file=${vDU_SCF_PATH}    plan_name=plan_vDU_commission
    ...    timeout=300    vdu_connection=${vdu_connection}
    sleep    120s
    LOG to console    \n--vDU SCF Upload plan is success--
    LOG    ${result}
    LOG    ${result['plan_id']}
    ${vDU_plan_id}=    Set Variable    ${result['plan_id']}
    LOG    ${vDU_plan_id}
    admindu.validate_plan    plan_id=${vDU_plan_id}    timeout=300    vdu_connection=${vdu_connection}
    LOG to console    \n--vDU SCF Validate plan is success--
    sleep    60s
    admindu.activate_plan    plan_id=${vDU_plan_id}    timeout=300    vdu_connection=${vdu_connection}
    LOG to console    \n--vDU SCF Activate plan is success--
    sleep    300s

Perform_vCU__SCF_Commission
    ${result}=    admincu.upload_plan_file    path_to_plan_file=${vCU_SCF_PATH}    plan_name=plan_vCU_commission
    ...    timeout=300    connection=vCU
    sleep    120s
    LOG to console    \n--vCU SCF Upload plan is success--
    LOG    ${result}
    LOG    ${result['plan_id']}
    ${vCU_plan_id}=    Set Variable    ${result['plan_id']}
    admincu.plan_validation    plan_id=${vCU_plan_id}    connection=vCU
    LOG to console    \n--vCU SCF Validate plan is success--
    sleep    120s
    admincu.plan_activation    plan_id=${vCU_plan_id}    timeout=300    connection=vCU
    LOG to console    \n--vCU SCF Activate plan is success--
    sleep    200s

ResetVdu
    Log to console    \nVDU reset ongoing
    admindu.reset_vdu    timeout=600    vdu_connection=${vdu_connection}
    Log to console    \nVDU reset completed

RANNIC_Reset
    admindu.reset_rannic    rannic_r_dn=${rannic_dn}    timeout=60    vdu_connection=${vdu_connection}

Cells_lock_unlock
    ${cells_list}=    Create List    1    2
    admincu.lock_cells    cell_ids=${cells_list}    connection=${vcu_connection}
    Log to console    \n--All cells are locked--
    sleep    60s
    admincu.unlock_cells    cell_ids=${cells_list}    connection=${vcu_connection}
    Log to console    \n--All cells are unlocked--

vDU_lock_unlock
    ${du_id}=    Create List    1
    admincu.lock_du    du_id=${du_id}    connection=${vcu_connection}
    Log to console    \n--vDU is locked--
    sleep    60s
    admincu.unlock_du    du_id=${du_id}    connection=${vcu_connection}
    Log to console    \n--vDU is unlocked--

Snapshot_vDU
    Log to console    \n--DU Snapshot collection started--
    create directory    ${out}/Snapshot_vDU/
    admindu.get_local_snapshot    directory=${out}/Snapshot_vDU/    compressed_or_not=True
    ...    request_timeout=30    operation_timeout=600     vdu_connection=${vdu_connection}
    Log to console    \n--DU Snapshot collection Ended--

Snapshot_vCU
    Log to console    \n--CU Snapshot collection started--
    create directory    ${out}/Snapshot_vCU/
    admincu.get_local_snapshot    directory=${out}/Snapshot_vCU/
    ...    request_timeout=30    operation_timeout=600     connection=vCU
    Log to console    \n--CU Snapshot collection Ended--

Attach UE and start data transfer
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Log to console    \nData transfer started
    ta_ultracaller.start_datatransfer   ${UE_alias}     ${data_transfer_protocol}     direction=@{direction_dl}
    sleep    60s
    Log to console    \nData transfer completed
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Run Keyword And Ignore error    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}

Check vDU Cell status
    [Documentation]    Check the vDU cell status
    ${vDU_Cell_status}=    admindu.get_vdu_cells_status    vdu_connection=${vdu_connection}    timeout=300
    log to console    ${vDU_Cell_status[0]['availability_status']}
    log    ${vDU_Cell_status[0]['availability_status']}
    Log    All cell statuses: ${vDU_Cell_status}
    FOR    ${cell}    IN    @{vDU_Cell_status}
        Should Be Equal As Strings    ${cell['availability_status']}    on line
        Log    Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
	END
    ${offline_cells}=    Evaluate    [cell for cell in ${vDU_Cell_status} if cell['availability_status'] != 'on line']
    Run Keyword If    len(${offline_cells}) == 0    Log    All cells are online
    Log To Console    Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
    [Return]    ${vDU_Cell_status[0]['availability_status']}

ORU Reset
    [Documentation]     Reset Radio Modules with IDs given by rmods_list.
	Log to console    \n--O-RU reset started--\n
    ${Res}=    admindu.reset_rmods    rmods_list=${rmods_list}    reset_reason=user
    ...    graceful_cell_shutdown=True    timeout=500    vdu_connection=${vdu_connection}    raw=True    wait_for_completion=true
    Log to console    \n--O-RU reset Completed--\n
    [Return]    ${Res}

ORU Reset with status
	[Documentation]    Gets status of the ‘reset_rmods’ operation
	Log to console    \n--O-RU reset with status Fetch started--\n
	${Reset_status}=    ORU Reset
    LOG    ${Reset_status}
    LOG    ${Reset_status['id']}
    ${op_id}=    Set Variable    ${Reset_status['id']}
    Log to console    \n--Operation ID of ORU-RESET is: ${op_id}--\n
	${Status}=    admindu.get_reset_rmods_operation_status    operation_id=${op_id}   timeout=300
	...    vdu_connection=${vdu_connection}    raw=True
	LOG    ${Status}
	Wait until keyword succeeds    15min    10sec    Check vDU Cell status

Delta_Commissioning
    [Arguments]    ${DELTA_FILE}
    Log to console    \n--Delta commissioning started--
    admindu.perform_delta_recommissioning    delta_file=${DELTA_FILE}    timeout=300   wait_for_completion=True    vdu_connection=${vdu_connection}
    Log to console    \n--Delta commissioning completed--

Stop_and_Collect_Syslog_Monitoring
    [Arguments]
    Log to Console     \n-----> Stop and Collect Syslog Mon <-----
	create directory        ${out}/Syslog_vDU/
    AIC Stop Collect vDU Syslog     ${out}/Syslog_vDU/    ${vDU_NODE_HOST}    ${vDU_NODE_USER}
    ...    ${vDU_NODE_PASSWORD}    ${vDU_NAMESPACE}

Search Text In Unzipped Syslogs With Multiple Patterns
    [Arguments]    @{PATTERNS}
    [Documentation]    Unzip syslogs, then search for multiple patterns in the unzipped files.

	${log_files}    unzip_syslog

    Log to Console    --- Searching patterns in unzipped syslogs ---
    ${match_found_files}=    Create List

    FOR    ${file}    IN    @{log_files}
        FOR    ${pattern}    IN    @{PATTERNS}
            ${result}=    Run Process    grep    -H    ${pattern}    ${extracted_path}/${file}    shell=True    stderr=ignore
            ${output}=    Set Variable    ${result.stdout.strip()}
            ${output}=    Replace String    ${output}    \n    ${EMPTY}
            # Log and store matches
            Run Keyword If    '${output}' != ''     Log To Console    Match found for pattern "${pattern}" in file: ${file} with line(s): ${output}
            Run Keyword If    '${output}' != ''    Log    Match found for pattern "${pattern}" in file: ${file} with line(s): ${output}    INFO
            Run Keyword If    '${output}' != ''    Append To List    ${match_found_files}    ${file}
            Run Keyword If    '${output}' == ''    Log    Pattern "${pattern}" not found in file: ${file}    WARN
        END
    END

    Run Keyword If    ${match_found_files} == []    Fail    No patterns were found in any files
    Log    Patterns found in files: ${match_found_files}

unzip_syslog
    [Documentation]        Unzipping syslogs
    Log to Console     --- Unzip of syslog Started ---
    ${path1}    Set Variable    ${out}/Syslog_vDU/
    ${extracted_path}    Set Variable    ${path1}Extracted/
	Set Global variable    ${extracted_path}
    create directory    ${extracted_path}
	${date}    Get Current Date    result_format=%Y%m%d
    ${files}    os.List Files In Directory    ${path1}
	Log to console    --- Starting to Unzip SYSLOG files ---
	FOR    ${zip}    IN    @{files}
		File_Should_Have_Extension    ${path1}${zip}
		Start Process    unzip    -q    ${path1}${zip}    -d    ${extracted_path}
		sleep    5
	END
	Log to console    --- Unzipping is Completed ---
    ${log_files}    Select_syslog_Files    ${extracted_path}
    Log to Console    --- Selected Syslog Files: ${log_files} ---
    [Return]    ${log_files}

Select_syslog_Files
    [Arguments]    ${directory}    ${prefix}=syslog_
    [Documentation]    Select syslog files from the extracted directory.
    ${selected_files}=    Create List
    ${all_files}=    os.List Files In Directory    ${directory}
	Log    All files found in ${directory}: ${all_files}
    FOR    ${file}    IN    @{all_files}
		${file_name}=    Split String    ${file}    ${/}    # Split by the directory separator
        ${file_name}=    Get From List    ${file_name}    -1    # Get the last element (filename)
		Log    Checking file: ${file_name}
		${file_pattern}    Set Variable
		Run Keyword If    '${file_name}'.startswith('${prefix}')    Append To List    ${selected_files}    ${file}
    END
	Log    Selected files with prefix ${prefix}: ${selected_files}
    [Return]    ${selected_files}

File_Should_Have_Extension
    [Arguments]    ${FILE_PATH}
	${ext}		Split Extension 		${FILE_PATH}
	log to console		${ext}
	[Return]		${ext}