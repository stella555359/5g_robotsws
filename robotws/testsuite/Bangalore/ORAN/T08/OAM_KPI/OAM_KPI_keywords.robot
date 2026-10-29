*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy
...   contact: kancham.reddy_madhuri_reddy@nokia.com
...   Description: Test Suite
...   "Test Case coverage in Documentation section for each case respectively"

Library    BuiltIn
Library    Collections
Library    String
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    RequestsLibrary
Library    Process
Library     OperatingSystem     WITH NAME    os
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Library     taf.nms.netact    WITH NAME    NMS
Library     taf.file.pack
Library     taf.analyzer.netconf		WITH NAME	Netconf
Library     taf.collectors.simple    WITH NAME    simple
Library     ./../../T02/resources/python/snapshotFileIdentifier.py
Library    ../../resources/python/netconf_validation.py
Library    ./../../../resources/python/AIC_LogCapture.py
Library    ./../../resources/python/ta_ultracaller/

*** Variables ***
${host_vDU}    10.43.196.131
${host_vCU}    10.43.196.130
${PORT}    443
${USER}    Nemuadmin
${PWD}    Nokia@123
${vDU_NODE_HOST}    10.58.230.134
${vDU_NODE_USER}    core
${vDU_NODE_PASSWORD}     system123
${vDU_NAMESPACE}    vdu01
${vdu_connection}       vDU
${vcu_connection}       vCU
${iteration}    2
${netconf_file}    RMOD_L-1_NetconfRpcMessageTrace.log
${timezone}=     +00:00
${MO_NAME}=    PLMN-PLMN/MRBTS-30004
@{PATTERNS}     authenticationMethodSshServer: PublicKeyBased    fjncuser0    fjnuser0
${rpc_get}    get
${rpc_reply}    software-inventory
${subtag}    build-name
${active}    active
${regexpattern}    <..........T..:..:..
${var_start_sys}    TimeBucketMgr cell down
${var_end_sys}    Setup finished with: Success
${block_request}    cells/operations/block request-id
${unblock_request}    cells/operations/unblock request-id
${kpi17a_time}    20
${kpi51a_time}    240
${kpi52_time}    360
${throughput_dl}=   300
${throughput_ul}=   60
@{UE_alias}=  UE1
@{direction_dl}=  dl
@{direction_ul}=  ul
${timeout}      100
@{deviation_dl}=  50
@{deviation_ul}=  50
@{capabilities}=     Legacy_1
@{data_transfer_protocol}       TCP

*** Keywords ***
Test Setup
    Log to console    \n--Cloud environment Setup--
    Setup_VDU
    Setup_VCU
    Get_active_alarms_vDU
    Check vDU Cell status

Test Teardown
    Log to console    \n--Cloud environment Teardown--
    Snapshot_vDU    ${out}
    Snapshot_vCU    ${out}
    Get_active_alarms_vDU
    admindu.disconnect    vdu_connection=${vdu_connection}
    admincu.disconnect    connection=vCU

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

Attach UE and start data transfer
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Log to console    \nData transfer started
    ta_ultracaller.start_datatransfer   ${UE_alias}     ${data_transfer_protocol}     direction=@{direction_dl}
    sleep    30s
    Log to console    \nData transfer completed
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Run Keyword And Ignore error    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}

ResetVdu
    Log to console    \nVDU reset ongoing
    admindu.reset_vdu    timeout=600    vdu_connection=${vdu_connection}
    Log to console    \nVDU reset completed

ORU Reset
    [Documentation]     Reset Radio Modules with IDs given by rmods_list.
	Log to console    \n--O-RU reset started--\n
    ${rmods_list}=    Create List    1
    ${Res}=    admindu.reset_rmods    rmods_list=${rmods_list}    reset_reason=user
    ...    graceful_cell_shutdown=True    timeout=500    vdu_connection=${vdu_connection}    raw=True    wait_for_completion=true
    Log to console    \n--O-RU reset Completed--\n
    [Return]    ${Res}

ORU Reset with status
    [Documentation]    Gets status of the reset_rmods operation
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

Verification of Reset KPI#52
    [Documentation]    Verification TCP DL UL data transfer after multiple ORU/vDU resets via WEBEM
    [Tags]  TC1
    Log to console    \n--Verification of Reset KPI#52--\n
    Check vDU Cell status
    ${kpi_timers}=    Create List
    FOR    ${i}    IN RANGE    ${iteration}
        Log to console    \n--vDU reset ${i}--
        os.Create Directory    ${out}/Iteration${i}
        ${log_path}=    Set Variable    ${out}/Iteration${i}
        ResetVdu
        Wait until keyword succeeds    10min    10sec    Check vDU Cell status
        Get_active_alarms_vDU
        Snapshot_vDU    ${log_path}
