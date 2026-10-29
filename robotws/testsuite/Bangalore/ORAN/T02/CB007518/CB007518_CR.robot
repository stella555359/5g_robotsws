*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
...   Description: Test Suite
...   "Test Case coverage in Documentation section for each case respectively"

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Suite Setup		    Suite_Setup
Test Setup	        Test Setup
Test Teardown       Test_Teardown
Suite Teardown		Suite Teardown

*** Variables ***

${host_vDU}    10.58.230.100
${host_vCU}    10.58.230.102
${PORT}        443
${USER}        Nemuadmin
${PWD}         Nokia@123
${BTS_path}=    /home/ute/logs
${vDU_NAMESPACE}        cran30026
${mrbtsid}              MRBTS-30026
${webem_addr}           10.43.196.131
${webem_username}       Nemuadmin
${webem_password}       Nokia@123
${rmod_id}=              RMOD-1

*** Test Cases ***

CB007518_PredefinedwithConnectedRadio
    [Documentation]    CB007518-B-CR Verification of vdu behaviour when non-predefined RU is changed to predefined in runtime configuration
    [Tags]    test1

    ${rmods_list}=    Create List    1    2     3     4     5     6     7
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/MNL-1    autoInstallOfPredefinedRu    false
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/EQM-1/APEQM-1/${rmod_id}    predefined    true
    Wait until Keyword succeeds    5m    20s    Fetch_cell_radio_alarm_status    0    off line    enabled
    admindu.reset_rmods    rmods_list=${rmods_list}    reset_reason=user    timeout=500    vdu_connection=vDU
    Wait until Keyword succeeds    5m    20s    Fetch_cell_radio_alarm_status    0    off line    enabled
    admindu.reset_vdu    timeout=600    vdu_connection=vDU
    Wait until Keyword succeeds    10m    20s    Fetch_cell_radio_alarm_status    0    off line    enabled
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/MNL-1    autoInstallOfPredefinedRu    true
    Wait until Keyword succeeds    10m    20s    Fetch_cell_radio_alarm_status    0    on line    enabled
    Wait until keyword succeeds    10m    10s    Check vDU Cell status

*** Keywords ***

Test Setup
    admindu.connect_to    host=${host_vDU}    port=${PORT}    connection_name=vDU
    ...    username=${USER}    password=${PWD}    secure=True    timeout=300
    admincu.connect_to    host=${host_vCU}    port=${PORT}    username=${USER}
    ...    password=${PWD}    secure=True    alias=vCU    timeout=300
    os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotVDU
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotVCU

Test Teardown
    Log to console  --End test--\n
    admindu.get_local_snapshot    directory=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotVDU/
    ...    request_timeout=30    operation_timeout=600     vdu_connection=vDU     compressed_or_not=true
    admincu.get_local_snapshot    directory=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SnapshotVCU/
    ...    request_timeout=30    operation_timeout=600     connection=vCU
    admindu.disconnect    vdu_connection=vDU
    admincu.disconnect    connection=vCU

Suite Setup
    log    "Test Started"
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}

Suite Teardown
	log    "Test END"

Perform_Parameter_Recommissioning_vDU
    [Arguments]    ${dist_name}      ${parameter}     ${value}
    admindu.perform_parameter_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    vdu_connection=vDU
    ...    operation=update
    ...    timeout=120
    ...    should_activate=true

Fetch_cell_radio_alarm_status
    [Arguments]      ${expectedalarms}    ${cellstate}     ${radiostate}

    ${cells}=    Create List   1    12    14    15
    FOR    ${cellid}    IN    @{cells}
        ${cellstatus}=    admindu.get_cell_specific_info     cell_id=${cellid}     timeout=30     vdu_connection=vDU
        run keyword and continue on failure    should contain any    ${cellstatus}[availabilityStatus]    ${cellstate}
    END
    ${rmodstatus}=    admindu.get_rmods_status    timeout=30    vdu_connection=vDU
    run keyword and continue on failure    should contain any    ${rmodstatus}[0][operational_state]    ${radiostate}
    ${alarmsinfo}=    admindu.vdu_get_active_alarms    timeout=30    vdu_connection=vDU
    ${alarms}=     Convert to String    ${alarmsinfo}[total]
    run keyword and continue on failure    should contain any    ${alarms}    ${expectedalarms}

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