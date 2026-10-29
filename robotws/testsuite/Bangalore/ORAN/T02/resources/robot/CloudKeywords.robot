*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
...   Description: OM operations related Keywords

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.nms.netact    WITH NAME    netact
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     taf.hw.pdu    WITH NAME    pdu

*** Variables ***

${BTS_ADDRESS}=    192.168.255.129
${value_true}=     true
${connection}=     default

*** Keywords ***

Test Setup
    Setup_VDU
    Setup_VCU
    os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotVDU
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotVCU
    Check vDU Cell status

Suite Setup
    log    "Test Started"
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}

Suite Teardown
	log    "Test END"

Test Teardown
    Log to console  --End test--\n
    Run Keyword and Ignore Error    Snapshot_vDU    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotVDU/
    Run Keyword and Ignore Error    Snapshot_vCU    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotVCU/
    admindu.disconnect    vdu_connection=vDU
    admincu.disconnect    connection=vCU

Setup_VDU
    admindu.connect_to    host=${host_vDU}    port=${PORT}    connection_name=vDU
    ...    username=${USER}    password=${PWD}    secure=True    timeout=300

Setup_VCU
    admincu.connect_to    host=${host_vCU}    port=${PORT}    username=${USER}
    ...    password=${PWD}    secure=True    alias=vCU    timeout=300

Snapshot_vDU
    [Arguments]     ${path}
    admindu.get_local_snapshot    directory=${path}
    ...    request_timeout=30    operation_timeout=600     vdu_connection=vDU     compressed_or_not=true

Snapshot_vCU
    [Arguments]     ${path}
    admincu.get_local_snapshot    directory=${path}
    ...    request_timeout=30    operation_timeout=600     connection=vCU

ORU Reset
    [Arguments]    ${rmods_list}
    admindu.reset_rmods    rmods_list=${rmods_list}    reset_reason=user    timeout=500    vdu_connection=vDU
    Wait until keyword succeeds    15min    10sec    Check vDU Cell status

RANNIC_reset
    [Arguments]     ${rannic_r_dn}
    admindu.reset_rannic      rannic_r_dn=${rannic_r_dn}     timeout=30     vdu_connection=vDU

ResetVdu
    admindu.reset_vdu    timeout=600    vdu_connection=vDU

ResetVcu
    admincu.reset_cu   connection=vCU

Reset_cells_from_vdu
    [Arguments]     ${cells}
    Setup_VDU
    admindu.reset_cells    dist_name=${cells}    timeout=30

Lock_Unlock_cells
   [Arguments]     ${cells}
   admincu.lock_cells     cell_ids=${cells}    connection=vCU
   Sleep    60s
   admincu.unlock_cells    cell_ids=${cells}    connection=vCU

Lock_Unlock_vDU
   [Arguments]     ${du_id}
   admincu.lock_du    du_id=${du_id}    connection=vCU
   Sleep    60s
   admincu.unlock_du    du_id=${du_id}    connection=vCU
   Sleep    60s

LockUnlock_Radios
    [Arguments]    ${rmods_list}
    admindu.lock_rmods    vdu_connection=vDU    rmod_id_list=${rmods_list}    timeout=60
    Sleep    60s
    admindu.unlock_rmods    vdu_connection=vDU    rmod_id_list=${rmods_list}    timeout=60

ActiveAlarms
    ${alrdata}=    admin.vdu_get_active_alarms    timeout=300
    ...    vdu_connection=vDU
    log    ${alrdata}

PodStatus
    ${pods}=    admin.get_pods_info    vdu_connection=vDU
    log    ${pods}

CellStatus
    ${result}=    admin.get_vdu_cells_status     timeout=300    vdu_connection=vDU
    ${Status}=    Set Variable    ${result['availability_status']}
    Run Keyword If    '${Status}'=='On line'
    log to console    Cell is On Air

AlarmHistory
    ${alarmhstry}=    admindu.vdu_get_active_alarms_summary    timeout=30
    ...    vdu_connection=vDU
    log     ${alarmhstry}
    ${history}=    admindu.vdu_get_historical_alarms    timeout=30
    ...    vdu_connection=vDU
    log     ${history}

Check vDU Cell status
    [Documentation]    Check the vDU cell status
    ${vDU_Cell_status}=    admindu.get_vdu_cells_status    vdu_connection=vDU    timeout=300
    log to console    ${vDU_Cell_status[0]['availability_status']}
    log    ${vDU_Cell_status[0]['availability_status']}
    Log    All cell statuses: ${vDU_Cell_status}
    # Verify if all cells are "on line"
    FOR    ${cell}    IN    @{vDU_Cell_status}
        Should Be Equal As Strings    ${cell['availability_status']}    on line
        Log    Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
	END
    # Check the overall state of vDU and return 'online' if all cells are "on line"
    ${offline_cells}=    Evaluate    [cell for cell in ${vDU_Cell_status} if cell['availability_status'] != 'on line']
    Run Keyword If    len(${offline_cells}) == 0    Log    All cells are online
    # Fail if there are offline cells
    #Log To Console    Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
    Log To Console    Cell procedural state is now: ${cell['availability_status']}
    #FAIL    Some cells are not online
    [Return]    ${vDU_Cell_status[0]['availability_status']}