#        Extract syslogs from snapshot    ${log_path}
        ${timer}=    Validate messages in syslogs and calculate time difference    ${out}/syslogs/
        ...    ${regexpattern}    ${var_start_sys}     ${var_end_sys}    ${kpi52_time}
        Append To List    ${kpi_timers}    ${timer}
        Attach UE and start data transfer
    END
    ${max}=    Evaluate    max(${kpi_timers})
    Log to console    \n--Max time taken for vdu reset is ${max}--
    ${sum}=    Evaluate    sum(${kpi_timers})
    ${avg}=    Evaluate    ${sum} / ${iteration}
    Log to console    \n--Average time taken for oru reset is ${avg}--

Verification of O-RU reset KPI#51a
    [Documentation]    Verification TCP DL UL data transfer after multiple ORU/vDU resets via WEBEM
    [Tags]  TC1
    Log to console    \n--Verification of O-RU reset KPI#51a--\n
    Check vDU Cell status
    FOR    ${i}    IN RANGE    ${iteration}
        Log to console    \n--vDU reset ${i}--
        os.Create Directory    ${out}/Iteration${i}
        ${log_path}=    Set Variable    ${out}/Iteration${i}
        ORU reset with status
        Wait until keyword succeeds    10min    10sec    Check vDU Cell status
        Get_active_alarms_vDU
        Snapshot_vDU    ${log_path}
#        Extract syslogs from snapshot    ${log_path}
        ${timer}=    Validate messages in syslogs and calculate time difference    ${out}/syslogs/
        ...    ${regexpattern}    ${var_start_sys}     ${var_end_sys}    ${kpi52_time}
        Append To List    ${kpi_timers}    ${timer}
        Attach UE and start data transfer
    END
    ${max}=    Evaluate    max(${kpi_timers})
    Log to console    \n--Max time taken for oru reset is ${max}--
    ${sum}=    Evaluate    sum(${kpi_timers})
    ${avg}=    Evaluate    ${sum} / ${iteration}
    Log to console    \n--Average time taken for oru reset is ${avg}--

Verification of Cell block/unblock KPI#17a
    [Tags]  TC1
    Log to console    \n--Verification of Cell block/unblock KPI#17a--\n
    Check vDU Cell status
    ${block_timers}=    Create List
    ${unblock_timers}=    Create List
    FOR    ${i}    IN RANGE    ${iteration}
        Log to console    \n--vDU reset ${i}--
        os.Create Directory    ${out}/Iteration${i}
        ${log_path}=    Set Variable    ${out}/Iteration${i}
        Cell block unblock
        Wait until keyword succeeds    10min    10sec    Check vDU Cell status
        Get_active_alarms_vDU
        Snapshot_vDU    ${log_path}
#        Extract syslogs from snapshot    ${log_path}
        ${block_time}=    Validate messages in syslogs and calculate time difference    ${out}/syslogs/
        ...    ${regexpattern}    ${block_request}     ${var_start_sys}    ${kpi17a_time}
        Append To List    ${block_timers}    ${block_time}
        ${unblock_time}=    Validate messages in syslogs and calculate time difference    ${out}/syslogs/
        ...    ${regexpattern}    ${unblock_request}     ${var_end_sys}    ${kpi17a_time}
        Append To List    ${unblock_timers}    ${unblock_time}
        Attach UE and start data transfer
    END
    ${max}=    Evaluate    max(${block_timers})
    Log to console    \n--Max time taken for cell block is ${max}--
    ${sum}=    Evaluate    sum(${block_timers})
    ${avg}=    Evaluate    ${sum} / ${iteration}
    Log to console    \n--Average time taken for cell block is ${avg}

    ${max}=    Evaluate    max(${unblock_timers})
    Log to console    \n--Max time taken for cell block is ${max}--
    ${sum}=    Evaluate    sum(${unblock_timers})
    ${avg}=    Evaluate    ${sum} / ${iteration}
    Log to console    \n--Average time taken for cell unblock is ${avg}

Snapshot_vDU
    [Arguments]    ${path}
    Log to console    \n--DU Snapshot collection started--
    create directory    ${path}
    admindu.get_local_snapshot    directory=${path}    compressed_or_not=True
    ...    request_timeout=30    operation_timeout=600     vdu_connection=${vdu_connection}
    Log to console    \n--DU Snapshot collection Ended--

Snapshot_vCU
    [Arguments]    ${path}
    Log to console    \n--CU Snapshot collection started--
    admincu.get_local_snapshot    directory=${path}
    ...    request_timeout=30    operation_timeout=600     connection=vCU
    Log to console    \n--CU Snapshot collection Ended--

Cell block unblock
    ${cell_ids}=    Set Variable    1
    admindu.block_cell    cell_id=${cell_ids}    vdu_connection=${vdu_connection}    timeout=60
    sleep    30s
    admindu.unblock_cell    cell_id=${cell_ids}    vdu_connection=${vdu_connection}    timeout=60

Get_active_alarms_vDU
    ${alarms_list}=    admindu.vdu_get_active_alarms    vdu_connection=${vdu_connection}    timeout=300    raw=True
    Log to console    ${alarms_list['alarms']}
    Should be empty    ${alarms_list['alarms']}

Extract syslogs from snapshot
    [Arguments]    ${log_path}
    os.Copy File    ${log_path}/Snapshot_*.zip    ${log_path}/Snapshot.zip
    os.Remove File    ${log_path}/Snapshot_*.zip
    ${snapshot_log_path}=    Set variable    ${log_path}/snapshot
    Extract
    ...  path=${log_path}/Snapshot.zip
    ...  output_dir=${snapshot_log_path}
    ...  .=rcplog_*.zip
    ...  **/rcplog_*.zip=*/*/logs.zip
    ...  **/logs.zip=syslog*.zip
    ...  **/syslog*.zip=*
    Copy syslogs    ${snapshot_log_path}

Copy syslogs
    [Arguments]    ${snapshot_log_path}
    ${items}=    os.List Directory    ${snapshot_log_path}
    FOR    ${item}    IN    @{items}
        ${file_path}=    Join Path    ${snapshot_log_path}    ${item}
        ${is_dir}=    Run Keyword And Return Status    os.Directory Should Exist    ${file_path}
        ${is_file}=   Run Keyword And Return Status    os.File Should Exist    ${file_path}

        Run Keyword If    ${is_dir}    Copy syslogs    ${file_path}
        Run Keyword If    ${is_file}    os.Copy File    ${file_path}    ${out}/syslogs/
    END

Validate messages in syslogs and calculate time difference
    [Arguments]    ${log_path}    ${regexpattern}    ${var_start_sys}     ${var_end_sys}    ${inputtime}
    [Documentation]    Unzip syslogs, then search for multiple patterns in the unzipped files.

    ${tmp}=    Convert To Number    ${inputtime}
    ${offlineindication}=       Run       grep \"${var_start_sys}\" ${log_path}/*
    log    ${offlineindication}
    ${offlineindicationregex}=  Get Regexp Matches  ${offlineindication}  ${regexpattern}
    ${onAirindication}=       Run       grep \"${var_end_sys}\" ${log_path}/*
    log    ${onAirindication}
    ${onAirindicationregex}=  Get Regexp Matches  ${onAirindication}    ${regexpattern}
    log    ${offlineindicationregex}
    log    ${onAirindicationregex}
    ${var_x}=    convert to string      ${offlineindicationregex}
    ${var_y}=    Remove String     ${var_x}    [    ]    '    <
    ${offlineindicationstatus}=   Replace String     ${var_y}    ${SPACE}        ${EMPTY}
    ${offlineindicationstatus}=   Replace String     ${var_y}    T    ${SPACE}
    log    ${offlineindicationstatus}
    @{offlineIndic_words}=    Split String    ${offlineindicationstatus}    ,
    ${Length1}=    Get length    ${offlineIndic_words}
    ${var_n}=    convert to string      ${onAirindicationregex}
    ${var_m}=    Remove String     ${var_n}    [    ]    '    <
    ${onAirindicationstatus}=   Replace String     ${var_m}    ${SPACE}        ${EMPTY}
    ${onAirindicationstatus}=   Replace String     ${var_m}    T    ${SPACE}
    log    ${onAirindicationstatus}
    @{onairIndic_words}=    Split String    ${onAirindicationstatus}    ,
    ${Length2}=    Get length    ${onairIndic_words}
    ${len}=      Evaluate    ${Length2} - 1
    ${time}=	Subtract Date From Date     ${onairIndic_words}[${len}]    ${offlineIndic_words}[-1]
    IF    ${time} < ${tmp}
        Log to console    The value ${time} is within the expected time
    END
    Run Keyword If    ${time} >= ${tmp}    Log to console    The value ${time} is more than expected time
    [Return]    ${time}
